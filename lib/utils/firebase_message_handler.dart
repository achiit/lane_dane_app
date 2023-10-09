import 'dart:convert';
import 'package:get/get.dart';
import 'package:lane_dane/helpers/notification_service.dart';
import 'package:logger/logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:lane_dane/app_controller.dart';
import 'package:lane_dane/utils/log_printer.dart';

enum MessageType {
  personaltransaction,
  grouptransaction,
  transactionconfirmation,
  transactionsettleup,
  undefined,
}

MessageType getMessageType(String? messageTypeSlug) {
  switch (messageTypeSlug) {
    case 'new_transaction':
      return MessageType.personaltransaction;
    case 'new_group_transaction':
      return MessageType.grouptransaction;

    case 'confirm_transaction':
      return MessageType.transactionconfirmation;

    default:
      return MessageType.undefined;
  }
}

Future<void> firebaseMessageHandler(RemoteMessage message) async {
  Logger log = getLogger('firebaseMessageHandler');
  if ((message.notification?.title) == null) {
    log.i('Null message recieved');
    return;
  }
  String? messageType = message.data['type'];
  switch (getMessageType(messageType)) {
    case MessageType.personaltransaction:
      log.i('Transaction update notification recieved');
      AppController appController = Get.find();
      await appController.retrieveTransactionsFromServer();
      break;
    case MessageType.grouptransaction:
      log.i('Transaction update notification recieved');
      AppController appController = Get.find();
      await appController.retrieveTransactionsFromServer();
      break;
    case MessageType.transactionconfirmation:
      log.i('Transaction update notification recieved');
      AppController appController = Get.find();
      await appController.retrieveTransactionsFromServer();
      break;
    case MessageType.transactionsettleup:
      log.i('Transaction update notification recieved');
      AppController appController = Get.find();
      await appController.retrieveTransactionsFromServer();
      break;
    case MessageType.undefined:
      return;
  }
}

@pragma('vm:entry-point')
Future<void> firebaseBackgroundMessageHandler(RemoteMessage message) async {
  NotificationService notificationService = NotificationService();
  String messageType = message.data['type'];
  switch (getMessageType(messageType)) {
    case MessageType.personaltransaction:
      notificationService.showPersonalTransactionNotification(
        json.decode(message.data['transaction']),
        message.data['transaction_creator'],
      );
      break;
    case MessageType.grouptransaction:
      notificationService.showGroupTransactionNotification(
        json.decode(message.data['transaction']),
        message.data['transaction_creator'],
      );
      break;
    case MessageType.transactionconfirmation:
      notificationService.showTransactionConfirmationNotification(
        json.decode(message.data['transaction']),
        message.data['transaction_creator'],
      );
      break;
    case MessageType.transactionsettleup:
      notificationService.showTransactionSettleUpNotification(
        json.decode(message.data['transaction']),
        message.data['transaction_creator'],
      );
      break;
    case MessageType.undefined:
      return;
  }
}
