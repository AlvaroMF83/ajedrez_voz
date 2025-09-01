// =========================
// lib/src/routes.dart
// =========================
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/game_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/settings_language_screen.dart';
import 'screens/choose_color_screen.dart';

class AppRoutes {
  static const home = '/';
  static const game = '/game';
  static const settings = '/settings';
  static const settingsLanguage = '/settings/language';
  static const chooseColor = '/choose-color';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case chooseColor: 
        return MaterialPageRoute(builder: (_) => const ChooseColorScreen());
      case game:
        final args = (settings.arguments as Map?) ?? {};
        return MaterialPageRoute(builder: (_) => GameScreen(playerColor: args['playerColor']));
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case settingsLanguage:
        return MaterialPageRoute(builder: (_) => const SettingsLanguageScreen());
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}