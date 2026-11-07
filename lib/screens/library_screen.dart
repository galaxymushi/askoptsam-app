import 'package:flutter/material.dart';

import '../app_state.dart';
import '../content/eye_facts.dart';
import '../l10n.dart';
import '../models.dart';
import '../services/daily_intelligence_service.dart';
import '../services/notification_store.dart';
import '../services/update_service.dart';
import '../theme.dart';
import '../widgets/fact_art.dart';
import '../widgets/ui.dart';
import 'chat_screen.dart';
import 'fact_screen.dart';
import 'notifications_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key, this.onStartChat});

  final VoidCallback? onStartChat;

  @override
  State<LibraryScreen> createState() => LibraryScreenState();
}

class LibraryScreenState extends State<LibraryScreen> {
  final _search = TextEditingController();
  final _notices = NotificationStore();
  List<ChatSession> _sessions = [];
  bool _loading = true;
  int _unread = 0;
  DailyBriefing _dailyBriefing = DailyIntelligenceService.seedForDay(
    DateTime.now(),
  );
  bool _generatingDaily = false;
  AppRelease? _updateRelease;

  @override
  void initState() {
    super.initState();
    reload();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> reload() async {
    final app = AppScope.read(context);
    final uid = app.user?.uid;
    if (uid == null) return;
    if (mounted) setState(() => _loading = true);
    try {
      final sessions = await app.store.load(uid);
      final cachedDaily = await DailyIntelligenceService.instance.loadToday();
      final cachedUpdate = await UpdateService.instance.cachedUpdate();
      if (!mounted) return;
      setState(() {
        _sessions = sessions;
        _dailyBriefing = cachedDaily;
        _updateRelease = cachedUpdate;
        _loading = false;
      });
      await _syncNotices(
        uid,
        app.settings.language,
        app.settings.notifyTips,
        app.settings.notifyUpdates,
      );
    } catch (error) {
      debugPrint('Could not load chats: $error');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _syncNotices(
    String uid,
    String language,
    bool includeDailyTip,
    bool includeUpdates,
  ) async {
    final s = Strings(language);
    await _notices.addOnce(
      uid,
      id: 'welcome',
      kind: NoticeKind.welcome,
      title: s.get('noticeWelcomeTitle'),
      body: s.get('noticeWelcomeBody'),
    );
    if (includeDailyTip) {
      final fact = EyeFacts.forDay(DateTime.now());
      final now = DateTime.now();
      await _notices.addOnce(
        uid,
        id: 'tip-${now.year}-${now.month}-${now.day}',
        kind: NoticeKind.tip,
        title: s.get('noticeTipTitle'),
        body: fact.title(language),
      );
    }
    final unread = await _notices.unread(uid);
    if (mounted) setState(() => _unread = unread);

    // Run autonomous daily AI synthesis and GitHub release check asynchronously
    // so the screen renders immediately and updates live when complete.
    _runAutonomousChecks(uid, language, includeDailyTip, includeUpdates);
  }

  Future<void> _runAutonomousChecks(
    String uid,
    String language,
    bool includeDailyTip,
    bool includeUpdates,
  ) async {
    try {
      final briefing = await DailyIntelligenceService.instance.syncDailyNotice(
        uid,
        language: language,
        includeDailyTip: includeDailyTip,
      );
      final release = await UpdateService.instance.syncUpdateNotice(
        uid,
        language: language,
        notifyUpdates: includeUpdates,
      );
      final unread = await _notices.unread(uid);
      if (!mounted) return;
      setState(() {
        _dailyBriefing = briefing;
        if (release != null) _updateRelease = release;
        _unread = unread;
      });
    } catch (_) {}
  }

  Future<void> _generateFreshDaily() async {
    if (_generatingDaily) return;
    setState(() => _generatingDaily = true);
    try {
      final fresh = await DailyIntelligenceService.instance.refreshWithAi(
        forceNew: true,
      );
      if (!mounted) return;
      setState(() {
        _dailyBriefing = fresh;
        _generatingDaily = false;
      });
    } catch (_) {
      if (mounted) setState(() => _generatingDaily = false);
    }
  }

  List<ChatSession> get _visible {
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return _sessions;
    return _sessions
        .where((s) => s.title.toLowerCase().contains(query))
        .toList();
  }

  Future<void> _open(ChatSession session) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatScreen(session: session)),
    );
    await reload();
  }

