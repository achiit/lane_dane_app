import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html/dom.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:lane_dane/controllers/group_controller.dart';
import 'package:lane_dane/controllers/group_transaction_controller.dart';
import 'package:lane_dane/controllers/user_group_entity_controller.dart';
import 'package:upgrader/src/play_store_search_api.dart' as play;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:lane_dane/controllers/category_controller.dart';
import 'package:lane_dane/helpers/local_store.dart';
import 'package:lane_dane/models/auth_user.dart';
import 'package:logger/logger.dart';
import 'package:lane_dane/api/auth_services.dart';
import 'package:lane_dane/controllers/contact_controller.dart';
import 'package:lane_dane/controllers/transaction_controller.dart';
import 'package:lane_dane/controllers/users_controller.dart';
import 'package:lane_dane/helpers/auth.dart';
import 'package:lane_dane/models/permission_manager.dart';
import 'package:lane_dane/controllers/all_transaction_controller.dart';
import 'package:lane_dane/utils/log_printer.dart';

export 'package:lane_dane/helpers/transaction_helper.dart';
export 'package:lane_dane/helpers/auth_helper.dart';
export 'package:lane_dane/helpers/group_helper.dart';
export 'package:lane_dane/helpers/sms_helper.dart';

class AppController extends GetxController {
  final Logger log = getLogger('AppController');
  final LocalStore localstore = LocalStore();
  final PermissionManager permissions = PermissionManager();
  final AuthServices authService = AuthServices();
  final Auth auth = Auth();
  final ContactController contactController = ContactController();
  final CategoryController categoryController = CategoryController();
  // final SmsControllerConcurrentEngine smsControllerConcurrentEngine =
  //     SmsControllerConcurrentEngine();
  UserHelper userController = UserHelper();
  final UserGroupEntityController usergroupController =
      UserGroupEntityController();
  final GroupTransactionController groupTransactionController =
      GroupTransactionController();
  final GroupController groupController = GroupController();
  final AllTransactionController allTransactionController =
      AllTransactionController();
  final TransactionController transactionController = TransactionController();

  /*
   * Listenable objects.
   * Changes here should update on the ui as well.
   */

  late PackageInfo packageInfo;
  late PackageInfo newPackage;

  late AuthUser user;
  late String token;
  bool loggedIn = false;

  late List<dynamic Function()> postLoginCallbacks;
  late Locale userLocale;

  /*
   *  Constructor and initializers 
   */

  AppController() {
    postLoginCallbacks = [];

    try {
      loadAppVersion();
      loadAppLocale();
    } catch (err, stack) {
      FirebaseCrashlytics.instance.recordError(
        err,
        stack,
        fatal: false,
        printDetails: true,
        reason: 'Failed to preload one or more app controller lists.',
      );
    }
  }

  Future<void> postLoginUpdates() async {
    for (int i = 0; i < postLoginCallbacks.length; i++) {
      dynamic Function() callback = postLoginCallbacks[i];
      await callback();
    }
  }

  /*
   * Loaders and initializers
   */

  Future<void> loadAppVersion() async {
    packageInfo = await PackageInfo.fromPlatform();
    log.i(packageInfo.appName);
    log.i(packageInfo.packageName);
    log.i(packageInfo.version);
    log.i(packageInfo.buildNumber);

    Document? doc =
        await play.PlayStoreSearchAPI().lookupById('com.lane_dane.lane_dane');
    if (doc != null) {
      String? version = play.PlayStoreResults.version(doc);
      newPackage = PackageInfo(
        appName: packageInfo.appName,
        buildNumber: packageInfo.buildNumber,
        packageName: packageInfo.packageName,
        version: version ?? packageInfo.version,
        buildSignature: packageInfo.buildSignature,
        installerStore: packageInfo.installerStore,
      );
    } else {
      newPackage = PackageInfo(
        appName: packageInfo.appName,
        buildNumber: packageInfo.buildNumber,
        packageName: packageInfo.packageName,
        version: packageInfo.version,
        buildSignature: packageInfo.buildSignature,
        installerStore: packageInfo.installerStore,
      );
    }
  }

  void loadAppLocale() {
    userLocale = localstore.getLocale();
  }

  Future<void> loadNewContacts() async {
    if (permissions.contactReadPermission) {
      await contactController.localStoreNewContacts();
    }
  }

  /*
   * Methods that will control and change the state of the app.
   */

  void updateAppLocale(Locale newLocale) {
    userLocale = newLocale;
    localstore.updateLocale(newLocale);
    Get.updateLocale(newLocale);
  }
}
