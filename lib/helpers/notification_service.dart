import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lane_dane/helpers/local_store.dart';
import 'package:lane_dane/models/all_transaction.dart';
import 'package:lane_dane/models/transactions.dart';
import 'package:lane_dane/utils/create_amount_image.dart';
import 'package:image/image.dart' as img;
import 'package:lane_dane/utils/init.dart';
import 'package:lane_dane/utils/save_file.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Constructor: That initialises the notifications for Platforms
  NotificationService() {
    _initialiseNotifications();
  }

  /// Only called by the constructor
  void _initialiseNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
      'notification_icon',
    );
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // void sendNotfications(int? id, String title, String body) async {
  //   AndroidNotificationDetails androidPlatformChannelSpecifics =
  //       const AndroidNotificationDetails(
  //     'channelId',
  //     'channelName',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //   );

  //   NotificationDetails platformChannelSpecifics =
  //       NotificationDetails(android: androidPlatformChannelSpecifics);

  //   await flutterLocalNotificationsPlugin.show(
  //     id ?? 0,
  //     title,
  //     body,
  //     platformChannelSpecifics,
  //   );
  // }

  // void scheduleNotfications(int? id, String title, String body) async {
  //   AndroidNotificationDetails androidPlatformChannelSpecifics =
  //       const AndroidNotificationDetails(
  //     'your channel id',
  //     'your channel name',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //   );

  //   NotificationDetails platformChannelSpecifics =
  //       NotificationDetails(android: androidPlatformChannelSpecifics);

  //   await flutterLocalNotificationsPlugin.periodicallyShow(
  //     id ?? 0,
  //     title,
  //     body,
  //     RepeatInterval.daily,
  //     platformChannelSpecifics,
  //   );
  // }

  Future<void> scheduleDailyDebit({
    required int amount,
    required tz.TZDateTime whenToShow,
  }) async {
    img.Image image = await createBlankFilledImage(
      backgroundColor: const Color(0xFFFAFAD2),
    );

    image = await addTitleToImage(
      image: image,
      text: 'Spent Yesterday',
      textColor: const Color(0xFF6F8FAF),
    );

    image = await addMainContentToImage(
      image: image,
      text: 'Rs. $amount',
      textColor: const Color(0xFF6495ED),
    );

    image = await addTransactionTypeIcon(
      type: TransactionType.Dane,
      image: image,
    );

    await savePngFileInSupDir(
      path: 'notification_image',
      name: 'daily_scheduled_debit_notification_image.png',
      image: image,
    );

    AndroidNotificationDetails scheduleDailyDebitNotificationDetails =
        AndroidNotificationDetails(
      'daily-debit-notification',
      'Daily Debit Notification Channel',
      channelDescription:
          'Channel for the notification that is shown daily to the user at 10:00 AM',
      icon: 'notification_icon',
      styleInformation: BigPictureStyleInformation(
        await loadPngFileInSupDir(
          path: 'notification_image',
          name: "daily_scheduled_debit_notification_image.png",
        ),
      ),
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: scheduleDailyDebitNotificationDetails,
    );

    String notificationMessage;
    await setupGetStorage();
    LocalStore localStore = LocalStore();
    Locale locale = localStore.getLocale();
    if (locale.languageCode == 'hi') {
      notificationMessage =
          'एसएमएस के अनुसार, कल आपने $amount रुपये खर्च किए थे।';
    } else {
      notificationMessage = 'As per sms, Yesterday you had spent Rs. $amount';
    }

    flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      '₹ $amount Spent Yesterday',
      notificationMessage,
      whenToShow,
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }

  Future<void> showIncomingTransactionSmsNotification({
    required AllTransactionObjectBox allTransaction,
  }) async {
    img.Image image = await createBlankFilledImage(
      backgroundColor: const Color(0xFFFAFAD2),
    );

    image = await addTitleToImage(
      image: image,
      text: allTransaction.transactionType.toLowerCase() == 'credit'
          ? 'Credited'
          : 'Debited',
      textColor: const Color(0xFF6F8FAF),
    );

    image = await addMainContentToImage(
      image: image,
      text: 'Rs. ${allTransaction.amount}',
      textColor: const Color(0xFF6495ED),
    );

    image = await addTransactionTypeIcon(
      type: allTransaction.transactionType.toLowerCase() == 'debit'
          ? TransactionType.Dane
          : TransactionType.Lane,
      image: image,
    );

    await savePngFileInSupDir(
      path: 'notification_image',
      name: 'daily_scheduled_debit_notification_image.png',
      image: image,
    );

    AndroidNotificationDetails incomingTransactionSmsDetails =
        AndroidNotificationDetails(
      'incoming-transaction-sms',
      'Incoming Transaction Sms Channel',
      channelDescription:
          'Channel for the notification that is shown when an incoming sms is of transactional nature',
      icon: 'notification_icon',
      styleInformation: BigPictureStyleInformation(
        await loadPngFileInSupDir(
          path: 'notification_image',
          name: "daily_scheduled_debit_notification_image.png",
        ),
      ),
      actions: [
        AndroidNotificationAction(
          'add_transaction_from_sms_notification',
          'Record Transaction',
          showsUserInterface: true,
        ),
      ],
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: incomingTransactionSmsDetails,
    );

    String notificationMessage;
    await setupGetStorage();
    LocalStore localStore = LocalStore();
    Locale locale = localStore.getLocale();
    if (locale.languageCode == 'hi') {
      String type = allTransaction.transactionType.toLowerCase() == 'credit'
          ? 'received'
          : 'spent';
      notificationMessage = 'You have just $type ₹ ${allTransaction.amount}';
    } else {
      String type = allTransaction.transactionType.toLowerCase() == 'credit'
          ? 'received'
          : 'spent';
      notificationMessage = 'You have just $type ₹ ${allTransaction.amount}';
    }

    String payload = allTransaction.toJson();

    flutterLocalNotificationsPlugin.show(
      2,
      'Amount Spent',
      notificationMessage,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  void showPersonalTransactionNotification(
    Map<String, dynamic> transaction,
    String transactionCreator,
  ) {
    AndroidNotificationDetails personalNotificationDetails =
        const AndroidNotificationDetails(
      'personal-transaction-notification',
      'Notification when a new Personal Transaction is created',
      channelDescription:
          'Channel for the notification that is shown when a new personal transaction is created',
      icon: 'notification_icon',
    );
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: personalNotificationDetails,
    );

    String body =
        "$transactionCreator has created a new transaction record of amount Rs. ${transaction['amount']}, please confirm!";
    flutterLocalNotificationsPlugin.show(
      3,
      'New Transaction Record Added',
      body,
      platformChannelSpecifics,
      payload: json.encode(transaction),
    );
  }

  void showGroupTransactionNotification(
    Map<String, dynamic> groupTransaction,
    String transactionCreator,
  ) {
    AndroidNotificationDetails groupTransactionNotification =
        const AndroidNotificationDetails(
      'group-transaction-notification',
      'Notification shown when a new Group Transaction is created',
      channelDescription:
          'Channel for the notification that is shown when a new group transaction is created',
      icon: 'notification_icon',
    );
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: groupTransactionNotification,
    );

    String body =
        "$transactionCreator has created a group transaction with a total amount of Rs. ${groupTransaction['amount']}. Details are specified in personal transaction, please confirm.";
    flutterLocalNotificationsPlugin.show(
      4,
      'New Group Transaction Record Added',
      body,
      platformChannelSpecifics,
      payload: json.encode(groupTransaction),
    );
  }

  void showTransactionSettleUpNotification(
    Map<String, dynamic> settledTransaction,
    String transactionCreator,
  ) {
    AndroidNotificationDetails groupTransactionNotification =
        const AndroidNotificationDetails(
      'group-transaction-notification',
      'Notification shown when a new Group Transaction is created',
      channelDescription:
          'Channel for the notification that is shown when a new group transaction is created',
      icon: 'notification_icon',
    );
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: groupTransactionNotification,
    );

    String body =
        "$transactionCreator has requested a settleup transaction of amount Rs. ${settledTransaction['amount']}, please confirm.";
    flutterLocalNotificationsPlugin.show(
      5,
      'Transaction Settle Up Request',
      body,
      platformChannelSpecifics,
      payload: json.encode(settledTransaction),
    );
  }

  void showTransactionConfirmationNotification(
    Map<String, dynamic> confirmedTransaction,
    String transactionCreator,
  ) {
    AndroidNotificationDetails confirmedTransactionNotification =
        const AndroidNotificationDetails(
      'group-transaction-notification',
      'Notification shown when a new Group Transaction is created',
      channelDescription:
          'Channel for the notification that is shown when a new group transaction is created',
      icon: 'notification_icon',
    );
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: confirmedTransactionNotification,
    );

    String body =
        "$transactionCreator has ${confirmedTransaction['confirmation']} your transaction request.";
    flutterLocalNotificationsPlugin.show(
      6,
      'Transaction confirmation',
      body,
      platformChannelSpecifics,
      payload: json.encode(confirmedTransaction),
    );
  }
}
