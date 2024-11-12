// ignore_for_file: depend_on_referenced_packages, directives_ordering

import 'package:flirt/core/infrastructures/caching/database_constant.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseManager {
  Database? _database;

  Future<Database> get instance async => _database ??= await initializeDb();

  Future<Database> initializeDb() async => _database = await openDatabase(
        join(await getDatabasesPath(), 'SampleApp2.db'),
        version: 1,
        onCreate: (Database db, int version) async {
          await db.execute(
            'CREATE TABLE $quotesTable(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name TEXT, createdAt INTEGER, synced INTEGER)',
          );

          await db.execute(
            'CREATE TABLE $catsTable(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name TEXT, createdAt INTEGER, synced INTEGER)',
          );

          await db.execute(
            'CREATE TABLE $employeesTable(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name TEXT, createdAt INTEGER, synced INTEGER, EMPLOYEE_ID INTEGER, FIRST_NAME TEXT, LAST_NAME TEXT, EMAIL TEXT, PHONE_NUMBER TEXT, HIRE_DATE TEXT, JOB_ID TEXT, SALARY REAL, COMMISSION_PCT REAL, MANAGER_ID INTEGER, action TEXT, createdDate INTEGER, localId TEXT, modifiedDate INTEGER, synced INTEGER)',
          );
        },
      );
}
