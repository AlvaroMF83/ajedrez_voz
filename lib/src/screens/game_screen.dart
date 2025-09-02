// =========================
// lib/src/screens/game_screen.dart
// =========================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ajedrez_voz/src/settings/settings_models.dart';
import 'package:ajedrez_voz/src/settings/settings_state.dart';
import 'package:ajedrez_voz/src/ui/board_renderer.dart';
import 'package:ajedrez_voz/src/state/juego_controller.dart';
import 'package:ajedrez_voz/src/engine/stockfish_service.dart';
import 'dart:math';
import 'package:ajedrez_voz/src/utils/logger.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, this.playerColor});
  final PlayerColor? playerColor;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late JuegoController _controller;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsState>();

    final isWhite = switch (widget.playerColor) {
      PlayerColor.white => true,
      PlayerColor.black => false,
      PlayerColor.random => Random().nextBool(),
      null => true, // por defecto
    };

    _controller = JuegoController(
      playsWhite: isWhite,
      engine: StockfishService(mode: EngineMode.stockfishOnly),
      engineSkill: settings.engineSkill,
    );

    _initController(settings);

  }

  Future<void> _initController(SettingsState settings) async {
    await _controller.replaceEngine(
      StockfishService(mode: EngineMode.stockfishOnly),
      settings.engineSkill,
    );

    await _controller.resetGame();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsState>();
    final colorLabel = switch (widget.playerColor) {
      PlayerColor.white => "Blancas",
      PlayerColor.black => "Negras",
      PlayerColor.random => "Aleatorio",
      _ => "Auto",
    };

    return Scaffold(
      appBar: AppBar(title: const Text("Partida")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text("Juegas con: $colorLabel"),
            Text(
              "Turno de: ${'${_controller.currentTurn}' == 'Color.WHITE' ? 'Blancas' : 'Negras'}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // ⬇️ TABLERO adaptado al ancho disponible
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.biggest.shortestSide;
                  return Center(
                    child: SizedBox(
                      width: size,
                      height: size,
                      child: BoardRenderer(
                        visualMode: s.visualMode,
                        board: _controller.currentPosition,
                        onSquareTap: (row, col) {
                          setState(() {
                            _handleTap(row, col);
                          });
                        },
                        lastMoveSquares: _controller.lastMoveSquares,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // ⌨️ Entrada de jugadas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextField(
                controller: _controller.textController,
                decoration: const InputDecoration(hintText: 'Introduce jugada: e4 o e2e4'),
                onSubmitted: (text) async {
                  final moved = await _controller.onUserMove(text);
                  if (moved) setState(() {});
                },
              ),
            ),

            const SizedBox(height: 12),

            // 🕹️ Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() {
                    _controller.resetGame();
                  }),
                  child: const Text("Empezar partida"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _resignGame,
                  child: const Text("Rendirse"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? _fromSquare;

  String _squareFromTap(int row, int col, {required bool isFlipped}) {
    final r = isFlipped ? 7 - row : row;
    final c = isFlipped ? 7 - col : col;
    final file = String.fromCharCode('a'.codeUnitAt(0) + c); // a..h
    final rank = (8 - r).toString();                          // 8..1
    return '$file$rank';                                      // e.g. "e2"
  }

  void _handleTap(int row, int col) {
    // Usa el mismo flag que empleas para dibujar el tablero volteado.
    final sq = _squareFromTap(row, col, isFlipped: !_controller.playsWhite);

    if (_fromSquare == null) {
      _fromSquare = sq;
    } else {
      final move = '$_fromSquare$sq';
      _fromSquare = null;
      _controller.onUserMove(move).then((moved) {
        if (moved) setState(() {});
      });
    }
    
  }

  void _resignGame() {
    debugPrint("Jugador se rinde");
  }
}
