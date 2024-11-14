import 'dart:convert';

import 'package:flirt/core/domain/models/employee/employee_request.dart';
import 'package:flirt/core/domain/models/employee/employee_response.dart';
import 'package:flirt/core/domain/repository/secure_storage_repository.dart';
import 'package:flirt/core/infrastructures/caching/database_constant.dart';
import 'package:flirt/core/infrastructures/repository/employee_repository.dart';
import 'package:flirt/internal/enums.dart';
import 'package:flirt/internal/local_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'sync_state.dart';

/// Sync Cubit is a global cubit that emits any changes in connectivity status as well as execute syncing of data
class SyncCubit extends Cubit<SyncState> {
  SyncCubit({
    required this.storage,
    required this.employeeRepository,
  }) : super(SyncState());
  final EmployeeRepository employeeRepository;
  final ISecureStorageRepository storage;

  late Map<String, void Function()> tablesMap = <String, void Function()>{
    employeesTable: _syncEmployeeRecords,
  };

  /// Emits a state change based on connectivity status.
  void updateConnectivityStatus(bool connected) =>
      emit(ConnectivityStatus(connected: connected));

  /// Initiates data synchronization when the device is online.
  /// This function fetches modified tables, syncs employee records, and updates the state accordingly.
  Future<void> syncData() async {
    emit(SyncDataLoading());
    try {
      final String storedData =
          await storage.read(key: lsModifiedTable) ?? '[]';

      final List<String> modifiedTables =
          List<String>.from(jsonDecode(storedData) as List<dynamic>);

      for (final String table in modifiedTables) {
        tablesMap[table]!.call();
      }

      emit(SyncDataSuccess());
    } catch (e) {
      emit(SyncDataFailed());
    }
  }

  /// Syncs employee records.
  Future<void> _syncEmployeeRecords() async {
    try {
      final List<EmployeeResponse> unsyncedData = await employeeRepository
          .employeeCache
          .getUnsyncedData<EmployeeResponse>(employeesTable);

      if (unsyncedData.isEmpty) return;

      for (final EmployeeResponse employee in unsyncedData) {
        switch (employee.action) {
          case Action.create:
            await employeeRepository.addEmployee(
              EmployeeRequest(
                employeeId: employee.employeeId,
                firstName: employee.firstName,
                lastName: employee.lastName,
                email: employee.email,
                phoneNumber: employee.phoneNumber,
                hireDate: employee.hireDate,
                jobId: employee.jobId,
                salary: employee.salary,
                commissionPct: employee.commissionPct,
                managerId: employee.managerId,
              ),
              syncing: true,
            );
          case Action.update:
            await employeeRepository.updateEmployee(
              EmployeeRequest(
                employeeId: employee.employeeId,
                firstName: employee.firstName,
                lastName: employee.lastName,
                email: employee.email,
                phoneNumber: employee.phoneNumber,
                hireDate: employee.hireDate,
                jobId: employee.jobId,
                salary: employee.salary,
                commissionPct: employee.commissionPct,
                managerId: employee.managerId,
              ),
              syncing: true,
            );
          case Action.delete:
            await employeeRepository.deleteEmployee(
              employee.employeeId,
              syncing: true,
            );

          default:
        }
      }

      if (!await employeeRepository.deviceIsOnline) return;
      await employeeRepository.employeeCache.truncateRecord(employeesTable);
    } catch (e) {
      rethrow;
    }
  }
}
