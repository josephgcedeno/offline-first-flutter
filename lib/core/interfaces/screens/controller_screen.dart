import 'package:flirt/core/interfaces/widgets/modify_employee_dialog.dart';
import 'package:flirt/core/module/home/application/service/cubit/employee_cubit.dart';
import 'package:flirt/core/module/home/application/service/cubit/home_cubit.dart';
import 'package:flirt/internal/ui_utils.dart';
import 'package:flirt/internal/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ControllerScreen extends StatefulWidget {
  const ControllerScreen({required this.body, super.key});
  final Widget body;

  @override
  State<ControllerScreen> createState() => _ControllerScreenState();
}

class _ControllerScreenState extends State<ControllerScreen> {
  Widget? item;

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (HomeState previous, HomeState current) =>
          current is FetchSyncDataLoading ||
          current is FetchSyncDataSuccess ||
          current is ConnectivityChanges,
      listener: (BuildContext context, HomeState state) {
        if (state is ConnectivityChanges) {
          if (state.connected) {
            context.read<HomeCubit>().syncDataWhenOnline();
            item = null;
          } else {
            /// call sync function heree
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
          setState(() {});
        } else if (state is FetchSyncDataLoading) {
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
          setState(() {});
        } else if (state is FetchSyncDataSuccess) {
          context.read<EmployeeCubit>().getAllEmployee();

          setState(() {
            item = null;
          });

          final int noActions = state.noActions;

          showSnackbar(
            context,
            isSuccessful: true,
            message: noActions != 0
                ? 'Successfully synced $noActions record.'
                : 'No action needed to sync.',
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orangeAccent,
          leading: GestureDetector(
            onTap: () => context.read<HomeCubit>().syncDataWhenOnline(),
            child: const Icon(Icons.sync),
          ),
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
              child: widget.body,
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () => showDialogAddEdit(
            null,
            context: context,
          ),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
