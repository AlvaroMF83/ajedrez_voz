// =========================
// lib/src/settings/settings_controller.dart
// =========================
import 'package:flutter/material.dart';
import 'settings_models.dart';
import 'settings_service.dart';

class SettingsController extends ChangeNotifier {
  final SettingsService _service;
  SettingsController(this._service);

  // Tema / idioma
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  Locale _locale = const Locale('es');
  Locale get locale => _locale;

  // Voz y dificultad visual
  bool _voiceEnabled = true;
  bool get voiceEnabled => _voiceEnabled;

  VisualMode _visualMode = VisualMode.normal;
  VisualMode get visualMode => _visualMode;

  // Motor y skill
  EnginePref _enginePref = EnginePref.auto;
  int _engineSkill = 8;

  EnginePref get enginePref => _enginePref;
  int get engineSkill => _engineSkill;

  Future<void> loadSettings() async {
    _themeMode = await _service.loadThemeMode();
    _locale = await _service.loadLocale();
    _voiceEnabled = await _service.loadVoiceEnabled();
    _visualMode = await _service.loadVisualMode();
    _enginePref = await _service.loadEnginePref();
    _engineSkill = await _service.loadEngineSkill();
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

  Future<void> setEnginePref(EnginePref p) async {
    _enginePref = p;
    await _service.saveEnginePref(p);
    notifyListeners();
  }

  Future<void> setEngineSkill(int s) async {
    _engineSkill = s.clamp(0, 20);
    await _service.saveEngineSkill(_engineSkill);
    notifyListeners();
  }

  String visualModeLabel(Strings t) {
    switch (_visualMode) {
      case VisualMode.normal: return t.visualNormal;
      case VisualMode.sameColorPieces: return t.visualSameColorPieces;
      case VisualMode.coloredDiscs: return t.visualColoredDiscs;
      case VisualMode.monochromeDiscs: return t.visualMonochromeDiscs;
      case VisualMode.noPieces: return t.visualNoPieces;
    }
  }

  String enginePrefLabel() {
    switch (_enginePref) {
      case EnginePref.auto: return 'Auto (según plataforma)';
      case EnginePref.stockfish: return 'Stockfish';
      case EnginePref.fallback: return 'Fallback simple';
    }
  }
}
