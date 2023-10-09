import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lane_dane/controllers/users_controller.dart';
import 'package:lane_dane/models/users.dart';
import 'package:lane_dane/utils/assets.dart';
import 'package:lane_dane/utils/colors.dart';
import 'package:lane_dane/views/widgets/elevated_btn.dart';

class AddNewContact extends StatefulWidget {
  static const String routeName = 'add-new-contact';

  const AddNewContact({Key? key}) : super(key: key);

  @override
  State<AddNewContact> createState() => _AddNewContactState();
}

class _AddNewContactState extends State<AddNewContact> {
  late TextEditingController fullNameController;
  late TextEditingController phoneNumberController;
  late FocusNode nameNode;
  late FocusNode numberNode;

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: AddNewContact.routeName,
    );
    fullNameController = TextEditingController();
    phoneNumberController = TextEditingController();
    nameNode = FocusNode();
    numberNode = FocusNode();

    nameNode.requestFocus();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    phoneNumberController.dispose();
    nameNode.dispose();
    numberNode.dispose();
    super.dispose();
  }

  void addContact() {
    Users newUser = UserHelper()
        .addUser(phoneNumberController.text, fullNameController.text);
    Navigator.of(context).pop(newUser);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final EdgeInsets padding = MediaQuery.of(context).padding;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenColor,
        title: Text(
          'add_contact'.tr,
          style: GoogleFonts.roboto(),
        ),
      ),
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          constraints: BoxConstraints(
            minHeight: size.height - padding.vertical - (56),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Image.asset(Assets.imagesAddNewContactImage),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'contact_name'.tr,
                    style: GoogleFonts.roboto(),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    focusNode: nameNode,
                    controller: fullNameController,
                    style: const TextStyle(fontSize: 17),
                    onEditingComplete: () {
                      numberNode.requestFocus();
                    },
                    decoration: InputDecoration(
                      hintText: 'full_name'.tr,
                      hintStyle: const TextStyle(fontSize: 17),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'contact_phone'.tr,
                    style: GoogleFonts.roboto(),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    focusNode: numberNode,
                    controller: phoneNumberController,
                    style: const TextStyle(fontSize: 17),
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      prefixIcon: Container(
                        alignment: Alignment.centerLeft,
                        width: 48,
                        height: 48,
                        padding: const EdgeInsets.only(left: 14),
                        child: Text(
                          '+91 ',
                          style: GoogleFonts.roboto(),
                        ),
                      ),
                      prefixStyle: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                      hintText: 'phone_number'.tr,
                      hintStyle: const TextStyle(fontSize: 17),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  CustomButton(
                    buttonName: 'add_contact'.tr,
                    onPressed: addContact,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
