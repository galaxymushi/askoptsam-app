import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/ui.dart';
import 'forgot_password_screen.dart';
import 'privacy_screen.dart';
import 'sign_up_screen.dart';
import 'welcome_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final t = L10nScope.of(context);
    final email = _email.text.trim();
    final password = _password.text;
    if (!email.contains('@') || email.length < 5) {
      setState(() => _error = t.get('errorInvalidEmail'));
      return;
    }
    if (password.isEmpty) {
      setState(() => _error = t.get('errorWrongPassword'));
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await AppScope.read(context).signIn(email, password);
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _error = authErrorKey(e.code, t));
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = t.get('errorGeneric'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = L10nScope.of(context);
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.get('welcomeBack'),
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 10),
          Text(
            t.get('signInSubtitle'),
            style: TextStyle(
              fontSize: 17,
              height: 1.4,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkMuted
                  : AppColors.muted,
            ),
          ),
          const SizedBox(height: 30),
          AppField(
            label: t.get('email'),
            hint: t.get('emailHint'),
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 18),
          AppField(
            label: t.get('password'),
            hint: t.get('passwordHint'),
            controller: _password,
            obscure: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            Text(
              _error!,
              style: const TextStyle(
                color: AppColors.danger,
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                foregroundColor: const Color(0xFF0A5FF2),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ForgotPasswordScreen(initialEmail: _email.text),
                ),
              ),
              child: Text(
                t.get('forgotPassword'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const Spacer(),
          PrimaryButton(
            label: t.get('signIn'),
            busy: _busy,
            onPressed: _submit,
          ),
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              Text(
                t.get('newHere'),
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkMuted
                      : AppColors.muted,
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
                ),
                child: Text(
                  t.get('createAccount'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0A5FF2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PrivacyScreen()),
              ),
              child: Text(
                t.language == 'sw'
                    ? 'Sera ya Faragha na Masharti ya Matumizi'
                    : 'Privacy Policy & Terms of Service',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkMuted
                      : AppColors.muted,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
