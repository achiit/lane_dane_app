import 'package:flutter/material.dart';

import '../../utils/colors.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenColor,
        title: const Text("Profile"),
      ),
      body: Stack(
        children: [
          const Positioned(
            top: 40.0,
            right: 50,
            left: 50.0,
            child: CircleAvatar(
              radius: 80,
            ),
          ),
          Positioned(
              top: 150,
              left: 220,
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      color: greenColor),
                  child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.add_a_photo,
                        color: Colors.white,
                      )))),
          Positioned(
            top: 240,
            left: 20.0,
            child: Row(
              children: [
                Image.asset('images/account_ic.png'),
                const SizedBox(
                  width: 15.0,
                ),
                Column(
                  children: const [
                    Text("data"),
                    Text("data"),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
