import 'package:sqflite/sqflite.dart';
import 'models/profile.dart';
import 'models/meal_log.dart';
import 'models/meal_photo.dart';
import 'models/allergen.dart';
import 'models/reaction.dart';
import 'models/setting.dart';
import 'database_helper.dart';

class KeComoRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<Database> get _db => _dbHelper.database;

  Future<List<Profile>> getAllProfiles() async {
    final db = await _db;
    final maps = await db.query('profiles');
    return maps.map((m) => Profile.fromMap(m)).toList();
  }

  Future<Profile?> getProfileById(int id) async {
    final db = await _db;
    final maps = await db.query('profiles', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Profile.fromMap(maps.first);
  }

  Future<int> insertProfile(Profile profile) async {
    final db = await _db;
    return await db.insert('profiles', profile.toMap());
  }

  Future<void> updateProfile(int id, String aliasName, String? photoUri) async {
    final db = await _db;
    await db.update(
      'profiles',
      {'firstName': aliasName, 'photoUri': photoUri},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateProfileFull(Profile profile) async {
    final db = await _db;
    await db.update(
      'profiles',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  Future<List<MealLog>> getMealLogsByProfileId(int profileId) async {
    final db = await _db;
    final maps = await db.query('meal_logs',
        where: 'profileId = ?', whereArgs: [profileId]);
    return maps.map((m) => MealLog.fromMap(m)).toList();
  }

  Future<List<MealLog>> getMealLogsByDate(int profileId, String date) async {
    final db = await _db;
    final maps = await db.query('meal_logs',
        where: 'profileId = ? AND date = ?',
        whereArgs: [profileId, date]);
    return maps.map((m) => MealLog.fromMap(m)).toList();
  }

  Future<List<MealLog>> getMealLogsByDateRange(
      int profileId, String from, String to) async {
    final db = await _db;
    final maps = await db.query('meal_logs',
        where: 'profileId = ? AND date >= ? AND date <= ?',
        whereArgs: [profileId, from, to]);
    return maps.map((m) => MealLog.fromMap(m)).toList();
  }

  Future<int> insertMealLog(MealLog mealLog) async {
    final db = await _db;
    return await db.insert('meal_logs', mealLog.toMap());
  }

  Future<void> deleteMealLog(int id) async {
    final db = await _db;
    await db.delete('meal_logs', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteMealLogsByDateAndMealType(
      int profileId, String date, String mealType) async {
    final db = await _db;
    await db.delete('meal_logs',
        where: 'profileId = ? AND date = ? AND mealType = ?',
        whereArgs: [profileId, date, mealType]);
  }

  Future<void> clearAllMealLogs() async {
    final db = await _db;
    await db.delete('meal_logs');
  }

  Future<void> updateMealLogText(int id, String newText) async {
    final db = await _db;
    await db.update(
      'meal_logs',
      {'foodItemsText': newText},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateMealLog(MealLog log) async {
    final db = await _db;
    await db.update(
      'meal_logs',
      log.toMap(),
      where: 'id = ?',
      whereArgs: [log.id],
    );
  }

  Future<List<MealPhoto>> getMealPhotosBySection(
      int profileId, String date, String mealType) async {
    final db = await _db;
    final maps = await db.query(
      'meal_photos',
      where: 'profileId = ? AND date = ? AND mealType = ?',
      whereArgs: [profileId, date, mealType],
      orderBy: 'id ASC',
    );
    return maps.map(MealPhoto.fromMap).toList();
  }

  Future<int> insertMealPhoto(MealPhoto photo) async {
    final db = await _db;
    return db.insert('meal_photos', photo.toMap());
  }

  Future<void> deleteMealPhoto(int id) async {
    final db = await _db;
    await db.delete('meal_photos', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteMealPhotosBySection(
      int profileId, String date, String mealType) async {
    final db = await _db;
    await db.delete(
      'meal_photos',
      where: 'profileId = ? AND date = ? AND mealType = ?',
      whereArgs: [profileId, date, mealType],
    );
  }

  Future<List<Allergen>> getAllergensByProfileId(int profileId) async {
    final db = await _db;
    final maps = await db.query('allergens',
        where: 'profileId = ?', whereArgs: [profileId]);
    return maps.map((m) => Allergen.fromMap(m)).toList();
  }

  Future<int> insertAllergen(Allergen allergen) async {
    final db = await _db;
    return await db.insert('allergens', allergen.toMap());
  }

  Future<void> updateAllergen(Allergen allergen) async {
    if (allergen.id == null) {
      throw ArgumentError(
        'updateAllergen requiere allergen.id; use insertAllergen para nuevos.',
      );
    }
    final db = await _db;
    await db.update(
      'allergens',
      allergen.toMap(),
      where: 'id = ?',
      whereArgs: [allergen.id],
    );
  }

  Future<void> deleteAllergen(int id) async {
    final db = await _db;
    await db.delete('allergens', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllAllergens(int profileId) async {
    final db = await _db;
    await db.delete('allergens', where: 'profileId = ?', whereArgs: [profileId]);
  }

  Future<List<Setting>> getAllSettings() async {
    final db = await _db;
    final maps = await db.query('settings');
    return maps.map((m) => Setting.fromMap(m)).toList();
  }

  Future<String?> getSettingValue(String key) async {
    final db = await _db;
    final maps = await db.query('settings',
        where: 'key = ?', whereArgs: [key]);
    if (maps.isEmpty) return null;
    return maps.first['value'] as String?;
  }

  Future<void> insertSetting(Setting setting) async {
    final db = await _db;
    await db.insert('settings', setting.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Reaction>> getReactionsByDate(
      int profileId, String date) async {
    final db = await _db;
    final maps = await db.query('reactions',
        where: 'profileId = ? AND date = ?',
        whereArgs: [profileId, date]);
    return maps.map((m) => Reaction.fromMap(m)).toList();
  }

  Future<List<Reaction>> getAllReactions(int profileId) async {
    final db = await _db;
    final maps = await db.query('reactions',
        where: 'profileId = ?', whereArgs: [profileId]);
    return maps.map((m) => Reaction.fromMap(m)).toList();
  }

  Future<Reaction?> getReaction(
      int profileId, String date, String mealType) async {
    final db = await _db;
    final maps = await db.query('reactions',
        where: 'profileId = ? AND date = ? AND mealType = ?',
        whereArgs: [profileId, date, mealType]);
    if (maps.isEmpty) return null;
    return Reaction.fromMap(maps.first);
  }

  Future<int> insertReaction(Reaction reaction) async {
    final db = await _db;
    return await db.insert('reactions', reaction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateReaction(Reaction reaction) async {
    if (reaction.id == null) {
      throw ArgumentError(
        'updateReaction requiere reaction.id; use insertReaction para nuevas.',
      );
    }
    final db = await _db;
    await db.update('reactions', reaction.toMap(),
        where: 'id = ?', whereArgs: [reaction.id]);
  }

  Future<void> deleteReactionById(int id) async {
    final db = await _db;
    await db.delete('reactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Reaction>> getReactionsByDateRange(
      int profileId, String from, String to) async {
    final db = await _db;
    final maps = await db.query('reactions',
        where: 'profileId = ? AND date >= ? AND date <= ?',
        whereArgs: [profileId, from, to]);
    return maps.map((m) => Reaction.fromMap(m)).toList();
  }

  Future<void> clearAllReactions() async {
    final db = await _db;
    await db.delete('reactions');
  }

  Future<void> clearCache() async {
    final db = await _db;
    await db.delete('meal_logs');
    await db.delete('allergens');
    await db.delete('reactions');
    await _populateDefaults(db);
  }

  Future<void> _populateDefaults(Database db) async {
    for (final s in kDefaultSettings) {
      await db.execute(
        'INSERT OR IGNORE INTO settings (key, value) VALUES (?, ?)',
        [s.$1, s.$2],
      );
    }
  }
}
