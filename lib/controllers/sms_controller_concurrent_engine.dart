// import 'dart:isolate';

// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:lane_dane/helpers/isolate_spawn.dart';
// import 'package:lane_dane/helpers/local_store.dart';
// import 'package:lane_dane/models/all_transaction.dart';
// import 'package:lane_dane/controllers/all_transaction_controller.dart';
// import 'package:lane_dane/utils/constants.dart';
// import 'package:sms_advanced/sms_advanced.dart';

// import '../main.dart';
// import '../objectbox.g.dart';
// import '../utils/log_printer.dart';

// class SmsControllerConcurrentEngine {
//   static bool smsParsed = false;

//   final log = getLogger('Sms-Controller');
//   SmsQuery query = SmsQuery();
//   final _allTransactionHelper = AllTransactionController();
//   // List<SmsMessage> messages = [];
//   final List<AllTransactionObjectBox> _smsToStoreFromUserDevice = [];
//   List<AllTransactionObjectBox> newSmsToBePushed = [];

//   Future<String> _fetchAmount(String msg) async {
//     final smsBody = msg;
//     final reg = RegExp(Constants.REGEXP_AMOUNT);
//     late String regxFilteredString;
//     late String stringToDouble;
//     String amount = '';

//     if (msg.contains('Rs') || msg.contains('rs') || msg.contains('INR')) {
//       regxFilteredString = reg
//           .firstMatch(smsBody)!
//           .group(0)!
//           .replaceAll('Rs', '')
//           .replaceAll('rs', '')
//           .replaceAll('INR', '');
//     }

//     FirebaseCrashlytics.instance.log('regxFilteredString: $regxFilteredString');

//     if (regxFilteredString.startsWith('.') ||
//         regxFilteredString.contains(',')) {
//       if (regxFilteredString.startsWith('.')) {
//         stringToDouble = regxFilteredString.replaceFirst('.', '');
//       } else {
//         stringToDouble = regxFilteredString.replaceAll(',', '');
//       }

//       FirebaseCrashlytics.instance.log('stringToDouble: $stringToDouble');

//       try {
//         log.i(stringToDouble);
//         amount = double.parse(stringToDouble).toString();
//         log.i('Amount: $amount');
//         FirebaseCrashlytics.instance
//             .log('Amount: returning from first try catch : $amount');
//         return amount.toString();
//       } catch (e) {
//         FirebaseCrashlytics.instance
//             .log('Error in parsing amount: $stringToDouble');
//         FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
//         rethrow;
//         // FirebaseCrashlytics.instance.crash();
//       }
//     }

//     try {
//       log.i('$amount before parsing to double');
//       amount = double.parse(regxFilteredString).toString();
//       FirebaseCrashlytics.instance
//           .log('Amount: returning from second try catch : $amount');
//       return amount.toString();
//     } catch (e) {
//       log.e(e);
//       log.e('final amount returned after error : $amount');
//       FirebaseCrashlytics.instance.log(
//           'final amount returned after error : $amount in Catch block of _fetchAmount()');
//       FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
//       rethrow;
//       // FirebaseCrashlytics.instance.crash();
//       // return null;
//     }
//     // log.i('final amount returned : $_amount');
//     // FirebaseCrashlytics.instance
//     //     .log('final amount returned : $_amount in _fetchAmount()');
//     // return _amount;
//   }

//   // Future<void>
//   Future<List<SmsMessage>> _fetchSMS() async {
//     List<SmsMessage> filteredMessages = [];

//     filteredMessages = [];

//     await query.querySms().then((value) {
//       filteredMessages = value;
//       // for (var logFiler in filteredMessages) {
//       //   log.i('logFiler: ${logFiler.body}');
//       //   FirebaseCrashlytics.instance.log('logFiler: ${logFiler.body}');
//       // }
//       // FirebaseCrashlytics.instance.recordError("Logs Sent", null);

//       // for (var m in value) {
//       //   if (m.dateSent?.isBefore(lastSmsQueryTime) ?? false) {
//       //     continue;
//       //   }
//       //   if (m.address!.contains('CANBNK')) {
//       //     _filteredMessages.add(m);
//       //   } else if (m.address!.contains('ICICIB')) {
//       //     _filteredMessages.add(m);
//       //   } else if (m.address!.contains('HDFCBK')) {
//       //     _filteredMessages.add(m);
//       //   } else if (m.address!.contains('SBIINB')) {
//       //     _filteredMessages.add(m);
//       //   } else if (m.address!.contains('PAYTMB')) {
//       //     _filteredMessages.add(m);
//       //   } else if (m.address!.contains('JKBANK')) {
//       //     _filteredMessages.add(m);
//       //   } else if (m.address!.contains('CBSSBI')) {
//       //     _filteredMessages.add(m);
//       //   }
//       // }
//     });

//     log.i('messgages retuened: ${filteredMessages.length}');
//     filteredMessages = filteredMessages.reversed.toList();
//     FirebaseCrashlytics.instance
//         .log('messgages retuened: ${filteredMessages.toString()}');
//     return filteredMessages;
//   }

