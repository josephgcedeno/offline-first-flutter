part of 'employee_cubit.dart';

class EmployeeState {}

class FetchItemsLoading extends EmployeeState {}

class FetchItemsSuccess extends EmployeeState {
  FetchItemsSuccess({
    required this.items,
  });

  final List<EmployeeResponse> items;
}

class FetchItemsFailed extends EmployeeState {}

class SaveEmployeeLoading extends EmployeeState {}

class SaveEmployeeSuccess extends EmployeeState {}

class SaveEmployeeFailed extends EmployeeState {}

class ClearLocalEmployeeLoading extends EmployeeState {}

class ClearLocalEmployeeSuccess extends EmployeeState {}

class ClearLocalEmployeeFailed extends EmployeeState {}
