import '../models/move.dart';
import '../models/position.dart';
import '../models/piece.dart';
import '../game/chess_game.dart';

abstract class ChessAI {
  Move? getBestMove(ChessGame game);
}

class RandomChessAI implements ChessAI {
  @override
  Move? getBestMove(ChessGame game) {
    return game.getRandomValidMove();
  }
}

class SimpleChessAI implements ChessAI {
  @override
  Move? getBestMove(ChessGame game) {
    final randomMove = game.getRandomValidMove();
    if (randomMove == null) return null;

    // Simple evaluation: prefer captures and center control
    final allMoves = _getAllValidMoves(game);
    if (allMoves.isEmpty) return null;

    // Sort moves by priority
    allMoves.sort((a, b) {
      final scoreA = _evaluateMove(a, game);
      final scoreB = _evaluateMove(b, game);
      return scoreB.compareTo(scoreA);
    });

    // Return the best move, or random if multiple moves have the same score
    final bestScore = _evaluateMove(allMoves.first, game);
    final bestMoves = allMoves
        .where((move) => _evaluateMove(move, game) == bestScore)
        .toList();

    if (bestMoves.length == 1) return bestMoves.first;

    // Random selection among best moves
    final random = DateTime.now().millisecondsSinceEpoch % bestMoves.length;
    return bestMoves[random];
  }

  List<Move> _getAllValidMoves(ChessGame game) {
    List<Move> moves = [];

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = game.getPieceAt(Position(row, col));
        if (piece != null && piece.color == game.currentPlayer) {
          final validMoves = game.getValidMoves(Position(row, col));
          for (final move in validMoves) {
            moves.add(Move(from: Position(row, col), to: move));
          }
        }
      }
    }

    return moves;
  }

  int _evaluateMove(Move move, ChessGame game) {
    int score = 0;

    // Prefer captures
    final capturedPiece = game.getPieceAt(move.to);
    if (capturedPiece != null) {
      score += _getPieceValue(capturedPiece.type);
    }

    // Prefer center control
    final centerDistance = _getCenterDistance(move.to);
    score += (4 - centerDistance) * 2;

    // Prefer moves that don't put own king in check
    if (!game.wouldBeInCheck(move.from, move.to)) {
      score += 10;
    }

    return score;
  }

  int _getPieceValue(PieceType type) {
    switch (type) {
      case PieceType.pawn:
        return 1;
      case PieceType.knight:
      case PieceType.bishop:
        return 3;
      case PieceType.rook:
        return 5;
      case PieceType.queen:
        return 9;
      case PieceType.king:
        return 100;
    }
  }

  int _getCenterDistance(Position position) {
    final centerRow = 3.5;
    final centerCol = 3.5;
    final rowDiff = (position.row - centerRow).abs();
    final colDiff = (position.col - centerCol).abs();
    return (rowDiff + colDiff).round();
  }
}