// /*
// This is the main method, this is the only method called from outside
// -> and others are called by this method
// -> It fetches all sms and stores them in all transactions model
// */
// // ! Entry point
//   Future<List<AllTransactionObjectBox>> getAndStoreSms() async {
//     if (SmsControllerConcurrentEngine.smsParsed) {
//       return [];
//     }

//     List<SmsMessage> listToSentToIsolate = await _fetchSMS();

//     final LocalStore store = LocalStore();
//     DateTime lastSmsQueryTime = store.retrieveLastSmsTime();

//     var parsedData =
//         await _spawnIsolateToParseSms(listToSentToIsolate, lastSmsQueryTime);
//     List<dynamic> todaysSmsList = _getDebitSmsForTodayOnly(parsedData);
//     log.d('todaysSmsList: ${todaysSmsList.length}');
//     calculateTotalSpendingForToday(todaysSmsList);

//     _smsToStoreFromUserDevice.clear();
//     for (var mapData in parsedData) {
//       var allTransactionObjectBoxModel =
//           AllTransactionObjectBox.fromMap(mapData);
//       _smsToStoreFromUserDevice.add(allTransactionObjectBoxModel);
//     }

//     if (parsedData.isNotEmpty) {
//       lastSmsQueryTime = parsedData.last['createdAt'];
//     } else {
//       lastSmsQueryTime = DateTime.now();
//     }

//     store.updateLastSmsTime(lastSmsQueryTime);

//     log.wtf('_smsToStoreFromUserDevice: ${_smsToStoreFromUserDevice.length}');

//     final List<AllTransactionObjectBox> smsFetchedFromObjectBox =
//         _allTransactionHelper.getAllTransactions();

//     FirebaseCrashlytics.instance
//         .log('_smsFromSqfLite: ${smsFetchedFromObjectBox.length}');
//     log.wtf('_smsFetchedFromObjectBox: ${smsFetchedFromObjectBox.length}');

//     if (smsFetchedFromObjectBox.isNotEmpty) {
//       final QueryBuilder query = _allTransactionHelper.box.query()
//         ..order(AllTransactionObjectBox_.createdAt, flags: Order.descending);
//       final AllTransactionObjectBox lastTnx = query.build().findFirst();
//       log.wtf(lastTnx.createdAt);

//       newSmsToBePushed = _smsToStoreFromUserDevice;

//       FirebaseCrashlytics.instance
//           .log('newSmsToBePushed: ${newSmsToBePushed.length}');
//       log.wtf('newSmsToBePushed: ${newSmsToBePushed.length}');
//     }

//     if (newSmsToBePushed.isNotEmpty) {
//       _allTransactionHelper.addMultipleInAllTransactions(newSmsToBePushed);
//       log.d('Sms Pushed to ObjectBox');
//     }

//     if (smsFetchedFromObjectBox.isEmpty) {
//       _allTransactionHelper
//           .addMultipleInAllTransactions(_smsToStoreFromUserDevice);
//     }
//     SmsControllerConcurrentEngine.smsParsed = true;
//     return _smsToStoreFromUserDevice;
//   }

//   Future<List> _spawnIsolateToParseSms(
//       List<SmsMessage> listToSentToIsolate, DateTime lastSmsQueryTime) async {
//     ReceivePort receivePort = ReceivePort();
//     dynamic data = await IsolateSpawn()
//         .getSms(listToSentToIsolate, receivePort, lastSmsQueryTime);
//     return data;
//   }

//   dynamic _getDebitSmsForTodayOnly(dynamic smsList) {
//     /*
//         Step by step guide to achieve this:
//         1- Get the current date and time.
//         2- Set the start time to be the beginning of the day.
//         3- This function will only take those sms which are after the start time (Only today) and has debit word in it.
//         4- The list recieved as arg is sorted by the algo already, and now we will take waht we need
//         5 - and pass this list back with the sendPort as List<dynamic> where dynamic is the map of the sms.
//         6 - The main isolate will then store this list in the database and you can this list and use to scehdule the notification on midnight.
//         7- This will happen everytime a new sms is recieved. You recieve new sms -> it calls isolate -> isolate calls you
//      */

//     // get the current date and time
//     DateTime now = DateTime.now();

//     // set the start time to be the beginning of the day
//     DateTime startTime = DateTime(now.year, now.month, now.day, 0, 0, 0);
//     log.i('_smsList: ${smsList.toString()}');

//     // Get me transaction having transactionType == debit and createdAt >= startTime
//     dynamic smsListForTodayOnly = smsList
//         .where((element) =>
//             element['transactionType'] == 'debit' &&
//             element['createdAt']!.isAfter(startTime))
//         .toList();

//     log.i('_smsListForTodayOnly: ${smsListForTodayOnly.toString()}');
//     log.i('_smsListForTodayOnly.length: ${smsListForTodayOnly.length}');
//     return smsListForTodayOnly;
//   }

//   void calculateTotalSpendingForToday(List<dynamic> todaysSmsList) {
//     double totalSpending = 0.0;
//     for (var sms in todaysSmsList) {
//       totalSpending += sms['amount']!;
//     }
//     log.i('totalSpending: $totalSpending');
//     dailySmsSpending = totalSpending;
//     FirebaseCrashlytics.instance.log('totalSpending: $totalSpending');
//     // ! Now you can use this totalSpending to schedule the notification on midnight
//   }
// }
