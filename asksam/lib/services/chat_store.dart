import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models.dart';

abstract class ChatStore {
  Future<List<ChatSession>> load(String uid);
  Future<void> save(String uid, ChatSession session);
  Future<void> delete(String uid, String sessionId);
  Future<void> rename(String uid, String sessionId, String title);
}

ChatStore createChatStore({required bool cloud}) =>
    cloud ? FirestoreChatStore() : LocalChatStore();

class LocalChatStore implements ChatStore {
  Future<File> _fileFor(String uid) async {
    final dir = await getApplicationDocumentsDirectory();
    final safe = base64Url.encode(utf8.encode(uid)).replaceAll('=', '');
    return File('${dir.path}/asksam_chats_$safe.json');
  }

  String _prefsKey(String uid) =>
      'asksam_chats_${base64Url.encode(utf8.encode(uid)).replaceAll('=', '')}';

  Future<String?> _readRaw(String uid) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_prefsKey(uid));
    }
    final file = await _fileFor(uid);
    if (!await file.exists()) return null;
    return file.readAsString();
  }

  Future<void> _writeRaw(String uid, String raw) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey(uid), raw);
      return;
    }
    final file = await _fileFor(uid);
    await file.writeAsString(raw, flush: true);
  }

  Future<Map<String, dynamic>> _read(String uid) async {
    final raw = await _readRaw(uid);
    if (raw == null) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<void> _write(String uid, Map<String, dynamic> data) async {
    await _writeRaw(uid, jsonEncode(data));
  }

  @override
  Future<List<ChatSession>> load(String uid) async {
    final data = await _read(uid);
    final sessions = data.values
        .map((v) => ChatSession.fromMap(Map<String, dynamic>.from(v as Map)))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sessions;
  }

  @override
  Future<void> save(String uid, ChatSession session) async {
    final data = await _read(uid);
    data[session.id] = session.toMap();
    await _write(uid, data);
  }

  @override
  Future<void> delete(String uid, String sessionId) async {
    final data = await _read(uid);
    data.remove(sessionId);
    await _write(uid, data);
  }

  @override
  Future<void> rename(String uid, String sessionId, String title) async {
    final data = await _read(uid);
    final raw = data[sessionId];
    if (raw == null) return;
    final session =
        ChatSession.fromMap(Map<String, dynamic>.from(raw as Map));
    session.title = title;
    data[sessionId] = session.toMap();
    await _write(uid, data);
  }
}

class FirestoreChatStore implements ChatStore {
  CollectionReference<Map<String, dynamic>> _sessions(String uid) =>
      FirebaseFirestore.instance.collection('users').doc(uid).collection('sessions');

  @override
  Future<List<ChatSession>> load(String uid) async {
    final snap = await _sessions(uid).orderBy('updatedAt', descending: true).get();
    return snap.docs
        .map((d) => ChatSession.fromMap(Map<String, dynamic>.from(d.data())))
        .toList();
  }

  @override
  Future<void> save(String uid, ChatSession session) =>
      _sessions(uid).doc(session.id).set(
        {
          ...session.toMap(),
          'messages': session.messages.map((m) => m.toMap()).toList(),
        },
        SetOptions(merge: false),
      );

  @override
  Future<void> delete(String uid, String sessionId) =>
      _sessions(uid).doc(sessionId).delete();

  @override
  Future<void> rename(String uid, String sessionId, String title) =>
      _sessions(uid).doc(sessionId).update({'title': title});
}
