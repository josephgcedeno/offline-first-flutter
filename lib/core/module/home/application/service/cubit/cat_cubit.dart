import 'dart:math';

import 'package:flirt/core/infrastructures/repository/cat_repository.dart';
import 'package:flirt/core/infrastructures/repository/local_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'cat_state.dart';

class CatCubit extends Cubit<CatState> {
  CatCubit({
    required this.catRepository,
  }) : super(CatState());
  final CatRepository catRepository;

  Future<void> getAllCat() async {
    emit(FetchItemsLoading());
    try {
      final List<Cats> getLocalItems = await catRepository.getCats();

      emit(FetchItemsSuccess(items: getLocalItems));
    } catch (_) {
      emit(FetchItemsFailed());
    }
  }

  Future<void> saveRecord() async {
    emit(SaveCatsLoading());
    try {
      await catRepository.saveRecord('${Random().nextInt(100)} Record');

      emit(SaveCatsSuccess());
    } catch (_) {
      emit(SaveCatsFailed());
    }
  }

  Future<void> deleteRecord() async {
    try {
      emit(ClearLocalCatsLoading());

      await catRepository.catCache.truncateRecord();

      emit(ClearLocalCatsSuccess());
    } catch (e) {
      emit(ClearLocalCatsFailed());
    }
  }
}
