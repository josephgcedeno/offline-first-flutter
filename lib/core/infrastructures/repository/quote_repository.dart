import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flirt/core/domain/models/api_error_response.dart';
import 'package:flirt/core/domain/models/api_response.dart';
import 'package:flirt/core/domain/models/quote/quote_response.dart';
import 'package:flirt/core/domain/repository/secure_storage_repository.dart';
import 'package:flirt/core/infrastructures/caching/quote_cache.dart';
import 'package:flirt/core/infrastructures/repository/local_repository.dart';
import 'package:flirt/core/infrastructures/repository/secure_storage_repository.dart';
import 'package:flirt/internal/api.dart';
import 'package:flirt/internal/env.dart';
import 'package:http/http.dart' as http;

class QuoteRepository {
  final ISecureStorageRepository _storage = SecureStorageRepository();
  final QuoteCache quoteCache = QuoteCache();

  final String _repositoryURL = '/api/v1/flirt/quote/random';

  static final List<Quotes> remoteRecord = <Quotes>[
    for (int i = 1; i < 5; i++) Quotes(quote: '$i record', synced: 1),
  ];

  /// This getter can be used to set the base URL based on the environment,
  /// if you are running a staging/production environment
  Future<String> get _baseURL => checkEnvironment(_storage);

  Future<bool> get hasConnectivity async =>
      (await Connectivity().checkConnectivity()).first !=
      ConnectivityResult.none;

  Future<List<Quotes>> fetchQuote() async {
    http.Response? response;

    try {
      if (await hasConnectivity) {
        response = await http.get(
          Uri.https(await _baseURL, _repositoryURL),
          headers: httpRequestHeaders,
        );

        if (response.statusCode < 200 || response.statusCode > 299) {
          if (response.statusCode == 401) {
            throw APIErrorResponse.unauthorizedErrorResponse();
          }

          throw APIErrorResponse.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>,
          );
        }

        APIListResponse<QuoteResponse>.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
          (Object? data) =>
              QuoteResponse.fromJson(data! as Map<String, dynamic>),
        );

        await quoteCache.saveToLocal(<Quotes>[
          Quotes(
            quote: response.body,
            synced: 1,
          ),
        ]);
      }

      return await quoteCache.getItems();
    } on SocketException {
      throw APIErrorResponse.socketErrorResponse();
    } catch (e) {
      if (e is APIErrorResponse) rethrow;

      throw APIErrorResponse.typeCastingErrorResponse();
    }
  }

  Future<void> saveRecord(String cat) async {
    try {
      if (await hasConnectivity) {
        await Future<void>.delayed(const Duration(seconds: 2));

        remoteRecord.add(Quotes(quote: cat));
      }
      await quoteCache.saveToLocal(<Quotes>[Quotes(quote: cat)]);
    } on SocketException {
      throw APIErrorResponse.socketErrorResponse();
    } catch (e) {
      if (e is APIErrorResponse) rethrow;

      throw APIErrorResponse.typeCastingErrorResponse();
    }
  }
}
