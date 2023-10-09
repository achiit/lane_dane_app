import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lane_dane/api/whatsapp.dart';
import 'package:lane_dane/models/group_model.dart';
import 'package:lane_dane/models/users.dart';
import 'package:lane_dane/utils/colors.dart';
import 'package:lane_dane/utils/constants.dart';

class SingleGroupWidget extends StatelessWidget {
  final Groups group;

  const SingleGroupWidget({
    Key? key,
    required this.group,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        // color: selected ? greenColor : Colors.white,
        color: Colors.white,
      ),
      child: ListTile(
        tileColor: Colors.transparent,
        // onTap: onSelect,
        // selected: selected,
        // selectedColor: Colors.trans,
        // selectedTileColor: greenColor,
        leading: ProfilePicture(
          name: group.groupName,
          radius: 21,
          fontsize: 21,
          count: 1,
        ),
        title: Text(
          group.groupName,
          style: GoogleFonts.roboto(
            // color: selected ? Colors.white : Colors.black,
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          group.details(),
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.roboto(),
        ),
        // trailing: !contact.userRegistered()
        //     ? GestureDetector(
        //         onTap: () {
        //           WhatsappHelper().send(
        //             context: context,
        //             message:
        //                 'Hey ${contact.firstName}, try out this new app that lets you keep track of all your financial happenings.\n${Constants.appLink}',
        //             phone: int.parse(contact.phoneNumberWithCode),
        //           );
        //         },
        //         child: Text(
        //           'invite'.tr,
        //           style: TextStyle(
        //             color: selected ? Colors.white : Colors.green,
        //             fontWeight: FontWeight.w400,
        //           ),
        //         ),
        //       )
        //     : SizedBox(),
      ),
    );
  }
}
