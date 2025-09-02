import 'package:flutter/material.dart';
import 'package:ajedrez_voz/src/settings/settings_models.dart';
import 'package:ajedrez_voz/src/model/board_square.dart';

class BoardRenderer extends StatelessWidget {
  final VisualMode visualMode;
  final List<List<BoardSquare>> board; // 8x8
  final void Function(int row, int col)? onSquareTap;
  final int? selectedRow;
  final int? selectedCol;
  final List<int>? lastMoveSquares;

  const BoardRenderer({
    super.key,
    required this.visualMode,
    required this.board,
    this.onSquareTap,
    this.selectedRow,
    this.selectedCol,
    this.lastMoveSquares,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int r = 0; r < 8; r++)
          Expanded(
            child: Row(
              children: [
                for (int c = 0; c < 8; c++)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onSquareTap?.call(r, c),
                      child: _buildCell(context, board[r][c], r, c),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCell(BuildContext context, BoardSquare sq, int row, int col) {
    final isSelected = selectedRow == row && selectedCol == col;
    final index = row * 8 + col;
    final isHighlighted = lastMoveSquares?.contains(index) ?? false;

    final background = isSelected
      ? Colors.yellow.withOpacity(0.5)
      : isHighlighted
          ? Colors.orange.withOpacity(0.4)
          : (sq.light ? const Color(0xFFF0D9B5) : const Color(0xFFB58863));

    switch (visualMode) {
      case VisualMode.normal:
        return _cell(
          background: background,
          child: Text(
            sq.pieceSymbol,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24),
          ),
        );
      case VisualMode.sameColorPieces:
        return _cell(
          background: background,
          child: const Text("●", textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
        );
      case VisualMode.coloredDiscs:
        return _cell(
          background: background,
          child: Icon(Icons.circle, size: 16, color: _discColor(sq.pieceSymbol)),
        );
      case VisualMode.monochromeDiscs:
        return _cell(
          background: background,
          child: const Icon(Icons.circle, size: 16),
        );
      case VisualMode.noPieces:
        return _cell(background: background);
    }
  }

  Color _discColor(String symbol) {
    if (symbol.isEmpty) return Colors.transparent;
    final isWhite = symbol == symbol.toUpperCase();
    return isWhite ? Colors.blue : Colors.red;
  }

  Widget _cell({required Color background, Widget? child}) {
    return Container(
      decoration: BoxDecoration(color: background),
      child: Center(child: child ?? const SizedBox.shrink()),
    );
  }
}
