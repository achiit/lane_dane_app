import 'package:flutter/foundation.dart';
import 'package:telephony/telephony.dart';
import 'package:lane_dane/app_controller.dart';
import 'package:lane_dane/controllers/sms_controller.dart';
import 'package:lane_dane/models/all_transaction.dart';
import 'package:lane_dane/utils/sms_parser.dart';

extension SmsHelper on AppController {
  Future<void> parseAndStoreTransactionSms() async {
    if (!permissions.smsReadPermission) {
      await permissions.requestSmsReadPermission();
    }
    if (!permissions.smsReadPermission) {
      return; // Permission not granted
    }

    DateTime lastSmsTime = localstore.retrieveLastSmsTime();

    List<SmsMessage> smsList = await SmsController().getAllReceivedBetween(
      start: lastSmsTime,
      end: DateTime.now(),
    );

    List<AllTransactionObjectBox> transactionList = await compute(
      parseSms,
      smsList,
    );

    if (transactionList.isNotEmpty) {
      localstore.updateLastSmsTime(transactionList.first.createdAt);
    }
    allTransactionController.addMultipleInAllTransactions(transactionList);
  }

  static List<AllTransactionObjectBox> parseSms(List<SmsMessage> smsList) {
    List<AllTransactionObjectBox> transactionList = [];

    for (SmsMessage message in smsList) {
      AllTransactionObjectBox? transaction = parseSmsToTransaction(message);
      if (transaction == null) {
        continue;
      }
      transactionList.add(transaction);
    }
    return transactionList;
  }
}
