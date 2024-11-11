part of 'quote_cubit.dart';

class QuoteState {}

class FetchQuotesLoading extends QuoteState {}

class FetchQuotesSuccess extends QuoteState {
  FetchQuotesSuccess({
    required this.quotes,
  });

  final List<Quotes> quotes;
}

class FetchQuotesFailed extends QuoteState {}
