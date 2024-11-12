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

class SaveItemsLoading extends QuoteState {}

class SaveItemsSuccess extends QuoteState {}

class SaveItemsFailed extends QuoteState {}

class ClearLocalQuotesLoading extends QuoteState {}

class ClearLocalQuotesSuccess extends QuoteState {}

class ClearLocalQuotesFailed extends QuoteState {}
