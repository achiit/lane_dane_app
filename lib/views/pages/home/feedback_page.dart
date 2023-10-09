import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lane_dane/api/feedback_services.dart';
import 'package:lane_dane/utils/assets.dart';
import 'package:lane_dane/utils/colors.dart';
import 'package:lane_dane/views/shared/snack-bar.dart';

class FeedbackPage extends StatefulWidget {
  static const String routeName = 'feedback-pagew';
  const FeedbackPage({Key? key}) : super(key: key);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  late final TextEditingController feedbackTextController;
  // late bool showSnackBar;

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: FeedbackPage.routeName,
    );
    feedbackTextController = TextEditingController();
    // showSnackBar = true;
  }

  @override
  void dispose() {
    feedbackTextController.dispose();
    super.dispose();
  }

  Future<void> sendFeedback() async {
    FeedbackServices feedbackServices = FeedbackServices();

    String content = feedbackTextController.text;
    AndroidDeviceInfo extractedDeviceInfo =
        await DeviceInfoPlugin().androidInfo;
    Map<String, dynamic> extractedDeviceInfoMap = extractedDeviceInfo.data;

    Map<String, String> deviceInfo = {
      'device': extractedDeviceInfoMap['model'] ?? 'model not found',
      'supported_abi': extractedDeviceInfo.supportedAbis.toList().toString(),
      'display': extractedDeviceInfo.displayMetrics.toMap().toString(),
    };

    Map<String, String> osInfo = {
      'base_os': extractedDeviceInfo.version.baseOS ?? 'baseOS not found',
      'version': extractedDeviceInfo.version.incremental,
      'release': extractedDeviceInfo.version.release,
      'sdk_int': extractedDeviceInfo.version.sdkInt.toString(),
      'security_patch': extractedDeviceInfo.version.securityPatch ??
          'Security Patch not found',
    };

    feedbackServices
        .sendFeedback(
          content: content,
          deviceInfo: deviceInfo.toString(),
          osInfo: osInfo.toString(),
        )
        .then((bool success) {})
        .onError((err, stack) {
      FirebaseCrashlytics.instance.recordError(
        err,
        stack,
        fatal: false,
        printDetails: true,
      );
    });
    showSnackBar(context, 'Sending Feedback');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                  left: 16,
                  right: 16,
                ),
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: greenColor,
                  ),
                ),
              ),
              Image.asset(
                Assets.imagesFeedbackImage,
                height: size.height * 0.4,
              ),
              Container(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'your_feedback'.tr,
                  style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'feedback_quote'.tr,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              _buildComposer(),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: Container(
                    width: 120,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(4.0)),
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
                          FocusScope.of(context).requestFocus(FocusNode());
                          sendFeedback();
                        },
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              'send'.tr,
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComposer() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 32, right: 32),
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.withOpacity(0.8),
                  offset: const Offset(4, 4),
                  blurRadius: 8),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Container(
              padding: const EdgeInsets.all(4.0),
              constraints: const BoxConstraints(minHeight: 80, maxHeight: 160),
              color: Colors.white,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                    left: 10, right: 10, top: 0, bottom: 0),
                child: TextField(
                  maxLines: 3,
                  controller: feedbackTextController,
                  maxLength: 500,
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  cursorColor: Colors.blue,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter your feedback...',
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
