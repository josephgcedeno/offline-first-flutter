import 'dart:math';

import 'package:flirt/core/infrastructures/repository/local_repository.dart';
import 'package:flirt/core/infrastructures/repository/quote_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'quote_state.dart';

class QuoteCubit extends Cubit<QuoteState> {
  QuoteCubit({
    required this.quoteRepository,
  }) : super(QuoteState());
  final QuoteRepository quoteRepository;

  Future<void> getAllQuotes() async {
    emit(FetchQuotesLoading());
    try {
      final List<Quotes> getLocalItems = await quoteRepository.fetchQuote();

      emit(FetchQuotesSuccess(quotes: getLocalItems));
    } catch (_) {
      emit(FetchQuotesFailed());
    }
  }

  Future<void> saveRecord() async {
    emit(SaveItemsLoading());
    try {
      await quoteRepository.saveRecord('${Random().nextInt(100)} Record');

      emit(SaveItemsSuccess());
    } catch (_) {
      emit(SaveItemsFailed());
    }
  }

  Future<void> deleteRecord() async {
    try {
      emit(ClearLocalQuotesLoading());

      await quoteRepository.quoteCache.truncateRecord();

      emit(ClearLocalQuotesSuccess());
    } catch (e) {
      emit(ClearLocalQuotesFailed());
    }
  }

  Future<void> addData(Item item) async {
    // emit(AddItemsLoading());
    // try {
    //   if (localRepository.database == null) {
    //     await localRepository.open();
    //   }

    //   if (await hasConnectivity) {
    //     item.isSync = true;
    //     await workOrderRepository.addData(item);
    //   }

    //   await localRepository.insert(item);

    //   emit(AddItemsSuccess(item: item));
    // } catch (_) {
    //   emit(AddItemsFailed());
    // }
  }

  // Future<List<Item>> getLocalItems() async {
  //   if (localRepository.database == null) {
  //     await localRepository.open();
  //   }
  //   final List<Item> res = await localRepository.getItems();

  //   return res;
  // }

  Future<void> syncDataWhenOnline() async {
    // final List<Item> res = await localRepository.getUnsyncedItems();

    // if (res.isEmpty) return;

    // if (localRepository.database == null) {
    //   await localRepository.open();
    // }

    // for (int i = 0; i < res.length; i++) {
    //   res[i].isSync = true;

    //   await remoteRepository.addData(res[i]);
    //   await localRepository.update(res[i]);
    // }

    // final List<Item> responseSyncedData = await getLocalItems();

    // emit(FetchSyncDataSuccess(items: responseSyncedData));
  }

  Future<void> deleteAllLocalDB() async {
    // await localRepository.clearAllItems();
  }
}
