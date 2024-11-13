// ignore_for_file: depend_on_referenced_packages, directives_ordering

import 'dart:convert';

import 'package:flirt/core/domain/repository/secure_storage_repository.dart';
import 'package:flirt/core/infrastructures/caching/database_constant.dart';
import 'package:flirt/core/infrastructures/repository/secure_storage_repository.dart';
import 'package:flirt/internal/local_storage.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseManager {
  final ISecureStorageRepository _storage = SecureStorageRepository();
  Database? _database;

  Future<Database> get instance async => _database ??= await initializeDb();

  Future<Database> initializeDb() async => _database = await openDatabase(
        join(await getDatabasesPath(), 'SampleApp3.db'),
        version: 1,
        onCreate: (Database db, int version) async {
          await db.execute(
            'CREATE TABLE $quotesTable(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name TEXT, createdAt INTEGER, synced INTEGER)',
          );

          await db.execute(
            'CREATE TABLE $catsTable(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name TEXT, createdAt INTEGER, synced INTEGER)',
          );

          await db.execute(
            'CREATE TABLE $employeesTable(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, EMPLOYEE_ID INTEGER, FIRST_NAME TEXT, LAST_NAME TEXT, EMAIL TEXT, PHONE_NUMBER TEXT, HIRE_DATE TEXT, JOB_ID TEXT, SALARY REAL, COMMISSION_PCT REAL, MANAGER_ID INTEGER, action TEXT, createdDate INTEGER, localId TEXT, modifiedDate INTEGER, synced INTEGER)',
          );
        },
      );

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
}
