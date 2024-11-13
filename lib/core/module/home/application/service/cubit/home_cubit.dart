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

      for (int i = 0; i < items.length; i++) {
        await _syncEmployeeRecords(items[i]);
      }

      await Future<void>.delayed(const Duration(seconds: 3));
      emit(FetchSyncDataSuccess());
    } catch (e) {
      emit(FetchSyncDataFailed());
    }
  }

  Future<void> _syncEmployeeRecords(String table) async {
    final List<EmployeeResponse> res = await employeeRepository.employeeCache
        .getUnsyncedData<EmployeeResponse>(table);

    if (res.isEmpty) return;
    
    for (int i = 0; i < res.length; i++) {
      await employeeRepository.saveRecord(
        EmployeeRequest(
          employeeId: res[i].employeeId,
          firstName: res[i].firstName,
          lastName: res[i].lastName,
          email: res[i].email,
          phoneNumber: res[i].phoneNumber,
          hireDate: res[i].hireDate,
          jobId: res[i].jobId,
          salary: res[i].salary,
          commissionPct: res[i].commissionPct,
          managerId: res[i].managerId,
        ),
        syncing: true,
      );
    }
  }
}
