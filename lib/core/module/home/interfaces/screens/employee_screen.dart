import 'dart:developer';

import 'package:flirt/core/domain/models/employee/employee_response.dart';
import 'package:flirt/core/interfaces/screens/controller_screen.dart';
import 'package:flirt/core/interfaces/widgets/modify_employee_dialog.dart';
import 'package:flirt/core/module/home/application/service/cubit/employee_cubit.dart';
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

  @override
  void initState() {
    super.initState();
    context.read<EmployeeCubit>().getAllEmployee();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EmployeeCubit, EmployeeState>(
      listenWhen: (EmployeeState previous, EmployeeState current) =>
          current is DeleteEmployeeSuccess ||
          current is UpdateEmployeeSuccess ||
          current is SaveEmployeeSuccess ||
          current is FetchItemsSuccess,
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
        } else if (state is UpdateEmployeeSuccess ||
            state is DeleteEmployeeSuccess) {
          context.read<EmployeeCubit>().getAllEmployee();
        }
      },
      child: ControllerScreen(
        body: ListView.builder(
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
                    onPressed: () => showDialogAddEdit(
                      employees[index],
                      context: context,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => context.read<EmployeeCubit>().deleteRecord(
                          employeeId: employees[index].employeeId,
                        ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
