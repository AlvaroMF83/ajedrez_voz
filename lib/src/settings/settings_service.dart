// =========================
// lib/src/settings/settings_service.dart
// =========================
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_controller.dart';

class SettingsService {
  static const _kTheme = 'themeMode';
  static const _kLang = 'languageCode';
  static const _kCountry = 'countryCode';
  static const _kVoice = 'voiceEnabled';
  static const _kVisual = 'visualMode';

  Future<ThemeMode> loadThemeMode() async {
    final p = await SharedPreferences.getInstance();
    final idx = p.getInt(_kTheme);
    if (idx == null) return ThemeMode.system;
    return ThemeMode.values[idx];
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kTheme, ThemeMode.values.indexOf(mode));
  }

  Future<Locale> loadLocale() async {
    final p = await SharedPreferences.getInstance();
    final code = p.getString(_kLang) ?? 'es';
    final country = p.getString(_kCountry);
    return Locale(code, country);
  }

  Future<void> saveLocale(Locale locale) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kLang, locale.languageCode);
    await p.setString(_kCountry, locale.countryCode ?? '');
  }

  Future<bool> loadVoiceEnabled() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kVoice) ?? true;
  }

  Future<void> saveVoiceEnabled(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kVoice, v);
  }

  Future<VisualMode> loadVisualMode() async {
    final p = await SharedPreferences.getInstance();
    final idx = p.getInt(_kVisual) ?? 0;
    return VisualMode.values[idx];
  }

  Future<void> saveVisualMode(VisualMode m) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kVisual, m.index);
  }
}
