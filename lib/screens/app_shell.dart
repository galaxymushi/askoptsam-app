import 'package:flutter/material.dart';

import '../eye/services/speech_service.dart';
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

class AppShellState extends State<AppShell> {
  int _index = 0;
  final _libraryKey = GlobalKey<LibraryScreenState>();
  final _chatKey = GlobalKey<ChatScreenState>();
  final _eyeKey = GlobalKey<EyeAssistantScreenState>();

  void setTab(int index) {
    final previous = _index;
    setState(() => _index = index);
    if (previous == 1 && index != 1) {
      SpeechService.instance.stop();
    }
    if (index == 1 && previous != 1) {
      _eyeKey.currentState?.onTabActivated();
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
      bottomNavigationBar: AppBottomNav(
        index: _index,
        onSelect: setTab,
      ),
      backgroundColor: AppColors.page,
    );
  }
}
