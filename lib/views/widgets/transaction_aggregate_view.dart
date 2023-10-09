import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lane_dane/models/aggregate_record.dart';
import 'package:lane_dane/utils/colors.dart';

class TransactionAggregateView extends StatelessWidget {
  final AggregateRecord record;
  const TransactionAggregateView({
    Key? key,
    required this.record,
  }) : super(key: key);

  final Color primaryGrey = const Color(0xFFDFE4ED);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    const BorderRadius defaultBorderRadius =
        BorderRadius.all(Radius.circular(10));
    const Radius curvedRadius = Radius.circular(20);

    bool showSmsAggregate = (record.smsDane != null && record.smsLane != null);

    return Container(
      width: size.width,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(curvedRadius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(height: 20),
          showSmsAggregate
              ? Row(
                  children: [
                    Expanded(
                      child: recordBox(
                        // name: '${'sms'.tr} ${'lane'.tr}',
                        name: 'bank_credit'.tr,
                        amount: record.smsLane ?? 0,
                        borderRadius: defaultBorderRadius.copyWith(
                          topLeft: curvedRadius,
                        ),
                      ),
                    ),
                    Expanded(
                      child: recordBox(
                        // name: '${'sms'.tr} ${'dane'.tr}',
                        name: 'bank_debit'.tr,
                        amount: record.smsDane ?? 0,
                        borderRadius: defaultBorderRadius.copyWith(
                          topRight: curvedRadius,
                        ),
                      ),
                    ),
                  ],
                )
              : Container(),
          Row(
            children: [
              Expanded(
                child: recordBox(
                  name: '${'lane'.tr} ${'done'.tr}',
                  amount: record.laneDone,
                  borderRadius: showSmsAggregate
                      ? defaultBorderRadius
                      : defaultBorderRadius.copyWith(
                          topLeft: curvedRadius,
                        ),
                ),
              ),
              Expanded(
                child: recordBox(
                  name: '${'lane'.tr} ${'pending'.tr}',
                  amount: record.lanePending,
                  borderRadius: showSmsAggregate
                      ? defaultBorderRadius
                      : defaultBorderRadius.copyWith(
                          topLeft: curvedRadius,
                        ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: recordBox(
                  name: '${'dane'.tr} ${'done'.tr}',
                  amount: record.daneDone,
                  borderRadius: defaultBorderRadius.copyWith(
                    bottomLeft: curvedRadius,
                  ),
                ),
              ),
              Expanded(
                child: recordBox(
                  name: '${'dane'.tr} ${'pending'.tr}',
                  amount: record.danePending,
                  borderRadius: defaultBorderRadius.copyWith(
                    bottomRight: curvedRadius,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget recordBox({
    required String name,
    required int amount,
    required BorderRadius borderRadius,
  }) {
    return Container(
      height: 120,
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: primaryGrey,
        borderRadius: borderRadius,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '₹$amount',
            style: GoogleFonts.roboto(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF656870),
            ),
          ),
          Text(
            name,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: const Color(0xFF818A9F),
            ),
          ),
        ],
      ),
    );
  }
}
