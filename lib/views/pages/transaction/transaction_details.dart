import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lane_dane/app_controller.dart';
import 'package:lane_dane/models/all_transaction.dart';
import 'package:lane_dane/models/group_model.dart';
import 'package:lane_dane/models/transactions.dart';
import 'package:lane_dane/models/users.dart';
import 'package:lane_dane/utils/colors.dart';
import 'package:lane_dane/utils/date_time_extensions.dart';
import 'package:lane_dane/views/pages/home/create_group.dart';
import 'package:lane_dane/views/pages/selectContact.dart';
import 'package:lane_dane/views/pages/transaction/add_group_transaction.dart';
import 'package:lane_dane/views/pages/transaction/add_transaction.dart';

enum TransactionDetailsPopupMenuOptions {
  removesms,
}

class TransactionDetails extends StatefulWidget {
  static const String routeName = 'transaction-details';

  final TransactionsModel? transaction;
  final AllTransactionObjectBox? allTransaction;
  final Users? contact;
  TransactionDetails({
    Key? key,
    required this.transaction,
    required this.contact,
    this.allTransaction,
  }) : super(key: key) {
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: TransactionDetails.routeName,
    );
  }

  @override
  State<TransactionDetails> createState() => _TransactionDetailsState();
}

class _TransactionDetailsState extends State<TransactionDetails> {
  final AppController appController = Get.find();

  @override
  void initState() {
    super.initState();
    loadAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  BannerAd? _bannerAd;

  bool _isLoaded = false;

  // TODO: replace this test ad unit with your own ad unit.
  final adUnitId = 'ca-app-pub-2816643402576603/1341969154';

  void loadAd() {
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            _isLoaded = true;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          // Dispose the ad here to free resources.
          ad.dispose();
        },
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (Ad ad) {},
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (Ad ad) {},
        // Called when an impression occurs on the ad.
        onAdImpression: (Ad ad) {},
      ),
    );
    _bannerAd!.load();
  }

  bool get isTransaction {
    if (widget.transaction == null) {
      return false;
    }

    return true;
  }

  bool get isTransactionDeclined {
    if (!isTransaction) {
      return false;
    }
    if (widget.transaction!.confirmation!.toLowerCase() != 'declined') {
      return false;
    }
    return true;
  }

  bool get isTransactionPending {
    if (!isTransaction) {
      return false;
    }
    if (widget.transaction!.paymentStatus.toLowerCase() != 'pending') {
      return false;
    }
    return true;
  }

  bool get isTransactionAuthCreated {
    if (!isTransaction) {
      return false;
    }
    if (widget.transaction!.tr_user_id != appController.user.id) {
      return false;
    }
    return true;
  }

  bool get isSms {
    if (widget.allTransaction == null) {
      return false;
    }
    if (widget.allTransaction!.smsBody == null) {
      return false;
    }
    return true;
  }

  bool get isNotAssignedSms {
    if (widget.allTransaction == null) {
      return false;
    }

    if (widget.transaction == null && widget.allTransaction!.smsBody != null) {
      return true;
    }

    return false;
  }

  bool get isAssignedSms {
    if (widget.allTransaction == null) {
      return false;
    }
    if (widget.allTransaction!.smsBody != null &&
        widget.allTransaction!.transactionId.hasValue) {
      return true;
    }

    return false;
  }

  bool get isTransactionOnly {
    if (widget.transaction != null && widget.allTransaction == null) {
      return true;
    }
    return false;
  }

  void removeSms() {
    appController.allTransactionController.remove(widget.allTransaction!.id!);
    if (context.mounted) {
      navigateBack();
    }
  }

  void popupMenuOnSelect(TransactionDetailsPopupMenuOptions option) {
    switch (option) {
      case TransactionDetailsPopupMenuOptions.removesms:
        removeSms();
        break;
    }
  }

  void navigateBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.transaction != null || widget.allTransaction != null);

    final Size size = MediaQuery.of(context).size;

    const Color backgroundColor = Colors.white;
    final Color themeColor = greenColor;

    const double padding = 18;
    final double width = size.width;

    String title = 'transaction_detail'.tr;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: buildPopupMenu(),
        centerTitle: true,
        backgroundColor: themeColor,
        title: Text(
          title,
          style: GoogleFonts.roboto(
            color: backgroundColor,
          ),
        ),
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: width,
            padding: const EdgeInsets.all(padding),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 7),
                  showSmsBody(),
                  const SizedBox(height: 15),
                  showTransactionDetailCard(),
                  const SizedBox(height: 10),
                  showTransactionEditButtons(),
                  const SizedBox(height: 10),
                  showSmsTransactionDetailCard(),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: showAd(),
          ),
        ],
      ),
    );
  }

  List<Widget> buildPopupMenu() {
    if (isSms) {
      return [
        PopupMenuButton<TransactionDetailsPopupMenuOptions>(
          onSelected: popupMenuOnSelect,
          itemBuilder: (BuildContext context) {
            return popupMenuItems();
          },
        ),
      ];
    } else {
      return [];
    }
  }

  Widget showAd() {
    if (!_isLoaded) {
      return Container();
    }

    return Container(
      // alignment: Alignment.bottomCenter,
      // height: MediaQuery.of(context).size.height,
      height: 60,
      child: AdWidget(ad: _bannerAd!),
    );
  }

  List<PopupMenuItem<TransactionDetailsPopupMenuOptions>> popupMenuItems() {
    TextStyle defaultStyle = GoogleFonts.roboto();

    return [
      PopupMenuItem<TransactionDetailsPopupMenuOptions>(
        value: TransactionDetailsPopupMenuOptions.removesms,
        child: Text(
          'Remove SMS',
          style: defaultStyle,
        ),
      )
    ];
  }

  Widget showSmsBody() {
    if (isSms) {
      return SmsBodyView(
        alltransaction: widget.allTransaction!,
      );
    } else {
      return SizedBox();
    }
  }

  Widget showTransactionDetailCard() {
    if (isTransaction) {
      return TransactionDetailCard(
        transaction: widget.transaction!,
      );
    } else {
      return SizedBox();
    }
  }

  Widget showTransactionEditButtons() {
    if (!isTransaction) {
      return SizedBox();
    }
    bool showSettleUp = (!isTransactionDeclined && isTransactionPending);
    bool showDecline = (!isTransactionDeclined);

    return TransactionEditButtons(
      transaction: widget.transaction!,
      settleUpOption: showSettleUp,
      declineOption: showDecline,
    );
  }

  Widget showSmsTransactionDetailCard() {
    if (!isSms) {
      return SizedBox();
    } else {
      return SmsTransactionDetailCard(
        allTransaction: widget.allTransaction!,
      );
    }
  }
}

