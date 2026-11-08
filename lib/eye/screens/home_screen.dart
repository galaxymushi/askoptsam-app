import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../services/app_settings.dart';
import '../services/speech_service.dart';
import '../theme.dart';
import '../widgets/accessible_scaffold.dart';
import '../widgets/big_button.dart';
import '../widgets/brand_mark.dart';
import '../widgets/eye_ui.dart';
import '../widgets/semantic_control.dart';
import 'ask_screen.dart';
import 'describe_screen.dart';
import 'read_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.speakOnInit = false});

  final bool speakOnInit;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AppSettings _settings = AppSettings.instance;

  @override
  void initState() {
    super.initState();
    if (widget.speakOnInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SpeechService.instance.speak(_settings.strings.homeSpeak);
      });
    }
  }

  void _open(Widget screen) {
    SpeechService.instance.stop();
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _settings,
          builder: (context, _) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: BrandMark(
                        tagline: s.tagline,
                        onDark: _settings.themeMode != AppThemeMode.daylight,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _SettingsButton(
                      label: s.openSettings,
                      hint: s.settingsHint,
                      onTap: () => _open(const SettingsScreen()),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                BigButton(
                  icon: Icons.subject,
                  label: s.readTitle,
                  hint: s.readHint,
                  onPressed: () => _open(const ReadScreen()),
                ),
                const SizedBox(height: 12),
                BigButton(
                  icon: Icons.mic_none,
                  label: s.askTitle,
                  hint: s.askHint,
                  onPressed: () => _open(const AskScreen()),
                ),
                const SizedBox(height: 12),
                BigButton(
                  icon: Icons.volume_up,
                  label: s.describeTitle,
                  hint: s.describeHint,
                  onPressed: () => _open(const DescribeScreen()),
                ),
                const SizedBox(height: 16),
                BottomNote(
                  _settings.autoSpeak ? s.voiceOnNote : s.voiceOffNote,
                  icon:
                      _settings.autoSpeak ? Icons.volume_up : Icons.volume_off,
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const SpeechActivityBar(),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  const _SettingsButton({
    required this.label,
    required this.hint,
    required this.onTap,
  });

  final String label;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SemanticControl(
      label: label,
      hint: hint,
      onTap: onTap,
      child: Material(
        color: theme.colorScheme.surface,
        shape: CircleBorder(
          side: BorderSide(color: theme.colorScheme.primary, width: 3),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 60,
            height: 60,
            child: Icon(
              Icons.settings,
              size: 30,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
