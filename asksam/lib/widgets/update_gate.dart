import 'package:flutter/material.dart';

import '../app_state.dart';
import '../config.dart';
import '../l10n.dart';
import '../services/notification_store.dart';
import '../services/update_service.dart';
import '../theme.dart';
import 'ui.dart';

/// Watches GitHub Releases and, the moment a newer version exists, covers the
/// whole app with a mandatory dialog: the user downloads the new APK before
/// they can continue using AskOptSam.
///
/// Safety rules baked in:
/// * the check runs on every app start (post-first-frame, so it never covers
///   a blank window);
/// * if GitHub cannot be reached the app stays usable — nobody gets locked
///   out because of a flaky connection;
/// * the dialog is a root route with `barrierDismissible: false` and
///   `PopScope(canPop: false)`, so neither tapping outside nor the Android
///   back button closes it;
/// * the same release also lands in the bell feed and the system status bar
///   (deduped by the `update-<version>` id, exactly like Library/Chat).
class UpdateGate extends StatefulWidget {
  const UpdateGate({
    super.key,
    required this.child,
    this.check,
    this.download,
  });

  final Widget child;

  /// Overridable so tests can feed a canned release; defaults to a live
  /// GitHub check through [UpdateService].
  final Future<AppRelease?> Function()? check;

  /// Overridable so tests can simulate the browser opening; defaults to the
  /// real APK download through [UpdateService.openDownload].
  final Future<bool> Function(AppRelease release)? download;

  @override
  State<UpdateGate> createState() => _UpdateGateState();
}

class _UpdateGateState extends State<UpdateGate> {
  bool _started = false;
  bool _showing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  Future<void> _check() async {
    if (_started) return;
    _started = true;
    try {
      final release =
          await (widget.check ?? UpdateService.instance.checkForUpdate)();
      if (release == null || !mounted || _showing) return;
      _showing = true;

      // Same entry as Library/Chat post: one bell notice and one status-bar
      // notification per version, never a duplicate.
      try {
        final app = AppScope.read(context);
        final uid = app.user?.uid;
        if (uid != null) {
          final s = Strings(app.settings.language);
          await NotificationStore().addOnce(
            uid,
            id: 'update-${release.version}',
            kind: NoticeKind.update,
            title: s.format('noticeUpdateTitle', {'version': release.version}),
            body: s.format('noticeUpdateBody', {
              'version': release.version,
              'notes': release.notes,
            }),
            actionUrl: release.downloadUrl,
          );
        }
      } catch (_) {
        // The bell feed is a bonus; the blocking dialog below is the point.
      }

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        useRootNavigator: true,
        barrierDismissible: false,
        builder: (_) => _ForceUpdateDialog(
          release: release,
          download: widget.download,
        ),
      );
    } catch (_) {
      // Offline or GitHub unreachable: keep the app usable rather than
      // locking the user out without proof that a newer release exists.
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _ForceUpdateDialog extends StatefulWidget {
  const _ForceUpdateDialog({required this.release, this.download});

  final AppRelease release;
  final Future<bool> Function(AppRelease release)? download;

  @override
  State<_ForceUpdateDialog> createState() => _ForceUpdateDialogState();
}

class _ForceUpdateDialogState extends State<_ForceUpdateDialog> {
  bool _downloading = false;

  /// Set once the user has fetched this release (or already did on a
  /// previous launch): the big download button then makes way for a
  /// confirmation and only comes back when a newer release appears.
  bool _downloaded = false;

  @override
  void initState() {
    super.initState();
    _restoreDownloaded();
  }

  Future<void> _restoreDownloaded() async {
    try {
      final done = await UpdateService.instance
          .hasDownloaded(widget.release.version);
      if (mounted && done) setState(() => _downloaded = true);
    } catch (_) {
      // No prefs access: keep the button visible.
    }
  }

  Future<void> _download() async {
    if (_downloading) return;
    setState(() => _downloading = true);
    final open = widget.download ?? UpdateService.instance.openDownload;
    final opened = await open(widget.release);
    if (mounted) {
      setState(() {
        _downloading = false;
        // Only a real hand-off to the browser counts as "downloaded"; on
        // failure the button simply comes back so they can retry.
        if (opened) _downloaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = L10nScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final release = widget.release;

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0A5FF2), Color(0xFF1B86F8)],
                  ),
                ),
                child: const Icon(
                  Icons.system_update_alt_rounded,
                  size: 38,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                t.format('updateForceTitle', {'version': release.version}),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 21,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                t.format('updateForceBody', {'version': release.version}),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.45,
                  color: isDark ? AppColors.darkMuted : AppColors.muted,
                ),
              ),
              if (release.notes.trim().isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkPage
                        : AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    release.notes.trim(),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: isDark ? AppColors.darkText : AppColors.ink,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              if (_downloaded) ...[
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF16A34A),
                        size: 30,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.get('updateDownloadedTitle'),
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.get('updateDownloadedBody'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.4,
                          color: isDark ? AppColors.darkMuted : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: _downloading ? null : _download,
                  child: Text(
                    t.get('updateDownloadedRetry'),
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkMuted : AppColors.muted,
                    ),
                  ),
                ),
              ] else ...[
                PrimaryButton(
                  label: t.get('updateForceDownload'),
                  height: 52,
                  busy: _downloading,
                  onPressed: _download,
                ),
                const SizedBox(height: 10),
              ],
              TextButton(
                onPressed: () => UpdateService.instance.openUrl(
                  release.pageUrl.isNotEmpty
                      ? release.pageUrl
                      : AppConfig.releasesPageUrl,
                ),
                child: Text(
                  t.get('updateForceDetails'),
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkMuted : AppColors.muted,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                t.get('updateForceHint'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.4,
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
