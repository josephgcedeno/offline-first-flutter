import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flirt/configs/themes.dart';
import 'package:flirt/core/application/service/cubit/sync_cubit.dart';
import 'package:flirt/core/infrastructures/repository/employee_repository.dart';
import 'package:flirt/core/infrastructures/repository/secure_storage_repository.dart';
import 'package:flirt/core/module/home/application/service/cubit/home_cubit.dart';
import 'package:flirt/core/module/home/interfaces/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  /// Load env file
  await dotenv.load();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final EmployeeRepository employeeRepository = EmployeeRepository();

    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<SyncCubit>(
          create: (BuildContext context) => SyncCubit(
            employeeRepository: employeeRepository,
            storage: SecureStorageRepository(),
          ),
        ),
        BlocProvider<HomeCubit>(
          create: (BuildContext context) => HomeCubit(
            employeeRepository: employeeRepository,
          ),
        ),
      ],
      child: MaterialApp(
        home: _HomePageState(),
        theme: defaultTheme,
        supportedLocales: const <Locale>[
          Locale('en'),
        ],
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class _HomePageState extends StatefulWidget {
  @override
  State<_HomePageState> createState() => _HomePageStateState();
}

class _HomePageStateState extends State<_HomePageState> {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  void startMonitoringConnectivity() {
    final Connectivity connectivity = Connectivity();

    // Add a boolean flag to track the first connectivity change event
    bool isFirstEvent = true;

    _connectivitySubscription = connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      // Determine connectivity status
      final bool isConnected = result.last != ConnectivityResult.none;

      if (!mounted) return;
      if (isFirstEvent && !isConnected) {
        isFirstEvent = false;
      }

      // Notify the Sync Cubit only when there is a connectivity change
      context.read<SyncCubit>().updateConnectivityStatus(isConnected);
    });
  }

  @override
  void initState() {
    super.initState();
    startMonitoringConnectivity();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
