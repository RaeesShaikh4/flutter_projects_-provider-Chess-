import 'dart:math';
import '../models/piece.dart';
import '../models/position.dart';
import '../models/move.dart';

enum GameState {
  playing,
  checkmate,
  stalemate,
  draw,
}

class ChessGame {
  late List<List<Piece?>> board;
  PieceColor currentPlayer = PieceColor.white;
  GameState gameState = GameState.playing;
  List<Move> moveHistory = [];
  Position? enPassantTarget;

  ChessGame() {
    _initializeBoard();
  }

  void _initializeBoard() {
    board = List.generate(8, (row) => List.generate(8, (col) => null));

    for (int col = 0; col < 8; col++) {
      board[1][col] = Piece(type: PieceType.pawn, color: PieceColor.black);
      board[6][col] = Piece(type: PieceType.pawn, color: PieceColor.white);
    }

    final pieceOrder = [
      PieceType.rook,
      PieceType.knight,
      PieceType.bishop,
      PieceType.queen,
      PieceType.king,
      PieceType.bishop,
      PieceType.knight,
      PieceType.rook,
    ];

    for (int col = 0; col < 8; col++) {
      board[0][col] = Piece(type: pieceOrder[col], color: PieceColor.black);
      board[7][col] = Piece(type: pieceOrder[col], color: PieceColor.white);
    }
  }

  Piece? getPieceAt(Position position) {
    if (!position.isValid) return null;
    return board[position.row][position.col];
  }

  void setPieceAt(Position position, Piece? piece) {
    if (!position.isValid) return;
    board[position.row][position.col] = piece;
  }

  List<Position> getValidMoves(Position from) {
    final piece = getPieceAt(from);
    if (piece == null || piece.color != currentPlayer) return [];

    List<Position> moves = [];
    final directions = _getPieceDirections(piece.type);

    for (final direction in directions) {
      Position current = from + direction;
      int steps = 0;

      while (current.isValid && steps < _getMaxSteps(piece.type)) {
        final targetPiece = getPieceAt(current);

        if (targetPiece == null) {
          moves.add(current);
        } else if (targetPiece.color != piece.color) {
          moves.add(current);
          break;
        } else {
          break;
        }

        if (!_isSlidingPiece(piece.type)) break;
        current = current + direction;
        steps++;
      }
    }

    if (piece.type == PieceType.pawn) {
      moves.addAll(_getPawnMoves(from, piece));
    }

    if (piece.type == PieceType.king) {
      moves.addAll(_getCastlingMoves(from, piece));
    }

    return moves.where((move) => !wouldBeInCheck(from, move)).toList();
  }

  List<Position> _getPawnMoves(Position from, Piece piece) {
    List<Position> moves = [];
    final direction = piece.color == PieceColor.white ? -1 : 1;
    final startRow = piece.color == PieceColor.white ? 6 : 1;

    final forward = Position(from.row + direction, from.col);
    if (forward.isValid && getPieceAt(forward) == null) {
      moves.add(forward);

      if (from.row == startRow) {
        final doubleForward = Position(from.row + 2 * direction, from.col);
        if (doubleForward.isValid && getPieceAt(doubleForward) == null) {
          moves.add(doubleForward);
        }
      }
    }

    for (final colOffset in [-1, 1]) {
      final diagonal = Position(from.row + direction, from.col + colOffset);
      if (diagonal.isValid) {
        final targetPiece = getPieceAt(diagonal);
        if (targetPiece != null && targetPiece.color != piece.color) {
          moves.add(diagonal);
        }
        else if (enPassantTarget == diagonal) {
          moves.add(diagonal);
        }
      }
    }

    return moves;
  }

  List<Position> _getCastlingMoves(Position from, Piece king) {
    List<Position> moves = [];
    if (king.hasMoved || _isInCheck(king.color)) return moves;

    final row = from.row;
    final kingSide = getPieceAt(Position(row, 7));
    final queenSide = getPieceAt(Position(row, 0));

    if (kingSide != null &&
        kingSide.type == PieceType.rook &&
        !kingSide.hasMoved &&
        getPieceAt(Position(row, 5)) == null &&
        getPieceAt(Position(row, 6)) == null) {
      moves.add(Position(row, 6));
    }

    if (queenSide != null &&
        queenSide.type == PieceType.rook &&
        !queenSide.hasMoved &&
        getPieceAt(Position(row, 1)) == null &&
        getPieceAt(Position(row, 2)) == null &&
        getPieceAt(Position(row, 3)) == null) {
      moves.add(Position(row, 2));
    }

    return moves;
  }

  List<Position> _getPieceDirections(PieceType type) {
    switch (type) {
      case PieceType.pawn:
        return [];
      case PieceType.rook:
        return [
          Position(-1, 0),
          Position(1, 0),
          Position(0, -1),
          Position(0, 1)
        ];
      case PieceType.bishop:
        return [
          Position(-1, -1),
          Position(-1, 1),
          Position(1, -1),
          Position(1, 1)
        ];
      case PieceType.queen:
        return [
          Position(-1, 0),
          Position(1, 0),
          Position(0, -1),
          Position(0, 1),
          Position(-1, -1),
          Position(-1, 1),
          Position(1, -1),
          Position(1, 1)
        ];
      case PieceType.king:
        return [
          Position(-1, -1),
          Position(-1, 0),
          Position(-1, 1),
          Position(0, -1),
          Position(0, 1),
          Position(1, -1),
          Position(1, 0),
          Position(1, 1)
        ];
      case PieceType.knight:
        return [
          Position(-2, -1),
          Position(-2, 1),
          Position(-1, -2),
          Position(-1, 2),
          Position(1, -2),
          Position(1, 2),
          Position(2, -1),
          Position(2, 1)
        ];
    }
  }

