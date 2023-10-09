import 'package:lane_dane/helpers/notification_service.dart';
import 'package:lane_dane/models/all_transaction.dart';
import 'package:lane_dane/utils/sms_parser.dart';
import 'package:telephony/telephony.dart';

void setupTelephony() {
  Telephony.instance.listenIncomingSms(
    onNewMessage: foregroundSmsHandler,
    onBackgroundMessage: backgroundSmsHandler,
    listenInBackground: true,
  );
  Telephony.backgroundInstance.listenIncomingSms(
    onNewMessage: foregroundSmsHandler,
    onBackgroundMessage: backgroundSmsHandler,
    listenInBackground: true,
  );
}

Future<void> foregroundSmsHandler(SmsMessage message) async {
  AllTransactionObjectBox? allTransaction = parseSmsToTransaction(message);
  if (allTransaction == null) {
    return;
  }

  NotificationService notifications = NotificationService();

  notifications.showIncomingTransactionSmsNotification(
    allTransaction: allTransaction,
  );
}

@pragma('vm:entry-point')
Future<void> backgroundSmsHandler(SmsMessage message) async {
  AllTransactionObjectBox? allTransaction = parseSmsToTransaction(message);
  if (allTransaction == null) {
    return;
  }

  NotificationService notifications = NotificationService();

  notifications.showIncomingTransactionSmsNotification(
    allTransaction: allTransaction,
  );
}
