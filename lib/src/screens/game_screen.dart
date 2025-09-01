// =========================
// lib/src/screens/game_screen.dart
// =========================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../settings/settings_controller.dart';
import '../settings/localization_service.dart';
import '../state/juego_controller.dart';
import '../ui/board_renderer.dart';
import '../routes.dart';
import 'choose_color_screen.dart';

class GameScreen extends StatefulWidget {
  final PlayerColor? playerColor;
  const GameScreen({super.key, this.playerColor});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final JuegoController _controller;

  @override
  void initState() {
    super.initState();
    _controller = JuegoController(
      playsWhite: (widget.playerColor ?? PlayerColor.white) == PlayerColor.white,
    );
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final t = LocalizationService.t(context);
    final settings = context.watch<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(t.game),
        actions: [
          IconButton(
            tooltip: t.settings,
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: BoardRenderer(
                  position: _controller.currentPosition,   // ← ahora pasa la posición real
                  lastMove: _controller.lastMoveSquares,
                  visualMode: settings.visualMode,
                  perspectiveWhite: _controller.playsWhite,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller.textController,
                    decoration: InputDecoration(
                      hintText: t.moveHint,
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (v) async {
                      await _controller.onUserMove(v);
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () async {
                    await _controller.onEngineMove();
                    setState(() {});
                  },
                  child: Text(t.playEngine),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

