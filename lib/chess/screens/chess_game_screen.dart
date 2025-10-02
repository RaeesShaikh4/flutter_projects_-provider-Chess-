import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/piece.dart';
import '../models/position.dart';
import '../models/level.dart';
import '../game/chess_game.dart';
import '../ai/level_chess_ai.dart';
import '../widgets/chess_board.dart';

class ChessGameScreen extends StatefulWidget {
  final ChessLevel? level;
  final Function(bool)? onLevelComplete;

  const ChessGameScreen({
    super.key,
    this.level,
    this.onLevelComplete,
  });

  @override
  State<ChessGameScreen> createState() => _ChessGameScreenState();
}

class _ChessGameScreenState extends State<ChessGameScreen>
    with TickerProviderStateMixin {
  late ChessGame game;
  late LevelChessAI ai;
  Position? selectedPosition;
  List<Position> validMoves = [];
  bool isAITurn = false;
  Position? lastMoveFrom;
  Position? lastMoveTo;
  ChessLevel? currentLevel;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    game = ChessGame();
    currentLevel = widget.level;
    ai = LevelChessAI.createAI(currentLevel?.aiDifficulty ?? 1);

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _onMove(Position from, Position to) {
    if (game.gameState != GameState.playing) return;
    if (isAITurn) return;

    // If from and to are the same, it's a selection/deselection
    if (from == to) {
      setState(() {
        if (selectedPosition == from) {
          selectedPosition = null;
          validMoves = [];
        } else {
          final piece = game.getPieceAt(from);
          if (piece != null && piece.color == game.currentPlayer) {
            selectedPosition = from;
            validMoves = game.getValidMoves(from);
          }
        }
      });
      return;
    }

    // Make the move
    if (game.makeMove(from, to)) {
      setState(() {
        lastMoveFrom = from;
        lastMoveTo = to;
        selectedPosition = null;
        validMoves = [];
      });

      // Check if game is over
      if (game.gameState != GameState.playing) {
        _showGameEndDialog();
        return;
      }

      // AI's turn
      if (game.currentPlayer == PieceColor.black) {
        _makeAIMove();
      }
    }
  }

  void _makeAIMove() async {
    setState(() {
      isAITurn = true;
    });

    // Add a small delay to make AI move visible
    await Future.delayed(const Duration(milliseconds: 800));

    final aiMove = ai.getBestMove(game);
    if (aiMove != null && game.makeMove(aiMove.from, aiMove.to)) {
      setState(() {
        lastMoveFrom = aiMove.from;
        lastMoveTo = aiMove.to;
        isAITurn = false;
      });

      // Check if game is over
      if (game.gameState != GameState.playing) {
        _showGameEndDialog();
      }
    } else {
      setState(() {
        isAITurn = false;
      });
    }
  }

  void _showGameEndDialog() {
    String message;
    Color dialogColor;
    IconData dialogIcon;

    switch (game.gameState) {
      case GameState.checkmate:
        message = game.currentPlayer == PieceColor.white
            ? 'Black wins by checkmate!'
            : 'White wins by checkmate!';
        dialogColor = Colors.red;
        dialogIcon = Icons.emoji_events;
        break;
      case GameState.stalemate:
        message = 'Draw by stalemate!';
        dialogColor = Colors.orange;
        dialogIcon = Icons.handshake;
        break;
      case GameState.draw:
        message = 'Draw!';
        dialogColor = Colors.blue;
        dialogIcon = Icons.balance;
        break;
      case GameState.playing:
        return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AnimatedDialog(
        message: message,
        dialogColor: dialogColor,
        icon: dialogIcon,
        onNewGame: () {
          Navigator.of(context).pop();
          _resetGame();
        },
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _resetGame() {
    setState(() {
      game.reset();
      selectedPosition = null;
      validMoves = [];
      isAITurn = false;
      lastMoveFrom = null;
      lastMoveTo = null;
    });

    // Restart animations
    _fadeController.reset();
    _slideController.reset();
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.brown[100]!,
              Colors.brown[200]!,
              Colors.brown[300]!,
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _fadeAnimation,
              _slideAnimation,
              _pulseAnimation,
              _glowAnimation,
            ]),
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(_slideAnimation),
                  child: Column(
                    children: [
                      // Game status with animations
                      _buildGameStatus(),

                      // Chess board with animations
                      Center(
                        child: Transform.scale(
                          scale: _pulseAnimation.value * 0.01 + 0.99,
                          child: Padding(
                            padding: EdgeInsets.all(20.r),
                            child: ChessBoard(
                              game: game,
                              onMove: _onMove,
                              selectedPosition: selectedPosition,
                              validMoves: validMoves,
                              lastMoveFrom: lastMoveFrom,
                              lastMoveTo: lastMoveTo,
                            ),
                          ),
                        ),
                      ),

                      // Animated game controls
                      _buildAnimatedControls(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value * 0.05 + 0.95,
            child: FloatingActionButton.extended(
              onPressed: _resetGame,
              backgroundColor: Colors.brown[700],
              foregroundColor: Colors.white,
              icon: const Icon(Icons.refresh),
              label: const Text('New Game'),
              elevation: 8,
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameStatus() {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 5.h, 20.w, 20.h),
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey[50]!,
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15.r,
            offset: Offset(0, 8.h),
          ),
        ],
        border: Border.all(
          color: _getStatusColor().withOpacity(0.3),
          width: 2.w,
        ),
      ),
      child: Column(
        children: [
          // Chess title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sports_esports,
                color: Colors.brown[700],
                size: 32.sp,
              ),
              SizedBox(width: 12.w),
              Column(
                children: [
                  Text(
                    currentLevel != null
                        ? 'LEVEL ${currentLevel!.levelNumber}'
                        : 'CHESS MASTER',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[700],
                      letterSpacing: 2,
                    ),
                  ),
                  if (currentLevel != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      currentLevel!.name,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.brown[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          SizedBox(height: 20.h),
          // Game status
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getStatusColor()
                          .withOpacity(0.1 + _glowAnimation.value * 0.1),
                      _getStatusColor()
                          .withOpacity(0.05 + _glowAnimation.value * 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25.r),
                  border: Border.all(
                    color: _getStatusColor().withOpacity(0.6),
                    width: 2.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getStatusColor().withOpacity(0.3),
                      blurRadius: 10.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isAITurn) ...[
                      SizedBox(
                        width: 24.w,
                        height: 24.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 3.w,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.brown),
                        ),
                      ),
                      SizedBox(width: 16.w),
                    ],
                    Icon(
                      _getStatusIcon(),
                      color: _getStatusColor(),
                      size: 28.sp,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      _getGameStatusText(),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedControls() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAnimatedButton(
            icon: Icons.info_outline,
            label: 'Game Rules',
            onPressed: _showGameInfo,
            color: Colors.brown[600]!,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value * 0.05 + 0.95,
          child: ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.r),
              ),
              elevation: 8,
              shadowColor: color.withOpacity(0.5),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor() {
    if (game.gameState != GameState.playing) {
      switch (game.gameState) {
        case GameState.checkmate:
          return Colors.red;
        case GameState.stalemate:
          return Colors.orange;
        case GameState.draw:
          return Colors.blue;
        case GameState.playing:
          break;
      }
    }
    return game.currentPlayer == PieceColor.white
        ? Colors.green
        : Colors.purple;
  }

  IconData _getStatusIcon() {
    if (game.gameState != GameState.playing) {
      switch (game.gameState) {
        case GameState.checkmate:
          return Icons.emoji_events;
        case GameState.stalemate:
          return Icons.handshake;
        case GameState.draw:
          return Icons.balance;
        case GameState.playing:
          break;
      }
    }
    return game.currentPlayer == PieceColor.white
        ? Icons.person
        : Icons.smart_toy;
  }

  String _getGameStatusText() {
    if (game.gameState != GameState.playing) {
      switch (game.gameState) {
        case GameState.checkmate:
          return game.currentPlayer == PieceColor.white
              ? 'Black wins by checkmate!'
              : 'White wins by checkmate!';
        case GameState.stalemate:
          return 'Draw by stalemate!';
        case GameState.draw:
          return 'Draw!';
        case GameState.playing:
          break;
      }
    }

    if (isAITurn) {
      return 'AI is thinking...';
    }

    return game.currentPlayer == PieceColor.white
        ? 'Your turn (White)'
        : 'AI turn (Black)';
  }

  void _showGameInfo() {
    showDialog(
      context: context,
      builder: (context) => AnimatedDialog(
        message: 'Chess Game Info',
        dialogColor: Colors.blue,
        icon: Icons.info,
        isInfo: true,
        onNewGame: null,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class AnimatedDialog extends StatefulWidget {
  final String message;
  final Color dialogColor;
  final IconData icon;
  final VoidCallback? onNewGame;
  final VoidCallback onClose;
  final bool isInfo;

  const AnimatedDialog({
    super.key,
    required this.message,
    required this.dialogColor,
    required this.icon,
    this.onNewGame,
    required this.onClose,
    this.isInfo = false,
  });

  @override
  State<AnimatedDialog> createState() => _AnimatedDialogState();
}

class _AnimatedDialogState extends State<AnimatedDialog>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              title: Row(
                children: [
                  Icon(widget.icon, color: widget.dialogColor, size: 32.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      widget.isInfo ? 'Game Info' : 'Game Over',
                      style: TextStyle(
                        color: widget.dialogColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                      ),
                    ),
                  ),
                ],
              ),
              content: widget.isInfo
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('How to play:', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8.h),
                        Text('• Tap a piece to select it', style: TextStyle(fontSize: 14.sp)),
                        Text('• Tap a valid move square to move', style: TextStyle(fontSize: 14.sp)),
                        Text('• Drag and drop pieces to move', style: TextStyle(fontSize: 14.sp)),
                        Text('• Green circles show valid moves', style: TextStyle(fontSize: 14.sp)),
                        SizedBox(height: 16.h),
                        Text('Game rules:', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                        Text('• Standard chess rules apply', style: TextStyle(fontSize: 14.sp)),
                        Text('• AI plays as black pieces', style: TextStyle(fontSize: 14.sp)),
                        Text('• You play as white pieces', style: TextStyle(fontSize: 14.sp)),
                      ],
                    )
                  : Text(
                      widget.message,
                      style: TextStyle(fontSize: 16.sp),
                    ),
              actions: [
                if (widget.onNewGame != null)
                  ElevatedButton.icon(
                    onPressed: widget.onNewGame,
                    icon: const Icon(Icons.refresh),
                    label: const Text('New Game'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                TextButton(
                  onPressed: widget.onClose,
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
