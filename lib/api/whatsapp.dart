import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:lane_dane/utils/constants.dart';
import 'package:lane_dane/utils/log_printer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../views/shared/snack-bar.dart';

class WhatsappHelper {
  WhatsappHelper();

  final log = getLogger('Whatsapp');

  Future<void> joinCustomerSupportGroup() async {
    try {
      String url = Constants.whatsappCustomerSupportGroup;
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (err, stack) {
      FirebaseCrashlytics.instance.recordError(
        err,
        stack,
        fatal: false,
        printDetails: true,
        reason: 'Failed to join user to group chat. Invalid link perhaps.',
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> send(
      {required BuildContext context,
      required int phone,
      required String message}) async {
    Map<String, dynamic>? response;
    try {
      // var res = await whatsapp.messagesText(
      //     message: 'hey', to: int.parse('91$phone'));
      //print('https://'+address+'/api/verify-contact?phone_no=$phone');
      final url = "https://wa.me/$phone?text=$message";
      var encoded = Uri.encodeFull(url);
      final responseBool = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      print(responseBool);
      // var res = await http.post(Uri.parse('h ttps://wa.me/$phone?text=Hello'),
      //     headers: <String, String>{'Accept': 'application/json'});
      // print(res.statusCode);

      // log.d(res.body);

      // httpErrorHandler(
      //     res: re,
      //     context: context,
      //     onSuccess: () {
      //       response = jsonDecode(res.body);
      //     });
    } catch (e) {
      log.e(jsonEncode(e.toString()));
      showSnackBar(context, 'Something went wrong..');
      return null;
    }
    print(response);
    return response;
  }
}
