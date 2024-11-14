part of 'home_cubit.dart';

class HomeState {}

class FetchEmployeesSuccess extends HomeState {
  FetchEmployeesSuccess({
    required this.items,
  });

  final List<EmployeeResponse> items;
}

class FetchEmployeesFailed extends HomeState {}

class FetchEmployeesLoading extends HomeState {}

class CreateEmployeeLoading extends HomeState {}

class CreateEmployeeSuccess extends HomeState {}

class CreateEmployeeFailed extends HomeState {}

class UpdateEmployeeLoading extends HomeState {}

class UpdateEmployeeSuccess extends HomeState {
  UpdateEmployeeSuccess({
    required this.employeeResponse,
  });

  final EmployeeResponse employeeResponse;
}

class UpdateEmployeeFailed extends HomeState {}

class DeleteEmployeeLoading extends HomeState {}

class DeleteEmployeeSuccess extends HomeState {}

class DeleteEmployeeFailed extends HomeState {}