class TransactionEditButtons extends StatelessWidget {
  final TransactionsModel transaction;
  final bool settleUpOption;
  final bool declineOption;
  TransactionEditButtons({
    Key? key,
    required this.transaction,
    required this.settleUpOption,
    required this.declineOption,
  }) : super(key: key);

  final AppController appController = Get.find();

  @override
  Widget build(BuildContext context) {
    const Color buttonRedColor = Color(0xFFE52525);

    void settleup() async {
      var newTransaction = await Navigator.of(context).pushNamed(
        AddTransaction.routeName,
        arguments: {
          'contact': transaction.user.target,
          'transaction_id': transaction.id,
          'amount': int.parse(transaction.amount),
          'transaction_type':
              transaction.transactionType.toLowerCase() == 'lane'
                  ? TransactionType.Lane
                  : TransactionType.Dane,
          'payment_status': transaction.paymentStatus.toLowerCase() == 'pending'
              ? PaymentStatus.Pending
              : PaymentStatus.Done,
          'category_id': transaction.category.targetId,
        },
      );
      if (newTransaction != null && context.mounted) {
        Navigator.of(context).pop();
      }
    }

    void decline() async {
      try {
        await appController.updateTransactionStatus(
          transaction,
          Confirmation.Declined,
        );
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      } catch (err, stack) {
        FirebaseCrashlytics.instance.recordError(
          err,
          stack,
          fatal: false,
          printDetails: true,
          reason: 'Error occurred while updating transaction status',
          information: [
            transaction.id ?? 'No transaction found',
          ],
        );
      }
    }

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          settleUpOption
              ? SizedBox(
                  width: (constraints.maxWidth / 2) - 10,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: greenColor,
                      side: BorderSide(color: greenColor),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: settleup,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.edit,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'settle_up'.tr,
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox(),
          separate(),
          declineOption
              ? SizedBox(
                  width: (constraints.maxWidth / 2) - 10,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: buttonRedColor,
                      side: const BorderSide(color: buttonRedColor),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: decline,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.horizontal_rule,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'decline'.tr,
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox(height: 10),
        ],
      );
    });
  }

  Widget separate() {
    if (settleUpOption && declineOption) {
      return SizedBox(width: 10);
    } else {
      return SizedBox();
    }
  }
}

