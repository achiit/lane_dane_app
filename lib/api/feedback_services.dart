import 'package:lane_dane/api/http_services.dart';
import 'package:lane_dane/helpers/auth.dart';
import 'package:lane_dane/utils/constants.dart';
import 'package:lane_dane/utils/log_printer.dart';
import 'package:logger/logger.dart';

class FeedbackServices {
  late final Logger log;
  late final HttpServices services;
  late final Auth auth;
  late String? token;

  FeedbackServices() {
    log = getLogger('FeedbackServicers');
    auth = Auth();
    token = auth.token;
    services = HttpServices(
      host: Constants.host,
      defaultHeader: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      defaultToHTTPS: Constants.defaultToHttps,
    );
  }

  Future<bool> sendFeedback({
    required String content,
    required String deviceInfo,
    required String osInfo,
  }) async {
    try {
      dynamic responseBody = await services.post(
        '/api/send-feedback',
        body: {
          'content': content,
          'device_info': deviceInfo,
          'os_info': osInfo,
        },
      );

      if (responseBody.containsKey('success')) {
        return true;
      } else {
        return false;
      }
    } catch (err) {
      log.e(err.toString());
      rethrow;
    }
  }
}
