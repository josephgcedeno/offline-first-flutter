import 'package:flirt/core/infrastructures/caching/database.dart';
import 'package:flirt/core/infrastructures/caching/database_constant.dart';
import 'package:flirt/core/infrastructures/repository/local_repository.dart';
import 'package:sqflite/sqlite_api.dart';

class QuoteCache {
  final DatabaseManager databaseManager = DatabaseManager();

  Future<List<Quotes>> getItems() async => await _getLocalItems();

  Future<void> saveToLocal(List<Quotes> response) async {
    for (int i = 0; i < response.length; i++) {
      await _insert(response[i]);
    }
  }

  Future<List<Quotes>> _getLocalItems() async {
    final Database dbInstance = await databaseManager.instance;

    final List<Map<String, dynamic>> maps = await dbInstance.query(quotesTable);

    return List<Quotes>.generate(maps.length, (int i) {
      return Quotes(
        quote: maps[i]['name'] as String,
      );
    });
  }

  Future<int> _insert(Quotes item) async {
    final Database dbInstance = await databaseManager.instance;

    return await dbInstance.insert('quotesTable', item.toMap());
  }

  Future<void> truncateRecord() async {
    final Database dbInstance = await databaseManager.instance;

    dbInstance.batch()
      ..delete(quotesTable)
      ..commit(noResult: true);
  }
}
