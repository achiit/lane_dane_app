import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lane_dane/models/aggregate_record.dart';
import 'package:lane_dane/models/users.dart';
import 'package:lane_dane/views/widgets/transaction_aggregate_view.dart';
import '../../../models/transactions.dart';
import '../../widgets/outlined_profile_box.dart';

import 'package:flutter_profile_picture/flutter_profile_picture.dart';

class UserProfile extends StatelessWidget {
  static const String routeName = 'user-screen';
  final Users user;
  final List<TransactionsModel> transactionHistory;

  UserProfile({
    Key? key,
    required this.user,
    required this.transactionHistory,
  }) : super(key: key) {
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: UserProfile.routeName,
    );
  }

  @override
  Widget build(BuildContext context) {
    AggregateRecord record =
        AggregateRecord.fromTransactionList(list: transactionHistory);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'user_profile'.tr,
          style: GoogleFonts.roboto(),
        ),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 10, left: 8, right: 8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ProfilePicture(
                    name: user.full_name!,
                    radius: 76,
                    fontsize: 48,
                    random: true,
                  ),
                ],
              ),
              const SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.person,
                          color: Color.fromARGB(226, 4, 78, 6),
                          size: 25.0,
                        ),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'name'.tr,
                            style: GoogleFonts.roboto(fontSize: 10),
                          ),
                          Text(user.full_name!,
                              style: const TextStyle(fontSize: 13.0)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 10.0,
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.call,
                      color: Color.fromARGB(226, 4, 78, 6),
                      size: 25.0,
                    ),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'phone'.tr,
                        style: GoogleFonts.roboto(fontSize: 10.0),
                      ),
                      Text(
                        user.phoneWithCodeFormat,
                        style: const TextStyle(fontSize: 13.0),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 40.0,
              ),
              TransactionAggregateView(record: record),
              // Column(
              //   children: [
              //     Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //       children: [
              //         OutlinedProfile(
              //           text: "Lane Done",
              //           chipText: record.laneDone.toString(),
              //         ),
              //         OutlinedProfile(
              //           text: "Dane Done",
              //           chipText: record.daneDone.toString(),
              //         ),
              //       ],
              //     ),
              //     const SizedBox(
              //       height: 20.0,
              //     ),
              //     Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //       children: [
              //         OutlinedProfile(
              //           text: "Lane Pending",
              //           chipText: record.lanePending.toString(),
              //         ),
              //         OutlinedProfile(
              //           text: "Dane Pending",
              //           chipText: record.danePending.toString(),
              //         ),
              //       ],
              //     ),
              //   ],
              // )
            ],
          ),
        ),
      ),
    );
  }
}
