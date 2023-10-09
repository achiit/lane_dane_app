import 'package:flutter/foundation.dart';
import 'package:telephony/telephony.dart';
import 'package:lane_dane/utils/filter_sms_between.dart';

class SmsController {
  static bool smsParsed = false;

  // late final SmsQuery smsquery;
  SmsController() {
    // smsquery = SmsQuery();
  }

  Future<List<SmsMessage>> getAll() async {
    // return await smsquery.getAllSms;
    return await Telephony.instance.getInboxSms();
  }

  Future<List<SmsMessage>> getAllReceived() async {
    return await getAll();
  }

  Future<List<SmsMessage>> getAllReceivedBetween({
    required DateTime start,
    required DateTime end,
  }) async {
    List<SmsMessage> allSms = await getAllReceived();
    // List<Map> allSmsMap = allSms.map<Map>((SmsMessage sms) {
    //   return sms.toMap;
    // }).toList();
    List<SmsMessage> smsBetween =
        await compute<Map<String, dynamic>, List<SmsMessage>>(
      filterSmsOnIsolate,
      {
        'sms_list': allSms,
        'start': start,
        'end': end,
      },
    );
    return smsBetween;
  }
}

Future<List<SmsMessage>> filterSmsOnIsolate(Map<String, dynamic> params) async {
  List<SmsMessage> allSms = params['sms_list'];
  DateTime start = params['start'];
  DateTime end = params['end'];

  List<SmsMessage> filteredSmsList = filterSmsBetween(allSms, start, end);
  return filteredSmsList;
}
