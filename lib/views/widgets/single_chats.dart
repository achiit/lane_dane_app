/*

-> This is a widget that displays the listTile of the contacts
-> values are passed to it through the constructor...
-> No API Calls are done here,
-> OnTap takes you to addTransaction Screen
*/

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lane_dane/app_controller.dart';
import 'package:lane_dane/models/aggregate_record.dart';
import 'package:lane_dane/models/group_model.dart';
import 'package:lane_dane/models/transactions.dart';
import 'package:lane_dane/models/user_group_entity.dart';
import 'package:lane_dane/models/users.dart';
import 'package:lane_dane/views/pages/transaction/group_transaction_screen.dart';

import '../pages/transaction/personal_transaction_view.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';

class UserGroupListTile extends StatefulWidget {
  final UserGroupEntity entity;
  const UserGroupListTile({
    Key? key,
    required this.entity,
  }) : super(key: key);

  @override
  State<UserGroupListTile> createState() => _UserGroupListTileState();
}

class _UserGroupListTileState extends State<UserGroupListTile>
    with SingleTickerProviderStateMixin {
  /// Send a list of transactions to this method to calculate the remainig
  /// lane/dane amount.
  ///
  /// If the return value is positive, then the pending amount is of type lane.
  /// If the return value is negative, then the pending amount is of type dane.
  int calculatePending(List<TransactionsModel> transactionList) {
    AggregateRecord record =
        AggregateRecord.fromTransactionList(list: transactionList);
    int laneAmount = record.lanePending;
    int daneAmount = record.danePending;

    return (laneAmount - daneAmount);
  }

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
      toTransactionListScreen();
    });
  }

  void toTransactionListScreen() {
    AppController appController = Get.find();
    if (widget.entity.type == UserGroupEntityType.user) {
      Users user =
          appController.userController.retrieveOnly(widget.entity.entityId)!;

      Navigator.of(context).pushNamed(
        PersonalTransactions.routeName,
        arguments: {
          'contact': user,
        },
      );
    } else if (widget.entity.type == UserGroupEntityType.group) {
      Groups group =
          appController.groupController.retrieveGroup(widget.entity.entityId)!;

      Navigator.of(context).pushNamed(
        GroupTransactionScreen.routeName,
        arguments: {
          'group': group,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // int amount = calculatePending(
    //   TransactionController().retrieveUserTransaction(contact.user.targetId),
    // );
    int amount = widget.entity.amount;
    String pending =
        '\u{20B9}${amount.abs()} ${amount > 0 ? TransactionType.Lane.name.toLowerCase().tr : TransactionType.Dane.name.toLowerCase().tr} ${'pending'.tr}';
    if (amount == 0) {
      pending = 'no_pending_amount'.tr;
    }

    return InkWell(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ListTile(
          // onTap: toTransactionListScreen,
          leading: ProfilePicture(
            name: widget.entity.name,
            radius: 21,
            fontsize: 21,
            random: true,
          ),
          title: Text(
            widget.entity.name,
            style: const TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(pending),
        ),
      ),
    );
  }
}
