class ChessLevel {
  final int levelNumber;
  final String name;
  final String description;
  final int aiDifficulty; // 1-10 scale
  final int timeLimit; // seconds, 0 means no limit
  final bool hasSpecialRules;
  final String specialRuleDescription;

  const ChessLevel({
    required this.levelNumber,
    required this.name,
    required this.description,
    required this.aiDifficulty,
    this.timeLimit = 0,
    this.hasSpecialRules = false,
    this.specialRuleDescription = '',
  });

  static List<ChessLevel> getAllLevels() {
    return List.generate(100, (index) {
      final levelNum = index + 1;
      return ChessLevel(
        levelNumber: levelNum,
        name: _getLevelName(levelNum),
        description: _getLevelDescription(levelNum),
        aiDifficulty: _getAIDifficulty(levelNum),
        timeLimit: _getTimeLimit(levelNum),
        hasSpecialRules: _hasSpecialRules(levelNum),
        specialRuleDescription: _getSpecialRuleDescription(levelNum),
      );
    });
  }

  static String _getLevelName(int level) {
    if (level <= 10) return 'Beginner $level';
    if (level <= 25) return 'Novice $level';
    if (level <= 50) return 'Intermediate $level';
    if (level <= 75) return 'Advanced $level';
    if (level <= 90) return 'Expert $level';
    if (level <= 99) return 'Master $level';
    return 'Grandmaster $level';
  }

  static String _getLevelDescription(int level) {
    if (level <= 10) return 'Learn the basics of chess';
    if (level <= 25) return 'Develop your tactical skills';
    if (level <= 50) return 'Master strategic thinking';
    if (level <= 75) return 'Advanced position evaluation';
    if (level <= 90) return 'Expert-level analysis';
    if (level <= 99) return 'Master-level precision';
    return 'Ultimate chess challenge';
  }

  static int _getAIDifficulty(int level) {
    // Progressive difficulty from 1 to 10
    if (level <= 10) return 1;
    if (level <= 20) return 2;
    if (level <= 30) return 3;
    if (level <= 40) return 4;
    if (level <= 50) return 5;
    if (level <= 60) return 6;
    if (level <= 70) return 7;
    if (level <= 80) return 8;
    if (level <= 90) return 9;
    return 10;
  }

  static int _getTimeLimit(int level) {
    // Time pressure increases with level
    if (level <= 20) return 0; // No time limit for beginners
    if (level <= 40) return 300; // 5 minutes
    if (level <= 60) return 180; // 3 minutes
    if (level <= 80) return 120; // 2 minutes
    if (level <= 95) return 60; // 1 minute
    return 30; // 30 seconds for final levels
  }

  static bool _hasSpecialRules(int level) {
    // Special rules for certain milestone levels
    return level % 10 == 0 || level >= 90;
  }

  static String _getSpecialRuleDescription(int level) {
    if (level == 10) return 'AI gets one extra move per turn';
    if (level == 20) return 'You must capture when possible';
    if (level == 30) return 'AI can see 2 moves ahead';
    if (level == 40) return 'No castling allowed';
    if (level == 50) return 'AI starts with extra piece';
    if (level == 60) return 'You must move within 10 seconds';
    if (level == 70) return 'AI can undo one move per game';
    if (level == 80) return 'No pawn promotion allowed';
    if (level == 90) return 'AI plays with time advantage';
    if (level == 100) return 'Ultimate challenge - all rules apply';
    return '';
  }

  String get difficultyText {
    switch (aiDifficulty) {
      case 1:
      case 2:
        return 'Easy';
      case 3:
      case 4:
        return 'Medium';
      case 5:
      case 6:
        return 'Hard';
      case 7:
      case 8:
        return 'Expert';
      case 9:
        return 'Master';
      case 10:
        return 'Grandmaster';
      default:
        return 'Unknown';
    }
  }

  String get timeLimitText {
    if (timeLimit == 0) return 'No time limit';
    if (timeLimit < 60) return '${timeLimit}s';
    return '${timeLimit ~/ 60}m ${timeLimit % 60}s';
  }
}
