// =========================
// lib/src/settings/localization_service.dart
// =========================
import 'package:flutter/material.dart';

class LocalizationService {
  static const defaultLocale = Locale('es');
  static const supportedLocales = <Locale>[
    Locale('es'),
    Locale('en'),
  ];

  static const delegates = <LocalizationsDelegate<dynamic>>[]; // Si usas intl, añade aquí

  static LocStrings t(BuildContext context) {
    final locale = Localizations.localeOf(context);
    switch (locale.languageCode) {
      case 'en':
        return LocStrings.en;
      case 'es':
      default:
        return LocStrings.es;
    }
  }

  static String localeName(Locale l) {
    switch (l.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return l.toLanguageTag();
    }
  }
}

class LocStrings {
  final String homeTitle;
  final String start;
  final String settings;
  final String exit;
  final String exitConfirm;
  final String cancel;
  final String change;
  final String language;
  final String darkMode;
  final String voiceInput;
  final String voiceInputDesc;
  final String visualDifficulty;
  final String visualNormal;
  final String visualSameColorPieces;
  final String visualColoredDiscs;
  final String visualMonochromeDiscs;
  final String visualNoPieces;
  final String game;
  final String moveHint;
  final String playEngine;

  const LocStrings({
    required this.homeTitle,
    required this.start,
    required this.settings,
    required this.exit,
    required this.exitConfirm,
    required this.cancel,
    required this.change,
    required this.language,
    required this.darkMode,
    required this.voiceInput,
    required this.voiceInputDesc,
    required this.visualDifficulty,
    required this.visualNormal,
    required this.visualSameColorPieces,
    required this.visualColoredDiscs,
    required this.visualMonochromeDiscs,
    required this.visualNoPieces,
    required this.game,
    required this.moveHint,
    required this.playEngine,
  });

  static const es = LocStrings(
    homeTitle: 'Ajedrez por Voz',
    start: 'Empezar',
    settings: 'Configuración',
    exit: 'Salir',
    exitConfirm: '¿Quieres salir de la aplicación?',
    cancel: 'Cancelar',
    change: 'Cambiar',
    language: 'Idioma',
    darkMode: 'Modo oscuro',
    voiceInput: 'Entrada por voz',
    voiceInputDesc: 'Jugar dictando movimientos',
    visualDifficulty: 'Dificultad visual',
    visualNormal: 'Normal (piezas estándar)',
    visualSameColorPieces: 'Piezas del mismo color',
    visualColoredDiscs: 'Discos de colores',
    visualMonochromeDiscs: 'Discos monocromos',
    visualNoPieces: 'Sin piezas',
    game: 'Partida',
    moveHint: 'Introduce un movimiento (p.ej. e2e4 o "caballo g1 f3")',
    playEngine: 'Juega la máquina',
  );

  static const en = LocStrings(
    homeTitle: 'Voice Chess',
    start: 'Start',
    settings: 'Settings',
    exit: 'Exit',
    exitConfirm: 'Do you want to exit the app?',
    cancel: 'Cancel',
    change: 'Change',
    language: 'Language',
    darkMode: 'Dark mode',
    voiceInput: 'Voice input',
    voiceInputDesc: 'Play by dictating moves',
    visualDifficulty: 'Visual difficulty',
    visualNormal: 'Normal (standard pieces)',
    visualSameColorPieces: 'Same-color pieces',
    visualColoredDiscs: 'Colored discs',
    visualMonochromeDiscs: 'Monochrome discs',
    visualNoPieces: 'No pieces',
    game: 'Game',
    moveHint: 'Enter a move (e.g. e2e4 or "knight g1 f3")',
    playEngine: 'Engine move',
  );
}
