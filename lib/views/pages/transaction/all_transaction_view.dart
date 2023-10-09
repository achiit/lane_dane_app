import 'dart:async';
import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lane_dane/app_controller.dart';
import 'package:lane_dane/controllers/all_transaction_controller.dart';
import 'package:lane_dane/controllers/sms_controller.dart';
import 'package:lane_dane/errors/request_error.dart';
import 'package:lane_dane/errors/unauthorized_error.dart';
import 'package:lane_dane/helpers/android_alarm_manager_helper.dart';
import 'package:lane_dane/helpers/auth.dart';
import 'package:lane_dane/helpers/telephony_background_sms_helper.dart';
import 'package:lane_dane/models/all_transaction.dart';
import 'package:lane_dane/models/transactions.dart';
import 'package:lane_dane/objectbox.g.dart';
import 'package:lane_dane/views/pages/authentication/enter_phone_screen.dart';
import 'package:lane_dane/views/pages/sms_permission_view.dart';
import 'package:lane_dane/views/pages/transaction/transaction_details.dart';
import 'package:lane_dane/views/shared/snack-bar.dart';
import 'package:lane_dane/views/widgets/all_transaction_list_builder.dart';
import 'package:logger/logger.dart';
import 'package:lane_dane/utils/log_printer.dart';

class AllTransaction extends StatefulWidget {
  static const String routeName = 'all-transaction-screen';
  const AllTransaction({Key? key}) : super(key: key);

  @override
  State<AllTransaction> createState() => _AllTransactionState();
}

class _AllTransactionState extends State<AllTransaction> {
  late final Logger log;
  late final AppController appController = Get.find();
  late List<AllTransactionObjectBox> allTransactionList;
  late StreamSubscription stream;

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: AllTransaction.routeName,
    );
    log = getLogger('AllTransaction');
    allTransactionList =
        appController.allTransactionController.retrieveAllSmsTransactions();
    stream = appController.allTransactionController
        .streamAllSmsTransactions()
        .listen(updateAllTransactionList);
    transactionListFetchProcess();
    appController.resendFailedTransactions();
    appController.resendFailedGroupTransactions();
  }

  @override
  void dispose() {
    stream.cancel();
    super.dispose();
  }

  void updateAllTransactionList(Query<AllTransactionObjectBox> query) {
    if (mounted) {
      allTransactionList = query.find();
      setState(() {});
    }
  }

  Future<void> refresh() async {
    await appController.retrieveTransactionsFromServer();
    appController.resendFailedTransactions();
  }

  Future<void> transactionListFetchProcess() async {
    if (!appController.permissions.contactReadPermission) {
      await appController.permissions.requestContactsReadPermission();
    }
    if (!appController.permissions.contactReadPermission) {
      return;
    }
    if (!appController.permissions.smsReadPermission) {
      await appController.permissions
          .requestSmsReadPermission()
          .then((bool granted) {
        if (granted) {
          setupTelephony();
          AndroidAlarmManagerHelper().setupDailySmsAlarm();
        }
      });
    }
    if (mounted) {
      setState(() {});
    }
    try {
      log.d('Fetching contacts');
      appController.parseAndStoreTransactionSms();
      log.d('Done Safely');
    } on SocketException catch (err) {
      showSnackBar(context, err.message);
      log.e('Failed to make a socket connection: ${err.toString()}');
      log.e('Host address: ${err.address}');
    } on RequestError catch (err) {
      showSnackBar(context, err.message);
      log.e('Failed to fetch contacts: ${err.toString()}');
      log.e('Response body: ${err.responseBody}');
    } on UnauthorizedError catch (err) {
      showSnackBar(context, err.message);
      Auth().logout();
      Navigator.of(context).pushReplacementNamed(EnterPhoneScreen.routeName);
    } catch (err) {
      if (kDebugMode) {
        showSnackBar(context, 'Unknown error occurred');
      }
      FirebaseCrashlytics.instance.log(
          '''An unknown error occurred while fetching launch data: ${err.toString()}
          Launch data includes, fetching contacts, SMS parsing, fetching remote transactions
          ''');
      log.e('An error occurred: ${err.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refresh,
      child: Builder(
        builder: (BuildContext context) {
          if (allTransactionList.isNotEmpty &&
              appController.permissions.smsReadPermission) {
            return AllTransactionLoader(
              alltransactionList: allTransactionList,
            );
          } else if (SmsController.smsParsed) {
            return Center(
              child: Text('all_transaction_empty_message'.tr,
                  style: const TextStyle(fontSize: 18, color: Colors.grey)),
            );
          } else if (appController.permissions.smsReadPermission) {
            return const SmsLoadingView();
          } else {
            return SmsPermissionView(
              onPressed: transactionListFetchProcess,
            );
          }
        },
      ),
    );
  }
}

class AllTransactionLoader extends StatelessWidget {
  final List<AllTransactionObjectBox> alltransactionList;
  AllTransactionLoader({
    Key? key,
    required this.alltransactionList,
  }) : super(key: key);

  final Logger log = getLogger('AllTransactionLoader');

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double topPadding =
        Get.statusBarHeight + kToolbarHeight + kToolbarHeight;
    return Container(
      height: size.height,
      alignment: Alignment.topCenter,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: alltransactionList.length,
        itemBuilder: (context, index) {
          AllTransactionObjectBox alltransaction = alltransactionList[index];
          bool isSms = alltransaction.transactionId.targetId == 0;

          TransactionsModel? transaction = alltransaction.transactionId.target;

          return AllTransactionListTile(
            alltransaction: alltransaction,
            isSms: isSms,
            navigationCallback: () {
              Navigator.of(context).pushNamed(
                TransactionDetails.routeName,
                arguments: {
                  'transaction': alltransaction.transactionId.target,
                  'alltransaction': alltransaction,
                  'contact': transaction?.user.target,
                },
              );
            },
          );
        },
      ),
    );
  }
}
