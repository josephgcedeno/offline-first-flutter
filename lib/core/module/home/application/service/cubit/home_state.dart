part of 'home_cubit.dart';

class HomeState {}

class FetchItemsLoading extends HomeState {}

class FetchItemsSuccess extends HomeState {
  FetchItemsSuccess({
    required this.items,
  });

  final List<Item> items;
}

class FetchItemsFailed extends HomeState {}

class AddItemsLoading extends HomeState {}

class AddItemsSuccess extends HomeState {
  AddItemsSuccess({
    required this.item,
  });

  final Item item;
}

class AddItemsFailed extends HomeState {}

class FetchSyncDataSuccess extends HomeState {
  FetchSyncDataSuccess({
    required this.items,
  });

  final List<Item> items;
}

class FetchSyncDataFailed extends HomeState {}
