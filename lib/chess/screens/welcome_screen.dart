import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'chess_game_screen.dart';
import 'level_selection_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.brown[50]!,
              Colors.brown[100]!,
              Colors.brown[200]!,
              Colors.brown[300]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _fadeAnimation,
                _slideAnimation,
                _pulseAnimation,
                _scaleAnimation,
              ]),
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // Header section
                      _buildHeader(),

                      // const SizedBox(height: 20),

                      // Main content
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.h),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Chess board preview
                                _buildChessPreview(),

                                SizedBox(height: 30.h),

                                // Title and description
                                _buildTitleSection(),

                                SizedBox(height: 40.h),

                                // Play buttons
                                _buildPlayButtons(),

                                SizedBox(height: 20.h),
 
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -0.5),
        end: Offset.zero,
      ).animate(_slideAnimation),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Row(
          children: [
            Icon(
              Icons.sports_esports,
              color: Colors.brown[700],
              size: 32.sp,
            ),
            SizedBox(width: 12.w),
            Text(
              'CHESS MASTER',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.brown[700],
                letterSpacing: 2,
              ),
            ),
            const Spacer(),
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: Colors.brown[700]!.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Icon(
                      Icons.settings,
                      color: Colors.brown[700],
                      size: 20.sp,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChessPreview() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(_slideAnimation),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 180.w,
              height: 180.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20.r,
                    offset: Offset(0, 10.h),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.brown[200]!,
                        Colors.brown[300]!,
                      ],
                    ),
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                    ),
                    itemCount: 64,
                    itemBuilder: (context, index) {
                      final row = index ~/ 8;
                      final col = index % 8;
                      final isLight = (row + col) % 2 == 0;

                      return Container(
                        decoration: BoxDecoration(
                          color:
                              isLight ? Colors.brown[100] : Colors.brown[400],
                          border: Border.all(
                            color: Colors.brown[600]!.withOpacity(0.3),
                            width: 0.5.w,
                          ),
                        ),
                        child: Center(
                          child: _getPreviewPiece(row, col),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget? _getPreviewPiece(int row, int col) {
    // Show some chess pieces in the preview
    if (row == 1) {
      return Text('♟',
          style: TextStyle(fontSize: 12.sp, color: Colors.black));
    }
    if (row == 6) {
      return Text('♙',
          style: TextStyle(fontSize: 12.sp, color: Colors.white));
    }
    if (row == 0) {
      const pieces = ['♜', '♞', '♝', '♛', '♚', '♝', '♞', '♜'];
      return Text(pieces[col],
          style: TextStyle(fontSize: 12.sp, color: Colors.black));
    }
    if (row == 7) {
      const pieces = ['♖', '♘', '♗', '♕', '♔', '♗', '♘', '♖'];
      return Text(pieces[col],
          style: TextStyle(fontSize: 12.sp, color: Colors.white));
    }
    return null;
  }

  Widget _buildTitleSection() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(_slideAnimation),
      child: Column(
        children: [
          Text(
            'Welcome to Chess Master',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: Colors.brown[800],
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          Text(
            'Challenge the AI in a game of strategy and skill',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.brown[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  Widget _buildPlayButtons() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(_slideAnimation),
      child: Column(
        children: [
          // Quick Play button
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.brown[700]!, Colors.brown[800]!],
                    ),
                    borderRadius: BorderRadius.circular(30.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.brown[700]!.withOpacity(0.4),
                        blurRadius: 15.r,
                        offset: Offset(0, 8.h),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _startGame,
                      borderRadius: BorderRadius.circular(30.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 32.w, vertical: 14.h),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 28.sp,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'QUICK PLAY',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 16.h),

          // Levels button
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value * 0.95 + 0.05,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[600]!, Colors.blue[800]!],
                    ),
                    borderRadius: BorderRadius.circular(30.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue[600]!.withOpacity(0.4),
                        blurRadius: 15.r,
                        offset: Offset(0, 8.h),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _startLevels,
                      borderRadius: BorderRadius.circular(30.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 32.w, vertical: 14.h),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.emoji_events,
                              color: Colors.white,
                              size: 28.sp,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'LEVELS (100)',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(_slideAnimation),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            _buildFeatureItem(Icons.smart_toy, 'AI Opponent',
                'Play against intelligent computer'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: Colors.brown[300]!,
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.brown[700],
            size: 20,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[700],
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.brown[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startGame() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const ChessGameScreen(),
      ),
    );
  }

  void _startLevels() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LevelSelectionScreen(),
      ),
    );
  }
}