  Future<void> _openFact(EyeFact fact) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => FactScreen(fact: fact)),
    );
  }

  Future<void> _openNotifications() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
    if (!mounted) return;
    final uid = AppScope.read(context).user?.uid;
    if (uid == null) return;
    final unread = await _notices.unread(uid);
    if (mounted) setState(() => _unread = unread);
  }

  Future<void> _openActions(ChatSession session) async {
    final t = L10nScope.of(context);
    final app = AppScope.read(context);
    final uid = app.user?.uid;
    if (uid == null) return;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline_rounded),
              title: Text(t.get('rename')),
              onTap: () async {
                Navigator.of(context).pop();
                await _rename(session);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.danger),
              title: Text(
                t.get('delete'),
                style: const TextStyle(color: AppColors.danger),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                await app.store.delete(uid, session.id);
                await reload();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _rename(ChatSession session) async {
    final t = L10nScope.of(context);
    final app = AppScope.read(context);
    final uid = app.user?.uid;
    if (uid == null) return;
    final controller = TextEditingController(text: session.title);
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(t.get('renameChat')),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.get('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(t.get('rename')),
          ),
        ],
      ),
    );
    if (title != null && title.isNotEmpty) {
      await app.store.rename(uid, session.id, title);
      await reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = L10nScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visible = _visible;
    final today = EyeFacts.forDay(DateTime.now());
    final more = EyeFacts.afterToday(DateTime.now());

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkPage : Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      t.get('library'),
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                  _BellButton(unread: _unread, onTap: _openNotifications),
                ],
              ),
            ),
            if (_sessions.isNotEmpty || _search.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                      width: 1.4,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        size: 24,
                        color: isDark ? AppColors.darkMuted : AppColors.muted,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _search,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(fontSize: 16.5),
                          decoration: InputDecoration(
                            hintText: t.get('searchChats'),
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 17),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: reload,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(22, 6, 22, 24),
                        children: [
                          if (_updateRelease != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _UpdateBanner(
                                release: _updateRelease!,
                                onDownload: () => UpdateService.instance
                                    .openDownload(_updateRelease!),
                              ),
                            ),
                          _FactHero(
                            fact: today,
                            lang: t.language,
                            onTap: () => _openFact(today),
                          ),
                          SectionLabel(t.get('eyeInfo')),
                          SizedBox(
                            height: 196,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.zero,
                              itemCount: more.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) => _FactCard(
                                fact: more[index],
                                lang: t.language,
                                onTap: () => _openFact(more[index]),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _DailyIntelligenceCard(
                            briefing: _dailyBriefing,
                            lang: t.language,
                            generating: _generatingDaily,
                            onRefresh: _generateFreshDaily,
                            onExplore: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                    initialPrompt:
                                        _dailyBriefing.chatPrompt(t.language),
                                  ),
                                ),
                              );
                            },
                            onPickQuestion: (q) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(initialPrompt: q),
                                ),
                              );
                            },
                          ),
                          SectionLabel(t.get('savedChats')),
                          if (_sessions.isEmpty)
                            _EmptyChats(
                              onCreate: widget.onStartChat ??
                                  () => Navigator.of(context)
                                      .push(
                                        MaterialPageRoute(
                                          builder: (_) => const ChatScreen(),
                                        ),
                                      )
                                      .then((_) => reload()),
                            )
                          else if (visible.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 26),
                              child: Text(
                                t.get('noResults'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15.5,
                                  color: isDark
                                      ? AppColors.darkMuted
                                      : AppColors.muted,
                                ),
                              ),
                            )
                          else
                            ...visible.map(
                              (session) => _ChatTile(
                                session: session,
                                onTap: () => _open(session),
                                onLongPress: () => _openActions(session),
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BellButton extends StatelessWidget {
  const _BellButton({required this.unread, required this.onTap});

  final int unread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      onPressed: onTap,
      tooltip: L10nScope.of(context).get('notifications'),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 28,
            color: isDark ? AppColors.darkText : AppColors.navy,
          ),
          if (unread > 0)
            Positioned(
              right: -3,
              top: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1),
                constraints: const BoxConstraints(minWidth: 17),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isDark ? AppColors.darkPage : Colors.white,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  unread > 9 ? '9+' : '$unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FactHero extends StatelessWidget {
  const _FactHero({
    required this.fact,
    required this.lang,
    required this.onTap,
  });

  final EyeFact fact;
  final String lang;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = L10nScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? AppColors.darkSurface : Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  FactArtwork(
                    fact: fact,
                    height: 150,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    top: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        t.get('factOfDay'),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.9,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fact.title(lang),
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      fact.body(lang),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.45,
                        color: isDark ? AppColors.darkMuted : AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          t.get('readMore'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 17,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FactCard extends StatelessWidget {
  const _FactCard({
    required this.fact,
    required this.lang,
    required this.onTap,
  });

  final EyeFact fact;
  final String lang;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: 172,
      child: Material(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.border,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FactArtwork(
                  fact: fact,
                  height: 96,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Text(
                    fact.title(lang),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  const _ChatTile({
    required this.session,
    required this.onTap,
    required this.onLongPress,
  });

  final ChatSession session;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSoft : const Color(0xFFE9F1FE),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 22,
                    color: Color(0xFF2E6BFF),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    session.title.isEmpty ? 'AskOptSam' : session.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? AppColors.darkMuted : AppColors.muted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyChats extends StatelessWidget {
  const _EmptyChats({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final t = L10nScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          const Mascot(height: 96),
          const SizedBox(height: 14),
          Text(
            t.get('nothingSaved'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            t.get('savedHere'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: isDark ? AppColors.darkMuted : AppColors.muted,
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: t.get('startChat'),
            height: 50,
            onPressed: onCreate,
          ),
        ],
      ),
    );
  }
}

class _UpdateBanner extends StatefulWidget {
  const _UpdateBanner({required this.release, required this.onDownload});

  final AppRelease release;
  final Future<bool> Function() onDownload;

  @override
  State<_UpdateBanner> createState() => _UpdateBannerState();
}

class _UpdateBannerState extends State<_UpdateBanner> {
  bool _downloaded = false;

  @override
  void initState() {
    super.initState();
    _restoreDownloaded();
  }

  /// Hides the download button once this release was already fetched, and it
  /// comes back automatically when a newer release appears.
  Future<void> _restoreDownloaded() async {
    try {
      final done = await UpdateService.instance
          .hasDownloaded(widget.release.version);
      if (mounted && done) setState(() => _downloaded = true);
    } catch (_) {
      // No prefs access: keep the button visible.
    }
  }

  Future<void> _download() async {
    final opened = await widget.onDownload();
    if (mounted && opened) setState(() => _downloaded = true);
  }

  @override
  Widget build(BuildContext context) {
    final release = widget.release;
    final t = L10nScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF142C63), Color(0xFF0A438A)]
              : const [Color(0xFF0A5FF2), Color(0xFF1B86F8)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  t.format('updateAvailableBadge', {
                    'version': release.version,
                  }),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.system_update_alt_rounded,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            t.format('updateAvailableTitle', {'version': release.version}),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18.5,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          if (release.notes.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              release.notes,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13.5,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (_downloaded)
            Container(
              width: double.infinity,
              height: 44,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      t.get('updateDownloadedShort'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: _download,
                icon: const Icon(Icons.download_rounded, size: 19),
                label: Text(
                  t.get('downloadUpdate'),
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DailyIntelligenceCard extends StatelessWidget {
  const _DailyIntelligenceCard({
    required this.briefing,
    required this.lang,
    required this.generating,
    required this.onRefresh,
    required this.onExplore,
    required this.onPickQuestion,
  });

  final DailyBriefing briefing;
  final String lang;
  final bool generating;
  final VoidCallback onRefresh;
  final VoidCallback onExplore;
  final ValueChanged<String> onPickQuestion;

  @override
  Widget build(BuildContext context) {
    final t = L10nScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final questions = briefing.questions(lang);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFF6F9FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2E6BFF).withValues(alpha: 0.45)
              : const Color(0xFFCCE0FF),
          width: 1.3,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      size: 13.5,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      t.get('dailyAiBadge'),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: generating ? null : onRefresh,
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        size: 15,
                        color: isDark ? AppColors.darkMuted : AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        generating
                            ? t.get('generatingAi')
                            : t.get('generateFreshAi'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark ? AppColors.darkMuted : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            briefing.title(lang),
            style: const TextStyle(
              fontSize: 19.5,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              height: 1.22,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            briefing.body(lang),
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: isDark ? AppColors.darkText : AppColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSoft : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.border,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.bolt_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.get('dailyActionLabel'),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        briefing.action(lang),
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.38,
                          color: isDark ? AppColors.darkText : AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (questions.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: questions
                  .take(2)
                  .map(
                    (q) => InkWell(
                      onTap: () => onPickQuestion(q),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSoft : Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.border,
                          ),
                        ),
                        child: Text(
                          q,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 12),
          InkWell(
            onTap: onExplore,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(
                    t.get('exploreWithAi'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 17,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
