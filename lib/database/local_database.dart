import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/medicine.dart';
import '../models/medicine_log.dart';
import '../models/health_log.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();
  static Database? _database;
  SharedPreferences? _webPrefs;

  LocalDatabase._init();

  Future<void> _initWeb() async {
    _webPrefs ??= await SharedPreferences.getInstance();
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('medicine.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      throw UnsupportedError(
          'SQFlite not supported on web without config. Using Prefs instead.');
    }
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE medicines(
        id TEXT PRIMARY KEY,
        name TEXT,
        genericName TEXT,
        dosage TEXT,
        frequency TEXT,
        times TEXT,
        specialInstructions TEXT,
        currentStock INTEGER,
        lowStockThreshold INTEGER,
        recommendationNote TEXT,
        lifestyleWarnings TEXT,
        pillShape INTEGER,
        pillColor INTEGER,
        isStopped INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE logs(
        id TEXT PRIMARY KEY,
        medicineId TEXT,
        medicineName TEXT,
        timestamp TEXT
      )
    ''');

    await db.execute('''
        CREATE TABLE health_logs(
          id TEXT PRIMARY KEY,
          type INTEGER,
          value1 REAL,
          value2 REAL,
          timestamp TEXT,
          note TEXT
        )
      ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      final columns = [
        'specialInstructions TEXT',
        'currentStock INTEGER',
        'lowStockThreshold INTEGER',
        'recommendationNote TEXT',
        'lifestyleWarnings TEXT',
        'pillShape INTEGER',
        'pillColor INTEGER',
        'isStopped INTEGER',
        'times TEXT'
      ];
      for (var col in columns) {
        try {
          await db.execute('ALTER TABLE medicines ADD COLUMN $col');
        } catch (e) {}
      }
    }
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE medicines ADD COLUMN genericName TEXT');
      } catch (e) {}
    }
    if (oldVersion < 4) {
      try {
        await db.execute('''
          CREATE TABLE health_logs(
            id TEXT PRIMARY KEY,
            type INTEGER,
            value1 REAL,
            value2 REAL,
            timestamp TEXT,
            note TEXT
          )
        ''');
      } catch (e) {}
    }
  }

  // --- WEB HELPERS ---
  Future<List<T>> _getWebList<T>(
      String key, T Function(Map<String, dynamic>) fromJson) async {
    await _initWeb();
    final jsonList = _webPrefs!.getStringList(key) ?? [];
    return jsonList.map((str) => fromJson(jsonDecode(str))).toList();
  }

  Future<void> _saveWebItem<T>(String key, T item, String id,
      Map<String, dynamic> Function(T) toJson) async {
    await _initWeb();
    final list = _webPrefs!.getStringList(key) ?? [];
    // Remove existing if any
    final decoded = list.map((s) => jsonDecode(s)).toList();
    decoded.removeWhere((m) => m['id'] == id);
    // Add new
    decoded.add(toJson(item));
    // Save back
    await _webPrefs!
        .setStringList(key, decoded.map((m) => jsonEncode(m)).toList());
  }

  Future<void> _deleteWebItem(String key, String id) async {
    await _initWeb();
    final list = _webPrefs!.getStringList(key) ?? [];
    final decoded = list.map((s) => jsonDecode(s)).toList();
    decoded.removeWhere((m) => m['id'] == id);
    await _webPrefs!
        .setStringList(key, decoded.map((m) => jsonEncode(m)).toList());
  }

  // --- METHODS ---

  Future<void> saveMedicine(Medicine medicine) async {
    if (kIsWeb) {
      await _saveWebItem('medicines', medicine, medicine.id, (m) => m.toJson());
      return;
    }
    final db = await instance.database;
    final map = medicine.toMap();
    map['isStopped'] = medicine.isStopped ? 1 : 0;
    if (map['times'] is List) {
      map['times'] = (map['times'] as List).join(',');
    }
    await db.insert('medicines', map,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Medicine>> getMedicines() async {
    if (kIsWeb) {
      return _getWebList('medicines', (json) => Medicine.fromJson(json));
    }
    final db = await instance.database;
    final result = await db.query('medicines');
    return result.map((json) {
      final map = Map<String, dynamic>.from(json);
      map['isStopped'] = (map['isStopped'] == 1);
      if (map['times'] is String) {
        map['times'] = (map['times'] as String).split(',');
      }
      return Medicine.fromMap(map);
    }).toList();
  }

  Future<void> saveLog(MedicineLog log) async {
    if (kIsWeb) {
      await _saveWebItem('logs', log, log.id, (l) => l.toJson());
      return;
    }
    final db = await instance.database;
    await db.insert('logs', log.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<MedicineLog>> getLogs() async {
    if (kIsWeb) {
      return _getWebList('logs', (json) => MedicineLog.fromJson(json));
    }
    final db = await instance.database;
    final result = await db.query('logs', orderBy: 'timestamp DESC');
    return result.map((json) => MedicineLog.fromMap(json)).toList();
  }

  Future<void> saveHealthLog(HealthLog log) async {
    if (kIsWeb) {
      await _saveWebItem('health_logs', log, log.id, (l) => l.toMap());
      return;
    }
    final db = await instance.database;
    await db.insert('health_logs', log.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<HealthLog>> getHealthLogs() async {
    if (kIsWeb) {
      return _getWebList('health_logs', (json) => HealthLog.fromMap(json));
    }
    final db = await instance.database;
    final result = await db.query('health_logs', orderBy: 'timestamp DESC');
    return result.map((json) => HealthLog.fromMap(json)).toList();
  }

  Future<void> deleteMedicine(String id) async {
    if (kIsWeb) {
      await _deleteWebItem('medicines', id);
      return;
    }
    final db = await instance.database;
    await db.delete('medicines', where: 'id = ?', whereArgs: [id]);
  }
}
