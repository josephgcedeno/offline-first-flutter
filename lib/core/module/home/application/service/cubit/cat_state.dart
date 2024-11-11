part of 'cat_cubit.dart';

class CatState {}

class FetchItemsLoading extends CatState {}

class FetchItemsSuccess extends CatState {
  FetchItemsSuccess({
    required this.items,
  });

  final List<Cats> items;
}

class FetchItemsFailed extends CatState {}
