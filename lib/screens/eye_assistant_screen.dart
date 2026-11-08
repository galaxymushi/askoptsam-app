import 'package:flutter/material.dart';

import '../eye/l10n/strings.dart';
import '../eye/screens/ask_screen.dart';
import '../eye/screens/describe_screen.dart';
import '../eye/screens/home_screen.dart';
import '../eye/screens/read_screen.dart';
import '../eye/services/app_settings.dart';
import '../eye/services/speech_service.dart';
import '../eye/theme.dart';

enum EyeCameraAction { soma, uliza, elezea }

class EyeAssistantScreen extends StatefulWidget {
  const EyeAssistantScreen({super.key, this.initialAction});

  final EyeCameraAction? initialAction;

  @override
  State<EyeAssistantScreen> createState() => EyeAssistantScreenState();
}

class EyeAssistantScreenState extends State<EyeAssistantScreen> {
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();
  final AppSettings _settings = AppSettings.instance;

  @override
  void initState() {
    super.initState();
    if (widget.initialAction != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        openCamera(widget.initialAction!);
      });
    }
  }

  void onTabActivated() {
    if (!SpeechService.instance.isEyeTabActive) return;
    SpeechService.instance.speak(_settings.strings.homeSpeak);
  }

  void onTabDeactivated() {
    stopSpeaking();
    _navKey.currentState?.popUntil((route) => route.isFirst);
  }

  void openCamera(EyeCameraAction action) {
    final nav = _navKey.currentState;
    if (nav == null) return;
    Widget target;
    switch (action) {
      case EyeCameraAction.soma:
        target = const ReadScreen();
        break;
      case EyeCameraAction.uliza:
        target = const AskScreen();
        break;
      case EyeCameraAction.elezea:
        target = const DescribeScreen();
        break;
    }
    nav.push(MaterialPageRoute<void>(builder: (_) => target));
  }

  void backToHome() {
    _navKey.currentState?.popUntil((route) => route.isFirst);
    stopSpeaking();
  }

  void stopSpeaking() {
    SpeechService.instance.stop();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settings,
      builder: (context, _) {
        final systemScale = MediaQuery.textScalerOf(context).scale(1.0);
        return Theme(
          data: AppTheme.build(_settings.themeMode),
          child: LocaleScope(
            strings: _settings.strings,
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(
                  (systemScale * _settings.textScale).clamp(1.0, 3.0),
                ),
              ),
              child: PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, _) async {
                  if (didPop) return;
                  final nav = _navKey.currentState;
                  if (nav != null && nav.canPop()) {
                    nav.pop();
                  }
                },
                child: Navigator(
                  key: _navKey,
                  onGenerateRoute: (_) => MaterialPageRoute<void>(
                    builder: (_) => const HomeScreen(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
