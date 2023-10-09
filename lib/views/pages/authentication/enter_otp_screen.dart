import 'dart:async';
import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lane_dane/app_controller.dart';
import 'package:lane_dane/api/auth_services.dart';
import 'package:lane_dane/errors/invalid_input_error.dart';
import 'package:lane_dane/errors/request_error.dart';
import 'package:lane_dane/errors/server_error.dart';
import 'package:lane_dane/errors/unauthorized_error.dart';
import 'package:lane_dane/utils/assets.dart';
import 'package:lane_dane/views/pages/authentication/user_meta_info_page.dart';
import 'package:lane_dane/views/pages/home/home.dart';
import 'package:lane_dane/views/shared/snack-bar.dart';
import 'package:lane_dane/utils/colors.dart';
import 'package:lane_dane/utils/log_printer.dart';
import 'package:lane_dane/views/widgets/elevated_btn.dart';
import 'package:pinput/pinput.dart';

class EnterOtpScreen extends StatefulWidget {
  static const routeName = 'otp-enter';
  final String phoneNumber;
  final Map<String, dynamic> httpResponse;
  const EnterOtpScreen(
      {Key? key, required this.phoneNumber, required this.httpResponse})
      : super(key: key);

  @override
  State<EnterOtpScreen> createState() => _EnterOtpScreenState();
}

class _EnterOtpScreenState extends State<EnterOtpScreen> {
  final log = getLogger('OTPEnter');
  final AppController appController = Get.find();
  final AuthServices _authService = AuthServices();
  late final TextEditingController otpcontroller;
  late String error = '';
  late bool autoRequest = true;
  int resendTimerSeconds = 60;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: EnterOtpScreen.routeName,
    );
    otpcontroller = TextEditingController();
    error = '';
    autoRequest = false;
    startResendTimer();
  }

  @override
  void dispose() {
    otpcontroller.dispose();
    timer.cancel();
    super.dispose();
  }

  void startResendTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (resendTimerSeconds > 0) {
        setState(() {
          resendTimerSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void requestNewOTP() async {
    try {
      final String phoneNumber = widget.phoneNumber;
      final res = await _authService.getOtp(
          context: context, phone: int.parse(phoneNumber));
      // Handle the response and update UI as needed
      // ...
      setState(() {
        error = '';
        resendTimerSeconds = 60; // Reset the timer
      });
      startResendTimer();
    } catch (err, stack) {
      // Handle errors during OTP request
      // ...
      log.e(err.toString());
    }
  }

  Future<void> onEnteredOTPCallback(String otp) async {
    if (otp.length != 4) {
      return;
    }
    if (mounted) {
      setState(() {
        autoRequest = true;
      });
    }
    await submit();
    if (mounted) {
      setState(() {
        autoRequest = false;
      });
    }
  }

  Future<void> submit() async {
    String otp = otpcontroller.text;
    if (otp.isNotEmpty &&
        otp.length == 4 &&
        widget.httpResponse['success']['new_user']) {
      // Register the User BY SENDING HIM TO USER_META_INFO_PAGE
      Navigator.of(context).pushNamed(UserMetaInfoPage.routeName, arguments: {
        'phone': widget.phoneNumber,
        'otp': otp,
      });
      setState(() {
        error = '';
      });
      return;
    }
    try {
      if (otp.isEmpty || otp.length != 4) {
        throw InvalidInputError(
            message:
            'Enter 4 digit One Time Password sent to the registered number',
            input: otp);
      }
      await appController.login(
        context: context,
        phoneNumber: widget.phoneNumber,
        otp: otp,
      );

      Navigator.of(context)
        ..pop()
        ..pushReplacementNamed(Home.routeName);
    } on InvalidInputError catch (err) {
      setState(() {
        error = err.message;
      });
      log.e('The entered input was: ${err.input}');
    } on ServerError catch (err, stack) {
      FirebaseCrashlytics.instance.recordError(
        err,
        stack,
        fatal: false,
        printDetails: true,
        reason: 'Error occurred while verifying otp',
        information: [otpcontroller.text],
      );
      showSnackBar(context, err.message);
      log.e('Server error while verifying otp.');
      log.e('The server responsed with a status code of ${err.statusCode}');
      log.e('Server response: ${err.responseBody}');
    } on SocketException catch (err) {
      showSnackBar(
        context,
        'Could not connect to the server. Check your internet connection or try again later.',
      );
      log.e('Socket exception error: ${err.message}');
      log.e('Address of the connection that failed: ${err.address}');
      log.e(err.toString());
    } on RequestError catch (err) {
      showSnackBar(context, 'One Time Password verification failed');
      log.e('Status code recieved during otp verification: ${err.statusCode}');
      log.e('Response recieved during otp verification: ${err.responseBody}');
    } on UnauthorizedError catch (err) {
      setState(() {
        error = 'The One Time Password entered was incorrect';
      });
      log.e(err.toString());
    } catch (err, stack) {
      FirebaseCrashlytics.instance.recordError(
        err,
        stack,
        fatal: false,
        printDetails: true,
        reason: 'Unknown error occurred while attempting to verify otp',
        information: [otpcontroller.text],
      );
      showSnackBar(context, 'An unknown error occured');
      log.e(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    final Color theme = greenColor;

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
              const SizedBox(height: 40),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: theme,
                ),
              ),
              const SizedBox(height: 50),
              Flexible(
                flex: 6,
                child: Image.asset(
                  Assets.imagesEnterOtp,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Flexible(
                flex: 2,
                child: Text(
                  'otp_verification'.tr,
                  style: GoogleFonts.roboto(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Flexible(
                flex: 2,
                child: Row(
                  children: [
                    Text(
                      'enter_otp_prompt'.tr,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      "+91 ${widget.phoneNumber} ",
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),

              const SizedBox(
                height: 20.0,
              ),
              Flexible(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Pinput(
                      controller: otpcontroller,
                      defaultPinTheme: PinTheme(
                        height: 50,
                        width: 56,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.black),
                          ),
                        ),
                        textStyle: GoogleFonts.roboto(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      cursor: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 0),
                            width: 1,
                            height: 18,
                            color: Colors.black,
                          ),
                        ],
                      ),
                      scrollPadding: const EdgeInsets.all(80),
                      onCompleted: onEnteredOTPCallback,
                      isCursorAnimationEnabled: true,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      autofocus: true,
                      forceErrorState: error.isNotEmpty,
                      errorText: error,
                      errorTextStyle: GoogleFonts.roboto(
                        fontSize: 10,
                        color: Colors.red.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligns the button and text to the start and end of the row
                  children: [
                    Text(
                      resendTimerSeconds > 0
                          ? 'Resend OTP in ${resendTimerSeconds.toString()} seconds'
                          : 'You can now resend OTP',
                      style: TextStyle(
                        color: resendTimerSeconds > 0 ? Colors.grey : Colors.green,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: resendTimerSeconds <= 0 ? requestNewOTP : null,
                      child: Text('Resend OTP'),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Flexible(
                flex: 2,
                child: autoRequest
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(
                  onPressed: submit,
                  buttonName: 'submit'.tr,
                ),
              ),
              const SizedBox(height: 220),
            ],
          ),
        ),
      ),
    );
  }
}
