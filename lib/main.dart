import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flirt/configs/themes.dart';
import 'package:flirt/core/application/service/cubit/quote_api_cubit.dart';
import 'package:flirt/core/infrastructures/repository/local_repository.dart';
import 'package:flirt/core/infrastructures/repository/quote_repository.dart';
import 'package:flirt/core/infrastructures/repository/remote_repository.dart';
import 'package:flirt/core/module/home/application/service/cubit/home_cubit.dart';
import 'package:flirt/core/module/home/interfaces/screens/home_screen.dart';
import 'package:flirt/internal/utils.dart';
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
    final LocalRepository localRepository = LocalRepository();
    final RemoteRepository remoteRepository = RemoteRepository();
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<QuoteAPICubit>(
          create: (BuildContext context) => QuoteAPICubit(
            quoteRepository: QuoteRepository(),
          ),
        ),
        BlocProvider<HomeCubit>(
          create: (BuildContext context) => HomeCubit(
            localRepository: localRepository,
            remoteRepository: remoteRepository,
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
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  int counter = 0;

  void startMonitoringConnectivity() {
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      /// TODO: Improve solution for checks initial unnecessary emits
      if (counter <= 1) {
        counter++;
        return;
      }
      final bool isConnected = result.last != ConnectivityResult.none;

      if (!mounted) return;
      showSnackbar(
        context,
        isSuccessful: isConnected,
        message: isConnected ? 'Syncing' : 'Offline',
      );

      if (result.first != ConnectivityResult.none) {
        if (!mounted) return;

        context.read<HomeCubit>().syncDataWhenOnline();
      }
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
