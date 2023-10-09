import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lane_dane/app_controller.dart';
import 'package:lane_dane/models/transactions.dart';
import 'package:lane_dane/utils/colors.dart';
import 'package:lane_dane/views/widgets/transaction_reminder_card.dart';

class TransactionReminderSetting extends StatelessWidget {
  /// This screen allows the user to setup reminders for all of their pending
  /// transactions. This screen should not be available if the user is not
  /// premium account user.
  static const String routeName = 'transaction-reminder-setting';

  final List<TransactionsModel> completeTransactionList;
  const TransactionReminderSetting({
    Key? key,
    required this.completeTransactionList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<TransactionsModel> pendingTransactionList =
        completeTransactionList.where((TransactionsModel transaction) {
      return transaction.paymentStatus.toLowerCase() == 'pending' &&
          transaction.confirmation!.toLowerCase() != 'declined';
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenColor,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Reminder Setup',
          style: GoogleFonts.roboto(
            fontSize: 22,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: pendingTransactionList.length,
          itemBuilder: (BuildContext context, int index) {
            TransactionsModel transaction = pendingTransactionList[index];
            return TransactionReminderCard(
              transaction: transaction,
            );
          },
        ),
      ),
    );
  }
}
