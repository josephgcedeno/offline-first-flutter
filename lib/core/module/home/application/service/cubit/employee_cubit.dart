import 'dart:math';

import 'package:flirt/core/domain/models/employee/employee_request.dart';
import 'package:flirt/core/domain/models/employee/employee_response.dart';
import 'package:flirt/core/infrastructures/repository/employee_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'employee_state.dart';

class EmployeeCubit extends Cubit<EmployeeState> {
  EmployeeCubit({
    required this.employeeRepository,
  }) : super(EmployeeState());
  final EmployeeRepository employeeRepository;

  Future<void> getAllEmployee() async {
    emit(FetchItemsLoading());
    try {
      final List<EmployeeResponse> getLocalItems =
          await employeeRepository.fetchEmployees();

      emit(FetchItemsSuccess(items: getLocalItems));
    } catch (_) {
      emit(FetchItemsFailed());
    }
  }

  Future<void> saveRecord({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String hireDate,
    required String jobId,
    required double salary,
    required double commissionPct,
    required int managerId,
  }) async {
    emit(SaveEmployeeLoading());
    try {
      await employeeRepository.saveRecord(
        EmployeeRequest(
          employeeId: Random().nextInt(3000),
          firstName: firstName,
          lastName: lastName,
          email: email,
          phoneNumber: phoneNumber,
          hireDate: hireDate,
          jobId: jobId,
          salary: salary,
          commissionPct: commissionPct,
          managerId: managerId,
        ),
      );

      emit(SaveEmployeeSuccess());
    } catch (_) {
      emit(SaveEmployeeFailed());
    }
  }

  Future<void> updateRecord({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String hireDate,
    required String jobId,
    required double salary,
    required double commissionPct,
    required int managerId,
    required int employeeId,
    String? localId,
  }) async {
    emit(UpdateEmployeeLoading());
    try {
      final EmployeeRequest item = EmployeeRequest(
        employeeId: employeeId,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        hireDate: hireDate,
        jobId: jobId,
        salary: salary,
        commissionPct: commissionPct,
        managerId: managerId,
        localId: localId,
      );

      await employeeRepository.updateRecord(item);

      emit(
        UpdateEmployeeSuccess(
          employeeResponse: EmployeeResponse(
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
        ),
      );
    } catch (_) {
      emit(UpdateEmployeeFailed());
    }
  }
}
