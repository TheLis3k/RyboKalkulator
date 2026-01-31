import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _themeKey = 'theme_mode';

/// Serwis przechowujący wybór motywu (jasny/ciemny) i zapisujący go lokalnie.
class ThemeService extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  bool _initialized = false;

  ThemeMode get themeMode => _themeMode;

  /// true = jasny, false = ciemny
  bool get isLight => _themeMode == ThemeMode.light;

  /// Inicjalizacja – wczytanie zapisanego motywu.
  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_themeKey);
    if (saved == 'light') {
      _themeMode = ThemeMode.light;
    } else if (saved == 'dark') {
      _themeMode = ThemeMode.dark;
    }
    _initialized = true;
    notifyListeners();
  }

  /// Ustawia motyw (jasny lub ciemny) i zapisuje wybór.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode == ThemeMode.light ? 'light' : 'dark');
    notifyListeners();
  }

  /// Przełącza na jasny motyw.
  Future<void> setLight() => setThemeMode(ThemeMode.light);

  /// Przełącza na ciemny motyw.
  Future<void> setDark() => setThemeMode(ThemeMode.dark);

  /// Przełącza między jasnym a ciemnym.
  Future<void> toggle() => setThemeMode(
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
      );
}
