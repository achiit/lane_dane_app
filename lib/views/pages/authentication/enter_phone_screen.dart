import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lane_dane/api/auth_services.dart';
import 'package:lane_dane/errors/invalid_input_error.dart';
import 'package:lane_dane/errors/server_error.dart';
import 'package:lane_dane/utils/assets.dart';
import 'package:lane_dane/views/pages/authentication/enter_otp_screen.dart';
import 'package:lane_dane/views/shared/snack-bar.dart';
import 'package:lane_dane/utils/log_printer.dart';
import 'package:lane_dane/utils/colors.dart';
import 'package:lane_dane/views/widgets/elevated_btn.dart';

class EnterPhoneScreen extends StatefulWidget {
  static const routeName = 'otp-screen';
  const EnterPhoneScreen({Key? key}) : super(key: key);

  @override
  State<EnterPhoneScreen> createState() => _EnterPhoneScreenState();
}

class _EnterPhoneScreenState extends State<EnterPhoneScreen> {
  final log = getLogger('OtpScreen');
  late TextEditingController _phoneNumberController;
  final AuthServices _authService = AuthServices();

  late FocusNode phoneNode;
  late String error;
  late bool autoRequest;
  bool isAccept = false;

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: EnterPhoneScreen.routeName,
    );
    _phoneNumberController = TextEditingController();
    phoneNode = FocusNode();
    error = '';
    autoRequest = false;
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> onPhoneEnterCallback(String value) async {
    log.d(value);
    if (value.length != 10) {
      return;
    }
    FocusScope.of(context).unfocus();
    if (mounted) {
      setState(() {
        autoRequest = true;
      });
    }
    await generateotp();
    if (mounted) {
      setState(() {
        autoRequest = false;
      });
    }
  }

  Future<void> generateotp() async {
    try {
      final String phoneNumber = _phoneNumberController.text;
      if (phoneNumber.isEmpty) {
        throw InvalidInputError(
          message: 'Please enter phone number',
          input: phoneNumber,
        );
      }
      if (phoneNumber.length != 10) {
        throw InvalidInputError(
          message: 'Phone number should be 10 digit',
          input: phoneNumber,
        );
      }
      final res = await _authService.getOtp(
          context: context, phone: int.parse(_phoneNumberController.text));
      log.d('response');

      Navigator.of(context).pushNamed(
        EnterOtpScreen.routeName,
        arguments: {
          'phoneNumber': _phoneNumberController.text,
          'httpResponse': res
        },
      );

      setState(() {
        error = '';
      });
    } on InvalidInputError catch (err) {
      setState(() {
        error = 'Phone number should be 10 digit';
      });
      log.e('The entered input was: ${err.input}');
    } on FormatException catch (err) {
      setState(() {
        error = 'Only numeric characters allowed';
      });
      log.e('input entered: ${_phoneNumberController.text}');
      log.e('FormateException message: ${err.message}');
      log.e(err.toString());
    } on ServerError catch (err, stack) {
      FirebaseCrashlytics.instance.recordError(
        err,
        stack,
        fatal: false,
        printDetails: true,
        reason: 'Server error occurred while attempting to generate otp',
        information: [err.toString()],
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
    } catch (err, stack) {
      FirebaseCrashlytics.instance.recordError(
        err,
        stack,
        fatal: false,
        printDetails: true,
        reason: 'Unknown error encountered while trying to generate otp',
        information: [_phoneNumberController.text],
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40.0),
              Flexible(
                  flex: 10,
                  child: Center(
                      child: Image.asset(Assets.imagesOtpOnBoarding,
                          height: 360, width: 301, fit: BoxFit.fitHeight))),
              const SizedBox(height: 28.0),
              Flexible(
                flex: 2,
                child: Text(
                  'otp_verification'.tr,
                  style: GoogleFonts.roboto(
                      fontSize: 24.0, fontWeight: FontWeight.w900),
                ),
              ),
              // TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold) ,)),
              const SizedBox(height: 10.0),
              Flexible(
                flex: 1,
                child: Text(
                  'enter_phone_details_1'.tr,
                  style: GoogleFonts.roboto(
                      fontSize: 12, fontWeight: FontWeight.w400),
                ),
              ),
              Flexible(
                flex: 1,
                child: Text(
                  'enter_phone_details_2'.tr,
                  style: GoogleFonts.roboto(
                      fontSize: 12, fontWeight: FontWeight.w400),
                ),
              ),
              const SizedBox(height: 24.0),
              Flexible(
                flex: 1,
                child: Text(
                  'phone_number'.tr,
                  // style: TextStyle(color: Color(0xff008069) ),)
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: greenColor,
                  ),
                ),
              ),
              Flexible(
                flex: 4,
                child: TextFormField(
                  onChanged: onPhoneEnterCallback,
                  controller: _phoneNumberController,
                  focusNode: phoneNode,
                  autofocus: true,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    /**
                     * 91 or +91 is never sent to the server. The app will
                     * always use the base phone number without country code.
                     * The prefix widget is only to prevent users from being
                     * confused if they should add the country code or not.
                     */
                    prefix: Text(
                      '+91 ',
                      style: GoogleFonts.roboto(),
                    ),
                    focusedErrorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: error.isEmpty
                            ? const Color(0xFF008069)
                            : Colors.red,
                      ),
                    ),
                    errorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: error.isEmpty
                            ? const Color(0xFF008069)
                            : Colors.red,
                      ),
                    ),
                    errorText: error,
                  ),
                ),
              ),
              const SizedBox(height: 36.0),
              Flexible(
                flex: 2,
                child: autoRequest
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(
                        onPressed: generateotp,
                        buttonName: 'otp'.tr,
                      ),
              ),
              const SizedBox(height: 40.0),
            ],
          ),
        ),
      ),
    );
  }
}
