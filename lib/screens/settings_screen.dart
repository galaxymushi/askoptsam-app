import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n.dart';
import '../services/voice_concierge_service.dart';
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
            ListenableBuilder(
              listenable: VoiceConciergeService.instance,
              builder: (context, _) {
                final enabled =
                    VoiceConciergeService.instance.handsFreeEnabled;
                final isSw = settings.language == 'sw';
                return Column(
                  children: [
                    SettingsTile(
                      icon: Icons.record_voice_over_rounded,
                      title: isSw
                          ? 'Hali ya Wasioona ("Hey AskOptSam")'
                          : 'Blind Hands-Free ("Hey AskOptSam")',
                      subtitle: isSw
                          ? (enabled
                              ? 'Imewashwa · Sema "Hey AskOptSam" au tikisa simu'
                              : 'Imezimwa · Gusa kuwasha sauti ya kuamsha')
                          : (enabled
                              ? 'Active · Say "Hey AskOptSam" or shake phone'
                              : 'Off · Tap to enable voice & shake wake'),
                      onTap: () => VoiceConciergeService.instance
                          .setHandsFreeEnabled(!enabled),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: enabled
                              ? const Color(0xFF00C853)
                              : AppColors.muted.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          enabled
                              ? (isSw ? 'IMEWASHWA' : 'ON')
                              : (isSw ? 'IMEZIMWA' : 'OFF'),
                          style: TextStyle(
                            color: enabled ? Colors.white : AppColors.ink,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    SettingsTile(
                      icon: Icons.security_update_good_rounded,
                      title: isSw
                          ? 'Ruhusa za Kuamsha Simu Ikiwa Imezimwa'
                          : 'Screen-Off Wake Permissions',
                      subtitle: isSw
                          ? 'Ruhusu kipaza sauti, betri na kuwaka juu ya kioo'
                          : 'Allow microphone, battery & lock-screen overlay',
                      onTap: () => _showWakePermissionsSheet(context, isSw),
                    ),
                    SettingsTile(
                      icon: Icons.hearing_rounded,
                      title: isSw
                          ? 'Amsha Msaidizi wa Sauti Sasa'
                          : 'Launch Voice Concierge Now',
                      subtitle: isSw
                          ? 'AI itakuuliza unataka kwenda wapi na kukuongoza'
                          : 'AI will ask where you want to go and guide you',
                      onTap: () =>
                          VoiceConciergeService.instance.triggerWake(),
                    ),
                  ],
                );
              },
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

  Future<void> _showWakePermissionsSheet(
    BuildContext context,
    bool isSw,
  ) async {
    await VoiceConciergeService.instance.refreshPermissionsStatus();
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) {
        return ListenableBuilder(
          listenable: VoiceConciergeService.instance,
          builder: (ctx, _) {
            final svc = VoiceConciergeService.instance;
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSw
                          ? 'Ruhusa za Kuamsha Simu Ikiwa Imezimwa'
                          : 'Screen-Off Wake Permissions',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isSw
                          ? 'Ili AskOptSam iweze kusikia au kuamka hata kioo cha simu kikiwa kimezimwa, ruhusu mipangilio hii kwenye Android:'
                          : 'So AskOptSam can wake up even when the phone screen is off, allow these Android settings:',
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    _PermissionRow(
                      icon: Icons.mic_rounded,
                      title: isSw
                          ? '1. Kipaza Sauti & Arifa (Microphone)'
                          : '1. Microphone & Notifications',
                      subtitle: isSw
                          ? 'Inahitajika kusikia sauti yako ("Hey AskOptSam")'
                          : 'Required to hear your voice ("Hey AskOptSam")',
                      granted: svc.micGranted,
                      isSw: isSw,
                      onAllow: svc.requestMicAndNotifications,
                    ),
                    const SizedBox(height: 10),
                    _PermissionRow(
                      icon: Icons.battery_charging_full_rounded,
                      title: isSw
                          ? '2. Kutoizima Chinichini (Battery)'
                          : '2. Ignore Battery Optimization',
                      subtitle: isSw
                          ? 'Inazuia Android kuua msaidizi kioo kikiwa kimezimwa'
                          : 'Prevents Android from killing the listener when screen is off',
                      granted: svc.batteryIgnored,
                      isSw: isSw,
                      onAllow: svc.requestIgnoreBatteryOptimizations,
                    ),
                    const SizedBox(height: 10),
                    _PermissionRow(
                      icon: Icons.layers_rounded,
                      title: isSw
                          ? '3. Kuonyesha Juu ya Programu Zingine'
                          : '3. Display Over Other Apps',
                      subtitle: isSw
                          ? 'Inaruhusu app kuwasha kioo na kufunguka yenyewe'
                          : 'Allows the app to turn on the screen and pop up automatically',
                      granted: svc.overlayGranted,
                      isSw: isSw,
                      onAllow: svc.requestOverlayPermission,
                    ),
                    const SizedBox(height: 10),
                    _PermissionRow(
                      icon: Icons.assistant_rounded,
                      title: isSw
                          ? '4. Chagua Kama Default Assistant (Hiari)'
                          : '4. Set as Default Voice Assistant (Optional)',
                      subtitle: isSw
                          ? 'Inakuwezesha kubonyeza kitufe cha Power/Home kuamsha AskOptSam'
                          : 'Lets you hold the Power/Home button to wake AskOptSam',
                      granted: false,
                      isSw: isSw,
                      buttonLabel: isSw ? 'FUNGUA' : 'OPEN',
                      onAllow: svc.openVoiceAssistantSettings,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.granted,
    required this.isSw,
    required this.onAllow,
    this.buttonLabel,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool granted;
  final bool isSw;
  final VoidCallback onAllow;
  final String? buttonLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFF6F9FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: granted
              ? const Color(0xFF00C853)
              : (isDark ? AppColors.darkBorder : AppColors.border),
          width: 1.4,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: granted ? const Color(0xFF00C853) : AppColors.primary,
            size: 26,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.3,
                    color: isDark ? AppColors.darkMuted : AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (granted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF00C853),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                isSw ? '✓ TAYARI' : '✓ ALLOWED',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          else
            ElevatedButton(
              onPressed: onAllow,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(
                buttonLabel ?? (isSw ? 'RUHUSU' : 'ALLOW'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
