import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:get/get.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lane_dane/app_controller.dart';
import 'package:lane_dane/models/group_model.dart';
import 'package:lane_dane/models/users.dart';
import 'package:lane_dane/utils/colors.dart';

class CreateGroupScreen extends StatefulWidget {
  static const String routeName = 'create-group_screen';

  final List<Users> userList;
  const CreateGroupScreen({
    Key? key,
    required this.userList,
  }) : super(key: key);

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final AppController appController = Get.find();

  late final TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: CreateGroupScreen.routeName,
    );
    nameController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void createGroup() {
    if (nameController.text.isEmpty) {
      Get.showSnackbar(
        const GetSnackBar(message: 'Please enter a grouop name'),
      );
      return;
    }

    Groups group = appController.createGroup(
      groupName: nameController.text,
      profilePicture: '',
      participants: widget.userList,
    );

    Navigator.of(context).pop(group);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: appBar,
      floatingActionButton: FloatingActionButton(
        onPressed: createGroup,
        backgroundColor: greenColor,
        child: const Icon(Icons.check),
      ),
      backgroundColor: Colors.white,
      body: Container(
        width: size.height - appBar.preferredSize.height,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            label('group_name'.tr),
            const SizedBox(height: 10),
            TextField(
              autofocus: true,
              controller: nameController,
              style: const TextStyle(fontSize: 17),
              decoration: InputDecoration(
                hintText: 'group_name'.tr,
                hintStyle: const TextStyle(fontSize: 17),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            label('${'participants'.tr} ${widget.userList.length}'),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: widget.userList.length,
                itemBuilder: (BuildContext context, int index) {
                  Users user = widget.userList[index];
                  return ListTile(
                    leading: ProfilePicture(
                      name: user.full_name!,
                      fontsize: 18,
                      radius: 18,
                    ),
                    title: Text(user.full_name!),
                  );
                },
              ),
            ),
            // Expanded(
            //   child: GridView.builder(
            //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            //       crossAxisCount: 4,
            //     ),
            //     itemCount: widget.userList.length,
            //     itemBuilder: (BuildContext context, int index) {
            //       Users user = widget.userList[index];
            //       return Column(
            //         crossAxisAlignment: CrossAxisAlignment.center,
            //         children: [
            //           ProfilePicture(
            //             name: user.full_name!,
            //             radius: 20,
            //             fontsize: 18,
            //           ),
            //           SizedBox(height: 10),
            //           Text(
            //             user.full_name!,
            //             overflow: TextOverflow.ellipsis,
            //             textAlign: TextAlign.center,
            //             style: GoogleFonts.roboto(),
            //           ),
            //         ],
            //       );
            //     },
            //   ),
            // )
          ],
        ),
      ),
    );
  }

  Widget label(String labelText) {
    return Container(
      child: Text(
        labelText,
        style: GoogleFonts.roboto(
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  PreferredSizeWidget appBar = AppBar(
    centerTitle: false,
    backgroundColor: greenColor,
    title: Text(
      'new_group'.tr,
      style: GoogleFonts.roboto(),
    ),
  );
}
