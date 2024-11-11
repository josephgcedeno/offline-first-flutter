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

  @override
  void initState() {
    super.initState();
    context.read<CatCubit>().getAllCat();
    context.read<QuoteCubit>().getAllQuotes();
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
        // TODO: implement listener
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
                        child: BlocBuilder<CatCubit, CatState>(
                          buildWhen: (CatState previous, CatState current) =>
                              current is FetchItemsSuccess,
                          builder: (BuildContext context, CatState state) {
                            if (state is FetchItemsSuccess) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(state.items.last.cat),
                              );
                            }
                            return const CircularProgressIndicator();
                          },
                        ),
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: Center(
                        child: BlocBuilder<QuoteCubit, QuoteState>(
                          buildWhen:
                              (QuoteState previous, QuoteState current) =>
                                  current is FetchQuotesSuccess,
                          builder: (BuildContext context, QuoteState state) {
                            if (state is FetchQuotesSuccess) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(state.quotes.last.quote),
                              );
                            }
                            return const CircularProgressIndicator();
                          },
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
