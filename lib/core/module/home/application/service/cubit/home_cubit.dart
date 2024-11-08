import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flirt/core/infrastructures/repository/local_repository.dart';
import 'package:flirt/core/infrastructures/repository/remote_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required this.localRepository,
    required this.remoteRepository,
  }) : super(HomeState());
  final LocalRepository localRepository;
  final RemoteRepository remoteRepository;

  /// This method is used to store a new quote and its author in the state.
  // /// It appends the quote to the list of quotes and the author to the list of authors.
  // ///
  // /// [quote] Single response from the quote
  Future<void> saveToLocal(List<Item> response) async {
    if (localRepository.database == null) {
      await localRepository.open();
    }

    for (int i = 0; i < response.length; i++) {
      await localRepository.insert(response[i]);
    }
  }

  Future<bool> get hasConnectivity async =>
      (await Connectivity().checkConnectivity()).first !=
      ConnectivityResult.none;

  Future<void> getAllData() async {
    emit(FetchItemsLoading());
    try {
      if (localRepository.database == null) {
        await localRepository.open();
      }

      if (await hasConnectivity) {
        final List<Item> res = await remoteRepository.getItems();
        await saveToLocal(res);
      }

      final List<Item> getLocalItems = await localRepository.getItems();

      emit(FetchItemsSuccess(items: getLocalItems));
    } catch (_) {
      emit(FetchItemsFailed());
    }
  }

  Future<void> addData(Item item) async {
    emit(AddItemsLoading());
    try {
      if (localRepository.database == null) {
        await localRepository.open();
      }

      if (await hasConnectivity) {
        item.isSync = true;
        await remoteRepository.addData(item);
      }

      await localRepository.insert(item);

      emit(AddItemsSuccess(item: item));
    } catch (_) {
      emit(AddItemsFailed());
    }
  }

  Future<List<Item>> getLocalItems() async {
    if (localRepository.database == null) {
      await localRepository.open();
    }
    final List<Item> res = await localRepository.getItems();

    return res;
  }

  Future<void> syncDataWhenOnline() async {
    if (!await hasConnectivity) {
      emit(FetchSyncDataFailed());
      return;
    }

    final List<Item> res = await localRepository.getUnsyncedItems();

    if (res.isEmpty) return;

    if (localRepository.database == null) {
      await localRepository.open();
    }
    
    for (int i = 0; i < res.length; i++) {
      res[i].isSync = true;

      await remoteRepository.addData(res[i]);
      await localRepository.update(res[i]);
    }

    final List<Item> responseSyncedData = await getLocalItems();

    emit(FetchSyncDataSuccess(items: responseSyncedData));
  }

  Future<void> deleteAllLocalDB() async {
    await localRepository.clearAllItems();
  }
}
