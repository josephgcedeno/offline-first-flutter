import 'package:flirt/core/infrastructures/caching/database.dart';
import 'package:flirt/core/infrastructures/repository/local_repository.dart';

class QuoteCache {
  final DatabaseManager databaseManager = DatabaseManager();

  Future<List<Quotes>> getItems() async => await _getLocalItems();

  Future<void> saveToLocal(List<Quotes> response) async {
    for (int i = 0; i < response.length; i++) {
      await _insert(response[i]);
    }
  }

  Future<List<Quotes>> _getLocalItems() async {
    if (databaseManager.database == null) {
      await databaseManager.open();
    }
    final List<Map<String, dynamic>> maps =
        await databaseManager.instance.query('quotesTable');

    return List<Quotes>.generate(maps.length, (int i) {
      return Quotes(
        quote: maps[i]['name'] as String,
      );
    });
  }

  Future<int> _insert(Quotes item) async {
    if (databaseManager.database == null) {
      await databaseManager.open();
    }

    return await databaseManager.instance.insert('quotesTable', item.toMap());
  }
}
