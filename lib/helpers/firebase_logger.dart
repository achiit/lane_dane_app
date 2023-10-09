import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:lane_dane/utils/date_time_extensions.dart';
import 'package:lane_dane/utils/log_printer.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

class FirebaseLogger {
  static late DateTime now;
  static bool printLog = true;

  static Future<String> _getVersion() async {
    PackageInfo package = await PackageInfo.fromPlatform();
    return package.version;
  }

  static Future<void> info(String message, {String? className}) async {
    now = DateTime.now();
    Logger log = getLogger(className ?? '');
    String version = await _getVersion();
    String logMessage =
        '[${now.toString()}][$version][info][$className]: $message';
    FirebaseCrashlytics.instance.log(
      logMessage,
    );
    if (kDebugMode && printLog) {
      log.i(logMessage);
    }
  }

  static sendReport() {
    FirebaseCrashlytics.instance.sendUnsentReports();
  }
}
