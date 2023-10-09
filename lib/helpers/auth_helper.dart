import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:lane_dane/app_controller.dart';
import 'package:lane_dane/controllers/contact_controller.dart';
import 'package:lane_dane/controllers/sms_controller.dart';
import 'package:lane_dane/controllers/sms_controller_concurrent_engine.dart';
import 'package:lane_dane/errors/server_error.dart';
import 'package:lane_dane/helpers/auth.dart';
import 'package:lane_dane/models/auth_user.dart';
import 'package:lane_dane/views/pages/authentication/enter_phone_screen.dart';

extension AuthHelper on AppController {
  Future<void> register({
    required BuildContext context,
    required String phoneNumber,
    required String fullName,
    required String otp,
    required bool businessAccount,
  }) async {
    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) {
        log.e('FCM Token not found');
      }
      // ignore: use_build_context_synchronously
      final Map<String, dynamic> response = await authService.register(
        context: context,
        phone: int.parse(phoneNumber),
        full_name: fullName,
        otp: otp,
        businessAccount: businessAccount,
        fcmToken: fcmToken,
      );
      log.d(response);
      log.d(response['success']['token']);

      Auth().saveUserAuthenticationData(response['success']);
      user = AuthUser.fromMap(response['success']['user']);
      token = response['success']['token'];
      loggedIn = true;

      FirebaseCrashlytics.instance
          .setUserIdentifier(response['success']['user']['full_name']);
      postLoginUpdates();
    } catch (err) {
      log.e('Failed to register user');
      rethrow;
    }
  }

  Future<void> login(
      {required BuildContext context,
      required String phoneNumber,
      required String otp}) async {
    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) {
        log.e('FCM Token not found');
      }
      final Map<String, dynamic> response = await authService.login(
        context: context,
        phone: int.parse(phoneNumber),
        otp: otp,
        fcmToken: fcmToken,
      );
      log.d(response);
      log.d(response['success']['token']);

      Auth().saveUserAuthenticationData(response['success']);
      user = AuthUser.fromMap(response['success']['user']);
      token = response['success']['token'];
      loggedIn = true;

      FirebaseCrashlytics.instance
          .setUserIdentifier(response['success']['user']['full_name']);
      postLoginUpdates();
    } catch (err) {
      log.e('Failed to login user');
      rethrow;
    }
  }

  Future<void> autoLogin() async {
    try {
      bool userAvailable = await auth.tryAutoLogin();
      if (!userAvailable) {
        return;
      }

      token = auth.token!;
      user = AuthUser.fromMap((await auth.getUserData())['user']);
      loggedIn = true;
      postLoginUpdates();
    } catch (err) {
      log.e('Failed to auto login user');
    }
  }

  void logout() {
    try {
      allTransactionController.clear();
      transactionController.clear();
      userController.clear();
      usergroupController.clear();
      groupTransactionController.clear();

      localstore.clear();

      SmsController.smsParsed = false;
      ContactController.contactsStored = false;

      loggedIn = false;
      auth.logout();

      // Get.offUntil(
      //   MaterialPageRoute(builder: (_) => EnterPhoneScreen()),
      //   (route) => true,
      // );
    } catch (err) {
      log.e('Failed to logout user');
      rethrow;
    }
  }

  void refreshToken(String newToken) {
    if (!loggedIn) {
      return;
    }
    authService.refreshToken(newToken, token).onError((err, stack) {
      FirebaseCrashlytics.instance.recordError(
        err,
        stack,
        fatal: false,
        printDetails: true,
        reason: 'Error occurred while attempting to refresh fcm token',
        information: [newToken, user.id],
      );
      return {};
    });
  }

  void activatePremium() {
    user.isPremium = true;
  }
}
