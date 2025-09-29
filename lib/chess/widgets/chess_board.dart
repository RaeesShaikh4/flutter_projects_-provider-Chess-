import 'package:flutter/material.dart';
import '../models/piece.dart';
import '../models/position.dart';
import '../game/chess_game.dart';

class ChessBoard extends StatefulWidget {
  final ChessGame game;
  final Function(Position, Position) onMove;
  final Position? selectedPosition;
  final List<Position> validMoves;
  final Position? lastMoveFrom;
  final Position? lastMoveTo;

  const ChessBoard({
    super.key,
    required this.game,
    required this.onMove,
    this.selectedPosition,
    this.validMoves = const [],
    this.lastMoveFrom,
    this.lastMoveTo,
  });

  @override
  State<ChessBoard> createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard> with TickerProviderStateMixin {
  Position? _hoveredPosition;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.brown[800]!, width: 3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              itemCount: 64,
              itemBuilder: (context, index) {
                final row = index ~/ 8;
                final col = index % 8;
                final position = Position(row, col);
                final piece = widget.game.getPieceAt(position);
                final isLight = (row + col) % 2 == 0;
                final isSelected = widget.selectedPosition == position;
                final isValidMove = widget.validMoves.contains(position);
                final isHovered = _hoveredPosition == position;
                final isLastMove = (widget.lastMoveFrom == position ||
                    widget.lastMoveTo == position);

                return _buildAnimatedSquare(
                  position: position,
                  piece: piece,
                  isLight: isLight,
                  isSelected: isSelected,
                  isValidMove: isValidMove,
                  isHovered: isHovered,
                  isLastMove: isLastMove,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSquare({
    required Position position,
    required Piece? piece,
    required bool isLight,
    required bool isSelected,
    required bool isValidMove,
    required bool isHovered,
    required bool isLastMove,
  }) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _glowController]),
      builder: (context, child) {
        return GestureDetector(
          onTap: () => _handleSquareTap(position),
          child: DragTarget<Position>(
            onWillAcceptWithDetails: (details) {
              return widget.validMoves.contains(position);
            },
            onAcceptWithDetails: (details) {
              widget.onMove(details.data, position);
            },
            builder: (context, candidateData, rejectedData) {
              return Container(
                decoration: _buildSquareDecoration(
                  isLight: isLight,
                  isSelected: isSelected,
                  isValidMove: isValidMove,
                  isHovered: isHovered,
                  isLastMove: isLastMove,
                  candidateData: candidateData,
                ),
                child: Stack(
                  children: [
                    // Square background with animations
                    _buildSquareBackground(isLight, isLastMove),

                    // Valid move indicator
                    if (isValidMove) _buildValidMoveIndicator(),

                    // Selected piece glow
                    if (isSelected) _buildSelectionGlow(),

                    // Piece with animations
                    if (piece != null)
                      _buildAnimatedPiece(piece, position, isSelected),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  BoxDecoration _buildSquareDecoration({
    required bool isLight,
    required bool isSelected,
    required bool isValidMove,
    required bool isHovered,
    required bool isLastMove,
    required List<Position?> candidateData,
  }) {
    Color baseColor = isLight ? Colors.brown[200]! : Colors.brown[400]!;

    if (isSelected) {
      baseColor = Colors.yellow.withOpacity(0.7);
    } else if (isHovered) {
      baseColor = Colors.blue.withOpacity(0.5);
    } else if (isValidMove) {
      baseColor = Colors.green.withOpacity(0.3);
    } else if (isLastMove) {
      baseColor = Colors.orange.withOpacity(0.4);
    }

    return BoxDecoration(
      color: baseColor,
      border: isSelected ? Border.all(color: Colors.yellow, width: 3) : null,
    );
  }

  Widget _buildSquareBackground(bool isLight, bool isLastMove) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLight
              ? [Colors.brown[100]!, Colors.brown[200]!]
              : [Colors.brown[300]!, Colors.brown[500]!],
        ),
      ),
    );
  }

  Widget _buildValidMoveIndicator() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Center(
          child: Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectionGlow() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.yellow.withOpacity(_glowAnimation.value * 0.8),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedPiece(Piece piece, Position position, bool isSelected) {
    return Draggable<Position>(
      data: position,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.3,
          child: Transform.rotate(
            angle: 0.1,
            child: _buildPieceWidget(piece, true),
          ),
        ),
      ),
      childWhenDragging: AnimatedOpacity(
        opacity: 0.3,
        duration: const Duration(milliseconds: 200),
        child: _buildPieceWidget(piece, false),
      ),
      onDragStarted: () {
        // Drag started
      },
      onDragEnd: (details) {
        // Drag ended
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform:
            isSelected ? (Matrix4.identity()..scale(1.1)) : Matrix4.identity(),
        child: _buildPieceWidget(piece, false),
      ),
    );
  }

  Widget _buildPieceWidget(Piece piece, bool isDragging) {
    final textColor =
        piece.color == PieceColor.white ? Colors.white : Colors.black;
    final shadowColor =
        piece.color == PieceColor.white ? Colors.black : Colors.white;

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: isDragging ? 28 : 24,
            color: textColor,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: shadowColor.withOpacity(0.5),
                offset: const Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
          child: Text(_getPieceSymbol(piece.type)),
        ),
      ),
    );
  }

  void _handleSquareTap(Position position) {
    if (widget.selectedPosition == position) {
      // Deselect
      widget.onMove(position, position);
    } else if (widget.validMoves.contains(position)) {
      // Make move
      widget.onMove(widget.selectedPosition!, position);
    } else if (widget.game.getPieceAt(position) != null &&
        widget.game.getPieceAt(position)!.color == widget.game.currentPlayer) {
      // Select piece
      widget.onMove(position, position);
    }
  }

  String _getPieceSymbol(PieceType type) {
    switch (type) {
      case PieceType.king:
        return '♔';
      case PieceType.queen:
        return '♕';
      case PieceType.rook:
        return '♖';
      case PieceType.bishop:
        return '♗';
      case PieceType.knight:
        return '♘';
      case PieceType.pawn:
        return '♙';
    }
  }
}
