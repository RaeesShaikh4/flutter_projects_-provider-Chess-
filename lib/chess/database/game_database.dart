import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class GameDatabase {
  static final GameDatabase _instance = GameDatabase._internal();
  factory GameDatabase() => _instance;
  GameDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'chess_game.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE game_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        level_number INTEGER NOT NULL,
        is_completed BOOLEAN NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL
      )
    ''');
  }

  // Get the highest unlocked level
  Future<int> getUnlockedLevel() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT MAX(level_number) as max_level 
      FROM game_progress 
      WHERE is_completed = 1
    ''');
    
    int maxLevel = result.first['max_level'] as int? ?? 0;
    print('DEBUG: Database query result: $result, maxLevel: $maxLevel, returning: ${maxLevel + 1}');
    return maxLevel + 1;
  }

  // Mark a level as completed
  Future<void> completeLevel(int levelNumber) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    print('DEBUG: Completing level $levelNumber in database');
    
    await db.insert(
      'game_progress',
      {
        'level_number': levelNumber,
        'is_completed': 1,
        'created_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    print('DEBUG: Level $levelNumber successfully saved to database');
  }

  // Check if a level is completed
  Future<bool> isLevelCompleted(int levelNumber) async {
    final db = await database;
    final result = await db.query(
      'game_progress',
      where: 'level_number = ? AND is_completed = 1',
      whereArgs: [levelNumber],
    );
    return result.isNotEmpty;
  }

  // Reset all progress
  Future<void> resetProgress() async {
    final db = await database;
    await db.delete('game_progress');
  }
}