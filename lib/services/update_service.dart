import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import '../l10n.dart';
import 'notification_store.dart';

class AppRelease {
  const AppRelease({
    required this.version,
    required this.tagName,
    required this.title,
    required this.notes,
    required this.downloadUrl,
    required this.pageUrl,
  });

  final String version;
  final String tagName;
  final String title;
  final String notes;
  final String downloadUrl;
  final String pageUrl;

  Map<String, dynamic> toMap() => {
        'version': version,
        'tagName': tagName,
        'title': title,
        'notes': notes,
        'downloadUrl': downloadUrl,
        'pageUrl': pageUrl,
      };

  static AppRelease fromMap(Map<String, dynamic> map) => AppRelease(
        version: map['version'] as String? ?? '',
        tagName: map['tagName'] as String? ?? '',
        title: map['title'] as String? ?? '',
        notes: map['notes'] as String? ?? '',
        downloadUrl:
            map['downloadUrl'] as String? ?? AppConfig.latestApkDownloadUrl,
        pageUrl: map['pageUrl'] as String? ?? AppConfig.releasesPageUrl,
      );

  static AppRelease? fromGitHubJson(Map<String, dynamic> json) {
    final rawTag = (json['tag_name'] as String? ?? '').trim();
    final version = UpdateService.normalizeVersion(rawTag);
    if (version.isEmpty) return null;

    final name = (json['name'] as String? ?? '').trim();
    final rawBody = (json['body'] as String? ?? '').trim();
    final htmlUrl =
        (json['html_url'] as String? ?? AppConfig.releasesPageUrl).trim();

    String apkUrl = AppConfig.latestApkDownloadUrl;
    final assets = json['assets'];
    if (assets is List) {
      for (final item in assets) {
        if (item is Map) {
          final assetName = (item['name'] as String? ?? '').toLowerCase();
          final browserUrl =
              (item['browser_download_url'] as String? ?? '').trim();
          if (assetName.endsWith('.apk') && browserUrl.isNotEmpty) {
            apkUrl = browserUrl;
            break;
          }
        }
      }
    }

    return AppRelease(
      version: version,
      tagName: rawTag.isEmpty ? 'v$version' : rawTag,
      title: name.isEmpty ? 'AskOptSam $version' : name,
      notes: _cleanReleaseNotes(rawBody, version),
      downloadUrl: apkUrl,
      pageUrl: htmlUrl.isEmpty ? AppConfig.releasesPageUrl : htmlUrl,
    );
  }

  static String _cleanReleaseNotes(String raw, String version) {
    if (raw.isEmpty) return 'AskOptSam $version';
    final lines = <String>[];
    for (final rawLine in const LineSplitter().convert(raw)) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;
      if (line.startsWith('#')) continue;
      if (line.startsWith('|') || line.startsWith('![')) continue;
      if (line.toLowerCase().startsWith('**sha-256')) continue;
      final cleaned = line
          .replaceAll(RegExp(r'^[-*•]\s*'), '')
          .replaceAll('**', '')
          .replaceAll('`', '')
          .trim();
      if (cleaned.isNotEmpty) {
        lines.add(cleaned);
      }
      if (lines.length >= 2) break;
    }
    return lines.isEmpty ? 'AskOptSam $version' : lines.join(' • ');
  }
}

/// Checks GitHub Releases for a newer APK and surfaces both an in-app update
/// card and a one-tap download notification in the bell feed.
class UpdateService {
  UpdateService._();

  static final UpdateService instance = UpdateService._();

  static const _cacheKey = 'asksam_latest_release_v1';
  static const _downloadedKey = 'asksam_update_downloaded_v1';
  static const _fallbackInstalledVersion = '2.4.2';

  /// Strips leading `v`/`V` and build metadata (`+5`) to return `major.minor.patch`.
  static String normalizeVersion(String raw) {
    final trimmed = raw.trim().replaceFirst(RegExp(r'^[vV]'), '');
    final withoutBuild = trimmed.split('+').first.split('-').first.trim();
    final match = RegExp(r'^\d+(\.\d+)*').firstMatch(withoutBuild);
    return match?.group(0) ?? '';
  }

