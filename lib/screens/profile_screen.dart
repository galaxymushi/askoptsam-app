import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/ui.dart';
import 'welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _name =
      TextEditingController(text: AppScope.read(context).user?.name ?? '');
  final TextEditingController _currentPassword = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();
  bool _busy = false;
  bool _pwBusy = false;
  String? _pwError;

  @override
  void dispose() {
    _name.dispose();
    _currentPassword.dispose();
    _newPassword.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = L10nScope.of(context);
    final app = AppScope.read(context);
    setState(() => _busy = true);
    try {
      await app.updateName(_name.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.get('savedToast'))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.get('errorGeneric'))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _updatePassword() async {
    final t = L10nScope.of(context);
    final isSw = t.language == 'sw';
    final currentPw = _currentPassword.text;
    final newPw = _newPassword.text;
    if (currentPw.isEmpty) {
      setState(() => _pwError = t.get('errorWrongPassword'));
      return;
    }
    if (newPw.length < 8) {
      setState(() => _pwError = t.get('errorWeakPassword'));
      return;
    }
    setState(() {
      _pwBusy = true;
      _pwError = null;
    });
    try {
      await AppScope.read(context).changePassword(currentPw, newPw);
      if (!mounted) return;
      _currentPassword.clear();
      _newPassword.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isSw ? 'Nenosiri limebadilishwa ✓' : 'Password updated ✓',
          ),
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _pwError = authErrorKey(e.code, t));
    } catch (_) {
      if (!mounted) return;
      setState(() => _pwError = t.get('errorGeneric'));
    } finally {
      if (mounted) setState(() => _pwBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = L10nScope.of(context);
    final isSw = t.language == 'sw';
    final app = AppScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 30),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(t.get('profileTitle')),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(26, 10, 26, 24),
          children: [
            const Center(child: BrandLogo(size: 110)),
            const SizedBox(height: 20),
            AppField(
              label: t.get('name'),
              hint: t.get('nameHint'),
              controller: _name,
            ),
            const SizedBox(height: 18),
            Text(
              t.get('email'),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 9),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : const Color(0xFFF7F9FE),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                  width: 1.4,
                ),
              ),
              child: Text(
                app.user?.email ?? '',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? AppColors.darkMuted : AppColors.muted,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  app.isCloud
                      ? Icons.cloud_done_outlined
                      : Icons.phone_android_rounded,
                  size: 17,
                  color: isDark ? AppColors.darkMuted : AppColors.muted,
                ),
                const SizedBox(width: 8),
                Text(
                  t.get(app.isCloud ? 'syncedCloud' : 'storedPhone'),
                  style: TextStyle(
                    fontSize: 13.5,
                    color: isDark ? AppColors.darkMuted : AppColors.muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: t.get('saveChanges'),
              busy: _busy,
              onPressed: _save,
            ),
            const SizedBox(height: 28),
            SectionLabel(isSw ? 'USALAMA NA NENOSIRI' : 'SECURITY & PASSWORD'),
            AppField(
              label: isSw ? 'Nenosiri la sasa' : 'Current password',
              hint: t.get('passwordHint'),
              controller: _currentPassword,
              obscure: true,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            AppField(
              label: isSw ? 'Nenosiri jipya' : 'New password',
              hint: t.get('passwordRule'),
              controller: _newPassword,
              obscure: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _updatePassword(),
            ),
            if (_pwError != null) ...[
              const SizedBox(height: 12),
              Text(
                _pwError!,
                style: const TextStyle(
                  color: AppColors.danger,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 18),
            OutlinePillButton(
              label: isSw ? 'Badilisha nenosiri' : 'Update password',
              icon: Icons.lock_reset_rounded,
              onPressed: _pwBusy ? null : _updatePassword,
            ),
          ],
        ),
      ),
    );
  }
}
