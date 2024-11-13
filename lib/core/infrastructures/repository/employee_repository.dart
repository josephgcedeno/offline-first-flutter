import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flirt/core/domain/models/api_error_response.dart';
import 'package:flirt/core/domain/models/employee/employee_request.dart';
import 'package:flirt/core/domain/models/employee/employee_response.dart';
import 'package:flirt/core/infrastructures/caching/employee_cache.dart';
import 'package:flirt/internal/api.dart';
import 'package:http/http.dart' as http;

class EmployeeRepository {
  final EmployeeCache employeeCache = EmployeeCache();

  Future<bool> get hasConnectivity async =>
      (await Connectivity().checkConnectivity()).first !=
      ConnectivityResult.none;

  Future<List<EmployeeResponse>> fetchEmployees() async {
    http.Response? response;

    try {
      if (await hasConnectivity) {
        response = await http.get(
          Uri.https('parse-baas-sample.onrender.com', '/dummy/employee'),
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

        final List<EmployeeResponse> item = List<EmployeeResponse>.from(
          (jsonDecode(response.body) as List<dynamic>).map((dynamic e) {
            return EmployeeResponse.fromJson(e as Map<String, dynamic>);
          }).toList(),
        );

        employeeCache.saveToLocal(item);

        return item;
      }

      return await employeeCache.getItems();
    } on SocketException {
      throw APIErrorResponse.socketErrorResponse();
    } catch (e) {
      if (e is APIErrorResponse) rethrow;

      throw APIErrorResponse.typeCastingErrorResponse();
    }
  }

  Future<void> saveRecord(
    EmployeeRequest employeeRequest, {
    bool syncing = false,
  }) async {
    http.Response? response;
    try {
      if (await hasConnectivity) {
        response = await http.post(
          Uri.https('parse-baas-sample.onrender.com', '/dummy/employee'),
          headers: httpRequestHeaders,
          body: jsonEncode(employeeRequest),
        );

        if (response.statusCode < 200 || response.statusCode > 299) {
          if (response.statusCode == 401) {
            throw APIErrorResponse.unauthorizedErrorResponse();
          }

          throw APIErrorResponse.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>,
          );
        }
        return;
      }

      /// If error occured in syncing while there is no internet prevent saving it again to local storage
      if (syncing) {
        throw APIErrorResponse.socketErrorResponse();
      }

      employeeRequest.action = 'create';
      employeeRequest.synced = 0;

      return await employeeCache.insertSingleItem(employeeRequest);
    } on SocketException {
      throw APIErrorResponse.socketErrorResponse();
    } catch (e) {
      if (e is APIErrorResponse) rethrow;

      throw APIErrorResponse.typeCastingErrorResponse();
    }
  }

  Future<void> updateRecord(EmployeeRequest employeeRequest) async {
    http.Response? response;

    try {
      if (await hasConnectivity) {
        response = await http.put(
          Uri.https(
            'parse-baas-sample.onrender.com',
            '/dummy/employee/${employeeRequest.employeeId}',
          ),
          headers: httpRequestHeaders,
          body: jsonEncode(employeeRequest),
        );

        if (response.statusCode < 200 || response.statusCode > 299) {
          if (response.statusCode == 401) {
            throw APIErrorResponse.unauthorizedErrorResponse();
          }

          throw APIErrorResponse.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>,
          );
        }
        return;
      }

      employeeRequest.action = 'update';

      return await employeeCache.updateItem(employeeRequest);
    } on SocketException {
      throw APIErrorResponse.socketErrorResponse();
    } catch (e) {
      if (e is APIErrorResponse) rethrow;

      throw APIErrorResponse.typeCastingErrorResponse();
    }
  }

  Future<void> deleteRecord(EmployeeRequest employeeRequest) async {
    http.Response? response;

    try {
      if (await hasConnectivity) {
        response = await http.delete(
          Uri.https(
            'parse-baas-sample.onrender.com',
            '/dummy/employee/${employeeRequest.employeeId}',
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
        return;
      }

      employeeRequest.action = 'delete';

      return await employeeCache.updateItem(employeeRequest);
    } on SocketException {
      throw APIErrorResponse.socketErrorResponse();
    } catch (e) {
      if (e is APIErrorResponse) rethrow;

      throw APIErrorResponse.typeCastingErrorResponse();
    }
  }
}
