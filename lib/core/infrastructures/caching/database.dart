// ignore_for_file: depend_on_referenced_packages, directives_ordering

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseManager {
  Database? database;

  Future<void> open() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'crud_database2.db'),
      version: 1,
      onCreate: (Database db, int version) async {
        // await db.execute(
        //   'CREATE TABLE items(id INTEGER PRIMARY KEY, name TEXT, value INTEGER, isSync TEXT)',
        // );
        await db.execute(
          'CREATE TABLE quotesTable(id INTEGER PRIMARY KEY, name TEXT)',
        );

        await db.execute(
          'CREATE TABLE catsTable(id INTEGER PRIMARY KEY, name TEXT)',
        );
      },
    );
  }

  Database get instance => database!;

  // Future<List<Item>> getUnsyncedItems() async {
  //   final List<Map<String, dynamic>> maps = await database!.query(
  //     'items',
  //     where: 'isSync = ?',
  //     whereArgs: <String>['false'],
  //   );

  //   return List.generate(maps.length, (int i) {
  //     return Item(
  //       id: maps[i]['id'] as int,
  //       name: maps[i]['name'] as String,
  //       value: maps[i]['value'] as int,
  //       isSync: maps[i]['isSync'] as String == 'true',
  //     );
  //   });
  // }

  // Future<List<Item>> getItems() async {
  //   final List<Map<String, dynamic>> maps = await database!.query('items');

  //   return List.generate(maps.length, (int i) {
  //     return Item(
  //       id: maps[i]['id'] as int,
  //       name: maps[i]['name'] as String,
  //       value: maps[i]['value'] as int,
  //       isSync: maps[i]['isSync'] as String == 'true',
  //     );
  //   });
  // }
}
