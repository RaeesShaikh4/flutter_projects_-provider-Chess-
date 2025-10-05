import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/level.dart';
import '../database/game_database.dart';
import '../utils/custom_toast.dart';
import 'chess_game_screen.dart';

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;

  int _unlockedLevel = 1;
  final List<ChessLevel> _levels = ChessLevel.getAllLevels();
  final GameDatabase _database = GameDatabase();

  @override
  void initState() {
    super.initState();
    _loadUnlockedLevel();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  Future<void> _loadUnlockedLevel() async {
    final unlockedLevel = await _database.getUnlockedLevel();
    print('DEBUG: Loaded unlocked level: $unlockedLevel');
    setState(() {
      _unlockedLevel = unlockedLevel;
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
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
              ]),
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // Header
                      SizedBox(height: 10.h),
                      _buildHeader(),
                          
                      SizedBox(height: 10.h),
                          
                      // Progress indicator
                      _buildProgressIndicator(),
                          
                      SizedBox(height: 10.h),
                          
                      // Level grid
                      Expanded(
                        child: _buildLevelGrid(),
                      ),

                      SizedBox(height: 20.h),
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
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.brown),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.sports_esports,
            color: Colors.brown[700],
            size: 32.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CHESS LEVELS',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[700],
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'Choose your challenge',
                  style: TextStyle(
                    fontSize: 14.sp,
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

  Widget _buildProgressIndicator() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(_slideAnimation),
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey[50]!],
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10.r,
              offset: Offset(0, 5.h),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[700],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '$_unlockedLevel / 100',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown[600],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    // Reset button integrated into progress indicator
                    GestureDetector(
                      onTap: () async {
                        print('DEBUG: Reset button pressed from progress indicator');
                        await _database.resetProgress();
                        await _loadUnlockedLevel();
                        
                        CustomToast.error(context, "Progress reset successfully!");
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.red[300]!, width: 1.w),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.refresh,
                              size: 14.sp,
                              color: Colors.red[600],
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Reset',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.red[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            LinearProgressIndicator(
              value: _unlockedLevel / 100,
              backgroundColor: Colors.brown[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.brown[600]!),
              minHeight: 8.h,
            ),
            SizedBox(height: 8.h),
            Text(
              '${(_unlockedLevel / 100 * 100).round()}% Complete',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.brown[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelGrid() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.1),
        end: Offset.zero,
      ).animate(_slideAnimation),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
          child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            childAspectRatio: 1.0,
            crossAxisSpacing: 4.w,
            mainAxisSpacing: 4.h,
          ),
          itemCount: _levels.length,
          itemBuilder: (context, index) {
            final level = _levels[index];
            final isUnlocked = level.levelNumber <= _unlockedLevel;
            final isCompleted = level.levelNumber < _unlockedLevel;

            return _buildLevelCard(level, isUnlocked, isCompleted);
          },
        ),
      ),
    );
  }

  Widget _buildLevelCard(ChessLevel level, bool isUnlocked, bool isCompleted) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          // Add padding to prevent clipping during scale animation
          padding: EdgeInsets.all(2.r),
          child: Transform.scale(
            scale: isUnlocked ? _pulseAnimation.value : 1.0,
            child: GestureDetector(
              onTap: isUnlocked ? () => _startLevel(level) : null,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _getLevelColors(level, isUnlocked, isCompleted),
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                  border: Border.all(
                    color: isUnlocked ? Colors.brown[400]! : Colors.grey[300]!,
                    width: 2.w,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isCompleted)
                      Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 16.sp,
                      )
                    else if (isUnlocked)
                      Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 16.sp,
                      )
                    else
                      Icon(
                        Icons.lock,
                        color: Colors.grey[400],
                        size: 16.sp,
                      ),
                    SizedBox(height: 2.h),
                    Text(
                      '${level.levelNumber}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: isUnlocked ? Colors.white : Colors.grey[400],
                      ),
                    ),
                    if (isUnlocked) ...[
                      SizedBox(height: 1.h),
                      Text(
                        level.difficultyText,
                        style: TextStyle(
                          fontSize: 7.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Color> _getLevelColors(
      ChessLevel level, bool isUnlocked, bool isCompleted) {
    if (!isUnlocked) {
      return [Colors.grey[300]!, Colors.grey[400]!];
    }

    if (isCompleted) {
      return [Colors.green[400]!, Colors.green[600]!];
    }

    // Color based on difficulty
    switch (level.aiDifficulty) {
      case 1:
      case 2:
        return [Colors.green[400]!, Colors.green[600]!];
      case 3:
      case 4:
        return [Colors.blue[400]!, Colors.blue[600]!];
      case 5:
      case 6:
        return [Colors.orange[400]!, Colors.orange[600]!];
      case 7:
      case 8:
        return [Colors.red[400]!, Colors.red[600]!];
      case 9:
        return [Colors.purple[400]!, Colors.purple[600]!];
      case 10:
        return [Colors.black, Colors.grey[800]!];
      default:
        return [Colors.brown[400]!, Colors.brown[600]!];
    }
  }

  void _startLevel(ChessLevel level) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChessGameScreen(
          level: level,
          onLevelComplete: (won) async {
            print('DEBUG: Level completion callback called with won: $won for level ${level.levelNumber}');
            if (won) {
              print('DEBUG: Marking level ${level.levelNumber} as completed');
              await _database.completeLevel(level.levelNumber);
              print('DEBUG: Level ${level.levelNumber} marked as completed, reloading unlocked level');
              await _loadUnlockedLevel();
            }
          },
        ),
      ),
    ).then((_) {
      // Always refresh the level selection when returning from game
      _loadUnlockedLevel();
    });
  }
}
