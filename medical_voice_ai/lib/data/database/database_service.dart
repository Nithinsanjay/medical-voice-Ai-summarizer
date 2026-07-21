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
      version: 2,
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
            followUp TEXT,
            diagnosis TEXT,
            vitals TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE consultations ADD COLUMN diagnosis TEXT DEFAULT ""');
          await db.execute('ALTER TABLE consultations ADD COLUMN vitals TEXT DEFAULT ""');
        }
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
