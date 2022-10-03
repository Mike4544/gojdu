import 'package:sqflite/sqflite.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:path/path.dart';

import '../widgets/Alert.dart';

class AlertDatabase {
  static final AlertDatabase instance = AlertDatabase._init();

  static Database? _database;

  AlertDatabase._init();


  Future<Database> get database async {
    if(_database != null) return _database!;

    _database = await _initDB('alerts.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);

  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const boolType = 'BOOLEAN NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const stringType = 'TEXT NOT NULL';



    await db.execute('''
    CREATE TABLE $tableAlerts (
    ${AlertFields.id} $idType,
    ${AlertFields.read} $boolType,
    ${AlertFields.title} $stringType,
    ${AlertFields.description} $stringType,
    ${AlertFields.imageString} $stringType,
    ${AlertFields.time} $stringType,
    ${AlertFields.owner} $stringType,
    ${AlertFields.shared} $boolType
    )
    ''');

  }

  Future<Alert> create(Alert note) async {
    final db = await instance.database;

    final id = await db.insert(tableAlerts, note.toJson());
    return note.copy(id: id);

  }

  Future<Alert> readAlert(int id) async {
    final db = await instance.database;

    final maps = await db.query(
        tableAlerts,
        columns: AlertFields.values,
        where: '${AlertFields.id} = ?',
        whereArgs: [id]
    );

    if(maps.isNotEmpty) {
      return Alert.fromJson(maps.first);
    }
    else {
      throw Exception('ID $id not found');
    }

  }

  Future<List<Alert>> readAllAlerts() async {
    final db = await instance.database;

    const orderBy = '${AlertFields.time} DESC';
    final result = await db.query(tableAlerts, orderBy: orderBy);

    return result.map((json) => Alert.fromJson(json)).toList();
  }

  Future truncate() async {
    final db = await instance.database;

    return await db.delete(tableAlerts);
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }

  Future<int> update(Alert alert) async {
    final db = await instance.database;

    return db.update(
        tableAlerts,
        alert.toJson(),
        where: '${AlertFields.id} = ?',
        whereArgs: [alert.id]
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return db.delete(
      tableAlerts,
      where: "${AlertFields.id} = ?",
      whereArgs: [id],
    );
  }


}