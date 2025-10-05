import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/piece.dart';
import '../models/position.dart';
import '../models/level.dart';
import '../game/chess_game.dart';
import '../ai/level_chess_ai.dart';
import '../widgets/chess_board.dart';
import 'welcome_screen.dart';

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
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    game = ChessGame();
    currentLevel = widget.level;
    ai = LevelChessAI.createAI(currentLevel?.aiDifficulty ?? 1);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
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
    bool playerWon = false;

    switch (game.gameState) {
      case GameState.checkmate:
        // Player wins if the AI (black) is checkmated
        // If it's Black's turn and Black is checkmated, White (player) wins
        // If it's White's turn and White is checkmated, Black (AI) wins
        playerWon = game.currentPlayer == PieceColor.black;
        print('DEBUG: Checkmate detected. Current player: ${game.currentPlayer}');
        print('DEBUG: Since currentPlayer is Black and Black is checkmated, White (player) wins: $playerWon');
        message = playerWon
            ? 'Congratulations! You won by checkmate!'
            : 'AI wins by checkmate!';
        dialogColor = playerWon ? Colors.green : Colors.red;
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

    // Call the level completion callback if provided
    print('DEBUG: Game ended. playerWon: $playerWon, gameState: ${game.gameState}');
    if (widget.onLevelComplete != null) {
      print('DEBUG: Calling onLevelComplete with won: $playerWon');
      widget.onLevelComplete!(playerWon);
    } else {
      print('DEBUG: onLevelComplete is null!');
    }


    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AnimatedDialog(
        message: message,
        dialogColor: dialogColor,
        icon: dialogIcon,
        onClose: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop(); // Go back to level selection
        },
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

    _fadeController.reset();
    _slideController.reset();
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( 
        backgroundColor: Colors.brown[100],
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const WelcomeScreen(),
              ),
            );
          },
          icon: const Icon(Icons.logout),
          tooltip: 'Back to Welcome Screen',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: ElevatedButton.icon(
              onPressed: _resetGame,
              icon: const Icon(Icons.refresh, color: Colors.white,),
              label: const Text('New Game'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[700],
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
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
            ]),
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.0),
                    end: Offset.zero,
                  ).animate(_slideAnimation),
                  child: Column(
                    children: [
                      SizedBox(height: 10.h),
                      // Game status
                      _buildGameStatus(),
                  
                      // Chess board
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.r, vertical: 10.h),
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
                  
                      // Game controls
                      _buildAnimatedControls(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGameStatus() {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 0.h, 20.w, 10.h),
      padding: EdgeInsets.all(16.r),
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
          SizedBox(height: 10.h),
          // Game status
          Container(
                margin: EdgeInsets.only(top: 5.h),
                padding:
                    EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getStatusColor().withOpacity(0.1),
                      _getStatusColor().withOpacity(0.05),
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
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(),
                      ),
                    ),
                  ],
                ),
          )
        ],
      ),
    );
  }

  Widget _buildAnimatedControls() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 5.h, 20.w, 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAnimatedButton(
            icon: Icons.info_outline,
            iconColor: Colors.white,
            label: 'Game Rules',
            onPressed: _showGameInfo,
            color: Colors.brown[600]!,
          ),
          SizedBox(width: 10.w),
          _buildAnimatedButton(
            icon: Icons.emoji_events,
            iconColor: Colors.white,
            label: 'Test Win',
            onPressed: _testWin,
            color: Colors.green[600]!,
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
    required Color iconColor
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: iconColor,),
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
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _testWin() {
    print('DEBUG: Test Win button pressed');
    // Force a win scenario
    game.gameState = GameState.checkmate;
    game.currentPlayer = PieceColor.white; // White's turn = Black is checkmated = White wins
    _showGameEndDialog();
  }


}

class AnimatedDialog extends StatefulWidget {
  final String message;
  final Color dialogColor;
  final IconData icon;
  final VoidCallback onClose;
  final bool isInfo;

  const AnimatedDialog({
    super.key,
    required this.message,
    required this.dialogColor,
    required this.icon,
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
                TextButton(
                  onPressed: widget.onClose,
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
