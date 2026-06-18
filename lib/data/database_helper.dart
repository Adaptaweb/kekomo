import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_setup_stub.dart'
    if (dart.library.js_interop) 'database_setup_web.dart';

class DatabaseHelper {
  static const int _schemaVersion = 5;
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static Completer<Database>? _opening;

  DatabaseHelper._init() {
    setupDatabase();
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    if (_opening != null) return _opening!.future;
    _opening = Completer<Database>();
    try {
      final db = await _initDB('kecomo-db.db');
      _database = db;
      _opening!.complete(db);
      return db;
    } catch (e, st) {
      _opening!.completeError(e, st);
      rethrow;
    } finally {
      _opening = null;
    }
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(
      path,
      version: _schemaVersion,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE meal_logs ADD COLUMN loggedAt TEXT',
      );
    }
    if (oldVersion < 3) {
      await db.execute(
        'ALTER TABLE meal_logs ADD COLUMN photoPaths TEXT DEFAULT \'\'',
      );
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS meal_photos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          profileId INTEGER NOT NULL,
          date TEXT NOT NULL,
          mealType TEXT NOT NULL,
          path TEXT NOT NULL,
          FOREIGN KEY (profileId) REFERENCES profiles(id)
        )
      ''');
    }
    if (oldVersion < 5) {
      // Una sola reacción por (perfil, fecha, comida) para evitar
      // que updateReaction/deleteReaction reescriban múltiples filas.
      await db.execute('''
        CREATE UNIQUE INDEX IF NOT EXISTS idx_reactions_section
          ON reactions(profileId, date, mealType)
      ''');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE profiles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        age INTEGER DEFAULT 0,
        category TEXT NOT NULL,
        photoUri TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE meal_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profileId INTEGER NOT NULL,
        date TEXT NOT NULL,
        mealType TEXT NOT NULL,
        foodItemsText TEXT NOT NULL,
        hasReaction INTEGER DEFAULT 0,
        reactionSymptoms TEXT DEFAULT '',
        reactionSeverity TEXT DEFAULT '',
        loggedAt TEXT,
        photoPaths TEXT DEFAULT '',
        FOREIGN KEY (profileId) REFERENCES profiles(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE allergens (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profileId INTEGER NOT NULL,
        name TEXT NOT NULL,
        FOREIGN KEY (profileId) REFERENCES profiles(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE reactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profileId INTEGER NOT NULL,
        date TEXT NOT NULL,
        mealType TEXT NOT NULL,
        description TEXT DEFAULT '',
        symptoms TEXT DEFAULT '',
        FOREIGN KEY (profileId) REFERENCES profiles(id)
      )
    ''');
    await db.execute('''
      CREATE UNIQUE INDEX idx_reactions_section
        ON reactions(profileId, date, mealType)
    ''');

    await db.execute('''
      CREATE TABLE meal_photos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profileId INTEGER NOT NULL,
        date TEXT NOT NULL,
        mealType TEXT NOT NULL,
        path TEXT NOT NULL,
        FOREIGN KEY (profileId) REFERENCES profiles(id)
      )
    ''');

    for (final s in kDefaultSettings) {
      await db.execute(
        'INSERT OR IGNORE INTO settings (key, value) VALUES (?, ?)',
        [s.$1, s.$2],
      );
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}

/// Defaults sembrados al crear la base de datos y al ejecutar
/// `clearCache`. Compartidos con [KeComoRepository].
const List<(String, String)> kDefaultSettings = [
  ('meal_config', 'Ambos'),
  ('dark_mode', 'false'),
  ('reminders_enabled', 'true'),
  ('safety_alerts_enabled', 'true'),
];
