import 'package:lane_dane/utils/sms_message_extension.dart';
import 'package:telephony/telephony.dart';
import 'package:lane_dane/models/all_transaction.dart';
import 'package:lane_dane/utils/constants.dart';

// --------------------------
// If given a sms, it finds out wether it is a transaction sms or not
// Based on the regualr expression checks written.
// --------------------------

AllTransactionObjectBox? parseSmsToTransaction(SmsMessage message) {
  // if (!isInbox(message)) {
  //   return null;
  // }

  // ! Sender check is no longer required as dont want to cap the sender limit to selective banks
  // if (isSenderInvalid(message)) {
  //   return null;
  // }

  if (!isTransactionSms(message)) {
    return null;
  }

  int? parsedAmount = parseAmount(message);
  if (parsedAmount == null) {
    return null;
  }
  DateTime? datetime = message.messageDate;
  // datetime ??= DateTime.now();

  String? messageBody = message.body;

  String? parsedTransactionType = parseTransactionType(message);
  parsedTransactionType ??= 'null';

  String? parsedAccountNumber = parseAccountNumber(message);
  if (parsedAccountNumber == null) {
    return null;
  }
  return AllTransactionObjectBox(
    amount: parsedAmount.toString(),
    name: parsedAccountNumber,
    smsBody: messageBody,
    transactionType: parsedTransactionType,
    profilePic: null,
    createdAt: datetime,
    updatedAt: datetime,
  );
}

bool isInbox(SmsMessage message) {
  if (message.type == SmsType.MESSAGE_TYPE_INBOX) {
    return true;
  } else {
    return false;
  }
}

bool isSenderInvalid(SmsMessage message) {
  switch (message.address) {
    case 'dm-axis':
      return true;
    default:
      return false;
  }
}

bool isTransactionSms(SmsMessage message) {
  // --------------------------
  // Triggers for possibility for promotional sms messages
  if (message.body!
      .toLowerCase()
      .contains(RegExp(r'\s(Click|withdraw|congragulations|Hello)'))) {
    return false;
  }

  if (message.body!.contains(RegExp(r'\s(Rs|rs|INR).[\d,.]*\b')) ||
      !message.body!.contains(RegExp(r'\bcredit\b(?![\w\s]*card)'))) {
    return true;
  } else {
    return false;
  }
}

int? parseAmount(SmsMessage message) {
  if (message.body == null) {
    return null;
  }
  final RegExp reg = RegExp(Constants.REGEXP_AMOUNT);
  String? filteredString = reg.firstMatch(message.body ?? '')?.group(0);
  if (filteredString == null) {
    return null;
  }

  String cleanString = filteredString
      .replaceAll(RegExp(r'((rs|inr)(\.)*)', caseSensitive: false), '')
      .replaceAll(' ', '')
      .replaceFirst(',', '');
  try {
    int amount = double.parse(cleanString).toInt();
    return amount;
  } catch (e) {
    return null;
  }
}

String? parseTransactionType(SmsMessage message) {
  String? messageBody = message.body?.toLowerCase();
  if (messageBody == null) {
    return null;
  }
  if (messageBody
      .contains(RegExp(r'debit|paid|sent|debited', caseSensitive: false))) {
    return 'debit';
  }

  if (messageBody.contains(RegExp(r'credit|deposit|deposited|returned|credited',
      caseSensitive: false))) {
    return 'credit';
  }

  return null;
}

String? parseAccountNumber(SmsMessage message) {
  String? messageBody = message.body;
  if (messageBody == null) {
    return null;
  }
  final RegExp reg =
      RegExp(Constants.REGEXP_ACCOUNTNUMBER, caseSensitive: false);
  String? filteredString = reg.firstMatch(messageBody)?.group(0);
  if (filteredString == null) {
    return null;
  }
  final String parsedAccountNumber = 'A/C $filteredString';
  return parsedAccountNumber;
}
