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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 8, 26, 24),
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
                imageAsset: 'assets/images/founders/jm_samwel.jpg',
              ),
              const SizedBox(height: 12),
              _PersonCard(
                initials: 'JE',
                name: 'J.M. EMANUELI',
                role: t.get('coFounder'),
                imageAsset: 'assets/images/founders/jm_emanueli.jpg',
              ),
              const SizedBox(height: 24),
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
    this.imageAsset,
  });

  final String initials;
  final String name;
  final String role;
  final String? imageAsset;

  void _showFullPhoto(BuildContext context) {
    if (imageAsset == null) return;
    final t = L10nScope.of(context);
    final isSw = t.language == 'sw';
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(80),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        imageAsset!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 320,
                        errorBuilder: (_, __, ___) => Container(
                          height: 200,
                          color: AppColors.primary,
                          alignment: Alignment.center,
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? AppColors.darkMuted : AppColors.muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close_rounded),
                      label: Text(isSw ? 'Funga' : 'Close'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: imageAsset != null ? () => _showFullPhoto(context) : null,
        borderRadius: BorderRadius.circular(18),
        child: Container(
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
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withAlpha(160),
                    width: 2.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(30),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: imageAsset != null
                      ? Image.asset(
                          imageAsset!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.primary,
                            alignment: Alignment.center,
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: AppColors.primary,
                          alignment: Alignment.center,
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
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
              ),
              if (imageAsset != null)
                Icon(
                  Icons.zoom_in_rounded,
                  size: 20,
                  color: isDark ? AppColors.darkMuted : AppColors.muted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
