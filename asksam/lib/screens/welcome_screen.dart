import 'package:flutter/material.dart';

import '../l10n.dart';
import '../theme.dart';
import '../widgets/ui.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = L10nScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final panelColor = isDark ? const Color(0xFF0E1A3E) : AppColors.splash;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkPage : Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: panelColor,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(38),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: Column(
                    children: [
                      const SizedBox(height: 96),
                      const BrandLogo(size: 150),
                      const SizedBox(height: 2),
                      const Mascot(height: 112),
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topCenter,
                        children: [
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.fromLTRB(28, 14, 28, 0),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 20,
                            ),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF12224F) : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  t.get('welcomeHi'),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.darkText
                                        : AppColors.navy,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  t.get('welcomeTitle'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.4,
                                    color: isDark
                                        ? AppColors.darkText
                                        : AppColors.navy,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 6,
                            child: Transform.rotate(
                              angle: 0.785398,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF12224F)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const PillTag('Seeing Is Believing'),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 22, 26, 18),
              child: Column(
                children: [
                  PrimaryButton(
                    label: t.get('signIn'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignInScreen()),
                    ),
                  ),
                  const SizedBox(height: 14),
                  OutlinePillButton(
                    label: t.get('createAccount'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared scaffold for the auth screens: back chevron and a padded body.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 30),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        leadingWidth: 56,
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(26, 4, 26, 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 24),
              child: IntrinsicHeight(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

String authErrorKey(String code, Strings t) {
  switch (code) {
    case 'email-already-in-use':
    case 'email-in-use':
      return t.get('errorEmailInUse');
    case 'wrong-password':
    case 'invalid-credential':
    case 'invalid-login-credentials':
      return t.get('errorWrongPassword');
    case 'user-not-found':
      return t.get('errorUserNotFound');
    case 'weak-password':
      return t.get('errorWeakPassword');
    case 'invalid-email':
      return t.get('errorInvalidEmail');
    case 'network-request-failed':
      return t.get('errorNetwork');
    default:
      return t.get('errorGeneric');
  }
}
