import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:lane_dane/helpers/android_alarm_manager_helper.dart';
import 'package:lane_dane/helpers/telephony_background_sms_helper.dart';
import 'package:lane_dane/models/all_transaction.dart';
import 'package:lane_dane/models/group_model.dart';
import 'package:lane_dane/models/transactions.dart';
import 'package:lane_dane/models/users.dart';
import 'package:lane_dane/utils/init.dart';
import 'package:lane_dane/utils/ui_text.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:lane_dane/views/introscreens/intro_main.dart';
import 'package:lane_dane/views/pages/home/create_group.dart';
import 'package:lane_dane/views/pages/selectContact.dart';
import 'package:lane_dane/views/pages/transaction/add_group_transaction.dart';
import 'package:lane_dane/views/pages/transaction/add_transaction.dart';
import 'package:lane_dane/views/pages/transaction/group_transaction_screen.dart';
import 'package:lane_dane/views/pages/transaction/personal_transaction_view.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';
import 'package:lane_dane/app_controller.dart';
import 'package:lane_dane/controllers/category_controller.dart';
import 'package:lane_dane/helpers/auth.dart';
import 'package:lane_dane/routes.dart';
import 'package:lane_dane/views/pages/authentication/enter_phone_screen.dart';
import 'package:lane_dane/views/pages/home/home.dart';
import 'package:lane_dane/views/pages/language_setting.dart';
import 'package:lane_dane/helpers/object_box.dart';

late ObjectBox OBJECTBOX;
// FirebaseAnalytics ANALYTICS = FirebaseAnalytics.instance;
late double dailySmsSpending;
late var weeklySmsSpending;
late var monthlySmsSpending;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsBinding binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  NotificationResponse? notificationResponse;
  AppController appController;
  try {
    setupTimeZone();
    await setupFirebase();
    await setupGetStorage();
    await setupObjectBox();
    appController = await setupGetx();
    notificationResponse = await setupFlutterLocalNotifications();
    await setupMobAds();

    if (appController.permissions.smsReadPermission) {
      setupTelephony();
      AndroidAlarmManagerHelper().setupDailySmsAlarm();
    }

    // Initialise Notifcation Service Class
    Logger.level = Level.debug;
    FirebaseMessaging.instance.onTokenRefresh
        .listen(appController.refreshToken);

    Permission.notification.request();
  } catch (err, stack) {
    FirebaseCrashlytics.instance.recordError(
      err,
      stack,
      fatal: true,
      printDetails: true,
      reason:
          'Error occurred during initialization of necessary plugins and objects',
    );
    return;
  }
  runApp(
    MyApp(
      appController: appController,
      notificationResponse: notificationResponse,
    ),
  );
}

class MyApp extends StatelessWidget {
  final AppController appController;
  final NotificationResponse? notificationResponse;
  const MyApp({
    Key? key,
    required this.appController,
    required this.notificationResponse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics.instance.logAppOpen();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top],
    );

    SystemChrome.setSystemUIChangeCallback((bool _) async {
      Timer(const Duration(seconds: 1), () {
        SystemChrome.restoreSystemUIOverlays();
      });
    });

    CategoryController().preloadCategories();
    return GetMaterialApp(
      translations: UIText(),
      locale: appController.userLocale,
      fallbackLocale: const Locale('en', 'US'),
      title: 'Lane Dane',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) => generateRoute(settings),
      home: UpgradeAlert(
        upgrader: Upgrader(
          durationUntilAlertAgain: const Duration(hours: 1),
          debugLogging: true,
          debugDisplayAlways:
              false, // Set to true to always display the update dialog
          dialogStyle: Platform.isIOS
              ? UpgradeDialogStyle.cupertino
              : UpgradeDialogStyle.material,
          messages: UpgraderMessages(
              code:
                  "Please update the app to ensure a smooth experience, thank you!"),
          minAppVersion: '1',
          showIgnore: false,
          showLater: false,
          debugDisplayOnce:
              false, // Set to true to display the update dialog only once
        ),
        child: AppSetup(
          notificationResponse: notificationResponse,
        ),
      ),
    );
  }
}

class AppSetup extends StatefulWidget {
  final NotificationResponse? notificationResponse;
  const AppSetup({
    Key? key,
    required this.notificationResponse,
  }) : super(key: key);

  @override
  State<AppSetup> createState() => _AppSetupState();
}

class _AppSetupState extends State<AppSetup> {
  late final AppController appController;

  @override
  void initState() {
    super.initState();
    appController = Get.find();
  }

  bool get isAuthenticated {
    return appController.loggedIn;
  }

