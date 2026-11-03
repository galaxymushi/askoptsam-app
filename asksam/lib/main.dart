import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_state.dart';
import 'config.dart';
import 'l10n.dart';
import 'screens/app_shell.dart';
import 'screens/welcome_screen.dart';
import 'services/auth_service.dart';
import 'services/chat_store.dart';
import 'services/local_notifications.dart';
import 'services/settings_controller.dart';
import 'theme.dart';
import 'widgets/gaze.dart';
import 'widgets/ui.dart';
import 'widgets/update_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppConfig.firebaseConfigured) {
    try {
      await Firebase.initializeApp(options: AppConfig.firebaseOptions);
    } catch (error) {
      debugPrint('Firebase initialization failed: $error');
    }
  }
  AppConfig.logMode();

  // Sets up real status-bar notifications (channel + Android 13 permission)
  // before the first frame so nothing posted later is silently dropped.
  await LocalNotifications.instance.init();

  final prefs = await SharedPreferences.getInstance();
  final settings = SettingsController(prefs);
  final auth = await createAuthService();
  final state = AppState(
    settings: settings,
    auth: auth,
    store: createChatStore(cloud: auth.isCloud),
  );
  state.restoreSession();

  runApp(AskOptSamApp(state: state));

  // Ask for the Android 13+ notification permission only once the first
  // frame is up, so the system dialog never covers a blank window.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    LocalNotifications.instance.requestPermission();
  });
}

class AskOptSamApp extends StatelessWidget {
  const AskOptSamApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: AnimatedBuilder(
        animation: Listenable.merge([state, state.settings]),
        builder: (context, _) {
          return L10nScope(
            strings: Strings(state.settings.language),
            child: MaterialApp(
              title: 'AskOptSam',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: state.settings.themeMode,
              builder: (context, child) => GazeScope(
                child: UpdateGate(
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
              home: const RootGate(),
            ),
          );
        },
      ),
    );
  }
}

class RootGate extends StatelessWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    if (!app.ready) return const SplashScreen();
    return app.user == null ? const WelcomeScreen() : const AppShell();
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkPage : AppColors.splash,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandLogo(size: 160),
            const SizedBox(height: 14),
            const Mascot(height: 110),
            const SizedBox(height: 30),
            SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2.6,
                valueColor: AlwaysStoppedAnimation(
                  isDark ? const Color(0xFF2E6BFF) : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
