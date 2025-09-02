enum PieceColor { white, black }

class BoardSquare {
  final String pieceSymbol;
  final bool light;
  final PieceColor? color; // null si no hay pieza

  const BoardSquare({
    required this.pieceSymbol,
    required this.light,
    this.color,
  });
}