import 'dart:developer';

import 'package:flirt/core/domain/models/employee/employee_response.dart';
import 'package:flirt/core/module/home/application/service/cubit/employee_cubit.dart';
import 'package:flirt/core/module/home/application/service/cubit/home_cubit.dart';
import 'package:flirt/internal/ui_utils.dart';
import 'package:flirt/internal/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  final List<EmployeeResponse> employees = <EmployeeResponse>[];
  Widget? item;

  void showDialogAddEdit(EmployeeResponse? employeeResponse) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController employeeIdController =
            employeeResponse != null
                ? TextEditingController(
                    text: employeeResponse.employeeId.toString(),
                  )
                : TextEditingController(text: '100');
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
                  controller: employeeIdController,
                  decoration: const InputDecoration(
                    labelText: 'Employee ID',
                  ),
                ),
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

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<EmployeeCubit>().getAllEmployee();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: <BlocListener<dynamic, dynamic>>[
        BlocListener<EmployeeCubit, EmployeeState>(
          listenWhen: (EmployeeState previous, EmployeeState current) =>
              current is SaveEmployeeSuccess || current is FetchItemsSuccess,
          listener: (BuildContext context, EmployeeState state) {
            if (state is FetchItemsSuccess) {
              setState(() {
                /// Clear if record is already filled for mocking real time
                if (employees.isNotEmpty) employees.clear();

                employees.addAll(state.items);
                inspect(employees);
              });
            } else if (state is SaveEmployeeSuccess) {
              context.read<EmployeeCubit>().getAllEmployee();

              showSnackbar(
                context,
                isSuccessful: true,
                message: 'Successfully added',
              );
            }
          },
        ),
        BlocListener<HomeCubit, HomeState>(
          listenWhen: (HomeState previous, HomeState current) =>
              current is ConnectivityChanges,
          listener: (BuildContext context, HomeState state) {
            if (state is ConnectivityChanges) {
              setState(() {
                if (state.connected) {
                  item = Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(color: Colors.green),
                    child: const Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SyncingAnimation(),
                          SizedBox(width: 5),
                          Text(
                            'Syncing',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );

                  /// call sync function heree
                } else {
                  item = Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(color: Colors.red),
                    child: const Center(
                      child: Text(
                        'Offline',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }
              });

              Future<void>.delayed(
                const Duration(seconds: 3),
                () => setState(() {
                  item = null;
                }),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Employee Management'),
        ),
        body: Column(
          children: <Widget>[
            /// TODO: improve switcher
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, -1.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
              child: item ?? const SizedBox.shrink(),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: employees.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(employees[index].firstName),
                    subtitle: Text(employees[index].lastName),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => showDialogAddEdit(employees[index]),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showDialogAddEdit(null),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
