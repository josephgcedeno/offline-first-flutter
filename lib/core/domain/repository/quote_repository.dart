import 'package:flirt/core/domain/models/api_response.dart';
import 'package:flirt/core/domain/models/quote/quote_response.dart';

abstract class IQuoteRepository {
  /// This function can be used to set the base URL based on the environment,
  /// if you are running a staging/production environment
  ///
  // Future<void> checkEnvironment();

  Future<APIListResponse<QuoteResponse>> fetchQuote();
}
