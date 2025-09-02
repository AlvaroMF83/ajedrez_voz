import 'package:flutter/material.dart';

/// Dificultad visual del tablero.
enum VisualMode { normal, sameColorPieces, coloredDiscs, monochromeDiscs, noPieces }

/// Preferencia de motor.
enum EnginePref { auto, stockfish, fallback }

/// Color elegido para el jugador.
enum PlayerColor { white, black, random }

/// Pequeño contenedor de cadenas (si no usas aún i18n completo aquí).
class Strings {
  final String visualNormal;
  final String visualSameColorPieces;
  final String visualColoredDiscs;
  final String visualMonochromeDiscs;
  final String visualNoPieces;
  const Strings({
    required this.visualNormal,
    required this.visualSameColorPieces,
    required this.visualColoredDiscs,
    required this.visualMonochromeDiscs,
    required this.visualNoPieces,
  });
}
