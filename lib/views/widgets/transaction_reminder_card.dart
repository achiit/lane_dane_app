import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lane_dane/utils/date_time_extensions.dart';
import 'package:lane_dane/models/transactions.dart';

class TransactionReminderCard extends StatefulWidget {
  final TransactionsModel transaction;
  const TransactionReminderCard({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  State<TransactionReminderCard> createState() =>
      _TransactionReminderCardState();
}

class _TransactionReminderCardState extends State<TransactionReminderCard> {
  late bool open;

  @override
  void initState() {
    super.initState();
    open = false;
  }

  void toggleOpen() {
    setState(() {
      open = !open;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    const Color laneArrowColor = Color(0xFF55AA55);
    const Color daneArrowColor = Color(0xFFDD2222);
    final Color laneBackgroundColor = laneArrowColor.withOpacity(0.2);
    final Color daneBackgroundColor = daneArrowColor.withOpacity(0.2);

    String transactionType = widget.transaction.transactionType.toLowerCase();

    return Container(
      child: Column(
        children: [
          ListTile(
            onTap: toggleOpen,
            leading: CircleAvatar(
              radius: 21,
              backgroundColor:
                  transactionType == TransactionType.Dane.name.toLowerCase()
                      ? daneBackgroundColor
                      : laneBackgroundColor,
              child: Transform.rotate(
                angle:
                    transactionType == TransactionType.Dane.name.toLowerCase()
                        ? math.pi / 4
                        : math.pi / -1.25,
                child: Icon(
                  Icons.arrow_upward,
                  color:
                      transactionType == TransactionType.Dane.name.toLowerCase()
                          ? daneArrowColor
                          : laneArrowColor,
                  size: 24,
                ),
              ),
            ),
            title: Text(
              // _allCon[index]['full_name'],
              widget.transaction.amount,
              style: TextStyle(
                  color:
                      transactionType == TransactionType.Dane.name.toLowerCase()
                          ? Colors.red
                          : Colors.green,
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              widget.transaction.user.target!.full_name!,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  DateFormat("d MMM").format(widget.transaction.createdAt),
                  style: GoogleFonts.roboto(
                    color: const Color(0xFF8F8F8F),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  DateFormat("jm").format(widget.transaction.createdAt),
                  style: GoogleFonts.roboto(
                    color: const Color(0xFF8F8F8F),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          open
              ? Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  padding: EdgeInsets.symmetric(horizontal: 42 + 16),
                  child: Row(
                    children: [
                      Text(
                        'Due Date: ',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        widget.transaction.dueDate?.digitOnlyDate() ??
                            'No Date Found',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
