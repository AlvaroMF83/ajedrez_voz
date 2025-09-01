// =========================
// lib/src/state/juego_controller.dart
// =========================
import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as ch;
import '../engine/stockfish_service.dart';
import '../ui/board_renderer.dart';

class JuegoController {
  final TextEditingController textController = TextEditingController();
  final bool playsWhite;
  final StockfishService _engine = StockfishService();

  late ch.Chess _game;
  List<int>? lastMoveSquares;

  JuegoController({required this.playsWhite}) {
    _game = ch.Chess();
    if (!playsWhite) {
      onEngineMove(); // si el usuario juega negras, que empiece el motor
    }
  }

  /// Convierte FEN a 64 casillas (a8..h1)
  List<BoardSquare> get currentPosition {
    final placement = _game.fen.split(' ').first;
    final out = <BoardSquare>[];
    for (final rank in placement.split('/')) {
      for (int i = 0; i < rank.length; i++) {
        final c = rank[i];
        if (RegExp(r'[1-8]').hasMatch(c)) {
          for (int k = 0; k < int.parse(c); k++) {
            out.add(BoardSquare(null));
          }
        } else {
          out.add(BoardSquare(c)); // letra FEN
        }
      }
    }
    return out;
  }

  Future<void> onUserMove(String input) async {
    final cleaned = input.trim().replaceAll(' ', '');

    // 1) Calcula movimiento verbose (from/to) ANTES de mover
    final mvInfo = _findVerboseMoveBefore(cleaned);

    // 2) Aplica el movimiento (UCI o SAN)
    final ok = _applyMove(cleaned);

    if (ok) {
      // 3) Guarda from/to (si lo encontramos antes)
      if (mvInfo != null) {
        lastMoveSquares = [_sqToIndex(mvInfo.from), _sqToIndex(mvInfo.to)];
      } else {
        lastMoveSquares = null; // no pasa nada: solo no se resaltará
      }
      textController.clear();

      if (!_game.game_over) {
        await onEngineMove();
      }
    } else {
      // movimiento inválido -> podrías mostrar un SnackBar
    }
  }

  Future<void> onEngineMove() async {
    if (_game.game_over) return;

    final fen = _game.fen;
    final best = await _engine.bestMove(fen, moveTimeMs: 700);

    if (best == null) {
      // Fallback: primer movimiento legal en SAN (y obtenemos from/to por verbose)
      final legalSans = _game.moves(); // List<String> SAN
      if (legalSans.isEmpty) return;
      final chosenSan = legalSans.first;

      final mvInfo = _findVerboseMoveBefore(chosenSan);
      final ok = _applyMove(chosenSan);
      if (ok && mvInfo != null) {
        lastMoveSquares = [_sqToIndex(mvInfo.from), _sqToIndex(mvInfo.to)];
      }
      return;
    }

    // Tenemos UCI (e2e4)
    final from = best.substring(0, 2);
    final to = best.substring(2, 4);
    final ok = _game.move({'from': from, 'to': to, 'promotion': 'q'});
    if (ok) {
      lastMoveSquares = [_sqToIndex(from), _sqToIndex(to)];
    }
  }

  /// Aplica un movimiento en UCI o SAN y devuelve si fue válido
  bool _applyMove(String cleaned) {
    if (cleaned.length >= 4 && RegExp(r'^[a-h][1-8][a-h][1-8]').hasMatch(cleaned)) {
      return _game.move({'from': cleaned.substring(0, 2), 'to': cleaned.substring(2, 4), 'promotion': 'q'});
    } else {
      return _game.move(cleaned); // SAN
    }
  }

  /// Busca el movimiento verbose correspondiente al input (UCI o SAN) en la posición ACTUAL,
  /// sin modificarla. Devuelve from/to en notación 'e2','e4'.
  _VerboseMove? _findVerboseMoveBefore(String cleaned) {
    final verbose = _game.moves({'verbose': true}) as List<dynamic>;
    if (cleaned.length >= 4 && RegExp(r'^[a-h][1-8][a-h][1-8]').hasMatch(cleaned)) {
      // UCI
      final from = cleaned.substring(0, 2);
      final to = cleaned.substring(2, 4);
      final match = verbose.cast<Map>().firstWhere(
        (m) => m['from'] == from && m['to'] == to,
        orElse: () => {},
      );
      if (match.isNotEmpty) return _VerboseMove(match['from'] as String, match['to'] as String);
    } else {
      // SAN
      final match = verbose.cast<Map>().firstWhere(
        (m) => (m['san'] as String).replaceAll('+', '').replaceAll('#', '') ==
               cleaned.replaceAll('+', '').replaceAll('#', ''),
        orElse: () => {},
      );
      if (match.isNotEmpty) return _VerboseMove(match['from'] as String, match['to'] as String);
    }
    return null;
  }

  int _sqToIndex(String sq) {
    // a8=0 ... h1=63
    final file = sq.codeUnitAt(0) - 'a'.codeUnitAt(0);
    final rankFromBottom = int.parse(sq[1]); // 1..8
    final rankIndexFromTop = 8 - rankFromBottom; // 0..7
    return rankIndexFromTop * 8 + file;
  }

  void dispose() => textController.dispose();
}

class _VerboseMove {
  final String from;
  final String to;
  _VerboseMove(this.from, this.to);
}