  /// True when [candidate] is strictly newer than [current].
  static bool isNewerVersion(String candidate, String current) {
    final a = _parseParts(candidate);
    final b = _parseParts(current);
    if (a.isEmpty || b.isEmpty) return false;
    final len = a.length > b.length ? a.length : b.length;
    for (var i = 0; i < len; i++) {
      final av = i < a.length ? a[i] : 0;
      final bv = i < b.length ? b[i] : 0;
      if (av > bv) return true;
      if (av < bv) return false;
    }
    return false;
  }

  static List<int> _parseParts(String version) {
    final norm = normalizeVersion(version);
    if (norm.isEmpty) return const [];
    return norm
        .split('.')
        .map((p) => int.tryParse(p) ?? 0)
        .toList(growable: false);
  }

  static bool get _isFlutterTest =>
      !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  Future<String> currentVersion() async {
    if (_isFlutterTest) return _fallbackInstalledVersion;
    try {
      final info = await PackageInfo.fromPlatform()
          .timeout(const Duration(seconds: 2));
      final v = normalizeVersion(info.version);
      if (v.isNotEmpty) return v;
    } catch (_) {
      // Platform channel unavailable; use fallback.
    }
    return _fallbackInstalledVersion;
  }

  Future<AppRelease?> cachedUpdate({String? installedVersion}) async {
    final current = installedVersion ?? await currentVersion();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      final release = AppRelease.fromMap(map);
      if (isNewerVersion(release.version, current)) {
        return release;
      }
    } catch (_) {}
    return null;
  }

  Future<AppRelease?> checkForUpdate({
    String? installedVersion,
    http.Client? client,
  }) async {
    final current = installedVersion ?? await currentVersion();
    if (_isFlutterTest && client == null) {
      return cachedUpdate(installedVersion: current);
    }
    final httpClient = client ?? http.Client();
    final shouldClose = client == null;
    try {
      final response = await httpClient
          .get(
            Uri.parse(AppConfig.releasesApiUrl),
            headers: const {
              'Accept': 'application/vnd.github+json',
              'X-GitHub-Api-Version': '2022-11-28',
            },
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map) {
          final release = AppRelease.fromGitHubJson(
            Map<String, dynamic>.from(decoded),
          );
          if (release != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_cacheKey, jsonEncode(release.toMap()));
            if (isNewerVersion(release.version, current)) {
              return release;
            }
            return null;
          }
        }
      }
    } catch (_) {
      // Offline or rate-limited: fall back to cached release metadata.
    } finally {
      if (shouldClose) httpClient.close();
    }
    return cachedUpdate(installedVersion: current);
  }

  /// Checks for a newer version and, if found, posts an in-app notification
  /// with the direct APK download link so tapping the notification downloads it.
  Future<AppRelease?> syncUpdateNotice(
    String uid, {
    required String language,
    bool notifyUpdates = true,
    String? installedVersion,
    http.Client? client,
  }) async {
    final release = await checkForUpdate(
      installedVersion: installedVersion,
      client: client,
    );
    if (release == null) return null;
    if (notifyUpdates) {
      final s = Strings(language);
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
    return release;
  }

  /// Remembers the release the user already fetched so every download button
  /// can hide itself until a newer version shows up.
  Future<void> markDownloaded(String version) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_downloadedKey, version.trim());
    } catch (_) {
      // Best effort: the buttons fall back to their visible state.
    }
  }

  /// True once [version] has been fetched on this device.
  Future<bool> hasDownloaded(String version) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_downloadedKey)?.trim() ?? '';
      return saved.isNotEmpty && saved == version.trim();
    } catch (_) {
      return false;
    }
  }

  Future<bool> openDownload(AppRelease release) async {
    final target = release.downloadUrl.isNotEmpty
        ? release.downloadUrl
        : release.pageUrl;
    // Never leave the caller hanging: if the browser does not answer within
    // a few seconds (no browser installed, odd OEM intent handling) the
    // button simply returns instead of spinning forever.
    final opened = await openUrl(target)
        .timeout(const Duration(seconds: 6), onTimeout: () => false);
    if (opened) await markDownloaded(release.version);
    return opened;
  }

  Future<bool> openUrl(String url) async {
    if (url.trim().isEmpty) return false;
    try {
      return await launchUrl(
        Uri.parse(url.trim()),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      return false;
    }
  }
}
