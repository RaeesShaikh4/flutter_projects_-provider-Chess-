enum PieceColor {
  white,
  black,
}

enum PieceType {
  pawn,
  rook,
  knight,
  bishop,
  queen,
  king,
}

class Piece {
  final PieceType type;
  final PieceColor color;
  final bool hasMoved;

  const Piece({
    required this.type,
    required this.color,
    this.hasMoved = false,
  });

  Piece copyWith({
    PieceType? type,
    PieceColor? color,
    bool? hasMoved,
  }) {
    return Piece(
      type: type ?? this.type,
      color: color ?? this.color,
      hasMoved: hasMoved ?? this.hasMoved,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Piece &&
        other.type == type &&
        other.color == color &&
        other.hasMoved == hasMoved;
  }

  @override
  int get hashCode => Object.hash(type, color, hasMoved);

  @override
  String toString() {
    return '${color.name} ${type.name}';
  }
}

