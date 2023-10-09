import 'package:flutter/material.dart';

import 'package:flutter_profile_picture/flutter_profile_picture.dart';

Widget GroupSelectContact(
    {required BuildContext context,
    // required UserContacts contact,
    required bool isSelected}) {
  return ListTile(
      // onTap: () {
      //   Navigator.of(context)
      //       .pushReplacementNamed(AddTransaction.routeName, arguments: contact);
      // },
      leading: const ProfilePicture(
        name: 'ankit',
        radius: 21,
        fontsize: 21,
        random: true,
      ),
      title: const Text(
        '',
        // contact.full_name,
        style: TextStyle(
            color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
      ),
      // subtitle: Text(contact.contact_no),
      trailing: isSelected
          ? const Icon(
              Icons.check_box,
              color: Colors.green,
            )
          : const Icon(Icons.check_box_outline_blank));
}
