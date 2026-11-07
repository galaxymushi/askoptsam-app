import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n.dart';
import '../services/notification_store.dart';
import '../services/update_service.dart';
import '../theme.dart';
import '../widgets/ui.dart';
import 'chat_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _store = NotificationStore();
  List<AppNotice> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String? get _uid => AppScope.read(context).user?.uid;

  Future<void> _load() async {
    final uid = _uid;
    if (uid == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final items = await _store.load(uid)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _markAll() async {
    final uid = _uid;
    if (uid == null) return;
    await _store.markAllRead(uid);
    await _load();
  }

  Future<void> _clearAll() async {
    final t = L10nScope.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(t.get('clearNotificationsTitle')),
        content: Text(t.get('clearNotificationsBody')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.get('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              t.get('delete'),
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final uid = _uid;
    if (uid == null) return;
    await _store.clearAll(uid);
    await _load();
  }

  Future<void> _open(AppNotice notice) async {
    final uid = _uid;
    if (uid != null && !notice.read) {
      await _store.markRead(uid, notice.id);
      await _load();
    }
    final actionUrl = notice.actionUrl;
    if (actionUrl != null && actionUrl.trim().isNotEmpty) {
      await UpdateService.instance.openUrl(actionUrl);
      return;
    }
    final prompt = notice.prompt;
    if (prompt != null && prompt.trim().isNotEmpty && mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ChatScreen(initialPrompt: prompt)),
      );
    }
  }

  int get _unread => _items.where((n) => !n.read).length;

  @override
  Widget build(BuildContext context) {
    final t = L10nScope.of(context);
    final app = AppScope.of(context);
    final settings = app.settings;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 30),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(t.get('notificationsTitle')),
        actions: [
          if (_unread > 0)
            TextButton(
              onPressed: _markAll,
              child: Text(
                t.get('markAllRead'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 26),
                children: [
                  if (_items.isEmpty)
                    _EmptyFeed()
                  else
                    ..._items.map(
                      (n) => _NoticeTile(
                        notice: n,
                        language: t.language,
                        onTap: () => _open(n),
                      ),
                    ),
                  SectionLabel(t.get('notificationSettings')),
                  if (_items.isNotEmpty)
                    SettingsTile(
                      icon: Icons.delete_sweep_rounded,
                      iconColor: AppColors.danger,
                      title: t.get('clearNotifications'),
                      titleColor: AppColors.danger,
                      onTap: _clearAll,
                    ),
                  SettingsTile(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: t.get('replies'),
                    onTap: () =>
                        settings.setNotifyReplies(!settings.notifyReplies),
                    trailing: Switch(
                      value: settings.notifyReplies,
                      activeThumbColor: Colors.white,
                      activeTrackColor: AppColors.primary,
                      onChanged: settings.setNotifyReplies,
                    ),
                  ),
                  SettingsTile(
                    icon: Icons.lightbulb_outline_rounded,
                    title: t.get('dailyTip'),
                    onTap: () => settings.setNotifyTips(!settings.notifyTips),
                    trailing: Switch(
                      value: settings.notifyTips,
                      activeThumbColor: Colors.white,
                      activeTrackColor: AppColors.primary,
                      onChanged: settings.setNotifyTips,
                    ),
                  ),
                  SettingsTile(
                    icon: Icons.system_update_alt_rounded,
                    title: t.get('updates'),
                    onTap: () =>
                        settings.setNotifyUpdates(!settings.notifyUpdates),
                    trailing: Switch(
                      value: settings.notifyUpdates,
                      activeThumbColor: Colors.white,
                      activeTrackColor: AppColors.primary,
                      onChanged: settings.setNotifyUpdates,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _NoticeTile extends StatelessWidget {
  const _NoticeTile({
    required this.notice,
    required this.language,
    required this.onTap,
  });

  final AppNotice notice;
  final String language;
  final VoidCallback onTap;

  IconData get _icon => switch (notice.kind) {
        NoticeKind.reply => Icons.chat_bubble_outline_rounded,
        NoticeKind.tip => Icons.lightbulb_outline_rounded,
        NoticeKind.welcome => Icons.auto_awesome_outlined,
        NoticeKind.update => Icons.campaign_outlined,
      };

  String _timeLabel(BuildContext context) {
    final t = L10nScope.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(
      notice.createdAt.year,
      notice.createdAt.month,
      notice.createdAt.day,
    );
    final diff = today.difference(day).inDays;
    final hm = '${notice.createdAt.hour.toString().padLeft(2, '0')}:'
        '${notice.createdAt.minute.toString().padLeft(2, '0')}';
    if (diff == 0) return '${t.get('daysToday')} · $hm';
    if (diff == 1) return '${t.get('daysYesterday')} · $hm';
    return '${notice.createdAt.day}/${notice.createdAt.month}/'
        '${notice.createdAt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unread = !notice.read;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: unread
                    ? const Color(0xFF2E6BFF).withValues(alpha: 0.55)
                    : (isDark ? AppColors.darkBorder : AppColors.border),
                width: unread ? 1.4 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSoft
                        : const Color(0xFFE9F1FE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_icon, size: 21, color: const Color(0xFF2E6BFF)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notice.title,
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (unread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        notice.body,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.4,
                          color: isDark
                              ? AppColors.darkMuted
                              : AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (notice.actionUrl != null &&
                          notice.actionUrl!.trim().isNotEmpty) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.download_rounded,
                                size: 15,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  L10nScope.of(context)
                                      .get('tapToDownloadUpdate'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else if (notice.prompt != null &&
                          notice.prompt!.trim().isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.auto_awesome_rounded,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  L10nScope.of(context).get('tapToAskAi'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      Text(
                        _timeLabel(context),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark
                              ? AppColors.darkMuted
                              : AppColors.muted,
                        ),
                      ),
                    ],
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

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed();

  @override
  Widget build(BuildContext context) {
    final t = L10nScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          const Mascot(height: 110),
          const SizedBox(height: 16),
          Text(
            t.get('noNotifications'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            t.get('noNotificationsBody'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.5,
              height: 1.45,
              color: isDark ? AppColors.darkMuted : AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}