class TransactionDetailCard extends StatelessWidget {
  final TransactionsModel transaction;
  const TransactionDetailCard({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color accentColor = Color(0x99000000);
    final Color amountTextColor = lightGreenColor;

    const double borderWidth = 0.5;
    const double borderRadius = 18;
    const double nameFontSize = 22;
    const double amountFontSize = 32;

    final String payableAmount = '₹ ${transaction.amount}  ';
    final String createdAtValue = transaction.createdAt.toTimeDDMMMMYYYY;
    final String updatedAtValue = transaction.updatedAt!.toTimeDDMMMMYYYY;
    final String typeValue = transaction.transactionType.toLowerCase().tr;
    final String paymentStatusValue =
        transaction.paymentStatus.toLowerCase().tr;
    final String confirmationValue =
        (transaction.confirmation ?? 'pending').toLowerCase().tr;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(borderRadius)),
        border: Border.all(color: accentColor, width: borderWidth),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          profilePicture(),
          const SizedBox(height: 10),
          Text(
            transaction.user.target!.full_name!,
            style: GoogleFonts.roboto(
              fontSize: nameFontSize,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(
            color: Colors.black,
            thickness: 0.5,
          ),
          const SizedBox(height: 10),
          Text(
            payableAmount,
            style: GoogleFonts.roboto(
              color: amountTextColor,
              fontSize: amountFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Column(
            children: [
              detailRow(
                'transaction_type'.tr,
                typeValue,
              ),
              detailRow(
                'payment_status'.tr,
                paymentStatusValue,
              ),
              detailRow(
                'confirmation'.tr,
                confirmationValue,
              ),
              showCategory(),
              showDueDate(),
              detailRow(
                'created_at'.tr,
                createdAtValue,
              ),
              detailRow(
                'updated_at'.tr,
                updatedAtValue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget showDueDate() {
    if (transaction.paymentStatus.toLowerCase() != 'pending'.tr.toLowerCase()) {
      return SizedBox();
    } else {
      return detailRow(
        'due_date'.tr,
        transaction.dueDate?.digitOnlyDate() ?? 'No Due Date',
      );
    }
  }

  Widget showCategory() {
    if (!transaction.category.hasValue) {
      return SizedBox();
    } else {
      return detailRow(
        'transaction_for'.tr,
        transaction.category.target!.message,
      );
    }
  }

  Widget profilePicture() {
    return ProfilePicture(
      name: transaction.user.target!.full_name!,
      radius: 60,
      fontsize: 60,
    );
  }

  Widget detailRow(String label, String data) {
    const double cellPadding = 10;
    const double tableFontSize = 12;

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Row(
        children: [
          Container(
            width: constraints.maxWidth / 2,
            padding: const EdgeInsets.symmetric(
              vertical: cellPadding,
              horizontal: cellPadding,
            ),
            child: Text(
              label,
              textAlign: TextAlign.end,
              style: GoogleFonts.roboto(
                fontSize: tableFontSize,
              ),
            ),
          ),
          Container(
            width: constraints.maxWidth / 2,
            padding: const EdgeInsets.symmetric(
              vertical: cellPadding,
              horizontal: cellPadding,
            ),
            child: Text(
              data,
              textAlign: TextAlign.start,
              style: GoogleFonts.roboto(
                fontSize: tableFontSize,
              ),
            ),
          ),
        ],
      );
    });
  }
}

class SmsBodyView extends StatelessWidget {
  final AllTransactionObjectBox alltransaction;
  const SmsBodyView({
    Key? key,
    required this.alltransaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color accentColor = Color(0x99000000);

    const double borderWidth = 0.5;
    const double borderRadius = 18;

    return Container(
      height: Get.height * 0.20,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(borderRadius)),
        border: Border.all(color: accentColor, width: borderWidth),
      ),
      child: Text(
        alltransaction.smsBody ?? 'Failed to save SMS from this transaction',
        style: GoogleFonts.roboto(
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class SmsTransactionDetailCard extends StatefulWidget {
  final AllTransactionObjectBox allTransaction;
  const SmsTransactionDetailCard({
    Key? key,
    required this.allTransaction,
  }) : super(key: key);

  @override
  State<SmsTransactionDetailCard> createState() =>
      _SmsTransactionDetailCardState();
}

class _SmsTransactionDetailCardState extends State<SmsTransactionDetailCard> {
  Future<dynamic> navigateToSelectContact() async {
    if (context.mounted) {
      dynamic response = await Navigator.of(context)
          .pushNamed(SelectContact.routeName, arguments: {
        'list_groups': true,
      });
      return response;
    } else {
      return null;
    }
  }

  void navigateToAddTransaction(Users user) {
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed(
        AddTransaction.routeName,
        arguments: {
          'contact': user,
          'all_transaction_id': widget.allTransaction.id,
          'amount': double.parse(
            widget.allTransaction.amount,
          ).toInt(),
          'transaction_type':
              widget.allTransaction.transactionType.toLowerCase() == 'debit'
                  ? TransactionType.Dane
                  : TransactionType.Lane,
        },
      );
    }
  }

  void navigateToAddGroupTransaction(Groups group) {
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed(
        AddGroupTransaction.routeName,
        arguments: {
          'group': group,
          'amount': double.parse(widget.allTransaction.amount).toInt(),
          'all_transaction_id': widget.allTransaction.id,
        },
      );
    }
  }

  Future<Groups?> navigateToCreateGroup(List<Users> userList) async {
    if (context.mounted) {
      dynamic group = await Navigator.of(context).pushNamed(
        CreateGroupScreen.routeName,
        arguments: {
          'user_list': userList,
        },
      );
      return group;
    } else {
      return null;
    }
  }

  Future<void> createTransactionForSms() async {
    dynamic response = await navigateToSelectContact();
    if (response.runtimeType == Users) {
      navigateToAddTransaction(response);
    }
    if (response.runtimeType == Groups) {
      navigateToAddGroupTransaction(response);
    }
    if (response.runtimeType == (List<Users>)) {
      Groups? group = await navigateToCreateGroup(response);
      if (group != null) {
        navigateToAddGroupTransaction(group);
      }
    }
  }

  Color amountColor() {
    if (widget.allTransaction.transactionType.toLowerCase() == 'credit') {
      return laneColor;
    } else {
      return daneColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    const double borderRadius = 18;
    const Color accentColor = Color(0x99000000);
    final Color amountTextColor = amountColor();

    const double borderWidth = 0.5;
    const double nameFontSize = 22;
    const double amountFontSize = 32;
    const double tableFontSize = 12;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(borderRadius)),
        border: Border.all(color: accentColor, width: borderWidth),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: Get.height * 0.042),
          Text(
            '₹ ${widget.allTransaction.amount}',
            style: GoogleFonts.roboto(
              color: amountTextColor,
              fontSize: amountFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.allTransaction.createdAt.toTimeDDMMMMYYYY,
            textAlign: TextAlign.end,
            style: GoogleFonts.roboto(
              fontSize: tableFontSize,
            ),
          ),
          SizedBox(height: Get.height * 0.03),
          const Divider(
            color: Colors.black,
            thickness: 0.5,
          ),
          SizedBox(height: Get.height * 0.09),
          showCreateTransactionButton(),
          const SizedBox(height: 10),
          Text(
            'record_transaction'.tr,
            style: GoogleFonts.roboto(
              fontSize: nameFontSize,
            ),
          ),
          SizedBox(
            height: Get.height * 0.09,
          )
        ],
      ),
    );
  }

  Widget showCreateTransactionButton() {
    return FloatingActionButton(
      backgroundColor: greenColor,
      onPressed: createTransactionForSms,
      child: const Icon(
        Icons.add,
      ),
    );
  }
}
