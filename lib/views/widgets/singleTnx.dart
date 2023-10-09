import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';

class SingleTransactionWidget extends StatelessWidget {
  final String name;
  final String amount;
  final String? url;
  final String date;

  const SingleTransactionWidget({
    Key? key,
    required this.name,
    required this.amount,
    required this.date,
    this.url,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
      leading: ProfilePicture(
            name: name,
            radius: 21,
            fontsize: 21,
            random: true,
          ),
      title: Text(
        name,
        style: const TextStyle(
            color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
      ),
      // subtitle: Text(amount ?? 'No Transaction Done'),
      // trailing: const Text(
      //   'invite',
      //   style: TextStyle(color: Colors.green, fontWeight: FontWeight.w400),
      // ),
    );
  }
}
