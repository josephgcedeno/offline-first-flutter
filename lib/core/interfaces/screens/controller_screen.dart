import 'package:flirt/core/application/service/cubit/sync_cubit.dart';
import 'package:flirt/core/interfaces/widgets/modify_employee_dialog.dart';
import 'package:flirt/core/module/home/application/service/cubit/home_cubit.dart';
import 'package:flirt/internal/enums.dart';
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
  Widget? connectivityBorder;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SyncCubit, SyncState>(
      listenWhen: (SyncState previous, SyncState current) =>
          current is SyncDataLoading ||
          current is SyncDataSuccess ||
          current is ConnectivityStatus,
      listener: (BuildContext context, SyncState state) {
        if (state is ConnectivityStatus) {
          if (state.connected) {
            context.read<SyncCubit>().syncData();
            connectivityBorder =
                const _ConnectivityIndicator(status: ConnectionStatus.syncing);
          } else {
            connectivityBorder =
                const _ConnectivityIndicator(status: ConnectionStatus.offline);
          }
          setState(() {});
        } else if (state is SyncDataSuccess) {
          context.read<HomeCubit>().getAllEmployees();

          setState(() {
            connectivityBorder =
                const _ConnectivityIndicator(status: ConnectionStatus.online);
          });

          showSnackbar(
            context,
            isSuccessful: true,
            message: 'Successfully synced data.',
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orangeAccent,
          leading: GestureDetector(
            onTap: () => context.read<SyncCubit>().syncData(),
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
              child: connectivityBorder ?? const SizedBox.shrink(),
            ),
            Expanded(child: widget.body),
          ],
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterFloat,
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

class _ConnectivityIndicator extends StatelessWidget {
  const _ConnectivityIndicator({required this.status});

  final ConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ConnectionStatus.offline:
        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(color: Colors.red),
          child: const Center(
            child: Text(
              'Offline',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      case ConnectionStatus.syncing:
        return Container(
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
      case ConnectionStatus.online:
        return const SizedBox.shrink();
    }
  }
}
