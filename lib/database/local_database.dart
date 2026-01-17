import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/medicine.dart';
import '../models/medicine_log.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();
  static Database? _database;

  LocalDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('medicine.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE medicines(
        id TEXT PRIMARY KEY,
        name TEXT,
        dosage TEXT,
        frequency TEXT,
        pillCount INTEGER,
        lastTaken TEXT
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
  }

  Future<void> saveMedicine(Medicine medicine) async {
    final db = await instance.database;
    await db.insert(
      'medicines',
      medicine.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Medicine>> getMedicines() async {
    final db = await instance.database;
    final result = await db.query('medicines');
    return result.map((json) => Medicine.fromMap(json)).toList();
  }

  Future<void> saveLog(MedicineLog log) async {
    final db = await instance.database;
    await db.insert(
      'logs',
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MedicineLog>> getLogs() async {
    final db = await instance.database;
    final result = await db.query('logs', orderBy: 'timestamp DESC');
    return result.map((json) => MedicineLog.fromMap(json)).toList();
  }

  Future<void> deleteMedicine(String id) async {
    final db = await instance.database;
    await db.delete('medicines', where: 'id = ?', whereArgs: [id]);
  }
}
