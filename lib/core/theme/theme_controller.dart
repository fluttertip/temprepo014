import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's theme choice (system/light/dark). v1 had no dark mode at
/// all despite declaring Material 3. `shared_preferences` was already a
/// dependency but unused — now it earns its place.
class ThemeController extends ChangeNotifier {
  ThemeController(this._prefs) {
    final saved = _prefs.getString(_key);
    _mode = switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  static const _key = 'theme_mode';
  final SharedPreferences _prefs;
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    await _prefs.setString(_key, mode.name);
  }

  Future<void> toggleDark() =>
      setMode(isDark ? ThemeMode.light : ThemeMode.dark);
}