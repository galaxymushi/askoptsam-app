import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

enum NoticeKind { welcome, reply, tip, update }

class AppNotice {
  AppNotice({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.createdAt,
    this.read = false,
  });

  final String id;
  final NoticeKind kind;
  final String title;
  final String body;
  final DateTime createdAt;
  bool read;

  Map<String, dynamic> toMap() => {
        'id': id,
        'kind': kind.name,
        'title': title,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'read': read,
      };

  static AppNotice fromMap(Map<String, dynamic> map) => AppNotice(
        id: map['id'] as String,
        kind: NoticeKind.values.firstWhere(
          (k) => k.name == map['kind'],
          orElse: () => NoticeKind.update,
        ),
        title: map['title'] as String? ?? '',
        body: map['body'] as String? ?? '',
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
            DateTime.now(),
        read: map['read'] as bool? ?? false,
      );
}

/// The in-app notification feed. It lives next to the chats on the device so
/// the bell always has something real behind it, without a push server.
class NotificationStore {
  static const _limit = 60;

  String _key(String uid) =>
      'asksam_notices_${base64Url.encode(utf8.encode(uid)).replaceAll('=', '')}';

  Future<List<AppNotice>> load(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(uid));
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => AppNotice.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _write(String uid, List<AppNotice> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key(uid),
      jsonEncode(items.map((n) => n.toMap()).toList()),
    );
  }

  /// Adds a notice once per [id] so repeated opens do not duplicate it.
  Future<bool> addOnce(
    String uid, {
    required String id,
    required NoticeKind kind,
    required String title,
    required String body,
  }) async {
    final items = await load(uid);
    if (items.any((n) => n.id == id)) return false;
    items.insert(
      0,
      AppNotice(
        id: id,
        kind: kind,
        title: title,
        body: body,
        createdAt: DateTime.now(),
      ),
    );
    await _write(uid, items.take(_limit).toList());
    return true;
  }

  Future<int> unread(String uid) async =>
      (await load(uid)).where((n) => !n.read).length;

  Future<void> markAllRead(String uid) async {
    final items = await load(uid);
    for (final n in items) {
      n.read = true;
    }
    await _write(uid, items);
  }

  Future<void> markRead(String uid, String id) async {
    final items = await load(uid);
    for (final n in items) {
      if (n.id == id) n.read = true;
    }
    await _write(uid, items);
  }
}
