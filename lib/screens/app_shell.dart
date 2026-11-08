import 'package:flutter/material.dart';

import '../eye/services/speech_service.dart';
import '../l10n.dart';
import '../services/update_service.dart';
import '../theme.dart';
import '../widgets/ui.dart';
import 'chat_screen.dart';
import 'eye_assistant_screen.dart';
import 'library_screen.dart';
import 'settings_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => AppShellState();
}

class AppShellState extends State<AppShell> with WidgetsBindingObserver {
  int _index = 0;
  final _libraryKey = GlobalKey<LibraryScreenState>();
  final _chatKey = GlobalKey<ChatScreenState>();
  final _eyeKey = GlobalKey<EyeAssistantScreenState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Eye speech stays strictly silent until the user specifically switches to the Eye tab
    SpeechService.instance.isEyeTabActive = false;
    SpeechService.instance.stop();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateService.instance.checkForUpdate();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SpeechService.instance.isEyeTabActive = false;
    SpeechService.instance.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      SpeechService.instance.stop();
    }
  }

  void setTab(int index) {
    final previous = _index;
    setState(() => _index = index);

    if (index == 1) {
      // User entered Eye tab
      SpeechService.instance.isEyeTabActive = true;
      if (previous != 1) {
        _eyeKey.currentState?.onTabActivated();
      }
    } else {
      // User is on another tab (Chat, Library, Settings)
      SpeechService.instance.isEyeTabActive = false;
      if (previous == 1) {
        _eyeKey.currentState?.onTabDeactivated();
        SpeechService.instance.stop();
      }
    }

    if (index == 2) _libraryKey.currentState?.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          ChatScreen(
            key: _chatKey,
            embedded: true,
            onOpenEye: () => setTab(1),
          ),
          EyeAssistantScreen(key: _eyeKey),
          LibraryScreen(
            key: _libraryKey,
            onStartChat: () => setTab(0),
          ),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder<AppRelease?>(
            valueListenable: UpdateService.instance.updateNotifier,
            builder: (context, release, _) {
              if (release == null) return const SizedBox.shrink();
              return _PersistentUpdateBottomBar(
                release: release,
                onDownload: () =>
                    UpdateService.instance.openDownload(release),
                onDismiss: () => UpdateService.instance.dismissUpdate(),
              );
            },
          ),
          AppBottomNav(
            index: _index,
            onSelect: setTab,
          ),
        ],
      ),
      backgroundColor: AppColors.page,
    );
  }
}

class _PersistentUpdateBottomBar extends StatelessWidget {
  const _PersistentUpdateBottomBar({
    required this.release,
    required this.onDownload,
    required this.onDismiss,
  });

  final AppRelease release;
  final VoidCallback onDownload;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final t = L10nScope.of(context);
    final isSw = t.language == 'sw';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF0F172A), Color(0xFF1E3A8A)]
              : const [Color(0xFF0038A8), Color(0xFF0A5FF2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
        border: const Border(
          top: BorderSide(color: Color(0x33FFFFFF), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(45),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.system_update_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isSw
                            ? 'Toleo Jipya ${release.version}'
                            : 'New Version ${release.version}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C853),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          isSw ? 'MPYA' : 'NEW',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1.5),
                  Text(
                    isSw
                        ? 'Bofya kupakua sasisho hili sasa'
                        : 'Tap to download this update now',
                    style: TextStyle(
                      color: Colors.white.withAlpha(210),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            ElevatedButton.icon(
              onPressed: onDownload,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C853),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.download_rounded, size: 15),
              label: Text(
                isSw ? 'PAKUA' : 'DOWNLOAD',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 2),
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                size: 18,
                color: Colors.white.withAlpha(180),
              ),
              onPressed: onDismiss,
              visualDensity: VisualDensity.compact,
              tooltip: isSw ? 'Funga' : 'Dismiss',
            ),
          ],
        ),
      ),
    );
  }
}
