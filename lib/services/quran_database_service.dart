import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/surah.dart';
import '../models/parah.dart';
import '../models/ayah.dart';

class QuranDatabaseService {
  // singleton
  static final QuranDatabaseService _instance =
      QuranDatabaseService._internal();
  static Database? _database;

  factory QuranDatabaseService() {
    return _instance;
  }

  QuranDatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    await _ensureTablesExist(_database!); // ensure schema
    return _database!;
  }

  Future<void> _ensureTablesExist(Database db) async {
    try {
      // probe ayahs
      await db.rawQuery('SELECT 1 FROM ayahs LIMIT 1');
    } catch (e) {
      print('⚠ Ayahs table missing, creating it...');
      // create if missing
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ayahs(
          id INTEGER PRIMARY KEY,
          number INTEGER NOT NULL,
          numberInSurah INTEGER NOT NULL,
          text TEXT NOT NULL,
          textArabic TEXT NOT NULL,
          surahNumber INTEGER NOT NULL,
          UNIQUE(surahNumber, numberInSurah)
        )
      ''');
      print('✓ Ayahs table created successfully');
    }
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'islamify_quran.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createTables, // v1 schema
      onUpgrade: _upgradeTables, // migrations
    );
  }

  Future<void> _upgradeTables(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    print('Upgrading database from version $oldVersion to $newVersion');

    if (oldVersion < 2) {
      // add ayahs
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ayahs(
          id INTEGER PRIMARY KEY,
          number INTEGER NOT NULL,
          numberInSurah INTEGER NOT NULL,
          text TEXT NOT NULL,
          textArabic TEXT NOT NULL,
          surahNumber INTEGER NOT NULL,
          UNIQUE(surahNumber, numberInSurah)
        )
      ''');
      print('✓ Created ayahs table');
    }
  }

  Future<void> _createTables(Database db, int version) async {
    // table: surahs
    await db.execute('''
      CREATE TABLE surahs(
        id INTEGER PRIMARY KEY,
        number INTEGER UNIQUE NOT NULL,
        name TEXT NOT NULL,
        nameArabic TEXT NOT NULL,
        verses INTEGER NOT NULL,
        revelationType TEXT NOT NULL,
        englishName TEXT NOT NULL,
        englishNameTranslation TEXT NOT NULL
      )
    ''');

    // table: parahs
    await db.execute('''
      CREATE TABLE parahs(
        id INTEGER PRIMARY KEY,
        number INTEGER UNIQUE NOT NULL,
        name TEXT NOT NULL,
        startSurah INTEGER NOT NULL,
        startVerse INTEGER NOT NULL,
        endSurah INTEGER NOT NULL,
        endVerse INTEGER NOT NULL
      )
    ''');

    // table: ayahs
    await db.execute('''
      CREATE TABLE ayahs(
        id INTEGER PRIMARY KEY,
        number INTEGER NOT NULL,
        numberInSurah INTEGER NOT NULL,
        text TEXT NOT NULL,
        textArabic TEXT NOT NULL,
        surahNumber INTEGER NOT NULL,
        UNIQUE(surahNumber, numberInSurah)
      )
    ''');
  }

  // SURAH OPS

  Future<void> saveSurahs(List<Surah> surahs) async {
    final db = await database;
    final batch = db.batch();

    for (final surah in surahs) {
      batch.insert(
        'surahs',
        surah.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }

  Future<List<Surah>> getSurahs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('surahs');

    if (maps.isEmpty) {
      return [];
    }

    return List<Surah>.from(maps.map((x) => Surah.fromJson(x)));
  }

  Future<Surah?> getSurah(int number) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'surahs',
      where: 'number = ?',
      whereArgs: [number],
    );

    if (maps.isEmpty) return null;
    return Surah.fromJson(maps.first);
  }

  Future<int> getSurahCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM surahs');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // PARAH OPS

  Future<void> saveParahs(List<Parah> parahs) async {
    final db = await database;
    final batch = db.batch();

    for (final parah in parahs) {
      batch.insert(
        'parahs',
        parah.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }

  Future<List<Parah>> getParahs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('parahs');

    if (maps.isEmpty) {
      return [];
    }

    return List<Parah>.from(maps.map((x) => Parah.fromJson(x)));
  }

  Future<Parah?> getParah(int number) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'parahs',
      where: 'number = ?',
      whereArgs: [number],
    );

    if (maps.isEmpty) return null;
    return Parah.fromJson(maps.first);
  }

  Future<int> getParahCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM parahs');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // AYAH OPS

  Future<void> saveAyahs(List<Ayah> ayahs) async {
    final db = await database;

    if (ayahs.isEmpty) return;

    final surahNumber = ayahs.first.surahNumber;

    // clear old (by surah)
    await db.delete(
      'ayahs',
      where: 'surahNumber = ?',
      whereArgs: [surahNumber],
    );
    print('✓ Cleared old Ayahs for Surah $surahNumber');

    final batch = db.batch();

    for (final ayah in ayahs) {
      batch.insert(
        'ayahs',
        ayah.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
    print(
      '✓ Saved ${ayahs.length} Ayahs with fresh data for Surah $surahNumber',
    );
  }

  Future<List<Ayah>> getAyahsBySurah(int surahNumber) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ayahs',
      where: 'surahNumber = ?',
      whereArgs: [surahNumber],
      orderBy: 'numberInSurah ASC',
    );

    if (maps.isEmpty) {
      return [];
    }

    return List<Ayah>.from(maps.map((x) => Ayah.fromJson(x)));
  }

  Future<int> getAyahCountBySurah(int surahNumber) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ayahs WHERE surahNumber = ?',
      [surahNumber],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // UTIL

  Future<bool> isQuranDataCached() async {
    final surahCount = await getSurahCount();
    final parahCount = await getParahCount();
    return surahCount > 0 && parahCount > 0;
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('surahs');
    await db.delete('parahs');
    await db.delete('ayahs');
  }
}
