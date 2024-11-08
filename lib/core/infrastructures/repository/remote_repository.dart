import 'package:flirt/core/infrastructures/repository/local_repository.dart';

class RemoteRepository {
  static final List<Item> listOfData = <Item>[
    for (int i = 0; i < 5; i++)
      Item(
        id: i,
        name: 'Item $i',
        value: i,
        isSync: true,
      ),
  ];

  Future<List<Item>> getItems() async => await Future<List<Item>>.delayed(
        const Duration(seconds: 1),
        () => listOfData,
      );

  Future<void> addData(Item item) async => await Future<void>.delayed(
        const Duration(seconds: 1),
        () => listOfData.add(item),
      );
}
