import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/ui.dart';
import 'chat_screen.dart';
import 'library_screen.dart';
import 'settings_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  final _libraryKey = GlobalKey<LibraryScreenState>();
  final _chatKey = GlobalKey<ChatScreenState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          ChatScreen(key: _chatKey, embedded: true),
          LibraryScreen(
            key: _libraryKey,
            onStartChat: () => setState(() => _index = 0),
          ),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        index: _index,
        onSelect: (index) {
          setState(() => _index = index);
          if (index == 1) _libraryKey.currentState?.reload();
        },
      ),
      backgroundColor: AppColors.page,
    );
  }
}
