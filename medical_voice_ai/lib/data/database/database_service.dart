import 'package:sqflite/sqflite.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  Database? _database;

  Future<void> initialize() async {
    if (_database != null) return;

    final databasePath = await getDatabasesPath();
    final path = '$databasePath/consultations.db';

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE consultations(
            id TEXT PRIMARY KEY,
            patientName TEXT,
            dateTime INTEGER,
            chiefComplaint TEXT,
            transcript TEXT,
            summary TEXT,
            medicines TEXT,
            followUp TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertConsultation(Map<String, Object?> values) async {
    await initialize();
    await _database!.insert(
      'consultations',
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, Object?>>> loadConsultations() async {
    await initialize();
    return await _database!.query('consultations', orderBy: 'dateTime DESC');
  }

  Future<void> deleteConsultation(String id) async {
    await initialize();
    await _database!.delete(
      'consultations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
