import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lane_dane/app_controller.dart';
import 'package:lane_dane/errors/invalid_input_error.dart';
import 'package:lane_dane/errors/server_error.dart';
import 'package:lane_dane/errors/unauthorized_error.dart';
import 'package:lane_dane/utils/colors.dart';
import 'package:lane_dane/utils/constants.dart';
import 'package:lane_dane/views/pages/home/home.dart';
import 'package:lane_dane/views/shared/snack-bar.dart';
import 'package:lane_dane/utils/log_printer.dart';
import 'package:lane_dane/views/widgets/elevated_btn.dart';
import 'package:url_launcher/url_launcher.dart';

class UserMetaInfoPage extends StatefulWidget {
  static const routeName = '/user-meta-info';
  const UserMetaInfoPage({Key? key, required this.phone, required this.otp})
      : super(key: key);

  final String phone;
  final String otp;

  @override
  State<UserMetaInfoPage> createState() => _UserMetaInfoPageState();
}

class _UserMetaInfoPageState extends State<UserMetaInfoPage> {
  final AppController appController = Get.find();
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _pincodeController;
  late bool businessAccount;

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: UserMetaInfoPage.routeName,
    );
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _pincodeController = TextEditingController();
    businessAccount = false;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  final log = getLogger('UserMetaInfoPage');

  Future<void> launchTermsOfServices() async {
    try {
      if (Constants.defaultToHttps) {
        await launchUrl(
            Uri.https(Constants.host, Constants.routeToTermsOfServices));
      } else {
        await launchUrl(
            Uri.http(Constants.host, Constants.routeToTermsOfServices));
      }
    } catch (err, stack) {
      FirebaseCrashlytics.instance.recordError(
        err,
        stack,
        fatal: false,
        information: [Constants.routeToTermsOfServices],
        printDetails: true,
        reason: 'Failed to launchUrl to Terms of Services web page',
      );
    }
  }

  Future<void> launchPrivacyPolicy() async {
    try {
      if (Constants.defaultToHttps) {
        await launchUrl(
            Uri.https(Constants.host, Constants.routeToPrivacyPolicy));
      } else {
        await launchUrl(
            Uri.http(Constants.host, Constants.routeToPrivacyPolicy));
      }
    } catch (err, stack) {
      FirebaseCrashlytics.instance.recordError(
        err,
        stack,
        fatal: false,
        information: [Constants.routeToTermsOfServices],
        printDetails: true,
        reason: 'Failed to launchUrl to Privacy Policy web page',
      );
    }
  }

  Future<void> registerUser() async {
    final String fullName = _fullNameController.text;
    try {
      // First Test & then Run Register User API
      if (fullName.isEmpty) {
        throw InvalidInputError(
            message: 'Please enter your first and last name',
            input: 'Full Name: $fullName');
      }
      log.i(widget.phone);
      log.i(fullName);
      log.i(widget.otp);

      await appController.register(
        context: context,
        phoneNumber: widget.phone,
        fullName: fullName,
        otp: widget.otp,
        businessAccount: businessAccount,
      );

      Navigator.of(context)
        ..pop()
        ..pop()
        ..pushReplacementNamed(Home.routeName);
    } on InvalidInputError catch (err) {
      showSnackBar(context, err.message);
      log.e('The entered input was: ${err.input}');
    } on ServerError catch (err, stack) {
      FirebaseCrashlytics.instance.recordError(
        err,
        stack,
        fatal: false,
        reason: 'Server error occurred while trying to register user',
        information: [
          _fullNameController.text,
          businessAccount,
          err.toString()
        ],
      );
      showSnackBar(context, err.message);
      log.e('Server error while requesting for otp.');
      log.e('The server responsed with a status code of ${err.statusCode}');
    } on SocketException catch (err) {
      showSnackBar(context,
          'Could not connect to the server. Check your internet connection or try again later.');
      log.e('Socket exception error: ${err.message}');
      log.e('Address of the connection that failed: ${err.address}');
      log.e(err.toString());
    } on UnauthorizedError catch (err) {
      showSnackBar(context, 'Incorrect one time password');
      log.e('Failed to authorized user: ${err.toString()}');
      Navigator.of(context).pop();
    } catch (err, stack) {
      FirebaseCrashlytics.instance.recordError(
        err,
        stack,
        fatal: false,
        reason: 'Server error occurred while trying to register user',
        information: [
          _fullNameController.text,
          businessAccount,
          err.toString()
        ],
      );
      showSnackBar(context, 'An unknown error occured');
      log.e(err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: size.width,
          height: size.height,
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('user_meta_info_greeting'.tr,
                  style: GoogleFonts.roboto(
                      fontSize: 24.0, fontWeight: FontWeight.w900)),
              const SizedBox(
                height: 10.0,
              ),
              Text(
                'user_meta_info_prompt'.tr,
                style: GoogleFonts.roboto(
                    fontSize: 12, fontWeight: FontWeight.w400),
              ),
              const SizedBox(
                height: 40.0,
              ),
              TextField(
                autofocus: true,
                controller: _fullNameController,
                style: const TextStyle(fontSize: 17),
                decoration: const InputDecoration(
                  labelText: 'Full Name', // Add label text
                  hintText: 'Eg. Vijay Shekhar Sharma', // Provide a hint for full name
                  hintStyle: TextStyle(fontSize: 17),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              TextField(
                controller: _emailController,
                style: const TextStyle(fontSize: 17),
                decoration: const InputDecoration(
                  labelText: 'Email', // Add label text
                  hintText: 'Eg. yours@gmail.com', // Provide an example email
                  hintStyle: TextStyle(fontSize: 17),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              TextField(
                controller: _pincodeController,
                style: const TextStyle(fontSize: 17),
                decoration: const InputDecoration(
                   labelText: 'Pincode', // Add label text
                   hintText: 'Eg. 110003', // Provide an example pincode
                   hintStyle: TextStyle(fontSize: 17),
                   border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'business_account'.tr,
                    style: GoogleFonts.roboto(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Switch(
                    value: businessAccount,
                    activeColor: greenColor,
                    onChanged: (bool value) {
                      if (mounted) {
                        setState(() {
                          businessAccount = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 10.0,
              ),
              RichText(
                softWrap: true,
                text: TextSpan(
                  text: 'user_meta_info_sign'.tr,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                        text: 'terms_of_use'.tr,
                        recognizer: TapGestureRecognizer()
                          ..onTap = launchTermsOfServices,
                        style: const TextStyle(
                          color: Colors.blue,
                        )),
                    TextSpan(
                        text: '&'.tr,
                        style: const TextStyle(
                          color: Colors.black,
                        )),
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = launchPrivacyPolicy,
                      text: 'privacy_policy'.tr,
                      style: const TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 40.0,
              ),
              Row(
                children: [
                  SizedBox(
                    width: size.width - 52,
                    child: CustomButton(
                      onPressed: registerUser,
                      buttonName: 'register'.tr,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}