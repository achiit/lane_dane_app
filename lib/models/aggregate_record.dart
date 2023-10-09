import 'package:lane_dane/models/all_transaction.dart';
import 'package:lane_dane/models/transactions.dart';

class AggregateRecord {
  int laneDone;
  int lanePending;
  int daneDone;
  int danePending;
  int? smsLane;
  int? smsDane;
  AggregateRecord({
    required this.laneDone,
    required this.lanePending,
    required this.daneDone,
    required this.danePending,
    this.smsLane,
    this.smsDane,
  });

  factory AggregateRecord.fromTransactionList({
    required List<TransactionsModel> list,
    List<AllTransactionObjectBox>? allTransactionList,
  }) {
    const String lane = 'lane';
    const String dane = 'dane';
    const String done = 'done';
    const String pending = 'pending';

    int laneDone = 0;
    int lanePending = 0;
    int daneDone = 0;
    int danePending = 0;

    for (int index = 0; index < list.length; index++) {
      final TransactionsModel t = list[index];
      if (t.confirmation!.toLowerCase() ==
          Confirmation.Declined.name.toLowerCase()) {
        continue;
      }
      if (t.transactionType.toLowerCase() == lane &&
          t.paymentStatus.toLowerCase() == done) {
        laneDone += int.parse(t.amount);
      } else if (t.transactionType.toLowerCase() == lane &&
          t.paymentStatus.toLowerCase() == pending) {
        lanePending += int.parse(t.amount);
      } else if (t.transactionType.toLowerCase() == dane &&
          t.paymentStatus.toLowerCase() == done) {
        daneDone += int.parse(t.amount);
      } else if (t.transactionType.toLowerCase() == dane &&
          t.paymentStatus.toLowerCase() == pending) {
        danePending += int.parse(t.amount);
      }
    }

    int smsLane = 0;
    int smsDane = 0;
    if (allTransactionList != null) {
      for (AllTransactionObjectBox allTransaction in allTransactionList) {
        if (allTransaction.smsBody == null) {
          continue;
        }

        if (allTransaction.transactionType.toLowerCase() == 'credit') {
          smsLane += double.parse(allTransaction.amount).toInt();
        } else {
          smsDane += double.parse(allTransaction.amount).toInt();
        }
      }
    }
    return AggregateRecord(
      laneDone: laneDone,
      lanePending: lanePending,
      daneDone: daneDone,
      danePending: danePending,
      smsLane: allTransactionList != null ? smsLane : null,
      smsDane: allTransactionList != null ? smsDane : null,
    );
  }
}
