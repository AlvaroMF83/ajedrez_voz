// =========================
// lib/src/ui/board_renderer.dart
// =========================
import 'package:flutter/material.dart';
import '../settings/settings_controller.dart';

class BoardSquare {
  final String? piece; // letra FEN / null
  BoardSquare(this.piece);
  bool get occupied => piece != null;
  bool get isWhite => occupied && piece! == piece!.toUpperCase();
}

class BoardRenderer extends StatelessWidget {
  final List<BoardSquare> position; // 64 squares, a8..h1
  final List<int>? lastMove;        // indices [from,to]
  final VisualMode visualMode;
  final bool perspectiveWhite;

  const BoardRenderer({
    super.key,
    required this.position,
    required this.lastMove,
    required this.visualMode,
    required this.perspectiveWhite,
  });

  static const _unicode = {
    'P': '♙', 'N': '♘', 'B': '♗', 'R': '♖', 'Q': '♕', 'K': '♔',
    'p': '♟', 'n': '♞', 'b': '♝', 'r': '♜', 'q': '♛', 'k': '♚',
  };

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      reverse: !perspectiveWhite,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
      itemCount: 64,
      itemBuilder: (context, index) {
        final file = index % 8;
        final rank = index ~/ 8;
        final light = (file + rank) % 2 == 0;
        final isLast = lastMove != null && lastMove!.contains(index);
        final sq = position[index];

        return Container(
          decoration: BoxDecoration(
            color: isLast
                ? Colors.amber.withOpacity(0.6)
                : (light ? Colors.brown.shade200 : Colors.brown.shade600),
            border: Border.all(width: 0.5, color: Colors.black26),
          ),
          child: _buildCell(context, sq),
        );
      },
    );
  }

  Widget _buildCell(BuildContext context, BoardSquare sq) {
    switch (visualMode) {
      case VisualMode.normal:
        if (!sq.occupied) return const SizedBox();
        final ch = _unicode[sq.piece!];
        return Center(child: Text(ch ?? '', style: const TextStyle(fontSize: 28)));
      case VisualMode.sameColorPieces:
        return sq.occupied ? Center(child: _disc(filled: true)) : const SizedBox();
      case VisualMode.coloredDiscs:
        return sq.occupied ? Center(child: _disc(filled: true, white: sq.isWhite)) : const SizedBox();
      case VisualMode.monochromeDiscs:
        return sq.occupied ? Center(child: _disc(filled: false)) : const SizedBox();
      case VisualMode.noPieces:
        return const SizedBox();
    }
  }

  Widget _disc({required bool filled, bool? white}) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled
            ? (white == null ? Colors.black87 : (white ? Colors.white : Colors.black))
            : Colors.transparent,
        border: Border.all(color: Colors.black87, width: 2),
      ),
    );
  }
}
