import 'package:flirt/core/infrastructures/caching/database.dart';
import 'package:flirt/core/infrastructures/caching/database_constant.dart';
import 'package:flirt/core/infrastructures/repository/local_repository.dart';
import 'package:sqflite/sqflite.dart';

class CatCache {
  final DatabaseManager databaseManager = DatabaseManager();

  Future<List<Cats>> getItems() async => await _getLocalItems();

  Future<void> saveToLocal(List<Cats> response) async {
    for (int i = 0; i < response.length; i++) {
      await _insert(response[i]);
    }
  }

  Future<List<Cats>> _getLocalItems() async {
    final Database dbInstance = await databaseManager.instance;

    final List<Map<String, dynamic>> maps = await dbInstance.query(catsTable);

    return List<Cats>.generate(maps.length, (int i) {
      return Cats(
        cat: maps[i]['name'] as String,
      );
    });
  }

  Future<int> _insert(Cats item) async {
    final Database dbInstance = await databaseManager.instance;

    return await dbInstance.insert(
      catsTable,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> truncateRecord() async {
    final Database dbInstance = await databaseManager.instance;

    dbInstance.batch()
      ..delete(catsTable)
      ..commit(noResult: true);
  }
}
