part of 'sync_cubit.dart';

class SyncState {}

class ConnectivityStatus extends SyncState {
  ConnectivityStatus({required this.connected});

  final bool connected;
}

class SyncDataLoading extends SyncState {}

class SyncDataSuccess extends SyncState {}

class SyncDataFailed extends SyncState {}
