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
    final explanation = fact.explanation(lang);
    final symptoms = fact.symptoms(lang);
    final actions = fact.actions(lang);
    final whenToSee = fact.whenToSeeDoctor(lang);

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
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
          children: [
            FactArtwork(fact: fact, height: 210, radius: 26),
            const SizedBox(height: 4),
            FactPhotoCredit(fact: fact),
            const SizedBox(height: 16),
            Text(
              fact.title(lang),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 12),
            // Overview summary
            Text(
              fact.body(lang),
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: isDark ? AppColors.darkText : AppColors.ink,
              ),
            ),

            // Detailed clinical explanation if available
            if (explanation != null) ...[
              const SizedBox(height: 20),
              _InfoCard(
                icon: Icons.menu_book_rounded,
                iconColor: AppColors.primary,
                title: t.get('clinicalDetails'),
                child: Text(
                  explanation,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.55,
                    color: isDark ? AppColors.darkText : AppColors.ink,
                  ),
                ),
              ),
            ],

            // Symptoms list
            if (symptoms != null && symptoms.isNotEmpty) ...[
              const SizedBox(height: 16),
              _InfoCard(
                icon: Icons.visibility_outlined,
                iconColor: const Color(0xFFE65100),
                title: t.get('symptomsTitle'),
                child: Column(
                  children: symptoms.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6, right: 10),
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE65100),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: 14.5,
                                height: 1.45,
                                color:
                                    isDark ? AppColors.darkText : AppColors.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            // Actionable prevention & care
            if (actions != null && actions.isNotEmpty) ...[
              const SizedBox(height: 16),
              _InfoCard(
                icon: Icons.health_and_safety_outlined,
                iconColor: const Color(0xFF2E7D32),
                title: t.get('preventionTitle'),
                child: Column(
                  children: actions.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2, right: 8),
                            child: Icon(
                              Icons.check_circle_outline_rounded,
                              size: 16,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: 14.5,
                                height: 1.45,
                                color:
                                    isDark ? AppColors.darkText : AppColors.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            // Quick daily tip card
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSoft : const Color(0xFFEFF5FF),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkBorder
                      : AppColors.primary.withAlpha(40),
                ),
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
                            color: AppColors.primary,
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

            // Emergency / When to see a doctor alert
            if (whenToSee != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2C1E1E)
                      : const Color(0xFFFFF4F4),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFD32F2F).withAlpha(100),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.medical_services_outlined,
                      color: Color(0xFFD32F2F),
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.get('whenToSeeDoctorTitle'),
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: Color(0xFFD32F2F),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            whenToSee,
                            style: TextStyle(
                              fontSize: 14.5,
                              height: 1.45,
                              color:
                                  isDark ? AppColors.darkText : AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

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
              label: t.get('askDoctorAboutThis'),
              onPressed: () {
                final prompt = lang == 'sw'
                    ? 'Nieleze zaidi kuhusu "${fact.title('sw')}". '
                        'Kama mtaalamu wa macho, nishauri dalili zangu na nifanye nini leo?'
                    : 'Tell me more about "${fact.title('en')}". '
                        'As an optometrist, advise me on symptoms and what action to take today?';
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
