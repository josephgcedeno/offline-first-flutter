import 'package:flirt/core/infrastructures/repository/local_repository.dart';
import 'package:flirt/core/infrastructures/repository/remote_repository.dart';
import 'package:flirt/core/module/home/application/service/cubit/home_cubit.dart';
import 'package:flirt/internal/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Item> data = <Item>[];

  bool isLoading = true;
  void alertDialogModal(List<Item> items, String title) => showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: SizedBox(
              height: 300,
              width: 400,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(
                      'Item Name: ${items[index].name} \nSynced: ${items[index].isSync}',
                    ),
                  );
                },
              ),
            ),
          );
        },
      );

  @override
  void initState() {
    super.initState();

    context.read<HomeCubit>().getAllData();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (HomeState previous, HomeState current) =>
          current is FetchSyncDataFailed ||
          current is FetchSyncDataSuccess ||
          current is AddItemsSuccess ||
          current is FetchItemsLoading ||
          current is FetchItemsSuccess,
      listener: (BuildContext context, HomeState state) {
        if (state is FetchItemsSuccess) {
          setState(() {
            data.addAll(state.items);
            isLoading = false;
          });
        } else if (state is FetchItemsLoading) {
          setState(() {
            isLoading = true;
          });
        } else if (state is AddItemsSuccess) {
          setState(() {
            data.add(state.item);
          });
        } else if (state is FetchSyncDataSuccess) {
          setState(() {
            data.clear();
            data.addAll(state.items);
          });

          showSnackbar(
            context,
            isSuccessful: true,
            message: 'Successfully Synced',
          );
        } else if (state is FetchSyncDataFailed) {
          showSnackbar(
            context,
            isSuccessful: false,
            message: 'Cannot be synced, bacause no internet connection.',
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.black38,
                ),
                child: Column(
                  children: <Widget>[
                    Wrap(
                      spacing: 10,
                      children: <Widget>[
                        SizedBox(
                          width: 300,
                          child: ElevatedButton(
                            onPressed: () {
                              context.read<HomeCubit>().addData(
                                    Item(
                                      id: data.length,
                                      name: 'Item ${data.length}',
                                      value: data.length,
                                    ),
                                  );
                            },
                            child: const Text('Save'),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            alertDialogModal(
                              RemoteRepository.listOfData,
                              'Remote Data',
                            );
                          },
                          child: const Text('Get remote data'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final List<Item> res =
                                await context.read<HomeCubit>().getLocalItems();

                            alertDialogModal(
                              res,
                              'Local Data',
                            );
                          },
                          child: const Text('Get local data'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            context.read<HomeCubit>().syncDataWhenOnline();
                          },
                          child: const Text('Sync'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            context.read<HomeCubit>().deleteAllLocalDB();
                          },
                          child: const Text('Clear DB'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Text(
                'Items From Source',
                style: TextStyle(color: Colors.white),
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            title: Text(
                              data[index].name,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
