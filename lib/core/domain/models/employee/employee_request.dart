import 'package:json_annotation/json_annotation.dart';

part 'employee_request.g.dart';

@JsonSerializable()
class EmployeeRequest {
  EmployeeRequest({
    required this.employeeId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.hireDate,
    required this.jobId,
    required this.salary,
    required this.commissionPct,
    required this.managerId,
    this.createdDate,
    this.modifiedDate,
    this.action,
    this.localId,
    this.synced,
  });

  factory EmployeeRequest.fromJson(Map<String, dynamic> json) =>
      _$EmployeeRequestFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeRequestToJson(this);

  Map<String, dynamic> toJsonInsertRecord() => <String, dynamic>{
        'EMPLOYEE_ID': employeeId,
        'FIRST_NAME': firstName,
        'LAST_NAME': lastName,
        'EMAIL': email,
        'PHONE_NUMBER': phoneNumber,
        'HIRE_DATE': hireDate,
        'JOB_ID': jobId,
        'SALARY': salary,
        'COMMISSION_PCT': commissionPct,
        'MANAGER_ID': managerId,
        'action': action,
        'createdDate': createdDate ?? DateTime.now().millisecondsSinceEpoch,
        'localId': localId,
        'modifiedDate': DateTime.now().millisecondsSinceEpoch,
        'synced': localId != null ? 1 : 0,
      };

  @JsonKey(name: 'EMPLOYEE_ID')
  final int employeeId;
  @JsonKey(name: 'FIRST_NAME')
  final String firstName;
  @JsonKey(name: 'LAST_NAME')
  final String lastName;
  @JsonKey(name: 'EMAIL')
  final String email;
  @JsonKey(name: 'PHONE_NUMBER')
  final String phoneNumber;
  @JsonKey(name: 'HIRE_DATE')
  final String hireDate;
  @JsonKey(name: 'JOB_ID')
  final String jobId;
  @JsonKey(name: 'SALARY')
  final double salary;
  @JsonKey(name: 'COMMISSION_PCT')
  final double commissionPct;
  @JsonKey(name: 'MANAGER_ID')
  final int managerId;

  String? action;
  int? createdDate;
  String? localId;
  int? modifiedDate;
  int? synced;
}
