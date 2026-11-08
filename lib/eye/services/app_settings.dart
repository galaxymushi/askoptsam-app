import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/strings.dart';
import '../theme.dart';

class AppSettings extends ChangeNotifier {
  AppSettings._();

  static final AppSettings instance = AppSettings._();

  static const String _envApiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String _encodedDefaultKey =
      'QVEuQWI4Uk42STNJRXlSbjhmMkxKbVhPUVNpRFl5OEI0eXM1eThxU0tjblFLSFNoYm1kSXc=';

  static String get builtInApiKey => _envApiKey.isNotEmpty
      ? _envApiKey
      : utf8.decode(base64Decode(_encodedDefaultKey));

  static const _apiKeyStore = 'gemini_api_key';
  static const _modelKey = 'gemini_model';
  static const _speechRateKey = 'speech_rate';
  static const _textScaleKey = 'text_scale';
  static const _themeKey = 'theme_mode';
  static const _languageKey = 'language';
  static const _onboardedKey = 'onboarded';
  static const _autoSpeakKey = 'auto_speak';
  static const _geminiVoiceKey = 'gemini_voice';

  final FlutterSecureStorage _secure = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  String _apiKey = builtInApiKey;
  String _model = 'gemini-3.5-flash';
  double _speechRate = 0.5;
  double _textScale = 1.0;
  AppThemeMode _themeMode = AppThemeMode.daylight;
  AppLanguage _language = AppLanguage.sw;
  bool _hasOnboarded = false;
  bool _autoSpeak = true;
  String _geminiVoice = 'Charon';

  String get apiKey => _apiKey.trim().isNotEmpty ? _apiKey.trim() : builtInApiKey;
  String get model => _model;
  double get speechRate => _speechRate;
  double get textScale => _textScale;
  AppThemeMode get themeMode => _themeMode;
  AppLanguage get language => _language;
  S get strings => S(_language);
  bool get hasOnboarded => _hasOnboarded;
  bool get autoSpeak => _autoSpeak;
  String get geminiVoice => _geminiVoice;
  bool get isConfigured => apiKey.isNotEmpty;
  bool get usingBuiltInKey =>
      apiKey == builtInApiKey && builtInApiKey.isNotEmpty;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    try {
      final stored = await _secure.read(key: _apiKeyStore);
      _apiKey = (stored != null && stored.trim().isNotEmpty)
          ? stored.trim()
          : builtInApiKey;
    } catch (_) {
      _apiKey = builtInApiKey;
    }
    final savedModel = _prefs!.getString(_modelKey);
    if (savedModel != null &&
        savedModel.isNotEmpty &&
        !savedModel.startsWith('gemini-2.') &&
        !savedModel.startsWith('gemini-1.')) {
      _model = savedModel;
    } else {
      _model = 'gemini-3.5-flash';
    }
    _speechRate = _prefs!.getDouble(_speechRateKey) ?? _speechRate;
    _textScale = _prefs!.getDouble(_textScaleKey) ?? _textScale;
    final themeName = _prefs!.getString(_themeKey);
    _themeMode = AppThemeMode.values.firstWhere(
      (mode) => mode.name == themeName,
      orElse: () => AppThemeMode.daylight,
    );
    final languageName = _prefs!.getString(_languageKey);
    _language = AppLanguage.values.firstWhere(
      (language) => language.name == languageName,
      orElse: () => AppLanguage.sw,
    );
    _hasOnboarded = _prefs!.getBool(_onboardedKey) ?? false;
    _autoSpeak = _prefs!.getBool(_autoSpeakKey) ?? true;
    _geminiVoice = _prefs!.getString(_geminiVoiceKey) ?? _geminiVoice;
    notifyListeners();
  }

  Future<void> setApiKey(String value) async {
    final trimmed = value.trim();
    _apiKey = trimmed.isNotEmpty ? trimmed : builtInApiKey;
    try {
      await _secure.write(key: _apiKeyStore, value: _apiKey);
    } catch (_) {
      // Secure storage is unavailable on some devices; keep the in-memory key.
    }
    notifyListeners();
  }

  Future<void> setModel(String value) async {
    _model = value;
    await _prefs?.setString(_modelKey, value);
    notifyListeners();
  }

  Future<void> setSpeechRate(double value) async {
    _speechRate = value.clamp(0.25, 0.8);
    await _prefs?.setDouble(_speechRateKey, _speechRate);
    notifyListeners();
  }

  Future<void> setTextScale(double value) async {
    _textScale = value.clamp(1.0, 2.0);
    await _prefs?.setDouble(_textScaleKey, _textScale);
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode value) async {
    _themeMode = value;
    await _prefs?.setString(_themeKey, value.name);
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage value) async {
    _language = value;
    await _prefs?.setString(_languageKey, value.name);
    notifyListeners();
  }

  Future<void> setAutoSpeak(bool value) async {
    _autoSpeak = value;
    await _prefs?.setBool(_autoSpeakKey, value);
    notifyListeners();
  }

  Future<void> setGeminiVoice(String value) async {
    _geminiVoice = value;
    await _prefs?.setString(_geminiVoiceKey, value);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _hasOnboarded = true;
    await _prefs?.setBool(_onboardedKey, true);
    notifyListeners();
  }
}
