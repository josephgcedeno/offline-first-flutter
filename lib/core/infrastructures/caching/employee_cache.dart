import 'package:flirt/core/domain/models/employee/employee_request.dart';
import 'package:flirt/core/domain/models/employee/employee_response.dart';
import 'package:flirt/core/infrastructures/caching/database.dart';
import 'package:flirt/core/infrastructures/caching/database_constant.dart';
import 'package:sqflite/sqflite.dart';

class EmployeeCache {
  final DatabaseManager databaseManager = DatabaseManager();

  Future<List<EmployeeResponse>> getItems() async => await _getLocalItems();

  Future<void> saveToLocal(List<EmployeeResponse> response) async {
    /// truncate data
    await truncateRecord(employeesTable);

    for (int i = 0; i < response.length; i++) {
      await _insert(response[i]);
    }
  }

  Future<List<EmployeeResponse>> _getLocalItems() async {
    final Database dbInstance = await databaseManager.instance;

    final List<Map<String, dynamic>> maps =
        await dbInstance.query(employeesTable);

    return List<EmployeeResponse>.generate(
      maps.length,
      (int i) => EmployeeResponse.fromJson(maps[i]),
    );
  }

  Future<void> insertSingleItem(
    EmployeeRequest item, {
    String table = employeesTable,
  }) async {
    final Database dbInstance = await databaseManager.instance;

    await dbInstance.insert(
      table,
      item.toJsonInsertRecord(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await databaseManager.setModifiedTable(table);
  }

  Future<void> updateItem(EmployeeRequest item) async {
    final Database dbInstance = await databaseManager.instance;

    await dbInstance.update(
      employeesTable,
      item.toJsonInsertRecord(),
      where: 'EMPLOYEE_ID = ?',
      whereArgs: <int>[item.employeeId],
    );
  }

  Future<int> _insert(EmployeeResponse item) async {
    final Database dbInstance = await databaseManager.instance;

    return await dbInstance.insert(
      employeesTable,
      item.toJsonInsertRecord(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<T>> getUnsyncedData<T>(String table) async {
    final Database dbInstance = await databaseManager.instance;

    final List<Map<String, dynamic>> maps = await dbInstance.query(
      table,
      where: 'synced = ?',
      whereArgs: <int>[0],
      orderBy: 'modifiedDate DESC',
    );

    if (T == EmployeeResponse) {
      return List<T>.generate(
        maps.length,
        (int i) => EmployeeResponse.fromJson(maps[i]) as T,
      );
    }
    return <T>[];
  }

  Future<void> truncateRecord(String table) async {
    final Database dbInstance = await databaseManager.instance;

    dbInstance.batch()
      ..delete(table)
      ..commit(noResult: true);
  }
}
