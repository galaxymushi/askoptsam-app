import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import '../l10n.dart';
import '../theme.dart';
import '../widgets/ui.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = L10nScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 30),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(t.get('privacyTitle')),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(26, 12, 26, 24),
          children: [
            const Center(child: BrandLogo(size: 108)),
            const SizedBox(height: 22),
            Text(
              t.get('privacyBody'),
              style: TextStyle(
                fontSize: 16,
                height: 1.55,
                color: isDark ? AppColors.darkText : AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  Future<void> _send(BuildContext context) async {
    final t = L10nScope.of(context);
    final target = AppConfig.supportEmail.isNotEmpty
        ? Uri(
            scheme: 'mailto',
            path: AppConfig.supportEmail,
            query: 'subject=${Uri.encodeComponent(t.get('feedbackSubject'))}',
          )
        : (AppConfig.supportUrl.isNotEmpty
            ? Uri.parse(AppConfig.supportUrl)
            : null);
    if (target == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.get('supportNotSet'))),
      );
      return;
    }
    await launchUrl(target, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final t = L10nScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 30),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(t.get('helpTitle')),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 12, 26, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Mascot(height: 140),
              const SizedBox(height: 22),
              Text(
                t.get('helpBody'),
                style: TextStyle(
                  fontSize: 16.5,
                  height: 1.55,
                  color: isDark ? AppColors.darkText : AppColors.ink,
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: t.get('contactSupport'),
                onPressed: () => _send(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
