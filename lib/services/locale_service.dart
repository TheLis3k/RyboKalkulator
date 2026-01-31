import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _localeKey = 'locale';

/// Serwis przechowujący wybór języka (pl/en/de) i zapisujący go lokalnie.
class LocaleService extends ChangeNotifier {
  Locale _locale = const Locale('pl');
  bool _initialized = false;

  Locale get locale => _locale;

  String get languageCode => _locale.languageCode;

  /// Inicjalizacja – wczytanie zapisanego języka.
  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_localeKey);
    if (saved == 'en' || saved == 'de') {
      _locale = Locale(saved!);
    }
    _initialized = true;
    notifyListeners();
  }

  /// Ustawia język i zapisuje wybór.
  Future<void> setLocale(Locale value) async {
    if (_locale == value) return;
    _locale = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, value.languageCode);
    notifyListeners();
  }
}
