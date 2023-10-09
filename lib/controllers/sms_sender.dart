import 'dart:async';

import 'package:flutter/services.dart';

class SmsService {
  // static const MethodChannel _channel = MethodChannel('sms.channel.send');
  static const MethodChannel _channel =
      MethodChannel('com.example.send_sms/sms');
/*
  /  ========================
  /  Send SMS
  /  ========================
  /  phoneNumber: String
  /  message: String
  */

  static Future<void> sendSms(
      {required String phoneNumber, required String message}) async {
    try {
      await _channel.invokeMethod('sendSMS', <String, dynamic>{
        'phoneNumber': phoneNumber,
        'message': message,
      });
    } on PlatformException catch (e) {
      print("Failed to send SMS: '${e.message}'.");
    }
  }
}
