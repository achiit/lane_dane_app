import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lane_dane/app_controller.dart';
import 'package:lane_dane/utils/analytics_events.dart';
import 'package:lane_dane/utils/colors.dart';

class LanguageSetting extends StatefulWidget {
  static const String routeName = 'language-setting';

  final void Function() postSettingCallback;
  const LanguageSetting({Key? key, required this.postSettingCallback})
      : super(key: key);

  @override
  State<LanguageSetting> createState() => _LanguageSettingState();
}

class _LanguageSettingState extends State<LanguageSetting> {
  final AppController appController = Get.find();

  late Locale userLocale;
  late String languageCode;
   int selectedOption = 1;

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: LanguageSetting.routeName,
    );
    userLocale = appController.userLocale;
    languageCode = userLocale.languageCode;
  }

  void changeLanguageToMarathi() {
    if (languageCode == 'mr') {
      return;
    }
    Locale marathiLocale = const Locale('mr', 'IN');
    appController.updateAppLocale(marathiLocale);
    updateUserLocale(marathiLocale);
  }


  void changeLanguageToTamil() {
    if (languageCode == 'ta') {
      return;
    }
    Locale tamilLocale = const Locale('ta', 'IN');
    appController.updateAppLocale(tamilLocale);
    updateUserLocale(tamilLocale);
  }


  void changeLanguageToHindi() {
    if (languageCode == 'hi') {
      return;
    }
    Locale hindiLocale = const Locale('hi', 'IN');
    appController.updateAppLocale(hindiLocale);
    updateUserLocale(hindiLocale);
  }

  void changeLanguageToEnglish() {
    if (languageCode == 'en') {
      return;
    }
    Locale englishLocale = const Locale('en', 'US');
    appController.updateAppLocale(englishLocale);
    updateUserLocale(englishLocale);
  }

  void updateUserLocale(Locale newLocale) {
    setState(() {
      userLocale = newLocale;
      languageCode = userLocale.languageCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color selectedColor = greenColor;
    Color unselectedColor = Colors.white;

    Color selectedTextColor = Colors.white;
    Color unselectedTextColor = greenColor;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AnalyticsEvents.languageChoice(languageCode: languageCode);
          widget.postSettingCallback();
        },
        backgroundColor: greenColor,
        child:   const Icon(
          Icons.arrow_forward,
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/logo/lane_dane_logo_green.png",
                  fit: BoxFit.contain,width:200,height:200
            
                  
                ),
                
                Text(
                  'lane_dane'.tr,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'language_setting_prompt_1'.tr,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    fontSize: 30,
                  ),
                ),
                SizedBox(height: constraints.maxHeight * 0.1),
                 Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        RadioListTile(
                          title: Text(
                            'english'.tr,
                            textAlign: TextAlign.left,
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            "(device language)",
                            textAlign: TextAlign.left,
                            style: GoogleFonts.roboto(
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          value: 1,
                          activeColor: laneColor,
                          fillColor: MaterialStateProperty.all(laneColor),
                          splashRadius: 25,
                          groupValue: selectedOption,
                          onChanged: (int? value) {
                            setState(() {
                              selectedOption = value!;
                            });
                            changeLanguageToEnglish();
                          },
                        ),
                        RadioListTile(
                          title: Text(
                            'hindi'.tr,
                            textAlign: TextAlign.left,
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            "Hindi",
                            textAlign: TextAlign.left,
                            style: GoogleFonts.roboto(
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          value: 2,
                          activeColor: laneColor,
                          fillColor: MaterialStateProperty.all(laneColor),
                          splashRadius: 25,
                          groupValue: selectedOption,
                          onChanged: (int? value) {
                            setState(() {
                              selectedOption = value!;
                            });
                            changeLanguageToHindi();
                          },
                        ),
                        RadioListTile(
                          title: Text(
                            'marathi'.tr,
                            textAlign: TextAlign.left,
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            "Marathi",
                            textAlign: TextAlign.left,
                            style: GoogleFonts.roboto(
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          value: 3,
                          activeColor: laneColor,
                          fillColor: MaterialStateProperty.all(laneColor),
                          splashRadius: 25,
                          groupValue: selectedOption,
                          onChanged: (int? value) {
                            setState(() {
                              selectedOption = value!;
                            });
                            changeLanguageToMarathi();
                          },
                        ),
                        RadioListTile(
                          title: Text(
                            'tamil'.tr,
                            textAlign: TextAlign.left,
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            "Tamil",
                            textAlign: TextAlign.left,
                            style: GoogleFonts.roboto(
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          activeColor: laneColor,
                          fillColor: MaterialStateProperty.all(laneColor),
                          splashRadius: 25,
                          value: 4,
                          groupValue: selectedOption,
                          onChanged: (int? value) {
                            setState(() {
                              selectedOption = value!;
                            });
                            changeLanguageToTamil();
                          },
                        ),
                      ],
                    ),
                  ),
                )
                
                
                
              ],
            );
          },
        ),
      ),
    );
  }
}
