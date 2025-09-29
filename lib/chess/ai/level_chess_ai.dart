import '../models/move.dart';
import '../models/position.dart';
import '../models/piece.dart';
import '../game/chess_game.dart';

abstract class LevelChessAI {
  final int difficulty;

  LevelChessAI(this.difficulty);

  Move? getBestMove(ChessGame game);

  static LevelChessAI createAI(int difficulty) {
    if (difficulty <= 2) {
      return RandomChessAI(difficulty);
    } else if (difficulty <= 5) {
      return SimpleChessAI(difficulty);
    } else if (difficulty <= 8) {
      return IntermediateChessAI(difficulty);
    } else {
      return AdvancedChessAI(difficulty);
    }
  }
}

class RandomChessAI extends LevelChessAI {
  RandomChessAI(super.difficulty);

  @override
  Move? getBestMove(ChessGame game) {
    return game.getRandomValidMove();
  }
}

class SimpleChessAI extends LevelChessAI {
  SimpleChessAI(super.difficulty);

  @override
  Move? getBestMove(ChessGame game) {
    final allMoves = _getAllValidMoves(game);
    if (allMoves.isEmpty) return null;

    // Sort moves by priority
    allMoves.sort((a, b) {
      final scoreA = _evaluateMove(a, game);
      final scoreB = _evaluateMove(b, game);
      return scoreB.compareTo(scoreA);
    });

    // Add some randomness based on difficulty
    final randomFactor = (10 - difficulty) / 10.0;
    final topMoves = (allMoves.length * (0.3 + randomFactor * 0.4)).round();
    final selectedMoves = allMoves.take(topMoves).toList();

    if (selectedMoves.isEmpty) return allMoves.first;

    final random = DateTime.now().millisecondsSinceEpoch % selectedMoves.length;
    return selectedMoves[random];
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

class IntermediateChessAI extends LevelChessAI {
  IntermediateChessAI(super.difficulty);

  @override
  Move? getBestMove(ChessGame game) {
    final allMoves = _getAllValidMoves(game);
    if (allMoves.isEmpty) return null;

    // Evaluate all moves with lookahead
    final evaluatedMoves = allMoves.map((move) {
      final score = _evaluateMoveWithLookahead(move, game, 2);
      return MapEntry(move, score);
    }).toList();

    evaluatedMoves.sort((a, b) => b.value.compareTo(a.value));

    // Select from top moves with some randomness
    final topPercentage = 0.2 + (difficulty - 5) * 0.1;
    final topCount = (evaluatedMoves.length * topPercentage).round();
    final topMoves = evaluatedMoves.take(topCount).map((e) => e.key).toList();

    if (topMoves.isEmpty) return allMoves.first;

    final random = DateTime.now().millisecondsSinceEpoch % topMoves.length;
    return topMoves[random];
  }

  int _evaluateMoveWithLookahead(Move move, ChessGame game, int depth) {
    if (depth == 0) return _evaluatePosition(game);

    // Simulate the move
    final originalPiece = game.getPieceAt(move.to);
    final movingPiece = game.getPieceAt(move.from);

    game.setPieceAt(move.to, movingPiece);
    game.setPieceAt(move.from, null);

    int score = _evaluatePosition(game);

    // Look ahead for opponent's best response
    if (depth > 1) {
      final opponentMoves = _getAllValidMoves(game);
      if (opponentMoves.isNotEmpty) {
        final bestOpponentScore = opponentMoves.map((opponentMove) {
          return _evaluateMoveWithLookahead(opponentMove, game, depth - 1);
        }).reduce((a, b) => a > b ? a : b);
        score -= bestOpponentScore ~/ 2;
      }
    }

    // Restore the board
    game.setPieceAt(move.from, movingPiece);
    game.setPieceAt(move.to, originalPiece);

    return score;
  }

  int _evaluatePosition(ChessGame game) {
    int score = 0;

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = game.getPieceAt(Position(row, col));
        if (piece != null) {
          final pieceValue = _getPieceValue(piece.type);
          final positionValue =
              _getPositionValue(piece.type, Position(row, col));
          final multiplier = piece.color == game.currentPlayer ? 1 : -1;
          score += (pieceValue + positionValue) * multiplier;
        }
      }
    }

    return score;
  }

  int _getPositionValue(PieceType type, Position position) {
    // Position values for different pieces
    switch (type) {
      case PieceType.pawn:
        return _getPawnPositionValue(position);
      case PieceType.knight:
        return _getKnightPositionValue(position);
      case PieceType.bishop:
        return _getBishopPositionValue(position);
      case PieceType.rook:
        return _getRookPositionValue(position);
      case PieceType.queen:
        return _getQueenPositionValue(position);
      case PieceType.king:
        return _getKingPositionValue(position);
    }
  }

