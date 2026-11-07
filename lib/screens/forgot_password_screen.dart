import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/ui.dart';
import 'welcome_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _email =
      TextEditingController(text: widget.initialEmail);
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final t = L10nScope.of(context);
    final email = _email.text.trim();
    if (!email.contains('@') || email.length < 5) {
      setState(() => _error = t.get('errorInvalidEmail'));
      return;
    }
    final app = AppScope.read(context);
    if (!app.isCloud) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Text(t.get('resetLocalTitle')),
          content: Text(t.get('resetLocalBody')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(t.get('ok')),
            ),
          ],
        ),
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await app.sendReset(email);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Text(t.get('resetSent')),
          content: Text(t.format('resetSentBody', {'email': email})),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(t.get('ok')),
            ),
          ],
        ),
      );
      if (mounted) Navigator.of(context).pop();
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
            t.get('forgotTitle'),
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 12),
          Text(
            t.get('forgotSubtitle'),
            style: TextStyle(
              fontSize: 17,
              height: 1.4,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkMuted
                  : AppColors.muted,
            ),
          ),
          const SizedBox(height: 28),
          AppField(
            label: t.get('email'),
            hint: t.get('emailHint'),
            controller: _email,
            keyboardType: TextInputType.emailAddress,
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
          const Spacer(),
          PrimaryButton(
            label: t.get('sendResetLink'),
            busy: _busy,
            onPressed: _submit,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
