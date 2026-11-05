import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n.dart';
import '../theme.dart';
import '../widgets/ui.dart';
import 'about_screen.dart';
import 'language_screen.dart';
import 'notifications_screen.dart';
import 'privacy_screen.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = L10nScope.of(context);
    final app = AppScope.of(context);
    final settings = app.settings;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    void open(Widget screen) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkPage : Colors.white,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
          children: [
            Text(
              t.get('settings'),
              style: Theme.of(context).textTheme.displayLarge,
            ),
            SectionLabel(t.get('account')),
            SettingsTile(
              icon: Icons.person_outline_rounded,
              title: t.get('profile'),
              subtitle: app.user?.email,
              onTap: () => open(const ProfileScreen()),
            ),
            SettingsTile(
              icon: Icons.notifications_none_rounded,
              title: t.get('notifications'),
              onTap: () => open(const NotificationsScreen()),
            ),
            SettingsTile(
              icon: Icons.delete_sweep_rounded,
              iconColor: AppColors.danger,
              title: t.get('clearHistory'),
              titleColor: AppColors.danger,
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    title: Text(t.get('clearHistoryTitle')),
                    content: Text(t.get('clearHistoryBody')),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(t.get('cancel')),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(
                          t.get('delete'),
                          style: const TextStyle(color: AppColors.danger),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirmed != true || !context.mounted) return;
                final app = AppScope.read(context);
                final uid = app.user?.uid;
                if (uid != null) {
                  await app.store.deleteAll(uid);
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(t.get('historyClearedToast'))),
                  );
                }
              },
            ),
            SectionLabel(t.get('preferences')),
            SettingsTile(
              icon: Icons.nightlight_round,
              title: t.get('darkMode'),
              onTap: () => settings.setDark(!settings.isDark),
              trailing: Switch(
                value: settings.isDark,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.primary,
                onChanged: settings.setDark,
              ),
            ),
            SettingsTile(
              icon: Icons.public_rounded,
              title: t.get('language'),
              subtitle: Strings.supported[settings.language],
              onTap: () => open(const LanguageScreen()),
            ),
            SectionLabel(t.get('aboutSection')),
            SettingsTile(
              icon: Icons.shield_outlined,
              title: t.get('privacyTerms'),
              onTap: () => open(const PrivacyScreen()),
            ),
            SettingsTile(
              icon: Icons.help_outline_rounded,
              title: t.get('helpFeedback'),
              onTap: () => open(const HelpScreen()),
            ),
            SettingsTile(
              icon: Icons.info_outline_rounded,
              title: t.get('about'),
              onTap: () => open(const AboutScreen()),
            ),
            const SizedBox(height: 18),
            OutlinePillButton(
              label: t.get('logOut'),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    title: Text(t.get('confirmLogout')),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(t.get('cancel')),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(
                          t.get('logOut'),
                          style: const TextStyle(color: AppColors.danger),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  await AppScope.read(context).signOut();
                  if (context.mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                }
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
