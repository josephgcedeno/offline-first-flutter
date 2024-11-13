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
        await dbInstance.query(employeesTable, where: 'action IS NOT "delete"');

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

    item.localId = DateTime.now().millisecondsSinceEpoch.toString();

    await dbInstance.insert(
      table,
      item.toJsonInsertRecord(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await databaseManager.setModifiedTable(table);
  }

  Future<void> updateItem(
    EmployeeRequest item, {
    String table = employeesTable,
  }) async {
    final Database dbInstance = await databaseManager.instance;

    /// When local id is just null, meaning that the record is not on the remote, we could simply use the default value of it.
    item.action = item.localId != null ? item.action : 'update';

    await dbInstance.update(
      employeesTable,
      item.toJsonInsertRecord(),
      where: item.localId == null ? 'EMPLOYEE_ID = ?' : 'localId = ?',
      whereArgs: <dynamic>[
        if (item.localId == null) item.employeeId else item.localId!,
      ],
    );

    await databaseManager.setModifiedTable(table);
  }

  Future<void> deleteItem(
    String employeeId, {
    String table = employeesTable,
  }) async {
    final Database dbInstance = await databaseManager.instance;

    final List<Map<String, dynamic>> maps = await dbInstance.query(
      employeesTable,
      where: 'EMPLOYEE_ID = $employeeId',
    );
    final Map<String, dynamic> item = Map<String, dynamic>.from(maps.first);
    final String? localId = item['localId'] as String?;

    /// If record from remote just update action to delete
    if (localId == null) {
      item.update('action', (_) => 'delete');
      await dbInstance.update(
        employeesTable,
        item,
        where: 'EMPLOYEE_ID = $employeeId',
      );
    } else {
      /// If from local record, just simply delete it.
      await dbInstance.delete(
        employeesTable,
        where: 'localId = $localId',
      );
    }

    await databaseManager.setModifiedTable(table);
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
      where: 'synced = 0 OR action IS NOT NULL',
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
