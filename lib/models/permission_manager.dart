import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  late bool _contactReadPermission;
  late bool _smsReadPermission;
  late bool _sendNotificationPermission;
  PermissionManager() {
    _contactReadPermission = false;
    _smsReadPermission = false;
    _sendNotificationPermission = false;
    loadPermissions();
  }

  bool get contactReadPermission {
    return _contactReadPermission;
  }

  bool get smsReadPermission {
    return _smsReadPermission;
  }

  bool get sendNotificationPermission {
    return _sendNotificationPermission;
  }

  Future<void> loadPermissions() async {
    _smsReadPermission = await Permission.sms.status.isGranted;
    _contactReadPermission = await Permission.contacts.status.isGranted;
    _sendNotificationPermission =
        await Permission.notification.status.isGranted;
  }

  Future<bool> requestSmsReadPermission() async {
    if (_smsReadPermission) {
      return _smsReadPermission;
    }
    if (await Permission.sms.status.isDenied) {
      await Permission.sms.request();
    }
    _smsReadPermission = await Permission.sms.status.isGranted;
    return _smsReadPermission;
  }

  Future<bool> requestContactsReadPermission() async {
    if (_contactReadPermission) {
      return _contactReadPermission;
    }
    if (await Permission.contacts.status.isDenied) {
      await Permission.contacts.request();
    }

    _contactReadPermission = await Permission.contacts.status.isGranted;
    return _contactReadPermission;
  }

  Future<bool> requestNotificationPermission() async {
    if (_sendNotificationPermission) {
      return _sendNotificationPermission;
    }
    if (await Permission.notification.status.isDenied) {
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .requestPermission();
    }

    _sendNotificationPermission =
        await Permission.notification.status.isGranted;
    return _sendNotificationPermission;
  }
}