  int _getMaxSteps(PieceType type) {
    switch (type) {
      case PieceType.pawn:
      case PieceType.king:
      case PieceType.knight:
        return 1;
      case PieceType.rook:
      case PieceType.bishop:
      case PieceType.queen:
        return 7;
    }
  }

  bool _isSlidingPiece(PieceType type) {
    return type == PieceType.rook ||
        type == PieceType.bishop ||
        type == PieceType.queen;
  }

  bool wouldBeInCheck(Position from, Position to) {
    final originalPiece = getPieceAt(to);
    final movingPiece = getPieceAt(from);

    setPieceAt(to, movingPiece);
    setPieceAt(from, null);

    final inCheck = _isInCheck(currentPlayer);

    setPieceAt(from, movingPiece);
    setPieceAt(to, originalPiece);

    return inCheck;
  }

  bool _isInCheck(PieceColor color) {
    final kingPosition = _findKing(color);
    if (kingPosition == null) return false;

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = getPieceAt(Position(row, col));
        if (piece != null && piece.color != color) {
          final moves = _getRawMoves(Position(row, col), piece);
          if (moves.contains(kingPosition)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  List<Position> _getRawMoves(Position from, Piece piece) {
    List<Position> moves = [];
    final directions = _getPieceDirections(piece.type);

    for (final direction in directions) {
      Position current = from + direction;
      int steps = 0;

      while (current.isValid && steps < _getMaxSteps(piece.type)) {
        final targetPiece = getPieceAt(current);

        if (targetPiece == null) {
          moves.add(current);
        } else if (targetPiece.color != piece.color) {
          moves.add(current);
          break;
        } else {
          break;
        }

        if (!_isSlidingPiece(piece.type)) break;
        current = current + direction;
        steps++;
      }
    }

    if (piece.type == PieceType.pawn) {
      moves.addAll(_getPawnMoves(from, piece));
    }

    return moves;
  }

  Position? _findKing(PieceColor color) {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = getPieceAt(Position(row, col));
        if (piece != null &&
            piece.type == PieceType.king &&
            piece.color == color) {
          return Position(row, col);
        }
      }
    }
    return null;
  }

  bool makeMove(Position from, Position to) {
    final piece = getPieceAt(from);
    if (piece == null || piece.color != currentPlayer) return false;

    final validMoves = getValidMoves(from);
    if (!validMoves.contains(to)) return false;

    final capturedPiece = getPieceAt(to);
    final move = Move(
      from: from,
      to: to,
      capturedPiece: capturedPiece,
    );

    setPieceAt(to, piece.copyWith(hasMoved: true));
    setPieceAt(from, null);

    if (piece.type == PieceType.pawn && (to.row == 0 || to.row == 7)) {
      setPieceAt(
          to, Piece(type: PieceType.queen, color: piece.color, hasMoved: true));
    }

    if (piece.type == PieceType.king && (to.col - from.col).abs() == 2) {
      final rookCol = to.col > from.col ? 7 : 0;
      final rook = getPieceAt(Position(from.row, rookCol));
      if (rook != null) {
        setPieceAt(Position(from.row, rookCol), null);
        setPieceAt(Position(from.row, to.col > from.col ? 5 : 3),
            rook.copyWith(hasMoved: true));
      }
    }

    moveHistory.add(move);
    currentPlayer =
        currentPlayer == PieceColor.white ? PieceColor.black : PieceColor.white;

    _updateGameState();

    return true;
  }

  void _updateGameState() {
    final hasValidMoves = _hasValidMoves(currentPlayer);
    final inCheck = _isInCheck(currentPlayer);

    if (!hasValidMoves) {
      if (inCheck) {
        gameState = GameState.checkmate;
      } else {
        gameState = GameState.stalemate;
      }
    } else {
      gameState = GameState.playing;
    }
  }

  bool _hasValidMoves(PieceColor color) {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = getPieceAt(Position(row, col));
        if (piece != null && piece.color == color) {
          final moves = getValidMoves(Position(row, col));
          if (moves.isNotEmpty) return true;
        }
      }
    }
    return false;
  }

  void reset() {
    _initializeBoard();
    currentPlayer = PieceColor.white;
    gameState = GameState.playing;
    moveHistory.clear();
    enPassantTarget = null;
  }

  Move? getRandomValidMove() {
    List<Move> allMoves = [];

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = getPieceAt(Position(row, col));
        if (piece != null && piece.color == currentPlayer) {
          final validMoves = getValidMoves(Position(row, col));
          for (final move in validMoves) {
            allMoves.add(Move(from: Position(row, col), to: move));
          }
        }
      }
    }

    if (allMoves.isEmpty) return null;

    final random = Random();
    return allMoves[random.nextInt(allMoves.length)];
  }
}