  bool get isNotAuthenticated {
    return !isAuthenticated;
  }

  bool get isLaunchedFromNotification {
    return widget.notificationResponse != null;
  }

  bool get isNotLaunchedFromNotification {
    return !isLaunchedFromNotification;
  }

  bool get isLaunchedFromDailyDebitNotification {
    if (isNotLaunchedFromNotification) {
      return false;
    }
    if (widget.notificationResponse!.id == null) {
      return false;
    }
    if (widget.notificationResponse!.id == 1) {
      return true;
    }
    return false;
  }

  bool get isLaunchedFromSmsTransactionNotification {
    if (isNotLaunchedFromNotification) {
      return false;
    }
    if (widget.notificationResponse!.id == null) {
      return false;
    }
    if (widget.notificationResponse!.id == 2 &&
        widget.notificationResponse!.payload != null) {
      return true;
    }
    return false;
  }

  bool get isLaunchedFromAddTransactionAction {
    if (!isLaunchedFromSmsTransactionNotification) {
      return false;
    }
    if (widget.notificationResponse!.actionId == null) {
      return false;
    }
    if (widget.notificationResponse!.actionId ==
        'add_transaction_from_sms_notification') {
      return true;
    }
    return false;
  }

  bool get isLaunchedFromPersonalTransactionNotification {
    if (isNotLaunchedFromNotification) {
      return false;
    }
    if (widget.notificationResponse!.id == null) {
      return false;
    }
    if (widget.notificationResponse!.id == 3 &&
        widget.notificationResponse!.payload != null) {
      return true;
    }
    return false;
  }

  bool get isLaunchedFromGroupTransactionNotification {
    if (isNotLaunchedFromNotification) {
      return false;
    }
    if (widget.notificationResponse!.id == null) {
      return false;
    }
    if (widget.notificationResponse!.id == 4 &&
        widget.notificationResponse!.payload != null) {
      return true;
    }
    return false;
  }

  bool get isLaunchedFromFromSettleUpNotification {
    if (isNotLaunchedFromNotification) {
      return false;
    }
    if (widget.notificationResponse!.id == null) {
      return false;
    }
    if (widget.notificationResponse!.id == 5 &&
        widget.notificationResponse!.payload != null) {
      return true;
    }
    return false;
  }

  bool get isLaunchedFromTransactionConfirmationNotification {
    if (isNotLaunchedFromNotification) {
      return false;
    }
    if (widget.notificationResponse!.id == null) {
      return false;
    }
    if (widget.notificationResponse!.id == 6 &&
        widget.notificationResponse!.payload != null) {
      return true;
    }
    return false;
  }

  Future<void> handleLaunchByNotification(Duration _) async {
    try {
      if (isNotLaunchedFromNotification) {
        FlutterNativeSplash.remove();
        return;
      }
      if (isLaunchedFromDailyDebitNotification) {
        FlutterNativeSplash.remove();
        return;
      }
      if (isLaunchedFromSmsTransactionNotification &&
          isLaunchedFromAddTransactionAction) {
        await appController.parseAndStoreTransactionSms();
        AllTransactionObjectBox? smsTransaction = appController
            .allTransactionController
            .retrieveLatestSmsTransaction();
        if (smsTransaction == null) {
          return;
        }
        handleLaunchedBySmsTransactionNotification(smsTransaction);
      }
      if (isLaunchedFromSmsTransactionNotification) {
        FlutterNativeSplash.remove();
      }
      if (isLaunchedFromPersonalTransactionNotification) {
        await appController.retrieveTransactionsFromServer();
        Map<String, dynamic> payload =
            json.decode(widget.notificationResponse!.payload!);
        handleLaunchByPersonalTransactionNotification(payload);
      }
      if (isLaunchedFromGroupTransactionNotification) {
        await appController.retrieveTransactionsFromServer();
        await appController.fetchRemoteGroupTransactionList();
        Map<String, dynamic> payload =
            json.decode(widget.notificationResponse!.payload!);
        handleLaunchByGroupTransactionNotification(payload);
      }
      if (isLaunchedFromTransactionConfirmationNotification) {
        await appController.retrieveTransactionsFromServer();
        Map<String, dynamic> payload =
            json.decode(widget.notificationResponse!.payload!);
        handleLaunchByTransactionConfirmationNotification(payload);
      }
      if (isLaunchedFromFromSettleUpNotification) {
        await appController.retrieveTransactionsFromServer();
        Map<String, dynamic> payload =
            json.decode(widget.notificationResponse!.payload!);
        handleLaunchBySettleUpNotification(payload);
      }
    } catch (err, stack) {
      FlutterNativeSplash.remove();
      FirebaseCrashlytics.instance.recordError(
        err,
        stack,
        fatal: false,
        information: [
          widget.notificationResponse?.payload as Object,
          widget.notificationResponse?.id as Object,
          widget.notificationResponse?.actionId as Object
        ],
        reason: 'Error occurred while handling launch by notification',
      );
    }
  }

