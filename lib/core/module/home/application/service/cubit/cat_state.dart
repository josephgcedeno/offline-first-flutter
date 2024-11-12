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

class SaveCatsLoading extends CatState {}

class SaveCatsSuccess extends CatState {}

class SaveCatsFailed extends CatState {}

class ClearLocalCatsLoading extends CatState {}

class ClearLocalCatsSuccess extends CatState {}

class ClearLocalCatsFailed extends CatState {}
