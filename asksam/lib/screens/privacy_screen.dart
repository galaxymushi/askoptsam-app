import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import '../content/legal_text.dart';
import '../l10n.dart';
import '../theme.dart';
import '../widgets/ui.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = L10nScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = t.language;
    final bodyColor = isDark ? AppColors.darkText : AppColors.ink;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.muted;

    Widget section(LegalSection item, int index) => Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSoft : const Color(0xFFE9F1FE),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title(lang),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.body(lang),
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.58,
                    color: bodyColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    Widget partHeader(String label) => Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 2),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: AppColors.primary,
        ),
      ),
    );

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
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
          children: [
            const Center(child: BrandLogo(size: 92)),
            const SizedBox(height: 16),
            Text(
              t.get('privacyTitle'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              t.format('lastUpdated', {'date': LegalText.updated(lang)}),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: mutedColor),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSoft : const Color(0xFFEFF5FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                LegalText.intro(lang),
                style: TextStyle(fontSize: 15, height: 1.55, color: bodyColor),
              ),
            ),
            partHeader(t.get('privacyPart')),
            for (var i = 0; i < LegalText.privacy.length; i++)
              section(LegalText.privacy[i], i),
            partHeader(t.get('termsPart')),
            for (var i = 0; i < LegalText.terms.length; i++)
              section(LegalText.terms[i], i),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          t.get('legalContactTitle'),
                          style: const TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.get('legalContactBody'),
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.5,
                      color: mutedColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: t.get('legalContactButton'),
                    height: 48,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HelpScreen()),
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.get('supportNotSet'))));
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
              if (AppConfig.supportEmail.isNotEmpty) ...[
                const SizedBox(height: 22),
                Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSoft
                            : const Color(0xFFE9F1FE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.mail_outline_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.get('helpEmailLabel'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkMuted
                                  : AppColors.muted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppConfig.supportEmail,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: t.get('copy'),
                      icon: Icon(
                        Icons.copy_rounded,
                        size: 19,
                        color: isDark ? AppColors.darkMuted : AppColors.muted,
                      ),
                      onPressed: () async {
                        await Clipboard.setData(
                          const ClipboardData(text: AppConfig.supportEmail),
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(t.get('helpCopiedToast')),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                ),
              ],
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
