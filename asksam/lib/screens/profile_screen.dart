import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n.dart';
import '../theme.dart';
import '../widgets/ui.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _name =
      TextEditingController(text: AppScope.read(context).user?.name ?? '');
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
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

  @override
  Widget build(BuildContext context) {
    final t = L10nScope.of(context);
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
            const SizedBox(height: 30),
            PrimaryButton(
              label: t.get('saveChanges'),
              busy: _busy,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
