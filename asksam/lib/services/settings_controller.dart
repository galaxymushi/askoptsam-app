import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this._prefs) {
    _themeMode = ThemeMode.values[_prefs.getInt('themeMode') ?? 0];
    _language = _prefs.getString('language') ?? 'sw';
    _notifyReplies = _prefs.getBool('notifyReplies') ?? true;
    _notifyTips = _prefs.getBool('notifyTips') ?? true;
    _notifyUpdates = _prefs.getBool('notifyUpdates') ?? true;
  }

  final SharedPreferences _prefs;

  late ThemeMode _themeMode;
  late String _language;
  late bool _notifyReplies;
  late bool _notifyTips;
  late bool _notifyUpdates;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;
  String get language => _language;
  bool get notifyReplies => _notifyReplies;
  bool get notifyTips => _notifyTips;
  bool get notifyUpdates => _notifyUpdates;

  void setDark(bool value) {
    _themeMode = value ? ThemeMode.dark : ThemeMode.light;
    _prefs.setInt('themeMode', _themeMode.index);
    notifyListeners();
  }

  void setLanguage(String code) {
    if (!['en', 'sw'].contains(code)) return;
    _language = code;
    _prefs.setString('language', code);
    notifyListeners();
  }

  void setNotifyReplies(bool v) {
    _notifyReplies = v;
    _prefs.setBool('notifyReplies', v);
    notifyListeners();
  }

  void setNotifyTips(bool v) {
    _notifyTips = v;
    _prefs.setBool('notifyTips', v);
    notifyListeners();
  }

  void setNotifyUpdates(bool v) {
    _notifyUpdates = v;
    _prefs.setBool('notifyUpdates', v);
    notifyListeners();
  }
}
