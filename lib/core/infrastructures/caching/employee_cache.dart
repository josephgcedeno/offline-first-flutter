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
    await truncateRecord();

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

  Future<void> insertSingleItem(EmployeeRequest item) async {
    final Database dbInstance = await databaseManager.instance;

    await dbInstance.insert(
      employeesTable,
      item.toJsonInsertRecord(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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

  Future<void> truncateRecord() async {
    final Database dbInstance = await databaseManager.instance;

    dbInstance.batch()
      ..delete(employeesTable)
      ..commit(noResult: true);
  }
}
