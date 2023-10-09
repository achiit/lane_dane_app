/*

-> This is a widget that displays the listTile of the contacts
-> values are passsed to it through the constructor...
-> No API Calles are done here,
-> ONTAP takes you to addTransaction Screen
*/

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lane_dane/api/whatsapp.dart';
import 'package:lane_dane/models/users.dart';
import 'package:lane_dane/utils/colors.dart';
import 'package:lane_dane/utils/constants.dart';

class SingleContacts extends StatelessWidget {
  final Users contact;
  final bool selected;

  const SingleContacts({
    Key? key,
    required this.contact,
    this.selected = false,
  }) : super(key: key);

  String contactNameTrim(String name) {
    if (name.length < 2) {
      return name;
    }
    return name.substring(0, 2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: selected ? greenColor : Colors.white,
      ),
      child: ListTile(
        tileColor: Colors.transparent,
        // onTap: onSelect,
        // selected: selected,
        // selectedColor: Colors.trans,
        // selectedTileColor: greenColor,
        leading: ProfilePicture(
          name: contact.full_name!,
          radius: 21,
          fontsize: 21,
          count: 1,
        ),
        title: Text(
          contact.full_name!,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(contact.phoneNumberRaw),
        trailing: !contact.userRegistered()
            ? GestureDetector(
                onTap: () {
                  WhatsappHelper().send(
                    context: context,
                    message:
                        'Hey ${contact.firstName}, try out this new app that lets you keep track of all your financial happenings.\n${Constants.appLink}',
                    phone: int.parse(contact.phoneNumberWithCode),
                  );
                },
                child: Text(
                  'invite'.tr,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.green,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              )
            : SizedBox(),
      ),
    );
  }
}
