// lib/src/settings/settings_state.dart
import 'package:flutter/foundation.dart';
import 'settings_models.dart';

class SettingsState extends ChangeNotifier {
  EnginePref _enginePref = EnginePref.auto;
  VisualMode _visualMode = VisualMode.normal;
  int _engineSkill = 8;
  
  
  
  int get engineSkill => _engineSkill;
  EnginePref get enginePref => _enginePref;
  VisualMode get visualMode => _visualMode;

  void setEngineSkill(int s) {
    _engineSkill = s.clamp(0, 20);
    notifyListeners();
  }
  
  void setEnginePref(EnginePref pref) {
    if (_enginePref == pref) return;
    _enginePref = pref;
    notifyListeners();
  }

  void setVisualMode(VisualMode mode) {
    if (_visualMode == mode) return;
    _visualMode = mode;
    notifyListeners();
  }
}