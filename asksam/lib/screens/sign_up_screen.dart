import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/ui.dart';
import 'welcome_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _agreed = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final t = L10nScope.of(context);
    final name = _name.text.trim();
    final email = _email.text.trim();
    final password = _password.text;

    if (name.isEmpty) {
      setState(() => _error = t.get('typeName'));
      return;
    }
    if (!email.contains('@') || email.length < 5) {
      setState(() => _error = t.get('errorInvalidEmail'));
      return;
    }
    if (password.length < 8) {
      setState(() => _error = t.get('errorWeakPassword'));
      return;
    }
    if (!_agreed) {
      setState(() => _error = t.get('errorTerms'));
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await AppScope.read(context).signUp(name, email, password);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.get('createYourAccount'),
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 26),
          AppField(
            label: t.get('name'),
            hint: t.get('nameHint'),
            controller: _name,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 18),
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
            hint: t.get('passwordRule'),
            controller: _password,
            obscure: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => setState(() => _agreed = !_agreed),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _agreed
                          ? AppColors.primary
                          : (isDark ? AppColors.darkSurface : Colors.white),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _agreed
                            ? AppColors.primary
                            : (isDark ? AppColors.darkMuted : AppColors.hint),
                        width: 1.4,
                      ),
                    ),
                    child: _agreed
                        ? const Icon(Icons.check_rounded,
                            size: 17, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        t.get('agreeTerms'),
                        style: const TextStyle(fontSize: 15.5, height: 1.35),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(
                color: AppColors.danger,
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const Spacer(),
          PrimaryButton(
            label: t.get('createAccountCta'),
            busy: _busy,
            onPressed: _submit,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
