import 'dart:math' as math;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lane_dane/app_controller.dart';
import 'package:lane_dane/controllers/transaction_controller.dart';
import 'package:lane_dane/errors/unauthorized_error.dart';
import 'package:lane_dane/models/transactions.dart';
import 'package:lane_dane/utils/string_extensions.dart';
import 'package:lane_dane/views/shared/snack-bar.dart';
import 'package:lane_dane/views/widgets/trans_button.dart';
import 'package:logger/logger.dart';
import 'package:lane_dane/utils/log_printer.dart';

class CustomCard extends StatefulWidget {
  final TransactionsModel transaction;
  const CustomCard({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  // final Map<String, Object> transaction;
  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  final Logger log = getLogger("Custom Card");
  final AppController appController = Get.find();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    double cardWidth = size.width * 0.6;

    TransactionsModel transaction = widget.transaction;
    final bool userCreated = transaction.tr_user_id == appController.user.id;

    String transactionType =
        userCreated ? transaction.transactionType : transaction.transactionType;

    final String transactionInfo =
        '${transactionType.toLowerCase().tr} - ${transaction.paymentStatus.toLowerCase().tr}';

    String confirmationStatusMessage = 'Unset';
    IconData confirmationStatusIcon = Icons.hourglass_empty;
    if (transaction.confirmation!.toLowerCase() ==
            Confirmation.Requested.name.toLowerCase() &&
        transaction.tr_user_id == 1) {
      confirmationStatusMessage = 'you_requested'.tr;
      confirmationStatusIcon = Icons.access_time_outlined;
    } else if (transaction.confirmation!.toLowerCase() ==
            Confirmation.Requested.name.toLowerCase() &&
        transaction.tr_user_id != 1) {
      confirmationStatusMessage = 'requested'.tr;
      confirmationStatusIcon = Icons.access_time_outlined;
    } else if (transaction.confirmation!.toLowerCase() ==
        Confirmation.Accepted.name.toLowerCase()) {
      confirmationStatusMessage = 'accepted'.tr;
      confirmationStatusIcon = Icons.check_circle;
    } else if (transaction.confirmation!.toLowerCase() ==
        Confirmation.Declined.name.toLowerCase()) {
      confirmationStatusMessage = 'declined'.tr;
      confirmationStatusIcon = Icons.block_flipped;
    }
    return Row(
      mainAxisAlignment:
          (userCreated) ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Card(
          elevation: 0,
          color: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey.shade400, width: 2.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            width: cardWidth,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const SizedBox(
                      width: 30,
                      child: Icon(
                        Icons.currency_rupee,
                        size: 20,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        transaction.amount,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.roboto(
                          fontSize: 50,
                          fontWeight: FontWeight.w500,
                          decoration: transaction.confirmation!.toLowerCase() ==
                                  Confirmation.Declined.name.toLowerCase()
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 30,
                      child: Transform.rotate(
                        angle: transactionType == TransactionType.Dane.name
                            ? math.pi / 4
                            : math.pi / -1.25,
                        child: const Icon(
                          Icons.arrow_circle_up_sharp,
                          color: Color(0xFF717171),
                          size: 18,
                        ),
                      ),
                    ),
                    Text(
                      transactionInfo,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 30,
                      child: Icon(
                        confirmationStatusIcon,
                        size: 18,
                        color: transaction.confirmation!.toLowerCase() ==
                                Confirmation.Accepted.name.toLowerCase()
                            ? const Color(0xFF26D367)
                            : const Color(0xFF717171),
                      ),
                    ),
                    Text(
                      confirmationStatusMessage,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.arrow_forward,
                          color: Color(0xFF26D367),
                        ),
                      ),
                    ),
                  ],
                ),
                userCreated ||
                        transaction.confirmation!.toLowerCase() !=
                            Confirmation.Requested.name.toLowerCase()
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: TranButton(
                                onPressed: () async {
                                  appController
                                      .updateTransactionStatus(
                                          transaction, Confirmation.Declined)
                                      .onError<UnauthorizedError>((err, stack) {
                                    appController.logout();
                                  }).onError((err, stack) {
                                    setState(() {
                                      transaction.confirmation =
                                          Confirmation.Requested.name;
                                    });
                                    FirebaseCrashlytics.instance.recordError(
                                      err,
                                      stack,
                                      fatal: false,
                                      printDetails: true,
                                      reason: 'Failed to accept transaction',
                                      information: [transaction.serverId!],
                                    );
                                  });
                                  setState(() {
                                    transaction.confirmation =
                                        Confirmation.Declined.name;
                                  });
                                },
                                text: 'decline'.tr,
                                foregroundColor: Colors.black,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: TranButton(
                                onPressed: () async {
                                  appController
                                      .updateTransactionStatus(
                                          transaction, Confirmation.Accepted)
                                      .onError<UnauthorizedError>((err, stack) {
                                    appController.logout();
                                  }).onError((err, stack) {
                                    setState(() {
                                      transaction.confirmation =
                                          Confirmation.Requested.name;
                                    });
                                    FirebaseCrashlytics.instance.recordError(
                                      err,
                                      stack,
                                      fatal: false,
                                      printDetails: true,
                                      reason: 'Failed to accept transaction',
                                      information: [transaction.serverId!],
                                    );
                                  });
                                  setState(() {
                                    transaction.confirmation =
                                        Confirmation.Accepted.name;
                                  });
                                },
                                text: 'accept'.tr,
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.teal,
                              ),
                            )
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
