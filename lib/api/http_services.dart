import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lane_dane/errors/request_error.dart';
import 'package:lane_dane/errors/server_error.dart';
import 'package:lane_dane/errors/unauthorized_error.dart';
import 'package:lane_dane/utils/log_printer.dart';
import 'package:logger/logger.dart';

class HttpServices {
  late final String host;
  late final Map<String, dynamic> defaultQuery;
  late final Map<String, dynamic> defaultBody;
  late final Map<String, String> defaultHeader;
  late final bool defaultToHTTPS;

  final Logger log = getLogger('HttpServices');

  HttpServices({
    required this.host,
    this.defaultQuery = const {},
    this.defaultBody = const {},
    this.defaultHeader = const {},
    this.defaultToHTTPS = true,
  });

  ///
  void responseStatusChecker(http.Response response) {
    int statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      return;
    }
    if (statusCode >= 500) {
      throw ServerError(
        message: 'An internal server error occurred',
        response: response,
      );
    }
    if (statusCode == 401) {
      throw UnauthorizedError(
        message: 'The user is not authorized to make this request',
        response: response,
      );
    }
    if (statusCode == 403) {
      throw UnauthorizedError(
        message: 'User is forbidden from accessing this resource',
        response: response,
      );
    }
    if (statusCode >= 404 && statusCode <= 500) {
      throw RequestError(
        message: 'The requested resource is unavailable at the moment',
        response: response,
      );
    }
  }

  ///
  Future<dynamic> get(
    String resource, {
    Map<String, dynamic>? query,
    Map<String, String>? header,
    bool includeDefaultQuery = true,
    bool includeDefaultHeader = true,
    bool? https,
  }) async {
    // Create final query from default query and queries passed in the argument
    Map<String, dynamic> finalQuery = Map.from(query ?? {})
      ..addAll(includeDefaultQuery ? defaultQuery : {});
    // Create final header from default header and headers passed in the argument
    Map<String, String> finalHeader = Map.from(header ?? {})
      ..addAll(includeDefaultHeader ? defaultHeader : {});
    https = https ?? defaultToHTTPS;

    //
    try {
      Uri targetUri = https
          ? Uri.https(host, resource, finalQuery)
          : Uri.http(host, resource, finalQuery);
      log.i('Making a [GET] request to $targetUri');

      http.Response response = await http.get(
        targetUri,
        headers: finalHeader,
      );

      responseStatusChecker(response);

      dynamic body = json.decode(response.body);
      return body;
    } catch (err) {
      log.e(
          'Error encountered while making [GET] request to host: $host, and resource: $resource');
      log.e('Query sent to resource: $finalQuery');
      log.e('Headers sent to resource: $finalHeader');
      rethrow;
    }
  }

  ///
  Future<dynamic> post(
    String resource, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    Map<String, String>? header,
    bool includeDefaultBody = true,
    bool includeDefaultQuery = true,
    bool includeDefaultHeader = true,
    bool? https,
  }) async {
    // Create final body from default body and body passed in the argument
    Map<String, dynamic> finalBody = Map.from(body ?? {})
      ..addAll(includeDefaultBody ? defaultBody : {});
    // Create final query from default query and queries passed in the argument
    Map<String, dynamic> finalQuery = Map.from(query ?? {})
      ..addAll(includeDefaultQuery ? defaultQuery : {});
    // Create final header from default header and headers passed in the argument
    Map<String, String> finalHeader = Map.from(header ?? {})
      ..addAll(includeDefaultHeader ? defaultHeader : {});
    https = https ?? defaultToHTTPS;

    //
    try {
      Uri targetUri = https
          ? Uri.https(host, resource, finalQuery)
          : Uri.http(host, resource, finalQuery);
      log.i('Making a [POST] request to $targetUri');
      log.i('Request Body: $finalBody');

      http.Response response = await http.post(
        targetUri,
        headers: finalHeader,
        body: json.encode(finalBody),
      );

      responseStatusChecker(response);

      dynamic body = json.decode(response.body);
      return body;
      //
    } catch (err) {
      log.e(
          'Error encountered while making [POST] request to host: $host, and resource: $resource');
      log.e('Body sent to resource: $finalBody');
      log.e('Query sent to resource: $finalQuery');
      log.e('Headers sent to resource: $finalHeader');
      rethrow;
    }
  }
}
