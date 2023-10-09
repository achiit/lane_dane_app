import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lane_dane/app_controller.dart';
import 'package:lane_dane/controllers/transaction_controller.dart';
import 'package:lane_dane/models/aggregate_record.dart';
import 'package:lane_dane/models/all_transaction.dart';
import 'package:lane_dane/models/auth_user.dart';
import 'package:lane_dane/models/transactions.dart';
import 'package:lane_dane/utils/colors.dart';
import 'package:lane_dane/views/widgets/transaction_aggregate_view.dart';

final _txn = TransactionController();

enum FilterOptions {
  alltime,
  today,
  yesterday,
  lastweek,
  thisweek,
  lastmonth,
  thismonth,
}

class Profile extends StatefulWidget {
  static const String routeName = 'profile-screen';

  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final AppController appController = Get.find();

  late List<TransactionsModel> transactionList;
  late List<AllTransactionObjectBox> allTransactionList;
  late AggregateRecord record;
  late FilterOptions currentFilter;

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: Profile.routeName,
    );
    transactionList = [];
    allTransactionList = [];
    fetchTransactions();
    fetchAllTransactions();
    filterThisMonth();
  }

  List<TransactionsModel> fetchTransactions() {
    if (transactionList.isEmpty) {
      transactionList =
          _txn.getAllTransactions().where((TransactionsModel transaction) {
        return transaction.confirmation!.toLowerCase() != 'denied';
      }).toList();
    }
    return transactionList;
  }

  List<AllTransactionObjectBox> fetchAllTransactions() {
    if (allTransactionList.isEmpty) {
      allTransactionList =
          appController.allTransactionController.retrieveAllSmsTransactions();
    }
    return allTransactionList;
  }

  void filterTotal() {
    currentFilter = FilterOptions.alltime;
    record = AggregateRecord.fromTransactionList(
      list: fetchTransactions(),
      allTransactionList: fetchAllTransactions(),
    );
  }

  void filterToday() {
    currentFilter = FilterOptions.today;

    DateTime now = DateTime.now();
    DateTime startOfToday = now.subtract(Duration(hours: now.hour));

    List<TransactionsModel> todayTransactions = filterTransactionsBetween(
      startOfToday,
      now,
    );

    List<AllTransactionObjectBox> todayAllTransactions =
        filterAllTransactionsBetween(
      startOfToday,
      now,
    );

    record = AggregateRecord.fromTransactionList(
      list: todayTransactions,
      allTransactionList: todayAllTransactions,
    );
  }

  void filterYesterday() {
    currentFilter = FilterOptions.yesterday;

    DateTime now = DateTime.now();
    DateTime endOfYesterday = now.subtract(Duration(hours: now.hour));
    DateTime startOfYesterday =
        endOfYesterday.subtract(const Duration(days: 1));

    List<TransactionsModel> yesterdayTransactions = filterTransactionsBetween(
      startOfYesterday,
      endOfYesterday,
    );

    List<AllTransactionObjectBox> yesterdayAllTransactions =
        filterAllTransactionsBetween(
      startOfYesterday,
      endOfYesterday,
    );

    record = AggregateRecord.fromTransactionList(
      list: yesterdayTransactions,
      allTransactionList: yesterdayAllTransactions,
    );
  }

  void filterLastWeek() {
    currentFilter = FilterOptions.lastweek;

    DateTime now = DateTime.now();
    int weekday = now.weekday;
    DateTime endOfLastWeek = now.subtract(Duration(days: weekday));

    endOfLastWeek = endOfLastWeek.add(Duration(
        hours: 23 - now.hour,
        minutes: 59 - now.minute,
        seconds: 59 - now.second));
    DateTime startOfLastWeek = endOfLastWeek.subtract(const Duration(days: 7));

    List<TransactionsModel> lastWeekTransactions = filterTransactionsBetween(
      startOfLastWeek,
      endOfLastWeek,
    );
    List<AllTransactionObjectBox> lastWeekAllTransactions =
        filterAllTransactionsBetween(
      startOfLastWeek,
      endOfLastWeek,
    );

    record = AggregateRecord.fromTransactionList(
      list: lastWeekTransactions,
      allTransactionList: lastWeekAllTransactions,
    );
  }

  void filterThisWeek() {
    currentFilter = FilterOptions.thisweek;

    DateTime now = DateTime.now();
    int weekday = now.weekday;
    DateTime startOfThisWeek = now.subtract(Duration(days: weekday));

    startOfThisWeek = startOfThisWeek.add(Duration(
        hours: 23 - now.hour,
        minutes: 59 - now.minute,
        seconds: 59 - now.second));

    List<TransactionsModel> thisWeekTransactions = filterTransactionsBetween(
      startOfThisWeek,
      now,
    );
    List<AllTransactionObjectBox> thisWeekAllTransaction =
        filterAllTransactionsBetween(
      startOfThisWeek,
      now,
    );

    record = AggregateRecord.fromTransactionList(
      list: thisWeekTransactions,
      allTransactionList: thisWeekAllTransaction,
    );
  }

  void filterLastMonth() {
    currentFilter = FilterOptions.lastmonth;

    DateTime now = DateTime.now();
    int day = now.day;
    DateTime endOfLastMonth = now.subtract(Duration(days: day));

    endOfLastMonth = endOfLastMonth.add(Duration(
        hours: 23 - now.hour,
        minutes: 59 - now.minute,
        seconds: 59 - now.second));
    DateTime startOfLastMonth = endOfLastMonth.subtract(Duration(
        days: DateTime(endOfLastMonth.year, endOfLastMonth.month + 1, 0).day));

    List<TransactionsModel> lastMonthTransactions = filterTransactionsBetween(
      startOfLastMonth,
      endOfLastMonth,
    );
    List<AllTransactionObjectBox> lastMonthAllTransactions =
        filterAllTransactionsBetween(
      startOfLastMonth,
      endOfLastMonth,
    );

    record = AggregateRecord.fromTransactionList(
      list: lastMonthTransactions,
      allTransactionList: lastMonthAllTransactions,
    );
  }

  void filterThisMonth() {
    currentFilter = FilterOptions.thismonth;

    DateTime now = DateTime.now();
    int day = now.day;
    DateTime startOfThisMonth = now.subtract(Duration(days: day));

    startOfThisMonth = startOfThisMonth.add(Duration(
        hours: 23 - now.hour,
        minutes: 59 - now.minute,
        seconds: 59 - now.second));

    List<TransactionsModel> thisMonthTransactions = filterTransactionsBetween(
      startOfThisMonth,
      now,
    );
    List<AllTransactionObjectBox> thisMonthAllTransactions =
        filterAllTransactionsBetween(
      startOfThisMonth,
      now,
    );

    record = AggregateRecord.fromTransactionList(
      list: thisMonthTransactions,
      allTransactionList: thisMonthAllTransactions,
    );
  }

  List<TransactionsModel> filterTransactionsBetween(
      DateTime start, DateTime end) {
    return transactionList.where((TransactionsModel t) {
      return t.createdAt.isAtSameMomentAs(start) ||
          (t.createdAt.isAfter(start) && t.createdAt.isBefore(end));
    }).toList();
  }

  List<AllTransactionObjectBox> filterAllTransactionsBetween(
      DateTime start, DateTime end) {
    return allTransactionList.where((AllTransactionObjectBox t) {
      return t.createdAt.isAtSameMomentAs(start) ||
          (t.createdAt.isAfter(start) && t.createdAt.isBefore(end));
    }).toList();
  }

  void dropdownSelectionCallback(FilterOptions? option) {
    switch (option) {
      case FilterOptions.alltime:
        filterTotal();
        break;
      case FilterOptions.today:
        filterToday();
        break;
      case FilterOptions.yesterday:
        filterYesterday();
        break;
      case FilterOptions.lastweek:
        filterLastWeek();
        break;
      case FilterOptions.thisweek:
        filterThisWeek();
        break;
      case FilterOptions.lastmonth:
        filterLastMonth();
        break;
      case FilterOptions.thismonth:
        filterThisMonth();
        break;
      default:
        break;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    
    final width = MediaQuery.of(context).size.width;
    final Size size = MediaQuery.of(context).size;
    AuthUser authuser = appController.user;

    String totalLabel = 'total'.tr;

    const double usableSpaceVerticalPadding = 24;
    const double usableSpaceHorizontalPadding = 18;
    const double labelFontSize = 12;
    const double valueFontSize = 16;

    const Color iconColors = Color.fromARGB(226, 4, 78, 6);

    String fullName = authuser.fullName;
    String phoneNumber = authuser.phoneNumberFormatted;

    return SingleChildScrollView(
      child: Container(
        width: size.width,
        padding: const EdgeInsets.symmetric(
          vertical: usableSpaceVerticalPadding,
          horizontal: usableSpaceHorizontalPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ProfilePicture(
                      name: fullName,
                      fontsize: 48,
                      radius: 76,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                      onPressed: () {},
                      icon: const Icon(
                        Icons.person,
                        color: iconColors,
                        size: 25.0,
                      ),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'name'.tr,
                          style: GoogleFonts.roboto(
                            fontSize: labelFontSize,
                            color: Colors.black.withOpacity(0.69),
                          ),
                        ),
                        Text(
                          fullName,
                          style: GoogleFonts.roboto(
                            fontSize: valueFontSize,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                      icon: const Icon(
                        Icons.call,
                        color: iconColors,
                        size: 25.0,
                      ),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'phone'.tr,
                          style: GoogleFonts.roboto(
                            fontSize: labelFontSize,
                            color: Colors.black.withOpacity(0.69),
                          ),
                        ),
                        Text(
                          phoneNumber,
                          style: GoogleFonts.roboto(
                            fontSize: valueFontSize,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40.0,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: width * 0.11),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        totalLabel.tr,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        currentFilter.name.tr,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          color: const Color(0xFF656870),
                        ),
                      ),
                    ],
                  ),
                  DropdownButton<FilterOptions>(
                    onChanged: dropdownSelectionCallback,
                    items: [
                      DropdownMenuItem(
                        value: FilterOptions.alltime,
                        child: Text(
                          'alltime'.tr,
                        ),
                      ),
                      DropdownMenuItem(
                        value: FilterOptions.today,
                        child: Text(
                          'today'.tr,
                        ),
                      ),
                      DropdownMenuItem(
                        value: FilterOptions.yesterday,
                        child: Text(
                          'yesterday'.tr,
                        ),
                      ),
                      DropdownMenuItem(
                        value: FilterOptions.lastweek,
                        child: Text(
                          'lastweek'.tr,
                        ),
                      ),
                      DropdownMenuItem(
                        value: FilterOptions.thisweek,
                        child: Text(
                          'thisweek'.tr,
                        ),
                      ),
                      DropdownMenuItem(
                        value: FilterOptions.lastmonth,
                        child: Text(
                          'lastmonth'.tr,
                        ),
                      ),
                      DropdownMenuItem(
                        value: FilterOptions.thismonth,
                        child: Text(
                          'thismonth'.tr,
                        ),
                      ),
                    ],
                    alignment: Alignment.centerRight,
                    icon: Container(),
                    underline: Container(),
                    isExpanded: false,
                    hint: Container(
                      // decoration: BoxDecoration(
                      //   color: greenColor,
                      //   border: Border.all(color: greenColor),
                      //   borderRadius:
                      //       const BorderRadius.all(Radius.circular(10)),
                      // ),
                      padding: const EdgeInsets.all(8),

                      child: Icon(
                        Icons.filter_alt,
                        size: 28,
                        color: greenColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            TransactionAggregateView(record: record),
          ],
        ),
      ),
    );
  }
}
