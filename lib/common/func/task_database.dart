import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/task.dart';

import 'package:flutter/material.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'checknote.db');

    final db = await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        // 创建 tasks 表
        await db.execute('''
        CREATE TABLE tasks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT,
          name TEXT,
          details TEXT,
          done INTEGER
        )
      ''');

        // 创建 notification_time 表
        await db.execute('''
        CREATE TABLE notification_time (
          id INTEGER PRIMARY KEY,
          hour INTEGER,
          minute INTEGER
        )
      ''');

        // 创建 checkins 表
        await db.execute('''
        CREATE TABLE checkins (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT UNIQUE,
          timestamp INTEGER
        )
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
          CREATE TABLE IF NOT EXISTS notification_time (
            id INTEGER PRIMARY KEY,
            hour INTEGER,
            minute INTEGER
          )
        ''');
        }
        if (oldVersion < 3) {
          await db.execute('''
          CREATE TABLE IF NOT EXISTS checkins (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT UNIQUE,
            timestamp INTEGER
          )
        ''');
        }
      },
    );

    // 🚀 自动检测逻辑：如果缺表就补建
    await _ensureTableExists(db, 'notification_time', '''
    CREATE TABLE IF NOT EXISTS notification_time (
            id INTEGER PRIMARY KEY,
            hour INTEGER,
            minute INTEGER
          )
  ''');
    await _ensureTableExists(db, 'checkins', '''
    CREATE TABLE checkins (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT UNIQUE,
      timestamp INTEGER
    )
  ''');

    return db;
  }

  Future<void> _ensureTableExists(
      Database db, String tableName, String createSql) async {
    final res = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );

    if (res.isEmpty) {
      print('⚙️ 表 $tableName 不存在，正在自动创建...');
      await db.execute(createSql);
      print('✅ 表 $tableName 已自动创建完成');
    } else {
      print('✅ 表 $tableName 已存在');
    }
  }

  Future<List<Task>> getTasksByDate(String date) async {
    final dbClient = await db;
    final maps =
        await dbClient.query('tasks', where: 'date = ?', whereArgs: [date]);
    return maps.map((e) => Task.fromMap(e)).toList();
  }

  Future<int> insertTask(Task task) async {
    final dbClient = await db;
    return await dbClient.insert('tasks', task.toMap());
  }

  Future<int> updateTask(Task task) async {
    final dbClient = await db;
    return await dbClient
        .update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<int> deleteTask(int? taskid) async {
    final dbClient = await db;
    return await dbClient.delete('tasks', where: 'id = ?', whereArgs: [taskid]);
  }

  Future<void> saveNotificationTime(TimeOfDay? time) async {
    final dbClient = await db;

    await dbClient.insert(
      'notification_time',
      {'id': 1, 'hour': time?.hour, 'minute': time?.minute},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<TimeOfDay?> getNotificationTime() async {
    final dbClient = await db;
    final result = await dbClient.query(
      'notification_time',
      where: 'id = ?',
      whereArgs: [1],
    );

    if (result.isNotEmpty) {
      final row = result.first;
      final hour = row['hour'];
      final minute = row['minute'];

      if (hour != null && minute != null) {
        return TimeOfDay(hour: hour as int, minute: minute as int);
      }
    }
    return null;
  }

  Future<void> checkInToday(DateTime today) async {
    final dbClient = await db;
    final dateStr = "${today.year}-${today.month}-${today.day}";

    await dbClient.insert(
      'checkins',
      {
        'date': dateStr,
        'timestamp': today.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore, // 避免重复插入
    );
  }

  Future<bool> hasCheckedInToday(DateTime today) async {
    final dbClient = await db;
    final dateStr = "${today.year}-${today.month}-${today.day}";

    final result = await dbClient.query(
      'checkins',
      where: 'date = ?',
      whereArgs: [dateStr],
    );

    return result.isNotEmpty;
  }

  Future<int> getTotalCheckinCount() async {
    final dbClient = await db;
    final result =
        await dbClient.rawQuery('SELECT COUNT(*) as count FROM checkins');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> clearCheckins() async {
    final dbClient = await db;
    await dbClient.delete('checkins');
  }

  Future<List<Map<String, dynamic>>> getAllTasks() async {
    final dbClient = await db;
    return await dbClient.query('tasks');
  }

  Future<List<Map<String, dynamic>>> getAllNotificationTimes() async {
    final dbClient = await db;
    return await dbClient.query('notification_time');
  }

  Future<List<Map<String, dynamic>>> getAllCheckIn() async {
    final dbClient = await db;
    return await dbClient.query('checkins');
  }
}
