import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../content/citations.dart';
import '../l10n.dart';
import '../models.dart';
import '../services/ai_service.dart';
import '../services/daily_intelligence_service.dart';
import '../services/notification_store.dart';
import '../services/update_service.dart';
import '../theme.dart';
import '../widgets/ui.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    this.session,
    this.embedded = false,
    this.initialPrompt,
  });

  final ChatSession? session;
  final bool embedded;
  final String? initialPrompt;

  @override
  State<ChatScreen> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  late ChatSession _session;
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _focus = FocusNode();

  bool _sending = false;
  bool _typing = false;
  bool _offline = false;
  String? _errorCard; // localized copy shown under a failed send
  String? _pendingText; // last user text that needs retrying
  DailyBriefing _dailyBriefing = DailyIntelligenceService.seedForDay(
    DateTime.now(),
  );
  AppRelease? _updateRelease;

  @override
  void initState() {
    super.initState();
    _session =
        widget.session ??
        ChatSession(
          id: _newId(),
          title: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          messages: [],
        );
    _initIntelligenceAndUpdates();
    final prompt = widget.initialPrompt;
    if (prompt != null && prompt.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _send(prompt);
      });
    }
  }

  Future<void> _initIntelligenceAndUpdates() async {
    final cachedDaily = await DailyIntelligenceService.instance.loadToday();
    final cachedUpdate = await UpdateService.instance.cachedUpdate();
    if (!mounted) return;
    setState(() {
      _dailyBriefing = cachedDaily;
      _updateRelease = cachedUpdate;
    });
    final app = AppScope.read(context);
    final uid = app.user?.uid;
    if (uid == null) return;
    final briefing = await DailyIntelligenceService.instance.syncDailyNotice(
      uid,
      language: app.settings.language,
      includeDailyTip: app.settings.notifyTips,
    );
    final release = await UpdateService.instance.syncUpdateNotice(
      uid,
      language: app.settings.language,
      notifyUpdates: app.settings.notifyUpdates,
    );
    if (!mounted) return;
    setState(() {
      _dailyBriefing = briefing;
      if (release != null) _updateRelease = release;
    });
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  String _newId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(99999)}';

  bool get _empty => _session.messages.isEmpty;

  void _scrollToEnd({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final position = _scroll.position;
      if (animate) {
        _scroll.animateTo(
          position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      } else {
        _scroll.jumpTo(position.maxScrollExtent);
      }
    });
  }

  Future<void> _save() async {
    final app = AppScope.read(context);
    final uid = app.user?.uid;
    if (uid == null) return;
    if (_session.title.isEmpty) {
      final userMessages = _session.messages.where((m) => m.isUser).toList();
      final firstUser = userMessages.isEmpty ? '' : userMessages.first.text;
      _session.title = firstUser.trim().replaceAll('\n', ' ');
      if (_session.title.length > 44) {
        _session.title = '${_session.title.substring(0, 44)}…';
      }
    }
    _session.updatedAt = DateTime.now();
    try {
      await app.store.save(uid, _session);
    } catch (error) {
      debugPrint('Could not save chat: $error');
    }
  }

  Future<void> _notifyReply(Strings t) async {
    if (!mounted) return;
    final app = AppScope.read(context);
    if (!app.settings.notifyReplies) return;
    final uid = app.user?.uid;
    if (uid == null || _session.messages.isEmpty) return;
    final last = _session.messages.last;
    if (last.isUser) return;
    final flat = last.text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (flat.isEmpty) return;
    await NotificationStore().addOnce(
      uid,
      id: 'reply-${_session.id}-${last.id}',
      kind: NoticeKind.reply,
      title: t.get('noticeReplyTitle'),
      body: flat.length > 110 ? '${flat.substring(0, 110)}…' : flat,
    );
  }

  Future<void> _send([String? preset]) async {
    final t = L10nScope.of(context);
    final text = (preset ?? _input.text).trim();
    if (text.isEmpty || _sending) return;
    if (!AiService.instance.configured) {
      return;
    }

    _input.clear();
    _focus.unfocus();
    setState(() {
      _offline = false;
      _errorCard = null;
      _pendingText = null;
      _typing = true;
      _sending = true;
      _session.messages.add(
        ChatMessage(
          id: _newId(),
          role: 'user',
          text: text,
          createdAt: DateTime.now(),
        ),
      );
    });
    _scrollToEnd();
    await _streamReply(t);
  }

  Future<void> _retry() async {
    final t = L10nScope.of(context);
    if (_pendingText == null) return;
    setState(() {
      _offline = false;
      _errorCard = null;
      _typing = true;
      _sending = true;
    });
    await _streamReply(t);
  }

  Future<void> _streamReply(Strings t) async {
    final history = List<ChatMessage>.from(_session.messages);
    ChatMessage? reply;
    final buffer = StringBuffer();

    try {
      await for (final chunk in AiService.instance.streamReply(
        history,
        lang: t.language,
      )) {
        buffer.write(chunk);
        if (!mounted) return;
        setState(() {
          // Source markers (`[S1]`, `[S2]`, …) are stripped while streaming so
          // they never reach the bubble, even mid-sentence.
          final visible = stripCitations(buffer.toString());
          if (reply == null) {
            reply = ChatMessage(
              id: _newId(),
              role: 'assistant',
              text: visible,
              createdAt: DateTime.now(),
            );
            _session.messages.add(reply!);
            _typing = false;
          } else {
            reply!.text = visible;
          }
        });
        _scrollToEnd();
      }
      if (!mounted) return;
      setState(() {
        _typing = false;
        _sending = false;
      });
      await _save();
      await _notifyReply(t);
    } on AiException catch (e) {
      if (!mounted) return;
      final lastUser = _session.messages.lastWhere(
        (m) => m.isUser,
        orElse: () => ChatMessage(
          id: '',
          role: 'user',
          text: '',
          createdAt: DateTime.now(),
        ),
      );
      setState(() {
        _typing = false;
        _sending = false;
        if (e.kind == 'offline') {
          _offline = true;
          _errorCard = t.get('couldntSend');
          _pendingText = lastUser.text;
        } else if (e.kind == 'auth') {
          _errorCard = t.get('errorChatAuth');
        } else if (e.kind == 'rate') {
          _errorCard = t.get('errorChatRate');
        } else {
          _errorCard = t.get('errorChatServer');
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _typing = false;
        _sending = false;
        _errorCard = t.get('errorGeneric');
      });
    }
  }

  Future<void> _copyMessage(ChatMessage message) async {
    final t = L10nScope.of(context);
    await Clipboard.setData(ClipboardData(text: message.text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.get('copied')),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _rate(ChatMessage message, String value) async {
    final t = L10nScope.of(context);
    setState(() {
      message.feedback = message.feedback == value ? null : value;
    });
    await _save();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.get('feedbackThanks')),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _resend(ChatMessage message) async {
    if (_sending) return;
    await _send(message.text);
  }

  void startNewChat() {
    setState(() {
      _session = ChatSession(
        id: _newId(),
        title: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        messages: [],
      );
      _offline = false;
      _errorCard = null;
      _pendingText = null;
      _sending = false;
      _typing = false;
    });
    _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    final t = L10nScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final configured = AiService.instance.configured;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkPage : Colors.white,
      body: SafeArea(
        bottom: !widget.embedded,
        child: Column(
          children: [
            ScreenHeader(
              title: 'AskOptSam',
              actions: [
                IconButton(
                  tooltip: t.get('newChat'),
                  onPressed: () {
                    if (widget.embedded) {
                      startNewChat();
                    } else {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const ChatScreen()),
                      );
                    }
                  },
                  icon: const Icon(Icons.add_comment_outlined, size: 23),
                ),
              ],
            ),
            if (_offline) _OfflineBanner(text: t.get('offline')),
            Expanded(
              child: _empty
                  ? ListView(
                      padding: const EdgeInsets.only(bottom: 12),
                      children: [
                        _ChatGreeting(
                          title: t.get('hiImSam'),
                          subtitle: configured
                              ? null
                              : t.get('chatNotConnected'),
                          hint: configured
                              ? null
                              : t.get('chatNotConnectedHint'),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                          child: _Composer(
                            controller: _input,
                            focusNode: _focus,
                            enabled: configured && !_sending,
                            hint: configured
                                ? t.get('askAnything')
                                : t.get('chatNotConnected'),
                            onSend: _sending ? null : () => _send(),
                          ),
                        ),
                        _SuggestionChips(
                          onPick: _send,
                          dailyQuestions:
                              _dailyBriefing.questions(t.language),
                        ),
                        const SizedBox(height: 12),
                      ],
                    )
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
                      itemCount:
                          _session.messages.length +
                          (_typing ? 1 : 0) +
                          (_errorCard != null ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < _session.messages.length) {
                          final message = _session.messages[index];
                          final streaming =
                              _sending &&
                              index == _session.messages.length - 1 &&
                              !message.isUser;
                          return _Bubble(
                            message: message,
                            interactive: !streaming,
                            onCopy: () => _copyMessage(message),
                            onResend: message.isUser && !_sending
                                ? () => _resend(message)
                                : null,
                            onFeedback: message.isUser
                                ? null
                                : (value) => _rate(message, value),
                          );
                        }
                        if (_typing && index == _session.messages.length) {
                          return const _TypingBubble();
                        }
                        return _ErrorCard(
                          message: _errorCard!,
                          onRetry: _pendingText != null ? _retry : null,
                          retryLabel: t.get('tryAgain'),
                        );
                      },
                    ),
            ),
            // Update prompt sits at the bottom (above the composer) so the
            // top of the chat stays clear for the mascot's eye animation.
            if (_updateRelease != null)
              _UpdateStrip(
                release: _updateRelease!,
                onTap: () =>
                    UpdateService.instance.openDownload(_updateRelease!),
              ),
            if (!_empty)
              _Composer(
                controller: _input,
                focusNode: _focus,
                enabled: configured && !_sending,
                hint: configured
                    ? t.get('askAnything')
                    : t.get('chatNotConnected'),
                onSend: _sending ? null : () => _send(),
              ),
          ],
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      color: isDark ? const Color(0xFF101F4E) : const Color(0xFFEFF5FF),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 22,
            color: isDark ? Colors.white : AppColors.navy,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15.5,
                height: 1.35,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : AppColors.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatGreeting extends StatelessWidget {
  const _ChatGreeting({required this.title, this.subtitle, this.hint});

  final String title;
  final String? subtitle;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bubbleColor = isDark
        ? const Color(0xFF12224F)
        : const Color(0xFFF0F5FF);
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 24, 26, 6),
      child: Column(
        children: [
          const Mascot(height: 150),
          const SizedBox(height: 16),
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkText : AppColors.navy,
                  ),
                ),
              ),
              Positioned(
                top: 3,
                child: Transform.rotate(
                  angle: 0.785398,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (hint != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      hint!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.4,
                        color: isDark ? AppColors.darkMuted : AppColors.muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _UpdateStrip extends StatefulWidget {
  const _UpdateStrip({required this.release, required this.onTap});

  final AppRelease release;
  final Future<bool> Function() onTap;

  @override
  State<_UpdateStrip> createState() => _UpdateStripState();
}

class _UpdateStripState extends State<_UpdateStrip> {
  bool _downloaded = false;

  @override
  void initState() {
    super.initState();
    _restoreDownloaded();
  }

  /// Once this release was fetched the strip stops offering the download; it
  /// re-arms itself as soon as a newer release appears.
  Future<void> _restoreDownloaded() async {
    try {
      final done = await UpdateService.instance
          .hasDownloaded(widget.release.version);
      if (mounted && done) setState(() => _downloaded = true);
    } catch (_) {
      // No prefs access: keep the strip tappable.
    }
  }

  Future<void> _tap() async {
    if (_downloaded) return;
    final opened = await widget.onTap();
    if (mounted && opened) setState(() => _downloaded = true);
  }

  @override
  Widget build(BuildContext context) {
    final release = widget.release;
    final t = L10nScope.of(context);
    return Material(
      color: AppColors.primary,
      child: InkWell(
        onTap: _downloaded ? null : _tap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
          child: Row(
            children: [
              Icon(
                _downloaded
                    ? Icons.check_circle_rounded
                    : Icons.system_update_alt_rounded,
                color: Colors.white,
                size: 19,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${t.format('noticeUpdateTitle', {'version': release.version})} · ${t.get(_downloaded ? 'updateDownloadedShort' : 'downloadUpdate')}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (!_downloaded)
                const Icon(
                  Icons.download_rounded,
                  color: Colors.white,
                  size: 19,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuggestionChips extends StatelessWidget {
  const _SuggestionChips({
    required this.onPick,
    this.dailyQuestions = const [],
  });

  final ValueChanged<String> onPick;
  final List<String> dailyQuestions;

  @override
  Widget build(BuildContext context) {
    final t = L10nScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // One daily briefing question when available, plus three common eye
    // questions that rotate by day so the suggestions stay on topic.
    final eyeQuestions = List.generate(
      8,
      (i) => t.get('sugEye${(DateTime.now().day + i) % 8 + 1}'),
    );
    final chips = [
      if (dailyQuestions.isNotEmpty) dailyQuestions.first,
      ...eyeQuestions.take(3),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 6, 22, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.get('tryAsking'),
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: isDark ? AppColors.darkMuted : AppColors.muted,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: chips
                .map(
                  (label) => InkWell(
                    onTap: () => onPick(label),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.hint,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final String hint;
  final VoidCallback? onSend;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 6, 7, 6),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isDark ? const Color(0xFF2E6BFF) : AppColors.primary,
            width: 1.6,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: enabled,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend?.call(),
                style: const TextStyle(fontSize: 16.5),
                decoration: InputDecoration(
                  hintText: hint,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: onSend == null
                  ? AppColors.primary.withValues(alpha: 0.45)
                  : AppColors.primary,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onSend,
                child: const SizedBox(
                  width: 46,
                  height: 46,
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.message,
    required this.onCopy,
    this.onResend,
    this.onFeedback,
    this.interactive = true,
  });

  final ChatMessage message;
  final VoidCallback onCopy;
  final VoidCallback? onResend;
  final ValueChanged<String>? onFeedback;
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    final t = L10nScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUser = message.isUser;

    final actions = <Widget>[];
    if (interactive) {
      if (isUser) {
        actions.add(
          _ActionIcon(
            icon: Icons.copy_rounded,
            tooltip: t.get('copy'),
            onTap: onCopy,
          ),
        );
        if (onResend != null) {
          actions.add(
            _ActionIcon(
              icon: Icons.refresh_rounded,
              tooltip: t.get('resend'),
              onTap: onResend!,
            ),
          );
        }
      } else {
        actions.add(
          _ActionIcon(
            icon: message.feedback == 'up'
                ? Icons.thumb_up_alt_rounded
                : Icons.thumb_up_off_alt_rounded,
            tooltip: t.get('feedbackUp'),
            active: message.feedback == 'up',
            onTap: () => onFeedback?.call('up'),
          ),
        );
        actions.add(
          _ActionIcon(
            icon: message.feedback == 'down'
                ? Icons.thumb_down_alt_rounded
                : Icons.thumb_down_off_alt_rounded,
            tooltip: t.get('feedbackDown'),
            active: message.feedback == 'down',
            onTap: () => onFeedback?.call('down'),
          ),
        );
        actions.add(
          _ActionIcon(
            icon: Icons.copy_rounded,
            tooltip: t.get('copy'),
            onTap: onCopy,
          ),
        );
      }
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary
                    : (isDark
                          ? const Color(0xFF12224F)
                          : const Color(0xFFF0F5FF)),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? 22 : 6),
                  topRight: Radius.circular(isUser ? 6 : 22),
                  bottomLeft: const Radius.circular(22),
                  bottomRight: const Radius.circular(22),
                ),
              ),
              child: isUser
                  ? Text(
                      message.text,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.42,
                        color: Colors.white,
                      ),
                    )
                  : _MarkdownText(
                      text: message.text,
                      color: isDark ? AppColors.darkText : AppColors.navy,
                    ),
            ),
            if (actions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(mainAxisSize: MainAxisSize.min, children: actions),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = active
        ? AppColors.primary
        : (isDark ? AppColors.darkMuted : AppColors.muted);
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 18,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}

/// Lightweight renderer for the assistant's markdown-ish replies: headings,
/// bullets, numbered steps and **bold**. Keeps long answers readable.
class _MarkdownText extends StatelessWidget {
  const _MarkdownText({required this.text, required this.color});

  final String text;
  final Color color;

  static final _heading = RegExp(r'^#{1,6}\s+(.*)$');
  static final _bullet = RegExp(r'^[-*•]\s+(.*)$');
  static final _numbered = RegExp(r'^(\d+)[.)]\s+(.*)$');
  static final _rule = RegExp(r'^-{3,}$');
  static final _bold = RegExp(r'\*\*(.+?)\*\*');

  List<InlineSpan> _inline(String source, TextStyle base) {
    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final match in _bold.allMatches(source)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: source.substring(cursor, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      );
      cursor = match.end;
    }
    if (cursor < source.length) {
      spans.add(TextSpan(text: source.substring(cursor)));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(fontSize: 16, height: 1.42, color: color);
    final blocks = <Widget>[];

    void add(Widget child) {
      blocks.add(
        Padding(
          padding: EdgeInsets.only(top: blocks.isEmpty ? 0 : 9),
          child: child,
        ),
      );
    }

    for (final raw in text.replaceAll('\r\n', '\n').split('\n')) {
      final line = raw.trim();
      if (line.isEmpty) continue;

      if (_rule.hasMatch(line)) {
        add(Divider(height: 1, color: color.withValues(alpha: 0.12)));
        continue;
      }

      final heading = _heading.firstMatch(line);
      if (heading != null) {
        add(
          Text.rich(
            TextSpan(
              children: _inline(heading.group(1)!, base),
              style: base.copyWith(fontSize: 17.5, fontWeight: FontWeight.w800),
            ),
          ),
        );
        continue;
      }

      final bullet = _bullet.firstMatch(line);
      if (bullet != null) {
        add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, right: 9),
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(children: _inline(bullet.group(1)!, base)),
                  style: base,
                ),
              ),
            ],
          ),
        );
        continue;
      }

      final numbered = _numbered.firstMatch(line);
      if (numbered != null) {
        add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 26,
                child: Text(
                  '${numbered.group(1)}.',
                  style: base.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(children: _inline(numbered.group(2)!, base)),
                  style: base,
                ),
              ),
            ],
          ),
        );
        continue;
      }

      add(Text.rich(TextSpan(children: _inline(line, base)), style: base));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: blocks,
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dotColor = isDark ? const Color(0xFF7D8DB4) : const Color(0xFF7D8DB4);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF12224F) : const Color(0xFFF0F5FF),
          borderRadius: BorderRadius.circular(18),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Mascot(height: 32, thinking: true),
              const SizedBox(width: 10),
              ...List.generate(3, (i) {
                final phase = ((_controller.value + i * 0.18) % 1.0);
                final opacity =
                    0.35 + 0.65 * (1 - (phase - 0.5).abs() * 2).clamp(0.0, 1.0);
                return Padding(
                  padding: EdgeInsets.only(right: i == 2 ? 0 : 7),
                  child: Opacity(
                    opacity: opacity,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
    this.onRetry,
    required this.retryLabel,
  });

  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF12224F) : const Color(0xFFF0F5FF),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: const TextStyle(fontSize: 16, height: 1.4)),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0A5FF2),
                  side: BorderSide(
                    color: isDark ? AppColors.darkBorder : Colors.white,
                  ),
                  backgroundColor: isDark
                      ? AppColors.darkSurface
                      : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                child: Text(
                  retryLabel,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
