import 'package:flirt/core/infrastructures/caching/database.dart';
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
    if (databaseManager.database == null) {
      await databaseManager.open();
    }
    final List<Map<String, dynamic>> maps =
        await databaseManager.instance.query('catsTable');
    // ignore: always_specify_types
    return List.generate(maps.length, (int i) {
      return Cats(
        cat: maps[i]['name'] as String,
      );
    });
  }

  Future<int> _insert(Cats item) async {
    if (databaseManager.database == null) {
      await databaseManager.open();
    }
    return await databaseManager.instance.insert(
      'catsTable',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
