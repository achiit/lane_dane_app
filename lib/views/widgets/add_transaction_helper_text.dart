import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lane_dane/models/users.dart';
import 'package:lane_dane/utils/colors.dart';
import 'package:lane_dane/views/widgets/date_selector.dart';

class AddTransactionHelperText extends StatefulWidget {
  final TextEditingController amountController;
  final ValueNotifier transactionTypeNotifier;
  final ValueNotifier paymentStatusNotifier;
  final DateController dateController;
  final Users user;
  const AddTransactionHelperText({
    Key? key,
    required this.amountController,
    required this.paymentStatusNotifier,
    required this.transactionTypeNotifier,
    required this.dateController,
    required this.user,
  }) : super(key: key);

  @override
  State<AddTransactionHelperText> createState() =>
      _AddTransactionHelperTextState();
}

class _AddTransactionHelperTextState extends State<AddTransactionHelperText> {
  late String helperText;

  @override
  void initState() {
    super.initState();
    updateText();

    widget.amountController.addListener(updateText);
    widget.transactionTypeNotifier.addListener(updateText);
    widget.paymentStatusNotifier.addListener(updateText);
    widget.dateController.addListener(updateText);
  }

  @override
  void dispose() {
    widget.amountController.removeListener(updateText);
    widget.transactionTypeNotifier.removeListener(updateText);
    widget.paymentStatusNotifier.removeListener(updateText);
    widget.dateController.removeListener(updateText);

    super.dispose();
  }

  bool lane() {
    return widget.transactionTypeNotifier.value.toLowerCase() == 'lane';
  }

  bool dane() {
    return widget.transactionTypeNotifier.value.toLowerCase() == 'dane';
  }

  bool pending() {
    return widget.paymentStatusNotifier.value.toLowerCase() == 'pending';
  }

  bool done() {
    return widget.paymentStatusNotifier.value.toLowerCase() == 'done';
  }

  void updateText() {
    String amount = widget.amountController.text;
    String name = widget.user.full_name!;
    Map<String, String> params = {
      'amount': amount,
      'name': name,
    };

    if (lane() && done()) {
      helperText = 'lane_done_helper_text'.trParams(params);
    } else if (lane() && pending()) {
      helperText = 'lane_pending_helper_text'.trParams(params);
    } else if (dane() && done()) {
      helperText = 'dane_done_helper_text'.trParams(params);
    } else if (dane() && pending()) {
      helperText = 'dane_pending_helper_text'.trParams(params);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 18, right: 18),
      child: Text(
        helperText,
        textAlign: TextAlign.center,
        style: GoogleFonts.roboto(
          color: secondaryGrey,
          fontSize: 18,
        ),
      ),
    );
  }
}
