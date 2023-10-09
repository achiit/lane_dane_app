import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lane_dane/app_controller.dart';
import 'package:lane_dane/controllers/category_controller.dart';
import 'package:lane_dane/errors/unauthorized_error.dart';
import 'package:lane_dane/helpers/local_store.dart';
import 'package:lane_dane/models/transactions.dart';
import 'package:lane_dane/utils/colors.dart';
import 'package:lane_dane/utils/constants.dart';
import 'package:lane_dane/views/widgets/add_transaction_helper_text.dart';
import 'package:lane_dane/views/widgets/amount_field.dart';

import 'package:lane_dane/models/categories_model.dart';
import 'package:lane_dane/models/users.dart';
import 'package:lane_dane/utils/log_printer.dart';
import 'package:lane_dane/views/shared/snack-bar.dart';
import 'package:lane_dane/views/widgets/cutom_toggle_button.dart';
import 'package:lane_dane/views/pages/addCategorySearchDelegate.dart';
import 'package:lane_dane/api/whatsapp.dart';
import 'package:lane_dane/views/widgets/date_selector.dart';
import 'package:logger/logger.dart';

import '../../../helpers/cache_storage_helper.dart';
import '../../../helpers/in_app_review_helper.dart';

class AddTransaction extends StatefulWidget {
  /// Add transaction screen where the auth user can create new transactions.
  /// Only the target contact is required, while all other fields are optional.
  ///
  /// Pass arguments to the screen as follows:
  /// ```dart
  /// {
  ///   'contact': (Users),
  ///   'all_transaction_id': (int),
  ///   'transaction_id': (int),
  ///   'amount': (int),
  ///   'transaction_type': (TransactionType),
  ///   'payment_status': (PaymentStatus),
  ///   'category_id': (int),
  /// }
  /// ```
  /// when navigating using named routes. Here the ['contact'] is the user for
  /// whom the transaction will be created. ['all_transaction_id'] is the id of
  /// the existing all transaction entry that will reference the transaction
  /// that will be created. ['transaction_id'] is the id of an existing
  /// transaction that indicating that the screen is in edit mode instead of
  /// create transaction  mode.['amount'] is the default amount to be entered
  /// into the amount field when the screen renders. ['transaction_type'] is the
  /// default transaction type selection that is to be set when the screen
  /// renders. ['payment_status'] is the default payment status option that
  /// will be selected when the screen renders. ['category_id'] is the default
  /// category that will be selected when the screen renders. Only ['contact']
  /// required, while all other fields can be skipped.
  static const String routeName = 'add-transaction-screen';

  final Users contact;
  final int? allTransactionId;
  final int? transactionId;
  final int? amount;
  final TransactionType? transactionType;
  final PaymentStatus? paymentStatus;
  final int? categoryId;

  const AddTransaction({
    Key? key,
    required this.contact,
    this.allTransactionId,
    this.transactionId,
    this.amount,
    this.transactionType,
    this.paymentStatus,
    this.categoryId,
  }) : super(key: key);

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  final Logger log = getLogger('AddTransaction');
  AppController appController = Get.find();

