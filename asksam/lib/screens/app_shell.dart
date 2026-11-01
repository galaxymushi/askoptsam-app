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
  int _index = 1;
  final _libraryKey = GlobalKey<LibraryScreenState>();
  final _chatKey = GlobalKey<ChatScreenState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          LibraryScreen(
            key: _libraryKey,
            onStartChat: () => setState(() => _index = 1),
          ),
          ChatScreen(key: _chatKey, embedded: true),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        index: _index,
        onSelect: (index) {
          setState(() => _index = index);
          if (index == 0) _libraryKey.currentState?.reload();
        },
      ),
      backgroundColor: AppColors.page,
    );
  }
}