  Future<void> handleLaunchedBySmsTransactionNotification(
      AllTransactionObjectBox smsTransaction) async {
    FlutterNativeSplash.remove();
    dynamic response = await toSelectContact();
    if (response.runtimeType == List<Users>) {
      Groups? group = await toCreateGroup(response);
      if (group == null) {
        return;
      }
      toAddGroupTransaction(group, smsTransaction);
    } else if (response.runtimeType == Groups) {
      toAddGroupTransaction(response, smsTransaction);
    } else if (response.runtimeType == Users) {
      toAddTransaction(response, smsTransaction);
    }
  }

  Future<void> handleLaunchByPersonalTransactionNotification(
    Map<String, dynamic> payload,
  ) async {
    int creatorId = payload['user_id'];
    Users user = appController.userController.retrieveUserFromServerId(
      creatorId,
    )!;

    FlutterNativeSplash.remove();
    await toPersonalTransaction(user);
  }

  Future<void> handleLaunchByGroupTransactionNotification(
    Map<String, dynamic> payload,
  ) async {
    int groupId = payload['group_id'];
    Groups group = appController.groupController.retrieveGroupByServerId(
      groupId,
    )!;
    FlutterNativeSplash.remove();
    await toGroupTransaction(group);
  }

  Future<void> handleLaunchByTransactionConfirmationNotification(
    Map<String, dynamic> payload,
  ) async {
    int authUserId = appController.user.id;
    int laneUserId = payload['lane_user_id'];
    int daneUserId = payload['dane_user_id'];

    Users user = appController.userController.retrieveUserFromServerId(
      authUserId == laneUserId ? daneUserId : laneUserId,
    )!;

    FlutterNativeSplash.remove();
    await toPersonalTransaction(user);
  }

  Future<void> handleLaunchBySettleUpNotification(
    Map<String, dynamic> payload,
  ) async {
    int creatorId = payload['user_id'];

    Users user = appController.userController.retrieveUserFromServerId(
      creatorId,
    )!;

    FlutterNativeSplash.remove();
    await toPersonalTransaction(user);
  }

  Future<Groups?> toCreateGroup(List<Users> userList) async {
    if (!mounted) {
      return null;
    }
    dynamic response = await Navigator.of(context)
        .pushNamed(CreateGroupScreen.routeName, arguments: {
      'user_list': userList,
    });

    if (response.runtimeType == Groups) {
      return response;
    } else {
      return null;
    }
  }

  Future<void> toAddTransaction(
    Users user,
    AllTransactionObjectBox smsTransaction,
  ) async {
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushNamed(AddTransaction.routeName, arguments: {
      'contact': user,
      'amount': double.parse(smsTransaction.amount).toInt(),
      'all_transaction_id': smsTransaction.id,
    });
  }

  Future<void> toAddGroupTransaction(
    Groups group,
    AllTransactionObjectBox smsTransaction,
  ) async {
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushNamed(
      AddGroupTransaction.routeName,
      arguments: {
        'group': group,
        'amount': double.parse(smsTransaction.amount).toInt(),
        'all_transaction_id': smsTransaction.id,
      },
    );
  }

  Future<dynamic> toSelectContact() async {
    if (mounted) {
      dynamic response = await Navigator.of(context)
          .pushNamed(SelectContact.routeName, arguments: {
        'list_groups': true,
      });
      return response;
    }
  }

  Future<dynamic> toPersonalTransaction(Users user) async {
    if (mounted) {
      await Navigator.of(context).pushNamed(
        PersonalTransactions.routeName,
        arguments: {
          'contact': user,
        },
      );
    }
  }

  Future<dynamic> toGroupTransaction(Groups group) async {
    if (mounted) {
      Navigator.of(context).pushNamed(
        GroupTransactionScreen.routeName,
        arguments: {
          'group': group,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(handleLaunchByNotification);

    if (isNotAuthenticated) {
      return LanguageSetting(
        postSettingCallback: () {
          Navigator.of(context)
              .pushReplacementNamed(IntroMain.routeName);
        },
      );
     
    }
    if (isAuthenticated) {
      FirebaseCrashlytics.instance
          .setUserIdentifier(appController.user.fullName);
      return const Home();
    }

    return Container();
  }
}
