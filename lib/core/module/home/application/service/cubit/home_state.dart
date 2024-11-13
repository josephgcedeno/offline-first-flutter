part of 'home_cubit.dart';

class HomeState {}

class ConnectivityChanges extends HomeState {
  ConnectivityChanges({
    required this.connected,
  });

  final bool connected;
}

class FetchSyncDataLoading extends HomeState {}

class FetchSyncDataSuccess extends HomeState {}

class FetchSyncDataFailed extends HomeState {}
