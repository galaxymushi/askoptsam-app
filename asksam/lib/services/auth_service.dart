import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import '../models.dart';

class AuthException implements Exception {
  const AuthException(this.code);
  final String code;

  @override
  String toString() => code;
}

abstract class AuthService {
  bool get isCloud;

  Future<AppUser?> restore();
  Future<AppUser> signIn(String email, String password);
  Future<AppUser> signUp(String name, String email, String password);
  Future<void> sendReset(String email);
  Future<void> updateName(String name);
  Future<void> signOut();
}

Future<AuthService> createAuthService() async {
  if (AppConfig.firebaseConfigured) {
    try {
      return FirebaseAuthService();
    } catch (error) {
      debugPrint('Cloud sign-in unavailable, using on-device accounts: $error');
    }
  }
  return LocalAuthService();
}

/// On-device accounts used when no Firebase project is configured.
/// Passwords are salted and hashed; nothing leaves the phone.
class LocalAuthService implements AuthService {
  static const _accountsKey = 'local_accounts';
  static const _sessionKey = 'local_session';

  final Map<String, Map<String, String>> _accounts = {};
  AppUser? _user;
  bool _loaded = false;

  @override
  bool get isCloud => false;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_accountsKey);
    if (raw != null) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      decoded.forEach((email, value) {
        _accounts[email] = Map<String, String>.from(value as Map);
      });
    }
    final session = prefs.getString(_sessionKey);
    if (session != null && _accounts.containsKey(session)) {
      _user = _userFrom(session);
    }
    _loaded = true;
  }

  AppUser _userFrom(String email) {
    final record = _accounts[email]!;
    return AppUser(uid: email, email: email, name: record['name'] ?? '');
  }

  String _hash(String password, String salt) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();

  String _salt() {
    final rand = Random.secure();
    return base64Url.encode(List.generate(16, (_) => rand.nextInt(256)));
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accountsKey, jsonEncode(_accounts));
    if (_user == null) {
      await prefs.remove(_sessionKey);
    } else {
      await prefs.setString(_sessionKey, _user!.email);
    }
  }

  @override
  Future<AppUser?> restore() async {
    await _ensureLoaded();
    return _user;
  }

  @override
  Future<AppUser> signIn(String email, String password) async {
    await _ensureLoaded();
    final key = email.trim().toLowerCase();
    final record = _accounts[key];
    if (record == null) throw const AuthException('user-not-found');
    if (_hash(password, record['salt']!) != record['password']) {
      throw const AuthException('wrong-password');
    }
    _user = _userFrom(key);
    await _persist();
    return _user!;
  }

  @override
  Future<AppUser> signUp(String name, String email, String password) async {
    await _ensureLoaded();
    final key = email.trim().toLowerCase();
    if (_accounts.containsKey(key)) throw const AuthException('email-in-use');
    final salt = _salt();
    _accounts[key] = {
      'name': name.trim(),
      'salt': salt,
      'password': _hash(password, salt),
    };
    _user = _userFrom(key);
    await _persist();
    return _user!;
  }

  @override
  Future<void> sendReset(String email) async {
    await _ensureLoaded();
    if (!_accounts.containsKey(email.trim().toLowerCase())) {
      throw const AuthException('user-not-found');
    }
  }

  @override
  Future<void> updateName(String name) async {
    final user = _user;
    if (user == null) return;
    _accounts[user.email]!['name'] = name.trim();
    _user = user.copyWith(name: name.trim());
    await _persist();
  }

  @override
  Future<void> signOut() async {
    _user = null;
    await _persist();
  }
}

class FirebaseAuthService implements AuthService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  AppUser? _user;

  @override
  bool get isCloud => true;

  Future<String> _nameFor(fb.User user) async {
    final stored = user.displayName;
    if (stored != null && stored.isNotEmpty) return stored;
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      return doc.data()?['name'] as String? ?? '';
    } catch (_) {
      return '';
    }
  }

  @override
  Future<AppUser?> restore() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final name = await _nameFor(user);
    return _user = AppUser(uid: user.uid, email: user.email ?? '', name: name);
  }

  @override
  Future<AppUser> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user!;
      final name = await _nameFor(user);
      return _user = AppUser(uid: user.uid, email: user.email!, name: name);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    }
  }

  @override
  Future<AppUser> signUp(String name, String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user!;
      await user.updateDisplayName(name.trim());
      await _saveProfile(user.uid, name.trim());
      return _user =
          AppUser(uid: user.uid, email: user.email!, name: name.trim());
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    }
  }

  @override
  Future<void> sendReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    }
  }

  @override
  Future<void> updateName(String name) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.updateDisplayName(name.trim());
    await _saveProfile(user.uid, name.trim());
    _user = _user?.copyWith(name: name.trim());
  }

  @override
  Future<void> signOut() async {
    _user = null;
    await _auth.signOut();
  }

  Future<void> _saveProfile(String uid, String name) => FirebaseFirestore
      .instance
      .collection('users')
      .doc(uid)
      .set(
        {'name': name, 'updatedAt': DateTime.now().toIso8601String()},
        SetOptions(merge: true),
      );
}
