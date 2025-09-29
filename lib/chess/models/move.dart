import 'position.dart';
import 'piece.dart';

class Move {
  final Position from;
  final Position to;
  final Piece? capturedPiece;
  final Piece? promotedPiece;
  final bool isCastling;
  final bool isEnPassant;

  const Move({
    required this.from,
    required this.to,
    this.capturedPiece,
    this.promotedPiece,
    this.isCastling = false,
    this.isEnPassant = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Move &&
        other.from == from &&
        other.to == to &&
        other.capturedPiece == capturedPiece &&
        other.promotedPiece == promotedPiece &&
        other.isCastling == isCastling &&
        other.isEnPassant == isEnPassant;
  }

  @override
  int get hashCode => Object.hash(
      from, to, capturedPiece, promotedPiece, isCastling, isEnPassant);

  @override
  String toString() {
    return '${from.toAlgebraic()} -> ${to.toAlgebraic()}';
  }
}

