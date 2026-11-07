import 'package:flutter/material.dart';

import '../content/eye_facts.dart';
import '../l10n.dart';
import '../theme.dart';
import '../widgets/fact_art.dart';
import '../widgets/ui.dart';
import 'chat_screen.dart';

class FactScreen extends StatelessWidget {
  const FactScreen({super.key, required this.fact});

  final EyeFact fact;

  @override
  Widget build(BuildContext context) {
    final t = L10nScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = t.language;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 30),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(t.get('eyeInfo')),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 6, 22, 28),
          children: [
            FactArtwork(fact: fact, height: 200, radius: 26),
            const SizedBox(height: 4),
            FactPhotoCredit(fact: fact),
            const SizedBox(height: 14),
            Text(
              fact.title(lang),
              style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              fact.body(lang),
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: isDark ? AppColors.darkText : AppColors.ink,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSoft : const Color(0xFFEFF5FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_outline_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.get('tipLabel'),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          fact.tip(lang),
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.45,
                            color: isDark ? AppColors.darkText : AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              t.get('factDisclaimer'),
              style: TextStyle(
                fontSize: 12.5,
                height: 1.5,
                color: isDark ? AppColors.darkMuted : AppColors.muted,
              ),
            ),
            const SizedBox(height: 22),
            PrimaryButton(
              label: t.get('askAboutThis'),
              onPressed: () {
                final prompt = lang == 'sw'
                    ? 'Nieleze zaidi kuhusu "${fact.title('sw')}". '
                          'Nifanye nini kivitendo leo?'
                    : 'Tell me more about "${fact.title('en')}". '
                          'What should I do about it today?';
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(initialPrompt: prompt),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
