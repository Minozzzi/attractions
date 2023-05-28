import 'dart:math';

import 'package:attractions/src/domain/attraction.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  static const _dbName = 'attractions.db';
  static const _dbVersion = 2;

  DatabaseProvider._init();
  static final DatabaseProvider instance = DatabaseProvider._init();

  Database? _database;

  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final dbPath = '$databasesPath/$_dbName';

    return await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE IF NOT EXISTS ${Attraction.TABLE_NAME} (
        ${Attraction.FIELD_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Attraction.FIELD_NAME} TEXT NOT NULL,
        ${Attraction.FIELD_DESCRIPTION} TEXT,
        ${Attraction.FIELD_DIFFERENTIALS} TEXT,
        ${Attraction.FIELD_LATITUDE} TEXT,
        ${Attraction.FIELD_LONGITUDE} TEXT,
        ${Attraction.FIELD_CREATED_AT} TEXT NOT NULL);
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    switch(oldVersion) {
      case 1:
        await db.execute('''
          ALTER TABLE ${Attraction.TABLE_NAME} ADD COLUMN ${Attraction.FIELD_LATITUDE} TEXT;
          ALTER TABLE ${Attraction.TABLE_NAME} ADD COLUMN ${Attraction.FIELD_LONGITUDE} TEXT;
        ''');
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
    }
  }
}
