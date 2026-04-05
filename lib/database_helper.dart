import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// =====================
// WEB STORAGE (temporary)
// =====================
List<Map<String, dynamic>> webUsers = [];
List<Map<String, dynamic>> webScans = [];

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  // =====================
  // DATABASE INIT
  // =====================

  Future<Database?> get database async {
    if (kIsWeb) return null;

    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE scans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_email TEXT,
        barcode TEXT,
        product_name TEXT,
        status TEXT,
        timestamp TEXT
      )
    ''');
  }

  // =====================
  // USER FUNCTIONS
  // =====================

  Future<int> insertUser(Map<String, dynamic> user) async {
    if (kIsWeb) {
      webUsers.add(user);
      print("WEB USERS: $webUsers");
      return 1;
    }

    final db = await database;
    return await db!.insert(
      'users',
      user,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    if (kIsWeb) {
      try {
        return webUsers.firstWhere((user) => user['email'] == email);
      } catch (e) {
        return null;
      }
    }

    final db = await database;
    final result = await db!.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    return result.isNotEmpty ? result.first : null;
  }

  // =====================
  // SCAN FUNCTIONS
  // =====================

  Future<int> insertScan(Map<String, dynamic> scan) async {
    if (kIsWeb) {
      webScans.add(scan);
      print("WEB SCANS: $webScans");
      return 1;
    }

    final db = await database;
    return await db!.insert(
      'scans',
      scan,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getScansByUser(String email) async {
    if (kIsWeb) {
      return webScans
          .where((scan) => scan['user_email'] == email)
          .toList();
    }

    final db = await database;
    return await db!.query(
      'scans',
      where: 'user_email = ?',
      whereArgs: [email],
      orderBy: 'timestamp DESC',
    );
  }
}