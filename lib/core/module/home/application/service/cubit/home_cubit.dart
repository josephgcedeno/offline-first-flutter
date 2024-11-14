import 'dart:convert';

import 'package:flirt/core/domain/models/employee/employee_request.dart';
import 'package:flirt/core/domain/models/employee/employee_response.dart';
import 'package:flirt/core/domain/repository/secure_storage_repository.dart';
import 'package:flirt/core/infrastructures/repository/employee_repository.dart';
import 'package:flirt/internal/enums.dart';
import 'package:flirt/internal/local_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_state.dart';

/// HomeCubit is a Cubit that manages the state of the home screen.
/// It handles connectivity changes and data synchronization.
class HomeCubit extends Cubit<HomeState> {
  /// Constructor for HomeCubit.
  ///
  /// [storage] An instance of ISecureStorageRepository for secure storage operations.
  /// [employeeRepository] An instance of EmployeeRepository for employee data operations.
  HomeCubit({
    required this.storage,
    required this.employeeRepository,
  }) : super(HomeState());
  final EmployeeRepository employeeRepository;
  final ISecureStorageRepository storage;

  /// Emits a state change based on connectivity status.
  ///
  /// [connected] A boolean indicating the current connectivity status.
  void connectivityChange(bool connected) =>
      emit(ConnectivityChanges(connected: connected));

  /// Initiates data synchronization when the device is online.
  /// This function fetches modified tables, syncs employee records, and updates the state accordingly.
  Future<void> syncDataWhenOnline() async {
    emit(FetchSyncDataLoading());
    try {
      final String modifieTables =
          await storage.read(key: lsModifiedTable) ?? '[]';
      final List<String> items =
          List<String>.from(jsonDecode(modifieTables) as List<dynamic>);

      int totalActions = 0;

      for (int i = 0; i < items.length; i++) {
        final int noActions = await _syncEmployeeRecords(items[i]);

        totalActions += noActions;
      }

      emit(FetchSyncDataSuccess(noActions: totalActions));
    } catch (e) {
      emit(FetchSyncDataFailed());
    }
  }

  /// Syncs employee records for a given table.
  ///
  /// [table] The name of the table to sync records from.
  /// Returns The number of actions performed during the sync process.
  Future<int> _syncEmployeeRecords(String table) async {
    try {
      final List<EmployeeResponse> res = await employeeRepository.employeeCache
          .getUnsyncedData<EmployeeResponse>(table);

      if (res.isEmpty) return 0;

      for (int i = 0; i < res.length; i++) {
        final EmployeeResponse item = res[i];

        switch (item.action) {
          case Action.create:
            await employeeRepository.saveRecord(
              EmployeeRequest(
                employeeId: item.employeeId,
                firstName: item.firstName,
                lastName: item.lastName,
                email: item.email,
                phoneNumber: item.phoneNumber,
                hireDate: item.hireDate,
                jobId: item.jobId,
                salary: item.salary,
                commissionPct: item.commissionPct,
                managerId: item.managerId,
              ),
              syncing: true,
            );
          case Action.update:
            await employeeRepository.updateRecord(
              EmployeeRequest(
                employeeId: item.employeeId,
                firstName: item.firstName,
                lastName: item.lastName,
                email: item.email,
                phoneNumber: item.phoneNumber,
                hireDate: item.hireDate,
                jobId: item.jobId,
                salary: item.salary,
                commissionPct: item.commissionPct,
                managerId: item.managerId,
              ),
              syncing: true,
            );
          case Action.delete:
            await employeeRepository.deleteRecord(
              item.employeeId,
              syncing: true,
            );
          default:
        }
      }

      if (!await employeeRepository.hasConnectivity) return res.length;
      await employeeRepository.employeeCache.truncateRecord(table);

      return res.length;
    } catch (e) {
      rethrow;
    }
  }
}