  int _getPawnPositionValue(Position position) {
    // Pawns are better in center and when advanced
    final centerDistance = _getCenterDistance(position);
    return (4 - centerDistance) + (7 - position.row);
  }

  int _getKnightPositionValue(Position position) {
    // Knights are better in center
    final centerDistance = _getCenterDistance(position);
    return (4 - centerDistance) * 2;
  }

  int _getBishopPositionValue(Position position) {
    // Bishops are better on long diagonals
    final centerDistance = _getCenterDistance(position);
    return (4 - centerDistance);
  }

  int _getRookPositionValue(Position position) {
    // Rooks are better on open files
    return 0; // Simplified
  }

  int _getQueenPositionValue(Position position) {
    // Queen is flexible, center is good
    final centerDistance = _getCenterDistance(position);
    return (4 - centerDistance);
  }

  int _getKingPositionValue(Position position) {
    // King safety is more important than position
    return 0; // Simplified
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

class AdvancedChessAI extends LevelChessAI {
  AdvancedChessAI(super.difficulty);

  @override
  Move? getBestMove(ChessGame game) {
    final allMoves = _getAllValidMoves(game);
    if (allMoves.isEmpty) return null;

    // Use minimax with alpha-beta pruning
    final depth = 3 + (difficulty - 8);
    final bestMove = _minimax(game, depth, true, -10000, 10000);

    return bestMove.move;
  }

  _MinimaxResult _minimax(
      ChessGame game, int depth, bool maximizingPlayer, int alpha, int beta) {
    if (depth == 0) {
      return _MinimaxResult(null, _evaluatePosition(game));
    }

    final moves = _getAllValidMoves(game);
    if (moves.isEmpty) {
      return _MinimaxResult(null, _evaluatePosition(game));
    }

    Move? bestMove;
    int bestScore = maximizingPlayer ? -10000 : 10000;

    for (final move in moves) {
      // Simulate move
      final originalPiece = game.getPieceAt(move.to);
      final movingPiece = game.getPieceAt(move.from);

      game.setPieceAt(move.to, movingPiece);
      game.setPieceAt(move.from, null);

      final result = _minimax(game, depth - 1, !maximizingPlayer, alpha, beta);

      // Restore board
      game.setPieceAt(move.from, movingPiece);
      game.setPieceAt(move.to, originalPiece);

      if (maximizingPlayer) {
        if (result.score > bestScore) {
          bestScore = result.score;
          bestMove = move;
        }
        alpha = alpha > bestScore ? alpha : bestScore;
      } else {
        if (result.score < bestScore) {
          bestScore = result.score;
          bestMove = move;
        }
        beta = beta < bestScore ? beta : bestScore;
      }

      if (beta <= alpha) break; // Alpha-beta pruning
    }

    return _MinimaxResult(bestMove, bestScore);
  }

  int _evaluatePosition(ChessGame game) {
    int score = 0;

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = game.getPieceAt(Position(row, col));
        if (piece != null) {
          final pieceValue = _getPieceValue(piece.type);
          final positionValue =
              _getPositionValue(piece.type, Position(row, col));
          final multiplier = piece.color == game.currentPlayer ? 1 : -1;
          score += (pieceValue + positionValue) * multiplier;
        }
      }
    }

    return score;
  }

  int _getPositionValue(PieceType type, Position position) {
    // More sophisticated position evaluation
    switch (type) {
      case PieceType.pawn:
        return _getPawnPositionValue(position);
      case PieceType.knight:
        return _getKnightPositionValue(position);
      case PieceType.bishop:
        return _getBishopPositionValue(position);
      case PieceType.rook:
        return _getRookPositionValue(position);
      case PieceType.queen:
        return _getQueenPositionValue(position);
      case PieceType.king:
        return _getKingPositionValue(position);
    }
  }

  int _getPawnPositionValue(Position position) {
    final centerDistance = _getCenterDistance(position);
    return (4 - centerDistance) + (7 - position.row) * 2;
  }

  int _getKnightPositionValue(Position position) {
    final centerDistance = _getCenterDistance(position);
    return (4 - centerDistance) * 3;
  }

  int _getBishopPositionValue(Position position) {
    final centerDistance = _getCenterDistance(position);
    return (4 - centerDistance) * 2;
  }

  int _getRookPositionValue(Position position) {
    return 0; // Simplified
  }

  int _getQueenPositionValue(Position position) {
    final centerDistance = _getCenterDistance(position);
    return (4 - centerDistance) * 2;
  }

  int _getKingPositionValue(Position position) {
    return 0; // Simplified
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

class _MinimaxResult {
  final Move? move;
  final int score;

  _MinimaxResult(this.move, this.score);
}