  late final TextEditingController _amountController;
  late final DateController dueDateController;
  late final List<CategoriesModel> _categories;
  late final ValueNotifier<CategoriesModel?> _categorySelected;
  late final ValueNotifier<String> transactionType;
  late final ValueNotifier<String> paymentStatus;
  late Widget profilePicture;
  int _counterForTrackingNumberOfTransactionsCreated = 0;

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: AddTransaction.routeName,
    );
    fetchCategories();

    _amountController = TextEditingController();
    dueDateController = DateController();
    _categorySelected = ValueNotifier(null);
    transactionType = ValueNotifier(
      widget.transactionType?.name ?? TransactionType.Lane.name,
    );
    paymentStatus = ValueNotifier(
      widget.paymentStatus?.name ?? PaymentStatus.Pending.name,
    );

    if (widget.categoryId != null) {
      _categorySelected.value =
          CategoryController().retrieve(widget.categoryId!);
    }

    _amountController.text = widget.amount?.toString() ?? '';
    profilePicture = ProfilePicture(
      name: widget.contact.full_name!,
      radius: 48,
      fontsize: 28,
      random: true,
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    dueDateController.dispose();
    transactionType.dispose();
    paymentStatus.dispose();
    super.dispose();
  }

  // final List<String> transactionTypeList = [
  //   TransactionType.Lane.name,
  //   TransactionType.Dane.name,
  // ];

  // final List<String> paymentStatusList = [
  //   PaymentStatus.Done.name,
  //   PaymentStatus.Pending.name,
  // ];

  // ! DUMMY for now later to be fetched from server
  void fetchCategories() {
    CategoryController controller = CategoryController();
    _categories = [];
    _categories.addAll(controller.retrieveAll());
  }

  bool validateAmount() {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Enter a valid amount', style: GoogleFonts.roboto()),
      ));
      return false;
    }
    int amount = double.parse(_amountController.text).toInt();
    if (amount.isNegative) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Amount cannot be negative', style: GoogleFonts.roboto()),
      ));
      return false;
    }
    if (amount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('Amount cannot be less than one', style: GoogleFonts.roboto()),
      ));
      return false;
    }
    return true;
  }

  Future<void> addSmsTnx() async {
    // final user = await _storageHelper.user();
    // print(user['id']);

    // * We have the amount -> So update the AllTransaction Table
    // TODO Add it to Transaction Table

    if (!validateAmount()) {
      return;
    }

    appController.createTransaction(
      amount: _amountController.text,
      contact: widget.contact,
      paymentStatus: paymentStatus.value,
      transactionType: transactionType.value,
      category: _categorySelected.value,
      createdAt: DateTime.now(),
      existingAllTransactionId: widget.allTransactionId,
      updatedAt: DateTime.now(),
    );
  }

  Future<TransactionsModel?> addPersonalTnx() async {
    // * We don't have the amount -> So add the Transaction to Transaction Table
    if (!validateAmount()) {
      return null;
    }

    log.d('TransacitonValue: ${transactionType.value}');

    TransactionsModel transaction = appController.createTransaction(
      amount: _amountController.text,
      contact: widget.contact,
      paymentStatus: paymentStatus.value,
      transactionType: transactionType.value,
      category: _categorySelected.value,
      createdAt: DateTime.now(),
      existingAllTransactionId: widget.allTransactionId,
      updatedAt: DateTime.now(),
      dueDate: dueDateController.date,
    );

    final res = await WhatsappHelper().send(
      context: context,
      phone: int.parse(widget.contact.phoneWithCode),
      message: 'new_transaction_message'.trParams({
            'name': appController.user.fullName,
            'amount': _amountController.text,
          }) +
          (!widget.contact.userRegistered()
              ? 'invite_prompt'.trParams({
                  'link': Constants.appLink,
                })
              : ''),
    );
    // '${appController.user.fullName} is inviting you to confirm transaction of amount \u{20B9}${_amountController.text} on the LaneDane app. ${widget.contact.serverId.isNegative ? "Download the app from link below. \n${Constants.appLink}" : ''}');
    log.e(res);

    return transaction;
  }

  TransactionsModel settleTransaction() {
    TransactionsModel transaction =
        appController.transactionController.retrieveOnly(
      widget.transactionId!,
    )!;

    if (transaction.serverId! < 1) {
      Get.showSnackbar(
        const GetSnackBar(
          title: 'Invalid Transaction',
          message:
              'This transaction may have failed to sync on the server. Try again later',
        ),
      );
      throw transaction.serverId!;
    }

    TransactionsModel newTransaction = appController.settleTransaction(
      amount: _amountController.text,
      contact: widget.contact,
      paymentStatus: paymentStatus.value,
      transactionType: transactionType.value,
      category: _categorySelected.value,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      existingTransactionId: transaction.serverId!,
    );

    transaction =
        appController.transactionController.declineTransaction(transaction);

    return newTransaction;
  }

  void _saveCounterVariableToCache() {
    final LocalStore store = appController.localstore;
    int transactionsCreatedCounter = store.retrieveTransactionsCreatedCounter();
    transactionsCreatedCounter++;
    store.updateTransactionsCreatedCounter(transactionsCreatedCounter);
    log.d('Cached Data: $transactionsCreatedCounter');
    _counterForTrackingNumberOfTransactionsCreated = transactionsCreatedCounter;
    // call setState and set the recieved value to the counter variable
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    void submit() async {
      try {
        if (widget.allTransactionId != null) {
          await addSmsTnx();
          Navigator.of(context).pop();
        } else if (widget.transactionId != null) {
          TransactionsModel transaction = settleTransaction();
          Navigator.of(context).pop(transaction);
        } else {
          final TransactionsModel? transactionData = await addPersonalTnx();
          // Lets keep a counter here
          _saveCounterVariableToCache();

          if (_counterForTrackingNumberOfTransactionsCreated == 5) {
            // TODO: Show the user a dialog to rate the app
            // InAppReviewHelper().requestReview();
            InAppReviewHelper().openStoreListing();
          }
          if (transactionData != null && mounted) {
            Navigator.of(context).pop(transactionData);
          }
          // Navigator.of(context). /*pushNamedAndRemoveUntil*/
          //     pushReplacementNamed(
          //   PersonalTransactions.routeName,
          //   arguments: {
          //     // 'transaction': transactionData['trasnsacitonObject'],
          //     'contact': widget.contact
          //   },
          // );
        }
      } on UnauthorizedError {
        appController.logout();
      } catch (err, stack) {
        switch (err) {
          case 'MISSING_AMOUNT':
            showSnackBar(context, 'Enter the amount');
            break;
          default:
            FirebaseCrashlytics.instance.recordError(
              err,
              stack,
              fatal: false,
              printDetails: true,
              reason: 'Failed to add transaction',
              information: [
                _amountController.text,
                _categorySelected.value?.message ?? 'no category selected',
                transactionType.value,
                paymentStatus.value,
              ],
            );
            showSnackBar(context, 'Unknown Error');
        }
      }
    }

    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text('add_transaction'.tr),
        backgroundColor: const Color(0xFF128C7E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: submit,
        backgroundColor: lightGreenColor,
        child: const Icon(
          Icons.check,
        ),
      ),
      persistentFooterAlignment: AlignmentDirectional.bottomCenter,
      body: Builder(
        builder: (context) {
          return Container(
            height: size.height -
                MediaQuery.of(context).viewInsets.top -
                Scaffold.of(context).appBarMaxHeight!,
            width: size.width,
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 40),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  const SizedBox(height: 10),
                  profilePicture,
                  const SizedBox(height: 10),
                  Text(
                    widget.contact.full_name!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AmountField(controller: _amountController),
                  const SizedBox(height: 30),
                  _addCategoryButton(context, _categories, _categorySelected),
                  const SizedBox(height: 30),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'transaction_type'.tr,
                      textAlign: TextAlign.left,
                      style:
                          GoogleFonts.roboto(color: Colors.black, fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 10),
                  CustomToggleButtons(
                    initialSelection: transactionType.value,
                    options:
                        TransactionType.values.map<String>((TransactionType t) {
                      return t.name.toLowerCase().tr;
                    }).toList(),
                    onSelect: (int index) {
                      transactionType.value =
                          TransactionType.values[index].name;
                      log.d(transactionType.value);
                    },
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'payment_status'.tr,
                      textAlign: TextAlign.left,
                      style:
                          GoogleFonts.roboto(color: Colors.black, fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 10),
                  PaymentStatusSelection(
                    paymentStatus: paymentStatus,
                    dateController: dueDateController,
                  ),
                  const SizedBox(height: 15),
                  AddTransactionHelperText(
                    amountController: _amountController,
                    paymentStatusNotifier: paymentStatus,
                    transactionTypeNotifier: transactionType,
                    dateController: dueDateController,
                    user: widget.contact,
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class PaymentStatusSelection extends StatefulWidget {
  final ValueNotifier paymentStatus;
  final DateController dateController;
  const PaymentStatusSelection({
    Key? key,
    required this.paymentStatus,
    required this.dateController,
  }) : super(key: key);

  @override
  State<PaymentStatusSelection> createState() => _PaymentStatusSelectionState();
}

class _PaymentStatusSelectionState extends State<PaymentStatusSelection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomToggleButtons(
          initialSelection: widget.paymentStatus.value,
          options: PaymentStatus.values.map<String>((PaymentStatus s) {
            return s.name.toLowerCase().tr;
          }).toList(),
          onSelect: (int index) {
            setState(() {
              widget.paymentStatus.value = PaymentStatus.values[index].name;
              if (widget.paymentStatus.value.toLowerCase() == 'done') {
                widget.dateController.date = null;
              }
            });
          },
        ),
        const SizedBox(height: 15),
        widget.paymentStatus.value.toLowerCase() == 'pending'
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'due_date'.tr,
                      textAlign: TextAlign.left,
                      style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  CalendarIcon(
                    size: 24,
                    dateController: widget.dateController,
                  ),
                ],
              )
            : Container(),
        // SizedBox(
        //     height:
        //         widget.paymentStatus.value.toLowerCase() == 'pending' ? 10 : 0),
        widget.paymentStatus.value.toLowerCase() == 'pending'
            ? DateInputField(
                dateController: widget.dateController,
              )
            : Container(),
      ],
    );
  }
}

Widget _addCategoryButton(
  BuildContext context,
  List<CategoriesModel> categories,
  ValueNotifier<CategoriesModel?> categorySelected,
) {
  return InkWell(
    onTap: () async {
      CategoriesModel? value = await showSearch<CategoriesModel?>(
        context: context,
        delegate: addCategorySearchDelegate(
          categoryModel: categories,
        ),
      );

      if (value != null) {
        categorySelected.value = value;
        // if (!_categories.contains(value.message)) {
        //   final cat = CategoriesModel(message: value.message);
        //   _categories.add(cat);
        //   // log.i('_categories length after: ${_categories.length}');
        // }
      }
      // log.i('_categories length before: ${_categories.length}');
    },
    child: SizedBox(
      height: 50,
      width: 230,
      child: Card(
        color: Colors.white70,
        child: Center(
          child: ValueListenableBuilder(
            valueListenable: categorySelected,
            builder:
                (BuildContext context, CategoriesModel? value, Widget? child) {
              String selectedVal = 'add_category'.tr;
              if (categorySelected.value != null) {
                selectedVal = categorySelected.value!.message;
              }
              return Text(selectedVal);
            },
          ),
        ),
      ),
    ),
  );
}
