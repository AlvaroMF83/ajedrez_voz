// =========================
// lib/src/state/juego_controller.dart
// =========================
import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as ch;
import '../engine/stockfish_service.dart';
import '../ui/board_renderer.dart';
import 'package:ajedrez_voz/src/model/board_square.dart';
import 'package:ajedrez_voz/src/utils/logger.dart';

class JuegoController {
  final TextEditingController textController = TextEditingController();
  final bool playsWhite;
  StockfishService _engine;
  int _skill;

  late ch.Chess _game;
  List<int>? lastMoveSquares;

  JuegoController({
    required this.playsWhite,
    required StockfishService engine,
    required int engineSkill,
  })  : _engine = engine,
        _skill = engineSkill {
    _game = ch.Chess();
    appLog('creado juego controller');
  }

  get currentTurn => _game.turn;


  bool get isAtStartPosition => _game.fen.startsWith('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR');

  Future<void> replaceEngine(StockfishService newEngine, int skill) async {
    await _engine.dispose();
    _engine = newEngine;
    _skill = skill;
    await _engine.setSkillLevel(_skill);
  }


  String _unicodeForPiece(String char) {
    const map = {
      'p': '♟', 'r': '♜', 'n': '♞', 'b': '♝', 'q': '♛', 'k': '♚',
      'P': '♙', 'R': '♖', 'N': '♘', 'B': '♗', 'Q': '♕', 'K': '♔',
    };
    return map[char] ?? '';
  }

  List<List<BoardSquare>> get currentPosition {
    final placement = _game.fen.split(' ').first; // FEN sin extras
    final rows = placement.split('/');            // 8 filas: a8..h8, ..., a1..h1
    final flip = !playsWhite;                     // si juegas con negras => voltear

    // Para la vista: si hay que voltear, recorremos filas al revés
    final ranks = flip ? rows.reversed : rows;

    final out = <List<BoardSquare>>[];
    int r = 0; // índice de fila en la VISTA (después del posible reverse)

    for (final rank in ranks) {
      final row = <BoardSquare>[];
      int fileIndex = 0; // 0..7 en la VISTA (izq->der)

      for (int i = 0; i < rank.length; i++) {
        final c = rank[i];

        if (c.codeUnitAt(0) >= 0x31 && c.codeUnitAt(0) <= 0x38) { // '1'..'8'
          final empty = c.codeUnitAt(0) - 0x30;
          for (int k = 0; k < empty; k++) {
            final light = ((r + fileIndex) % 2 == 0);
            row.add(BoardSquare(pieceSymbol: '', light: light, color: null));
            fileIndex++;
          }
        } else {
          final isWhitePiece = c == c.toUpperCase();
          final symbol = _unicodeForPiece(c);
          final light = ((r + fileIndex) % 2 == 0);
          row.add(BoardSquare(
            pieceSymbol: symbol,
            light: light,
            color: isWhitePiece ? PieceColor.white : PieceColor.black,
          ));
          fileIndex++;
        }
      }

      // 👉 si jugamos con negras, además de invertir el orden de filas,
      //    invertimos el orden de columnas de cada fila
      out.add(flip ? row.reversed.toList() : row);
      r++;
    }

    return out;
  }


  Future<bool> onUserMove(String input) async {
    // ❌ Evita que el jugador mueva cuando no es su turno
    if ('${_game.turn}' != (playsWhite ? 'Color.WHITE' : 'Color.BLACK')) {
    //if (_game.turn != (playsWhite ? 'w' : 'b')) {
      debugPrint("No es tu turno");
      return false;
    }

    final cleaned = input.trim().replaceAll(' ', '');
    final mvInfo = _findVerboseMoveBefore(cleaned);
    final ok = _applyMove(cleaned);

    if (ok) {
      if (mvInfo != null) {
        lastMoveSquares = [_sqToIndex(mvInfo.from), _sqToIndex(mvInfo.to)];
      } else {
        lastMoveSquares = null;
      }
      textController.clear();

      // ✅ Si aún no ha terminado, deja que el engine mueva
      if (!_game.game_over) {
        await onEngineMove();
      }

      return true;
    }

    return false;
  }

  Future<void> onEngineMove() async {
    if (_game.game_over) return;
    final fen = _game.fen;
    final best = await _engine.bestMove(fen, moveTimeMs: 800);
    if (best == null) {
      appLog('primer movimiento legal');
      final legalSans = _game.moves();
      if (legalSans.isEmpty) return;
      final chosenSan = legalSans.first;
      final mvInfo = _findVerboseMoveBefore(chosenSan);
      final ok = _applyMove(chosenSan);
      if (ok && mvInfo != null) {
        lastMoveSquares = [_sqToIndex(mvInfo.from), _sqToIndex(mvInfo.to)];
      }
      return;
    }
    final from = best.substring(0, 2);
    final to = best.substring(2, 4);
    final ok = _game.move({'from': from, 'to': to, 'promotion': 'q'});
    if (ok) {
      lastMoveSquares = [_sqToIndex(from), _sqToIndex(to)];
    }
  }

  bool _applyMove(String cleaned) {
    if (cleaned.length >= 4 && RegExp(r'^[a-h][1-8][a-h][1-8]').hasMatch(cleaned)) {
      return _game.move({'from': cleaned.substring(0, 2), 'to': cleaned.substring(2, 4), 'promotion': 'q'});
    } else {
      return _game.move(cleaned);
    }
  }

  _VerboseMove? _findVerboseMoveBefore(String cleaned) {
    final verbose = _game.moves({'verbose': true}) as List<dynamic>;
    if (cleaned.length >= 4 && RegExp(r'^[a-h][1-8][a-h][1-8]').hasMatch(cleaned)) {
      final from = cleaned.substring(0, 2);
      final to = cleaned.substring(2, 4);
      final match = verbose.cast<Map>().firstWhere(
        (m) => m['from'] == from && m['to'] == to,
        orElse: () => {},
      );
      if (match.isNotEmpty) return _VerboseMove(match['from'] as String, match['to'] as String);
    } else {
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
    final file = sq.codeUnitAt(0) - 'a'.codeUnitAt(0);
    final rankFromBottom = int.parse(sq[1]);
    final rankIndexFromTop = 8 - rankFromBottom;
    return rankIndexFromTop * 8 + file;
  }

  void dispose() => textController.dispose();
  
  Future<void> resetGame() async {
    _game = ch.Chess();
    lastMoveSquares = null;
    textController.clear();

    if (!playsWhite) {
      await onEngineMove();
    }
  }

}

class _VerboseMove {
  final String from;
  final String to;
  _VerboseMove(this.from, this.to);
}
