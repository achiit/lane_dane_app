import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lane_dane/app_controller.dart';
import 'package:lane_dane/views/widgets/elevated_btn.dart';

class PremiumDetails extends StatelessWidget {
  static const String routeName = 'premium-details55';

  const PremiumDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 40,
          left: 24,
          right: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text(
                  'Lane Dane',
                  style: GoogleFonts.roboto(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Premium',
                  style: GoogleFonts.roboto(
                    fontSize: 24,
                  ),
                ),
              ],
            ),
            CustomButton(
                onPressed: () {
                  final AppController appController = Get.find();
                  appController.activatePremium();
                },
                buttonName: 'Upgrade Account')
          ],
        ),
      ),
    );
  }
}
