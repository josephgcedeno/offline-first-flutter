import 'dart:convert';

import 'package:flirt/core/domain/models/employee/employee_request.dart';
import 'package:flirt/core/domain/models/employee/employee_response.dart';
import 'package:flirt/core/domain/repository/secure_storage_repository.dart';
import 'package:flirt/core/infrastructures/caching/database.dart';
import 'package:flirt/core/infrastructures/caching/database_constant.dart';
import 'package:flirt/core/infrastructures/repository/secure_storage_repository.dart';
import 'package:flirt/internal/local_storage.dart';
import 'package:sqflite/sqflite.dart';

class EmployeeCache {
  final ISecureStorageRepository _storage = SecureStorageRepository();
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

    await setModifiedTable(table);
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

  Future<void> setModifiedTable(String table) async {
    final String modifieTables =
        await _storage.read(key: lsModifiedTable) ?? '[]';
    final List<String> items =
        List<String>.from(jsonDecode(modifieTables) as List<dynamic>);

    if (items.contains(table)) {
      items.remove(table);
    }

    items.insert(0, table);

    await _storage.write(key: lsModifiedTable, value: jsonEncode(items));
  }

  Future<void> truncateRecord() async {
    final Database dbInstance = await databaseManager.instance;

    dbInstance.batch()
      ..delete(employeesTable)
      ..commit(noResult: true);
  }
}
