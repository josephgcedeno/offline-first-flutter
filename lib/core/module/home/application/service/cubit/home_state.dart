part of 'home_cubit.dart';

class HomeState {}

class ConnectivityChanges extends HomeState {
  ConnectivityChanges({
    required this.connected,
  });

  final bool connected;
}

class FetchSyncDataLoading extends HomeState {}

class FetchSyncDataSuccess extends HomeState {
  FetchSyncDataSuccess({required this.noActions});

  final int noActions;
}

class FetchSyncDataFailed extends HomeState {}
