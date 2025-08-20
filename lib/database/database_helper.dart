import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';

class DatabaseHelper {
  static const String _databaseName = 'tasks.db';
  static const int _databaseVersion = 1;
  static const String table = 'tasks';

  static const String columnId = 'id';
  static const String columnTitle = 'title';
  static const String columnDescription = 'description';
  static const String columnDeadline = 'deadline';
  static const String columnIsCompleted = 'isCompleted';
  static const String columnCreatedAt = 'createdAt';

  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTitle TEXT NOT NULL,
        $columnDescription TEXT,
        $columnDeadline INTEGER NOT NULL,
        $columnIsCompleted INTEGER NOT NULL DEFAULT 0,
        $columnCreatedAt INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert(table, task.toMap());
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final List<Map<String, Object?>> maps = await db.query(table);
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<List<Task>> getTasksByStatus(bool isCompleted) async {
    final db = await database;
    final List<Map<String, Object?>> maps = await db.query(
      table,
      where: '$columnIsCompleted = ?',
      whereArgs: [isCompleted ? 1 : 0],
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      table,
      task.toMap(),
      where: '$columnId = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<List<Task>> getTasksSortedByDeadline() async {
    final db = await database;
    final List<Map<String, Object?>> maps = await db.query(
      table,
      orderBy: '$columnDeadline ASC',
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<int> getCompletedTasksCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $table WHERE $columnIsCompleted = 1',
    );
    return result.first['count'] as int;
  }

  Future<int> getTasksCompletedOnDay(DateTime day) async {
    final db = await database;
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $table WHERE $columnIsCompleted = 1 AND $columnCreatedAt >= ? AND $columnCreatedAt < ?',
      [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
    );
    return result.first['count'] as int;
  }

  Future<void> clearAllTasks() async {
    final db = await database;
    await db.delete(table);
  }
}
