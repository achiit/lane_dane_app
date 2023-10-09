import 'package:telephony/telephony.dart';

extension MessageDate on SmsMessage {
  DateTime get messageDate {
    return DateTime.fromMillisecondsSinceEpoch(date!);
  }
}
