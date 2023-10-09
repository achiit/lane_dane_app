/*

-> This is a widget that displays the listTile of the contacts
-> values are passsed to it through the constructor...
-> No API Calles are done here,
-> ONTAP takes you to addTransaction Screen
*/

import 'package:flutter/material.dart';

import '../../models/group_model.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';

Widget GroupChats({
  required BuildContext context,
  required Groups groups,
  // required Transactions transaction,
}) {
  return ListTile(
    onTap: () {
      // Navigator.of(context).pushNamed(
      //   PersonalTransactions.routeName,
      //   arguments: {
      //     'transaction': transaction,
      //     'contact': contact,
      //   },
      // );
    },
    leading: ProfilePicture(
      name: groups.groupName,
      radius: 21,
      fontsize: 21,
      random: true,
    ),
    title: Text(
      groups.groupName,
      style: const TextStyle(
          color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
    ),
    // subtitle: Text(transaction.amount.toString()),
    // trailing: const Text(
    //   'invite',
    //   style: TextStyle(color: Colors.green, fontWeight: FontWeight.w400),
    // ),
  );
}
