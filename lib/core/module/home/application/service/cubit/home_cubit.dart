import 'dart:convert';

import 'package:flirt/core/domain/models/employee/employee_request.dart';
import 'package:flirt/core/domain/models/employee/employee_response.dart';
import 'package:flirt/core/domain/repository/secure_storage_repository.dart';
import 'package:flirt/core/infrastructures/repository/employee_repository.dart';
import 'package:flirt/internal/local_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required this.storage,
    required this.employeeRepository,
  }) : super(HomeState());
  final EmployeeRepository employeeRepository;
  final ISecureStorageRepository storage;

  void connectivityChange(bool connected) =>
      emit(ConnectivityChanges(connected: connected));

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

  Future<int> _syncEmployeeRecords(String table) async {
    final List<EmployeeResponse> res = await employeeRepository.employeeCache
        .getUnsyncedData<EmployeeResponse>(table);

    if (res.isEmpty) return 0;

    for (int i = 0; i < res.length; i++) {
      final EmployeeResponse item = res[i];
      if (item.action == 'create') {
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
      } else if (item.action == 'update') {
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
      } else if (item.action == 'delete') {
        await employeeRepository.deleteRecord(
          item.employeeId,
          syncing: true,
        );
      }
    }

    if (!await employeeRepository.hasConnectivity) return res.length;
    await employeeRepository.employeeCache.truncateRecord(table);

    return res.length;
  }
}
