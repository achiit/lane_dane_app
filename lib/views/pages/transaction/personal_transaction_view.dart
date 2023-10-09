import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lane_dane/app_controller.dart';
import 'package:lane_dane/controllers/transaction_controller.dart';
import 'package:lane_dane/helpers/auth.dart';
import 'package:lane_dane/models/transactions.dart';
import 'package:lane_dane/models/users.dart';
import 'package:lane_dane/objectbox.g.dart';
import 'package:lane_dane/views/pages/profile/user_profile.dart';
import 'package:lane_dane/views/pages/transaction/transaction_details.dart';
import 'package:lane_dane/views/widgets/bottom_chat_ui.dart';
import 'package:lane_dane/utils/log_printer.dart';
import 'package:lane_dane/views/widgets/CustomCard.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';

class PersonalTransactions extends StatefulWidget {
  static const String routeName = 'personal-transactions';

  final Users contact;
  final Map<String, dynamic> objects;

  const PersonalTransactions({
    Key? key,
    required this.objects,
    required this.contact,
  }) : super(key: key);

  @override
  State<PersonalTransactions> createState() => _PersonalTransactionsState();
}

class _PersonalTransactionsState extends State<PersonalTransactions> {
  final AppController appController = Get.find();
  final log = getLogger('PersonalTransactions');
  Map<String, dynamic> me = {};

  late final Users user = widget.contact;
  late final StreamSubscription stream;
  late final ScrollController scrollController;
  late List<TransactionsModel> transactionList;

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: PersonalTransactions.routeName,
    );
    transactionList = appController.transactionController
        .retrieveUserTransaction(widget.contact.id!);
    stream = appController.transactionController
        .streamAllForUserIdSortByServerId(widget.contact.id!)
        .listen(updateTransactionList);
    scrollController = ScrollController();
    setMe();
  }

  @override
  void dispose() {
    stream.cancel();
    super.dispose();
  }

  void updateTransactionList(Query<TransactionsModel> query) {
    if (mounted) {
      setState(() {
        transactionList = query.find();
      });
    }
  }

  void setMe() async {
    me = await Auth().user();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ProfilePicture(
              name: user.full_name!,
              radius: 21,
              fontsize: 21,
              random: true,
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .pushNamed(UserProfile.routeName, arguments: {
                  'contact': user,
                  'transaction': transactionList,
                });
              },
              child: Text(
                user.full_name!,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF128C7E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return Column(
          children: [
            SizedBox(
              /// The Chat widget takes up 52 pixels in height.
              /// Subtracting 60 just to be safer
              height: constraints.maxHeight - 60,
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 20),
                scrollDirection: Axis.vertical,
                reverse: true,
                controller: scrollController,
                itemCount: transactionList.length,
                itemBuilder: (context, index) {
                  bool isSameDate = true;
                  String dateString =
                      transactionList[index].createdAt.toString();
                  log.i('->$dateString');
                  DateTime date = DateTime.parse(dateString);
                  log.i(date);
                  if (index == 0) {
                    isSameDate = false;
                  } else {
                    String prevDateString =
                        transactionList[index - 1].createdAt.toString();
                    DateTime prevDate = DateTime.parse(prevDateString);
                    isSameDate = date.isSameDate(prevDate);
                  }
                  var date1 = '';
                  if (index == 0 || !(isSameDate)) {
                    date1 = date.formatDate();
                  }
                  return Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Text(date1),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            TransactionDetails.routeName,
                            arguments: {
                              'transaction': transactionList[index],
                              'contact': widget.contact,
                            },
                          );
                        },
                        child: CustomCard(
                          transaction: transactionList[index],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            // Moved to column so it can be visible when the keyboard pops up
            BottomChatField(
              user: widget.contact,
              transactionList: transactionList,
              me: me,
            ),
          ],
        );
      }),
    );
  }
}

const String dateFormatter = 'MMMM dd, y';

extension DateHelper on DateTime {
  String formatDate() {
    final formatter = DateFormat(dateFormatter);
    return formatter.format(this);
  }

  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  int getDifferenceInDaysWithNow() {
    final now = DateTime.now();
    return now.difference(this).inDays;
  }
}
