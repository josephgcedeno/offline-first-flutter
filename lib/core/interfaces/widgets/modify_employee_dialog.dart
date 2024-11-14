import 'package:flirt/core/domain/models/employee/employee_response.dart';
import 'package:flirt/core/module/home/application/service/cubit/employee_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void showDialogAddEdit(
  EmployeeResponse? employeeResponse, {
  required BuildContext context,
}) =>
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController firstNameController =
            employeeResponse != null
                ? TextEditingController(text: employeeResponse.firstName)
                : TextEditingController(text: 'Default First Name');
        final TextEditingController lastNameController =
            employeeResponse != null
                ? TextEditingController(text: employeeResponse.lastName)
                : TextEditingController(text: 'Default Last Name');
        final TextEditingController emailController = employeeResponse != null
            ? TextEditingController(text: employeeResponse.email)
            : TextEditingController(text: 'Default Email');
        final TextEditingController phoneNumberController =
            employeeResponse != null
                ? TextEditingController(text: employeeResponse.phoneNumber)
                : TextEditingController(text: 'Default Phone Number');
        final TextEditingController hireDateController =
            employeeResponse != null
                ? TextEditingController(text: employeeResponse.hireDate)
                : TextEditingController(text: 'Default Hire Date');
        final TextEditingController jobIdController = employeeResponse != null
            ? TextEditingController(text: employeeResponse.jobId)
            : TextEditingController(text: 'Default Job ID');
        final TextEditingController salaryController = employeeResponse != null
            ? TextEditingController(text: employeeResponse.salary.toString())
            : TextEditingController(text: '100');
        final TextEditingController commissionPctController =
            employeeResponse != null
                ? TextEditingController(
                    text: employeeResponse.commissionPct.toString(),
                  )
                : TextEditingController(text: '110');
        final TextEditingController managerIdController = employeeResponse !=
                null
            ? TextEditingController(text: employeeResponse.managerId.toString())
            : TextEditingController(text: '120');

        return AlertDialog(
          title: const Text('Add/Edit Employee'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                  ),
                ),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                  ),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                TextField(
                  controller: phoneNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                  ),
                ),
                TextField(
                  controller: hireDateController,
                  decoration: const InputDecoration(
                    labelText: 'Hire Date',
                  ),
                ),
                TextField(
                  controller: jobIdController,
                  decoration: const InputDecoration(
                    labelText: 'Job ID',
                  ),
                ),
                TextField(
                  controller: salaryController,
                  decoration: const InputDecoration(
                    labelText: 'Salary',
                  ),
                ),
                TextField(
                  controller: commissionPctController,
                  decoration: const InputDecoration(
                    labelText: 'Commission Pct',
                  ),
                ),
                TextField(
                  controller: managerIdController,
                  decoration: const InputDecoration(
                    labelText: 'Manager ID',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                if (employeeResponse == null) {
                  context.read<EmployeeCubit>().saveRecord(
                        firstName: firstNameController.text,
                        lastName: lastNameController.text,
                        email: emailController.text,
                        phoneNumber: phoneNumberController.text,
                        hireDate: hireDateController.text,
                        jobId: jobIdController.text,
                        salary: double.parse(salaryController.text),
                        commissionPct:
                            double.parse(commissionPctController.text),
                        managerId: int.parse(managerIdController.text),
                      );
                  return;
                }

                context.read<EmployeeCubit>().updateRecord(
                      firstName: firstNameController.text,
                      lastName: lastNameController.text,
                      email: emailController.text,
                      phoneNumber: phoneNumberController.text,
                      hireDate: hireDateController.text,
                      jobId: jobIdController.text,
                      salary: double.parse(salaryController.text),
                      commissionPct: double.parse(commissionPctController.text),
                      managerId: int.parse(managerIdController.text),
                      employeeId: employeeResponse.employeeId,
                    );

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
