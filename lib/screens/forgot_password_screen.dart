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
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final t = L10nScope.of(context);
    final isSw = t.language == 'sw';
    final email = _email.text.trim();
    if (!email.contains('@') || email.length < 5) {
      setState(() => _error = t.get('errorInvalidEmail'));
      return;
    }
    final app = AppScope.read(context);
    if (!app.isCloud) {
      final newPass = _newPassword.text;
      final confirmPass = _confirmPassword.text;
      if (newPass.length < 8) {
        setState(() => _error = t.get('errorWeakPassword'));
        return;
      }
      if (newPass != confirmPass) {
        setState(
          () => _error = isSw
              ? 'Nenosiri jipya na uthibitisho havilingani.'
              : 'New passwords do not match.',
        );
        return;
      }
      setState(() {
        _busy = true;
        _error = null;
      });
      try {
        await app.resetLocalPassword(email, newPass);
        if (!mounted) return;
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            title: Text(
              isSw ? 'Nenosiri limebadilishwa' : 'Password updated',
            ),
            content: Text(
              isSw
                  ? 'Nenosiri la akaunti $email limewekwa upya. Sasa unaweza kuingia kwa nenosiri jipya.'
                  : 'Your password for $email has been reset. You can now sign in with your new password.',
            ),
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
    final isSw = t.language == 'sw';
    final app = AppScope.of(context);
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
            app.isCloud
                ? t.get('forgotSubtitle')
                : (isSw
                    ? 'Weka barua pepe ya akaunti yako na uchague nenosiri jipya.'
                    : 'Enter your account email and choose a new password.'),
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
            textInputAction:
                app.isCloud ? TextInputAction.done : TextInputAction.next,
            onSubmitted: app.isCloud ? (_) => _submit() : null,
          ),
          if (!app.isCloud) ...[
            const SizedBox(height: 18),
            AppField(
              label: isSw ? 'Nenosiri jipya' : 'New password',
              hint: t.get('passwordRule'),
              controller: _newPassword,
              obscure: true,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 18),
            AppField(
              label: isSw ? 'Thibitisha nenosiri jipya' : 'Confirm new password',
              hint: t.get('passwordRule'),
              controller: _confirmPassword,
              obscure: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),
          ],
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
            label: app.isCloud
                ? t.get('sendResetLink')
                : (isSw ? 'Badilisha nenosiri' : 'Reset password'),
            busy: _busy,
            onPressed: _submit,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
