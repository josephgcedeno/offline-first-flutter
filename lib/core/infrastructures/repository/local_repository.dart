// ignore_for_file: use_late_for_private_fields_and_variables, depend_on_referenced_packages, always_specify_types

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalRepository {
  Database? database;

  Future<void> open() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'crud_database1.db'),
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          'CREATE TABLE items(id INTEGER PRIMARY KEY, name TEXT, value INTEGER, isSync TEXT)',
        );
      },
    );
  }

  Future<int> insert(Item item) async {
    final int? existingId = await database!.query(
      'items',
      where: 'id = ?',
      whereArgs: <int>[item.id],
    ).then(
      (List<Map<String, dynamic>> maps) =>
          maps.isNotEmpty ? maps.first['id'] as int : null,
    );

    if (existingId == null) {
      return await database!.insert('items', item.toMap());
    } else {
      return existingId;
    }
  }

  Future<List<Item>> getUnsyncedItems() async {
    final List<Map<String, dynamic>> maps = await database!.query(
      'items',
      where: 'isSync = ?',
      whereArgs: <String>['false'],
    );

    return List.generate(maps.length, (int i) {
      return Item(
        id: maps[i]['id'] as int,
        name: maps[i]['name'] as String,
        value: maps[i]['value'] as int,
        isSync: maps[i]['isSync'] as String == 'true',
      );
    });
  }

  Future<List<Item>> getItems() async {
    final List<Map<String, dynamic>> maps = await database!.query('items');

    return List.generate(maps.length, (int i) {
      return Item(
        id: maps[i]['id'] as int,
        name: maps[i]['name'] as String,
        value: maps[i]['value'] as int,
        isSync: maps[i]['isSync'] as String == 'true',
      );
    });
  }

  Future<void> clearAllItems() async {
    await database!.execute('DELETE FROM items');
  }

  Future<int> update(Item item) async {
    return await database!.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: <Object?>[item.id],
    );
  }
}

class Item {
  Item({
    required this.id,
    required this.name,
    required this.value,
    this.isSync = false,
  });
  final int id;
  final String name;
  final int value;
  bool isSync;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'value': value,
      'isSync': isSync.toString(),
    };
  }
}

class Quotes {
  Quotes({
    required this.quote,
    this.synced,
  });
  final String quote;
  int? synced;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': quote,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'synced': synced ?? 0,
    };
  }
}

class Cats {
  Cats({
    required this.cat,
    this.synced,
  });
  final String cat;
  int? synced;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': cat,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'synced': synced ?? 0,
    };
  }
}
