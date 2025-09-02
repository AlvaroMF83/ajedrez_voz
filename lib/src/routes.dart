// =========================
// lib/src/routes.dart
// =========================
// =========================
// lib/src/routes.dart
// =========================
import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/game_screen.dart';            // <-- un solo import (relativo) es suficiente
import 'screens/settings_screen.dart';
import 'screens/settings_language_screen.dart';
import 'screens/choose_color_screen.dart';

import 'settings/settings_models.dart' show PlayerColor; // <-- IMPORTA PlayerColor AQUÍ

PlayerColor? parsePlayerColor(dynamic raw) {
  if (raw is PlayerColor) return raw;
  if (raw is String) {
    final v = raw.toLowerCase();
    if (v == 'white' || v == 'w' || v == 'blancas') return PlayerColor.white;
    if (v == 'black' || v == 'b' || v == 'negras') return PlayerColor.black;
    if (v == 'random' || v == 'aleatorio' || v == 'r') return PlayerColor.random;
  }
  return null;
}

class AppRoutes {
  static const home = '/';
  static const game = '/game';
  static const settings = '/settings';
  static const settingsLanguage = '/settings/language';
  static const chooseColor = '/choose-color';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case AppRoutes.chooseColor:
        return MaterialPageRoute(builder: (_) => const ChooseColorScreen());

      case AppRoutes.game:
        // Acepta: null, Map<String, dynamic>, String directo, o PlayerColor
        PlayerColor? pc;
        final args = settings.arguments;
        if (args is Map<String, dynamic>) {
          pc = parsePlayerColor(args['playerColor']);
        } else {
          pc = parsePlayerColor(args); // por si pasas String o PlayerColor directamente
        }
        return MaterialPageRoute(builder: (_) => GameScreen(playerColor: pc));

      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case AppRoutes.settingsLanguage:
        return MaterialPageRoute(builder: (_) => const SettingsLanguageScreen());

      default:
        // Fallback razonable
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}
