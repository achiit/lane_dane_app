import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lane_dane/models/all_transaction.dart';
import 'package:lane_dane/models/transactions.dart';

class AllTransactionListTile extends StatefulWidget {
  final AllTransactionObjectBox alltransaction;
  final bool isSms;
  final void Function() navigationCallback;
  const AllTransactionListTile({
    Key? key,
    required this.alltransaction,
    this.isSms = false,
    required this.navigationCallback,
  }) : super(key: key);

  @override
  State<AllTransactionListTile> createState() => _AllTransactionListTileState();
}

class _AllTransactionListTileState extends State<AllTransactionListTile>
    with SingleTickerProviderStateMixin {
  get greenColor => null;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _animationController.forward().then((value) {
      _animationController.reverse();
      widget.navigationCallback();
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color laneArrowColor = Color(0xFF55AA55);
    const Color daneArrowColor = Color(0xFFDD2222);
    final Color laneBackgroundColor = laneArrowColor.withOpacity(0.2);
    final Color daneBackgroundColor = daneArrowColor.withOpacity(0.2);

    final String transactionType =
        widget.alltransaction.transactionType.toLowerCase() == 'lane' ||
                widget.alltransaction.transactionType.toLowerCase() == 'credit'
            ? 'lane'
            : 'dane';
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: InkWell(
        onTap: _handleTap,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: ListTile(
            // onTap: widget.navigationCallback,
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
              widget.alltransaction.amount,
              style: TextStyle(
                  color:
                      transactionType == TransactionType.Dane.name.toLowerCase()
                          ? Colors.red
                          : Colors.green,
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              widget.isSms
                  ? 'A/C ${widget.alltransaction.name.substring(widget.alltransaction.name.length - 5).toUpperCase()}'
                  : widget.alltransaction.name,
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
                  DateFormat("d MMM").format(widget.alltransaction.createdAt),
                  style: GoogleFonts.roboto(
                    color: const Color(0xFF8F8F8F),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  DateFormat("jm").format(widget.alltransaction.createdAt),
                  style: GoogleFonts.roboto(
                    color: const Color(0xFF8F8F8F),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
