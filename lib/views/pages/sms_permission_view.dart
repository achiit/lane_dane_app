import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lane_dane/utils/assets.dart';
import 'package:lane_dane/utils/colors.dart';
import 'package:lane_dane/views/widgets/elevated_btn.dart';

class SmsPermissionView extends StatelessWidget {
  final void Function() onPressed;
  const SmsPermissionView({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    const double usableAreaVPadding = 0;
    const double usableAreaHPadding = 40;

    const double primaryTextFontSize = 20;
    const double secondaryTextFontSize = 12;

    return Container(
      width: size.width,
      height: 600,
      // color: Colors.red,
      padding: const EdgeInsets.only(
        top: usableAreaVPadding,
        left: usableAreaHPadding,
        right: usableAreaHPadding,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Image.asset(Assets.imageschatMesssageIconLightGreen),
          Column(
            children: [
              Column(
                children: [
                  Text(
                    'sms_permission_prompt_1'.tr,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      fontSize: primaryTextFontSize,
                    ),
                  ),
                  // Text(
                  //   'sms_permission_prompt_1'.tr,
                  //   style: GoogleFonts.roboto(
                  //     fontSize: primaryTextFontSize,
                  //   ),
                  // ),
                  // Text(
                  //   'sms_permission_prompt_2'.tr,
                  //   style: GoogleFonts.roboto(
                  //     fontSize: primaryTextFontSize,
                  //   ),
                  // ),
                  // Text(
                  //   'sms_permission_prompt_3'.tr,
                  //   style: GoogleFonts.roboto(
                  //     fontSize: primaryTextFontSize,
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  Text(
                    'sms_permission_safety_1'.tr,
                    style: GoogleFonts.roboto(fontSize: secondaryTextFontSize),
                  ),
                  Text(
                    'sms_permission_safety_2'.tr,
                    style: GoogleFonts.roboto(fontSize: secondaryTextFontSize),
                  ),
                ],
              ),
            ],
          ),
          Opacity(
            opacity: 1.0,
            child: CustomButton(
              onPressed: onPressed,
              buttonName: 'okay'.tr,
            ),
          ),
        ],
      ),
    );
  }
}

class SmsLoadingView extends StatelessWidget {
  const SmsLoadingView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    const double usableAreaVPadding = 0;
    const double usableAreaHPadding = 40;

    const double primaryTextFontSize = 20;
    const double secondaryTextFontSize = 12;

    return Container(
      width: size.width,
      height: 600,
      // color: Colors.red,
      padding: const EdgeInsets.only(
        top: usableAreaVPadding,
        left: usableAreaHPadding,
        right: usableAreaHPadding,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Image.asset(Assets.imageschatMesssageIconLightGreen),
          Column(
            children: [
              Column(
                children: [
                  Text(
                    'sms_loading_text_1'.tr,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      fontSize: primaryTextFontSize,
                    ),
                  ),
                  // Text(
                  //   'sms_loading_text_2'.tr,
                  //   style: GoogleFonts.roboto(
                  //     fontSize: primaryTextFontSize,
                  //   ),
                  // ),
                  // Text(
                  //   'sms_loading_text_3'.tr,
                  //   style: GoogleFonts.roboto(
                  //     fontSize: primaryTextFontSize,
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  Text(
                    'sms_permission_safety_1'.tr,
                    style: GoogleFonts.roboto(fontSize: secondaryTextFontSize),
                  ),
                  Text(
                    'sms_permission_safety_2'.tr,
                    style: GoogleFonts.roboto(fontSize: secondaryTextFontSize),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 50,
            child: Center(
                child: CircularProgressIndicator(
              color: greenColor,
            )),
          ),
        ],
      ),
    );
  }
}
