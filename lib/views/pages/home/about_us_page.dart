import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lane_dane/utils/assets.dart';
import 'package:lane_dane/utils/colors.dart';

class AboutUsPage extends StatefulWidget {
  static const String routeName = 'about-us-page';

  const AboutUsPage({Key? key}) : super(key: key);

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  late final PageController pageController;
  late int currentPage;

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: AboutUsPage.routeName,
    );
    pageController = PageController();
    pageController.addListener(onPageChange);
    currentPage = 0;
  }

  @override
  void dispose() {
    pageController.removeListener(onPageChange);
    pageController.dispose();
    super.dispose();
  }

  void onPageChange() {
    if (pageController.page == null) {
      return;
    }
    if (mounted) {
      setState(() {
        currentPage = pageController.page!.toInt();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: size.height,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.center,
                child: Image.asset(
                  Assets.imagesFeedbackImage,
                  height: size.height * 0.4,
                  fit: BoxFit.fitWidth,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: size.width,
                height: size.height * 0.4,
                child: PageView.builder(
                  scrollDirection: Axis.horizontal,
                  controller: pageController,
                  itemCount: aboutUsText.length,
                  pageSnapping: true,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      width: size.width,
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          aboutUsText[index],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: aboutUsText.length * (10 + 4) + 10,
                height: 10 + 4,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: aboutUsText.length,
                  itemBuilder: (BuildContext context, int index) {
                    double size;
                    if (index == currentPage) {
                      size = 20;
                    } else {
                      size = 10;
                    }
                    return Container(
                      width: size,
                      height: size,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: greenColor,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final List<String> aboutUsText = [
    'about_us_text_1'.tr,
    'about_us_text_2'.tr,
    'about_us_text_3'.tr,
    'about_us_text_4'.tr,
  ];
}
