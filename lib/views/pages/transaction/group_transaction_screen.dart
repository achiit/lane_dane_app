import 'dart:async';

import 'dart:math' as math;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lane_dane/app_controller.dart';
import 'package:lane_dane/controllers/group_transaction_controller.dart';
import 'package:lane_dane/models/group_model.dart';
import 'package:lane_dane/models/group_transaction.dart';
import 'package:lane_dane/models/users.dart';
import 'package:lane_dane/objectbox.g.dart';
import 'package:lane_dane/utils/colors.dart';
import 'package:lane_dane/utils/date_time_extensions.dart';
import 'package:lane_dane/views/pages/transaction/add_group_transaction.dart';

class GroupTransactionScreen extends StatefulWidget {
  static const String routeName = 'group-transaction-screen';

  final Groups group;
  GroupTransactionScreen({
    Key? key,
    required this.group,
  }) : super(key: key);

  @override
  State<GroupTransactionScreen> createState() => _GroupTransactionScreenState();
}

class _GroupTransactionScreenState extends State<GroupTransactionScreen> {
  final AppController appController = Get.find();

  late List<GroupTransaction> transactionList;
  late StreamSubscription<Query<GroupTransaction>> stream;

  @override
  void initState() {
    super.initState();
    transactionList = appController.groupTransactionController
        .retrieveForGroupOrderByServerId(groupId: widget.group.id);
    stream = appController.groupTransactionController
        .streamAllForGroupIdSortByServerId(widget.group.id)
        .listen(updateGroupTransactionList);
  }

  @override
  void dispose() {
    stream.cancel();
    super.dispose();
  }

  void updateGroupTransactionList(Query<GroupTransaction> query) {
    if (mounted) {
      setState(() {
        transactionList = query.find();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    void toGroupProfile() {}

    Future<void> toAddGroupTransaction() async {
      dynamic groupTransaction = await Navigator.of(context)
          .pushNamed(AddGroupTransaction.routeName, arguments: {
        'group': widget.group,
      });

      if (groupTransaction == null) {
        return;
      }

      print(groupTransaction.amount);
    }

    final AppBar appBar = AppBar(
      title: Row(
        children: [
          ProfilePicture(
            name: widget.group.groupName,
            radius: 21,
            fontsize: 21,
            random: true,
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: toGroupProfile,
            child: Text(
              widget.group.groupName,
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
    );

    final Widget addTransactionButton = FloatingActionButton(
      onPressed: toAddGroupTransaction,
      backgroundColor: greenColor,
      child: const Icon(
        Icons.add,
      ),
    );

    return Scaffold(
      appBar: appBar,
      // resizeToAvoidBottomInset: true,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          addTransactionButton,
        ],
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          DateTime listTime = DateTime.now();

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
                  itemCount: transactionList.length,
                  itemBuilder: (context, index) {
                    final GroupTransaction groupTransaction =
                        transactionList[index];

                    void onCardTap() {
                      /// Navigate to group transaction details screen
                    }

                    if (index == transactionList.length - 1) {
                      return transactionCardWithTime(
                        groupTransaction,
                        onCardTap,
                        listTime,
                      );
                    } else if (listTime.notSameDayAs(
                      groupTransaction.createdAt,
                    )) {
                      DateTime timeToDisplay = listTime;
                      listTime = groupTransaction.createdAt;
                      return transactionCardWithTime(
                        groupTransaction,
                        onCardTap,
                        timeToDisplay,
                      );
                    } else {
                      return transactionCard(
                        groupTransaction,
                        onCardTap,
                      );
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget transactionCard(
    GroupTransaction groupTransaction,
    void Function() cardTap,
  ) {
    return GestureDetector(
      onTap: cardTap,
      child: Column(
        children: [
          const SizedBox(height: 10),
          GroupTransactionCard(
            groupTransaction: groupTransaction,
          ),
        ],
      ),
    );
  }

  Widget transactionCardWithTime(
    GroupTransaction groupTransaction,
    void Function() cardTap,
    DateTime time,
  ) {
    return GestureDetector(
      onTap: cardTap,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Text(time.toMMMMDDYYYY),
          GroupTransactionCard(
            groupTransaction: groupTransaction,
          ),
        ],
      ),
    );
  }
}

class GroupTransactionCard extends StatefulWidget {
  final GroupTransaction groupTransaction;
  const GroupTransactionCard({
    Key? key,
    required this.groupTransaction,
  }) : super(key: key);

  @override
  State<GroupTransactionCard> createState() => _GroupTransactionCardState();
}

class _GroupTransactionCardState extends State<GroupTransactionCard> {
  final AppController appController = Get.find();

  late bool authCreated;

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: GroupTransactionScreen.routeName,
    );
    authCreated = widget.groupTransaction.creatorId == appController.user.id;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    double cardWidth = size.width * 0.6;

    String participantCount =
        widget.groupTransaction.participantCount.toString();
    String totalGroupParticipants =
        widget.groupTransaction.group.target!.groupSize().toString();
    String amount = widget.groupTransaction.amount.toString();
    String directionStatusText = 'Lane - Pending';
    String confirmationText = 'You requested';

    return Row(
      mainAxisAlignment:
          authCreated ? MainAxisAlignment.end : MainAxisAlignment.start,
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
            // height: cardHeight,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '$participantCount/$totalGroupParticipants Participants',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    rupeeIcon,
                    Text(
                      amount,
                      style: GoogleFonts.roboto(
                        fontSize: 50,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    directionStatusIcon,
                    Text(
                      directionStatusText,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    confirmationIcon,
                    Text(
                      confirmationText,
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
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget rupeeIcon = const SizedBox(
    width: 30,
    child: Icon(
      Icons.currency_rupee,
      size: 20,
    ),
  );

  Widget directionStatusIcon = SizedBox(
    width: 30,
    child: Transform.rotate(
      angle: math.pi / -1.25,
      child: const Icon(
        Icons.arrow_circle_up_sharp,
        color: Color(0xFF717171),
        size: 18,
      ),
    ),
  );

  Widget confirmationIcon = const SizedBox(
    width: 30,
    child: Icon(
      Icons.access_time_outlined,
      size: 18,
      color: Color(0xFF717171),
    ),
  );
}
