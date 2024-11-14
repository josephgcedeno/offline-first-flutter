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

      if (await employeeRepository.hasConnectivity) {
        getLocalItems.sort(
          (EmployeeResponse a, EmployeeResponse b) =>
              DateTime.parse(a.updatedAt!)
                  .compareTo(DateTime.parse(b.updatedAt!)),
        );
      }

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
            updatedAt: '',
          ),
        ),
      );
    } catch (_) {
      emit(UpdateEmployeeFailed());
    }
  }

  Future<void> deleteRecord({
    required int employeeId,
  }) async {
    emit(DeleteEmployeeLoading());
    try {
      await employeeRepository.deleteRecord(employeeId);

      emit(DeleteEmployeeSuccess());
    } catch (_) {
      emit(DeleteEmployeeFailed());
    }
  }
}
