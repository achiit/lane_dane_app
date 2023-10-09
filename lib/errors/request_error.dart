import 'package:http/http.dart';

class RequestError implements Exception {
  String message;
  Response response;
  RequestError({
    required this.message,
    required this.response,
  });

  int get statusCode {
    return response.statusCode;
  }

  String get responseBody {
    return response.body;
  }

  @override
  String toString() {
    return {
      'message': message,
      'status': statusCode,
      'body': responseBody,
      'resource': response.request?.url.toString() ?? 'Request object was null',
      'headers':
          response.request?.headers.toString() ?? 'Request object was null',
      'query': response.request?.url.queryParameters.toString() ??
          'Request object was null',
    }.toString();
  }
}
