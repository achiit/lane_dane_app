import 'package:lane_dane/utils/sms_message_extension.dart';
import 'package:telephony/telephony.dart';

List<SmsMessage> filterSmsBetween(
  List<SmsMessage> smsList,
  DateTime start,
  DateTime end,
) {
  List<SmsMessage> filteredSms = smsList.where((SmsMessage message) {
    if ((message.messageDate.isAfter(start)) &&
        (message.messageDate.isBefore(end))) {
      return true;
    } else {
      return false;
    }
  }).toList();
  return filteredSms;
}
