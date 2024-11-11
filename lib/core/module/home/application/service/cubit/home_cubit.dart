import 'package:flirt/core/infrastructures/repository/local_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeState());

  void connectivityChange(bool connected) =>
      emit(ConnectivityChanges(connected: connected));
  // Future<void> getAllData() async {
  //   emit(FetchItemsLoading());
  //   try {
  //     final List<Item> getLocalItems = await workOrderRepository.getItems();

  //     emit(FetchItemsSuccess(items: getLocalItems));
  //   } catch (_) {
  //     emit(FetchItemsFailed());
  //   }
  // }

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
