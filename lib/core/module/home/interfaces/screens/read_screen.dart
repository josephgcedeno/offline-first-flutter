import 'package:flirt/core/module/home/application/service/cubit/cat_cubit.dart';
import 'package:flirt/core/module/home/application/service/cubit/home_cubit.dart';
import 'package:flirt/core/module/home/application/service/cubit/quote_cubit.dart';
import 'package:flirt/internal/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReadScreen extends StatefulWidget {
  const ReadScreen({super.key});

  @override
  State<ReadScreen> createState() => _ReadScreenState();
}

class _ReadScreenState extends State<ReadScreen> {
  Widget? item;

  int totalCatRecord = 0;
  int totalQuoteRecord = 0;

  void fetchRecord() {
    context.read<CatCubit>().getAllCat();
    context.read<QuoteCubit>().getAllQuotes();
  }

  @override
  void initState() {
    super.initState();

    fetchRecord();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (HomeState previous, HomeState current) =>
          current is ConnectivityChanges,
      listener: (BuildContext context, HomeState state) {
        if (state is ConnectivityChanges) {
          setState(() {
            if (state.connected) {
              item = Container(
                width: double.infinity,
                decoration: const BoxDecoration(color: Colors.green),
                child: const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SyncingAnimation(),
                      SizedBox(width: 5),
                      Text(
                        'Syncing',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              );

              context.read<CatCubit>().getAllCat();
              context.read<QuoteCubit>().getAllQuotes();
            } else {
              item = Container(
                width: double.infinity,
                decoration: const BoxDecoration(color: Colors.red),
                child: const Center(
                  child: Text(
                    'Offline',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            }
          });

          Future<void>.delayed(
            const Duration(seconds: 3),
            () => setState(() {
              item = null;
            }),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              /// TODO: improve switcher
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 100),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, -1.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
                child: item ?? const SizedBox.shrink(),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            Text(
                              'Cat API: $totalCatRecord',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            BlocConsumer<CatCubit, CatState>(
                              listenWhen:
                                  (CatState previous, CatState current) =>
                                      current is ClearLocalCatsSuccess ||
                                      current is FetchItemsSuccess ||
                                      current is SaveCatsSuccess,
                              listener: (BuildContext context, CatState state) {
                                if (state is FetchItemsSuccess) {
                                  setState(() {
                                    totalCatRecord = state.items.length;
                                  });
                                } else if (state is SaveCatsSuccess ||
                                    state is ClearLocalCatsSuccess) {
                                  context.read<CatCubit>().getAllCat();
                                }
                              },
                              buildWhen:
                                  (CatState previous, CatState current) =>
                                      current is FetchItemsSuccess,
                              builder: (BuildContext context, CatState state) {
                                if (state is FetchItemsSuccess &&
                                    state.items.isNotEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(state.items.last.cat),
                                  );
                                }
                                return const CircularProgressIndicator();
                              },
                            ),
                            const Spacer(),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ElevatedButton(
                                  onPressed: () =>
                                      context.read<CatCubit>().saveRecord(),
                                  child: const Text('Save'),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () =>
                                      context.read<CatCubit>().deleteRecord(),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            Text(
                              'Quote API: $totalQuoteRecord',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            BlocConsumer<QuoteCubit, QuoteState>(
                              listenWhen:
                                  (QuoteState previous, QuoteState current) =>
                                      current is ClearLocalQuotesSuccess ||
                                      current is SaveItemsSuccess ||
                                      current is FetchQuotesSuccess,
                              listener:
                                  (BuildContext context, QuoteState state) {
                                if (state is FetchQuotesSuccess) {
                                  setState(() {
                                    totalQuoteRecord = state.quotes.length;
                                  });
                                } else if (state is SaveItemsSuccess ||
                                    state is ClearLocalQuotesSuccess) {
                                  context.read<QuoteCubit>().getAllQuotes();
                                }
                              },
                              buildWhen:
                                  (QuoteState previous, QuoteState current) =>
                                      current is FetchQuotesSuccess,
                              builder:
                                  (BuildContext context, QuoteState state) {
                                if (state is FetchQuotesSuccess &&
                                    state.quotes.isNotEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(state.quotes.last.quote),
                                  );
                                }
                                return const CircularProgressIndicator();
                              },
                            ),
                            const Spacer(),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ElevatedButton(
                                  onPressed: () =>
                                      context.read<QuoteCubit>().saveRecord(),
                                  child: const Text('Save'),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () =>
                                      context.read<QuoteCubit>().deleteRecord(),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
