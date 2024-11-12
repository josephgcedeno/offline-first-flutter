import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flirt/core/domain/models/api_error_response.dart';
import 'package:flirt/core/infrastructures/caching/cat_cache.dart';
import 'package:flirt/core/infrastructures/repository/local_repository.dart';
import 'package:flirt/internal/api.dart';
import 'package:http/http.dart' as http;

class CatRepository {
  final CatCache catCache = CatCache();

  static final List<Cats> remoteRecord = <Cats>[
    for (int i = 1; i < 5; i++) Cats(cat: '$i record', synced: 1),
  ];

  Future<bool> get hasConnectivity async =>
      (await Connectivity().checkConnectivity()).first !=
      ConnectivityResult.none;

  Future<List<Cats>> getCats() async {
    http.Response? response;
    try {
      if (await hasConnectivity) {
        response = await http.get(
          Uri.https(
            'cataas.com',
            '/cat',
            <String, String>{
              'json': true.toString(),
            },
          ),
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

        await catCache.saveToLocal(<Cats>[
          Cats(
            cat: response.body,
            synced: 1,
          ),
        ]);
      }

      return await catCache.getItems();
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

        remoteRecord.add(Cats(cat: cat));
      }

      await catCache.saveToLocal(<Cats>[Cats(cat: cat)]);
    } on SocketException {
      throw APIErrorResponse.socketErrorResponse();
    } catch (e) {
      if (e is APIErrorResponse) rethrow;

      throw APIErrorResponse.typeCastingErrorResponse();
    }
  }
}
