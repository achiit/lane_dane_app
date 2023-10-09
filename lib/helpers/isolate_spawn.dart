// import 'dart:isolate';

// import '../utils/constants.dart';
// import '../utils/log_printer.dart';
// import 'package:sms_advanced/sms_advanced.dart';

// class IsolateSpawn {
//   final log = getLogger('IsolateSpawn');

//   Future<String> _fetchAccountNumber(String msg) async {
//     final smsBody = msg;
//     final reg = RegExp(Constants.REGEXP_ACCOUNTNUMBER, caseSensitive: false);
//     late String? regxFilteredString;

//     regxFilteredString =
//         reg.firstMatch(smsBody)?.group(0) ?? 'No Account Number Found';
//     final str = 'A/C $regxFilteredString';
//     return str;
//   }

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

//     if (regxFilteredString.startsWith('.') ||
//         regxFilteredString.contains(',')) {
//       if (regxFilteredString.startsWith('.')) {
//         stringToDouble = regxFilteredString.replaceFirst('.', '');
//       } else {
//         stringToDouble = regxFilteredString.replaceAll(',', '');
//       }

//       try {
//         log.i(stringToDouble);
//         amount = double.parse(stringToDouble).toString();
//         log.i('Amount: $amount');
//         return amount.toString();
//       } catch (e) {
//         rethrow;
//         // FirebaseCrashlytics.instance.crash();
//       }
//     }

//     try {
//       log.i('$amount before parsing to double');
//       amount = double.parse(regxFilteredString).toString();
//       return amount.toString();
//     } catch (e) {
//       log.e(e);
//       log.e('final amount returned after error : $amount');
//       rethrow;
//       // FirebaseCrashlytics.instance.crash();
//       // return null;
//     }
//     // log.i('final amount returned : $_amount');
//     // FirebaseCrashlytics.instance
//     //     .log('final amount returned : $_amount in _fetchAmount()');
//     // return _amount;
//   }

//   Future<List<dynamic>> getSms(List<SmsMessage> smsList, ReceivePort rp,
//       DateTime lastSmsQueryTime) async {
//     final List<dynamic> args = [
//       rp.sendPort,
//       smsList,
//       lastSmsQueryTime.toString()
//     ];

//     await Isolate.spawn(_getSms, args).whenComplete(() => Isolate.current.kill);
//     return await rp.first;
//   }

//   void _getSms(List<dynamic> args) async {
//     SendPort sp = args[0];
//     List<SmsMessage> filteredMessages = args[1];
//     DateTime lastSmsQueryTime = DateTime.parse(args[2]);
//     List smsToStoreFromUserDevice = [];
//     String tnxType = '';
//     DateTime? date;
//     String amount = '';
//     String? smsBody;
//     String? accNumber;

//     for (int i = 0; i < filteredMessages.length; i++) {
//       SmsMessage currentlyParsingSms = filteredMessages[i];
//       // ! To avoid recording the same transaction twice
//       if (currentlyParsingSms.sender == 'dm-axis') {
//         continue;
//       }

//       if ((currentlyParsingSms.date?.isBefore(lastSmsQueryTime) ?? true) ||
//           (currentlyParsingSms.date?.isAtSameMomentAs(lastSmsQueryTime) ??
//               true)) {
//         continue;
//       }
//       log.i(
//           '-------------------  $i out of ${filteredMessages.length} --------------------------');

//       // ? TRY BLOCK FOR SMS BODY -> Checking
//       try {
//         smsBody = filteredMessages[i].body;
//         if (!smsBody!.contains(RegExp(r'\s(Rs|rs|INR).[\d,.]*\b'))) {
//           continue;
//         }
//         log.wtf('Body with Transaction found: $smsBody');
//       } catch (err) {
//         log.e(
//             'Failed to parse and store SMS transaction: ${filteredMessages[i].id}');
//         log.e('Body: ${filteredMessages[i].body}');
//         log.e('Error: $err');
//         continue;
//       }

//       // ? TRY BLOCK FOR SMS DATE -> Checking
//       date = filteredMessages[i].date;
//       log.wtf('date: $date');

//       //? SMS CREDIT/DEBIT -> Checking
//       if (smsBody.contains('debit') ||
//           smsBody.contains('paid') ||
//           smsBody.contains('sent') ||
//           smsBody.contains('Debit') ||
//           smsBody.contains('DEBITED') ||
//           smsBody.contains('DEBIT')) {
//         log.wtf('Debit found ');
//         tnxType = 'debit';
//       } else if (smsBody.contains('credit') ||
//           smsBody.contains('Credit') ||
//           smsBody.contains('deposited') ||
//           smsBody.contains('returned') ||
//           smsBody.contains('CREDITED')) {
//         log.wtf('Credit found');
//         tnxType = 'credit';
//       } else {
//         log.e('No debit or credit found in $smsBody');
//         tnxType = 'null';
//       }

//       // ? TRY BLOCK FOR SMS AMOUNT -> Checking
//       try {
//         amount = await _fetchAmount(smsBody);
//         if (amount.isEmpty) {
//           continue;
//         }
//         log.wtf('Amount retrieved: $amount');

//         // _smsToStoreFromUserDevice.add(allTransactionObjectBoxModel);
//       } catch (err) {
//         log.e(
//             'Failed to parse and store SMS transaction: ${filteredMessages[i].id}');
//         log.e('Body of failed SMS: ${filteredMessages[i].body}');
//         log.e('DateTime of failed SMS ${filteredMessages[i].dateSent}');
//         continue;
//       }

//       // ? TRY BLOCK FOR SMS ACCOUNT NUMBER -> Checking
//       try {
//         accNumber = await _fetchAccountNumber(smsBody);
//         if (accNumber == 'A/C No Account Number Found') {
//           continue;
//         }
//         log.wtf('accNumber: $accNumber');
//       } catch (e) {
//         log.e(e);
//       }

//       // ! That means the sms is not a transaction sms. or the sms was not captured by the regex.
//       if ('null' == tnxType) {
//         continue;
//       }

//       final Map<String, dynamic> smsFromUserDevice = {
//         'transactionType': tnxType,
//         'amount': amount,
//         'name': accNumber,
//         'createdAt': date,
//         'smsBody': smsBody,
//       };
//       log.i('sms added to _smsFromUserDevice array');
//       smsToStoreFromUserDevice.add(smsFromUserDevice);
//       log.i('');
//       log.i('');
//       log.i('');
//     }
//     log.d('Sending data to main isolate : ${smsToStoreFromUserDevice.length}');
//     sp.send(smsToStoreFromUserDevice);
//     // TODO: A map of parsed data must be returned to the main isolate.
//     // Isolate.exit(args[0], 'done');
//   }

//   // dynamic getContact() async {
//   //   ReceivePort rp = ReceivePort();
//   //   await Isolate.spawn(_getContact, rp.sendPort)
//   //       .then((_) => log.d('Done: with isolate $rp : $_'));
//   // }

//   // void _getContact(SendPort sp) async {
//   //   SmsController sc = SmsController();
//   //   sc.getAndStoreSms();
//   //   Isolate.exit(sp, 'done');
//   // }
// }
