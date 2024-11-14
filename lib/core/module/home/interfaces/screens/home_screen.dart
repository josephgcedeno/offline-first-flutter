import 'package:flirt/core/domain/models/employee/employee_response.dart';
import 'package:flirt/core/interfaces/screens/controller_screen.dart';
import 'package:flirt/core/interfaces/widgets/modify_employee_dialog.dart';
import 'package:flirt/core/module/home/application/service/cubit/home_cubit.dart';
import 'package:flirt/internal/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<EmployeeResponse> employees = <EmployeeResponse>[];

  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().getAllEmployees();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (HomeState previous, HomeState current) =>
          current is DeleteEmployeeSuccess ||
          current is UpdateEmployeeSuccess ||
          current is CreateEmployeeSuccess ||
          current is FetchEmployeesSuccess,
      listener: (BuildContext context, HomeState state) {
        if (state is FetchEmployeesSuccess) {
          setState(() {
            /// Clear if record is not empty to 'refresh' data
            if (employees.isNotEmpty) employees.clear();

            employees.addAll(state.items);
          });
        } else if (state is CreateEmployeeSuccess ||
            state is UpdateEmployeeSuccess ||
            state is DeleteEmployeeSuccess) {
          context.read<HomeCubit>().getAllEmployees();

          switch (state) {
            case CreateEmployeeSuccess():
              showSnackbar(
                context,
                isSuccessful: true,
                message: 'Successfully added employees',
              );
            case UpdateEmployeeSuccess():
              showSnackbar(
                context,
                isSuccessful: true,
                message: 'Successfully updated employee',
              );
            case DeleteEmployeeSuccess():
              showSnackbar(
                context,
                isSuccessful: true,
                message: 'Successfully deleted employee',
              );
          }
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
                    onPressed: () => context.read<HomeCubit>().deleteRecord(
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
