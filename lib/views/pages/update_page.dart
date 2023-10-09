import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lane_dane/utils/assets.dart';
import 'package:lane_dane/utils/colors.dart';
import 'package:lane_dane/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdatePage extends StatelessWidget {
  static const String routeName = 'update-page';
  const UpdatePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back,
            color: greenColor,
          ),
        ),
      ),
      body: Container(
        height: size.height,
        width: size.width,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              Assets.imagesSplashScreen,
            ),
            const SizedBox(height: 28),
            Text(
              'We\'re better than ever',
              style: GoogleFonts.roboto(
                fontSize: 15,
                color: const Color(0xFF000000).withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'The current version of the application is no longer supported. Please update the app.',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 15,
                color: const Color(0xFF000000).withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 120,
              height: 40,
              decoration: BoxDecoration(
                color: greenColor,
                borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.6),
                      offset: const Offset(4, 4),
                      blurRadius: 8.0),
                ],
              ),
              child: Material(
                color: greenColor,
                child: InkWell(
                  onTap: () {
                    launchUrl(Uri.parse(Constants.appLink),
                        mode: LaunchMode.externalApplication);
                  },
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const Icon(
                          Icons.upgrade,
                          color: Colors.white,
                          size: 22,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            'Update',
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // SizedBox(
            //   width: size.width,
            //   height: 52,
            //   child: ElevatedButton(
            //     style: ButtonStyle(
            //       backgroundColor: MaterialStateProperty.all(greenColor),
            //     ),
            //     onPressed: () {},
            //     child: Text(
            //       'UPDATE TO A NEW VERSION',
            //       style: GoogleFonts.roboto(
            //         fontSize: 14,
            //         letterSpacing: 1,
            //         fontWeight: FontWeight.w500,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
