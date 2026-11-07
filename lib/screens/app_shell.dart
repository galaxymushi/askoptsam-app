import 'package:flutter/material.dart';

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

  void setTab(int index) {
    setState(() => _index = index);
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
          const EyeAssistantScreen(),
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
