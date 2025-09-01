// =========================
// lib/src/settings/settings_controller.dart
// =========================
import 'package:flutter/material.dart';
import 'settings_service.dart';
import 'localization_service.dart';

enum VisualMode { normal, sameColorPieces, coloredDiscs, monochromeDiscs, noPieces }

class SettingsController extends ChangeNotifier {
  final SettingsService _service;
  SettingsController(this._service);

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  Locale _locale = LocalizationService.defaultLocale;
  Locale get locale => _locale;

  bool _voiceEnabled = true;
  bool get voiceEnabled => _voiceEnabled;

  VisualMode _visualMode = VisualMode.normal;
  VisualMode get visualMode => _visualMode;

  Future<void> loadSettings() async {
    _themeMode = await _service.loadThemeMode();
    _locale = await _service.loadLocale();
    _voiceEnabled = await _service.loadVoiceEnabled();
    _visualMode = await _service.loadVisualMode();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _service.saveThemeMode(mode);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await _service.saveLocale(locale);
    notifyListeners();
  }

  Future<void> setVoiceEnabled(bool v) async {
    _voiceEnabled = v;
    await _service.saveVoiceEnabled(v);
    notifyListeners();
  }

  Future<void> setVisualMode(VisualMode m) async {
    _visualMode = m;
    await _service.saveVisualMode(m);
    notifyListeners();
  }

  String visualModeLabel(LocStrings t) {
    switch (_visualMode) {
      case VisualMode.normal:
        return t.visualNormal;
      case VisualMode.sameColorPieces:
        return t.visualSameColorPieces;
      case VisualMode.coloredDiscs:
        return t.visualColoredDiscs;
      case VisualMode.monochromeDiscs:
        return t.visualMonochromeDiscs;
      case VisualMode.noPieces:
        return t.visualNoPieces;
    }
  }
}
