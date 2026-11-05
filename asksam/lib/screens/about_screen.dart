import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../l10n.dart';
import '../services/update_service.dart';
import '../theme.dart';
import '../widgets/ui.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';
  AppRelease? _update;
  bool _checking = false;
  bool _downloaded = false;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) {
        setState(() => _version = '${info.version} (${info.buildNumber})');
      }
    });
    UpdateService.instance.cachedUpdate().then((release) {
      if (mounted && release != null) {
        setState(() => _update = release);
        _restoreDownloaded(release);
      }
    });
  }

  /// Swaps the download button for a "downloaded" note until a newer release
  /// shows up.
  Future<void> _restoreDownloaded(AppRelease release) async {
    final done = await UpdateService.instance.hasDownloaded(release.version);
    if (mounted && done) setState(() => _downloaded = true);
  }

  Future<void> _downloadUpdate() async {
    final release = _update;
    if (release == null) return;
    final opened = await UpdateService.instance.openDownload(release);
    if (mounted && opened) setState(() => _downloaded = true);
  }

  Future<void> _checkUpdates() async {
    if (_checking) return;
    setState(() => _checking = true);
    final release = await UpdateService.instance.checkForUpdate();
    if (!mounted) return;
    setState(() {
      _checking = false;
      _update = release;
      _downloaded = false;
    });
    if (release != null) _restoreDownloaded(release);
    if (release == null) {
      final t = L10nScope.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.get('upToDateToast')),
          duration: const Duration(seconds: 2),
        ),
      );
    }
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
        title: Text(t.get('aboutTitle')),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 8, 26, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              const Center(child: BrandLogo(size: 168)),
              const SizedBox(height: 18),
              const Text(
                'AskOptSam',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Seeing Is Believing',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: isDark ? AppColors.darkMuted : AppColors.muted,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                t.get('developedBy'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16.5, height: 1.45),
              ),
              const SizedBox(height: 26),
              _PersonCard(
                initials: 'JS',
                name: 'J.M. SAMWEL',
                role: t.get('founder'),
              ),
              const SizedBox(height: 12),
              _PersonCard(
                initials: 'JE',
                name: 'J.M. EMANUELI',
                role: t.get('coFounder'),
              ),
              const Spacer(),
              if (_update != null) ...[
                if (_downloaded)
                  OutlinePillButton(
                    label: t.get('updateDownloadedShort'),
                    height: 48,
                    icon: Icons.check_circle_outline_rounded,
                    onPressed: null,
                  )
                else
                  PrimaryButton(
                    label:
                        '${t.get('downloadUpdate')} (${_update!.version})',
                    height: 50,
                    onPressed: _downloadUpdate,
                  ),
                const SizedBox(height: 12),
              ] else ...[
                OutlinePillButton(
                  label: _checking
                      ? t.get('checkingUpdates')
                      : t.get('checkForUpdates'),
                  height: 48,
                  icon: Icons.system_update_alt_rounded,
                  onPressed: _checking ? null : _checkUpdates,
                ),
                const SizedBox(height: 12),
              ],
              Text(
                '${t.get('version')} $_version',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? AppColors.darkMuted : AppColors.muted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                t.get('rightsReserved'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: isDark ? AppColors.darkMuted : AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  const _PersonCard({
    required this.initials,
    required this.name,
    required this.role,
  });

  final String initials;
  final String name;
  final String role;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                role,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? AppColors.darkMuted : AppColors.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
