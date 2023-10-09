import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lane_dane/app_controller.dart';
import 'package:lane_dane/controllers/category_controller.dart';
import 'package:lane_dane/models/group_model.dart';
import 'package:lane_dane/models/group_transaction.dart';
import 'package:lane_dane/models/users.dart';
import 'package:lane_dane/utils/colors.dart';
import 'package:lane_dane/views/pages/transaction/filter_group_transaction_participants.dart';
import 'package:lane_dane/views/widgets/amount_field.dart';
import 'package:lane_dane/models/categories_model.dart';
import 'package:lane_dane/utils/log_printer.dart';
import 'package:lane_dane/views/widgets/cutom_toggle_button.dart';
import 'package:lane_dane/views/pages/addCategorySearchDelegate.dart';
import 'package:lane_dane/views/widgets/date_selector.dart';
import 'package:logger/logger.dart';

class AddGroupTransaction extends StatefulWidget {
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
  static const String routeName = 'add-group-transaction';

  final Groups group;
  final int? amount;
  final int? allTransactionId;

  const AddGroupTransaction({
    Key? key,
    required this.group,
    this.amount,
    this.allTransactionId,
  }) : super(key: key);

  @override
  State<AddGroupTransaction> createState() => _AddGroupTransactionState();
}

class _AddGroupTransactionState extends State<AddGroupTransaction> {
  final Logger log = getLogger('AddTransaction');
  AppController appController = Get.find();

  late final List<CategoriesModel> categories;
  late final TextEditingController amountController;
  late final DateController dueDateController;
  late final ValueNotifier<CategoriesModel?> categoryNotifier;
  late List<Users> selectedUserList;
  late Widget profilePicture;

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: AddGroupTransaction.routeName,
    );
    fetchCategories();

    amountController = TextEditingController();
    dueDateController = DateController();
    categoryNotifier = ValueNotifier(null);
    selectedUserList = [...widget.group.participants];
    profilePicture = ProfilePicture(
      name: widget.group.groupName,
      radius: 48,
      fontsize: 28,
      random: false,
    );

    if (widget.amount != null) {
      amountController.text = widget.amount.toString();
    }

    amountController.addListener(rebuild);
  }

  @override
  void dispose() {
    amountController.removeListener(rebuild);
    amountController.dispose();
    dueDateController.dispose();
    categoryNotifier.dispose();
    super.dispose();
  }

  void rebuild() {
    setState(() {});
  }

  void fetchCategories() {
    CategoryController controller = CategoryController();
    categories = [];
    categories.addAll(controller.retrieveAll());
  }

  void toggleUserSelection(Users u) {
    if (selectedUserList.contains(u)) {
      selectedUserList.remove(u);
    } else {
      selectedUserList.add(u);
    }
    setState(() {});
  }

  bool validateAmount() {
    if (amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Enter a valid amount', style: GoogleFonts.roboto()),
      ));
      return false;
    }
    int amount = double.parse(amountController.text).toInt();
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

  Future<void> addGroupTransaction() async {
    if (!validateAmount()) {
      return;
    }
    // dynamic selectedUsers = await Navigator.of(context)
    //     .pushNamed(FilterGroupTransactionParticipants.routeName, arguments: {
    //   'user_list': widget.group.participants,
    //   'amount': int.parse(amountController.text),
    // });

    if (selectedUserList.isEmpty) {
      return;
    }

    GroupTransaction groupTransaction = appController.createGroupTransaction(
      amount: int.parse(amountController.text),
      group: widget.group,
      participants: selectedUserList,
      allTransactionId: widget.allTransactionId,
      category: categoryNotifier.value,
    );

    if (mounted) {
      Navigator.of(context).pop(groupTransaction);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('add_group_transaction'.tr),
        backgroundColor: const Color(0xFF128C7E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addGroupTransaction,
        backgroundColor: lightGreenColor,
        child: const Icon(
          Icons.check,
        ),
      ),
      body: Builder(
        builder: (context) {
          return Container(
            width: size.width,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(left: 40, right: 40),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  profilePicture,
                  const SizedBox(height: 10),
                  Text(
                    widget.group.groupName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AmountField(controller: amountController),
                  const SizedBox(height: 30),
                  _addCategoryButton(context, categories, categoryNotifier),
                  const SizedBox(height: 30),
                  transactionDetails(
                    propertyLabel: 'transaction_type'.tr,
                    propertyValue: 'lane'.tr,
                  ),
                  const SizedBox(height: 20),
                  transactionDetails(
                    propertyLabel: 'payment_status'.tr,
                    propertyValue: 'pending'.tr,
                  ),
                  const SizedBox(height: 15),
                  ...participantList(),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget transactionDetails({
    required String propertyLabel,
    required String propertyValue,
  }) {
    return Row(
      children: [
        Flexible(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              propertyLabel,
              textAlign: TextAlign.left,
              style: GoogleFonts.roboto(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Flexible(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              propertyValue,
              textAlign: TextAlign.left,
              style: GoogleFonts.roboto(color: Colors.black, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> participantList() {
    int payableAmount = 0;

    if (amountController.text.isNotEmpty) {
      int amount = double.parse(amountController.text).toInt();
      payableAmount = amount ~/ (selectedUserList.length + 1);
    }

    List<Widget> participantListTiles = [
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: ProfilePicture(
          name: appController.user.fullName,
          fontsize: 18,
          random: false,
          radius: 24,
        ),
        title: Text(
          appController.user.fullName,
          style: GoogleFonts.roboto(),
        ),
        subtitle: Text(
          payableAmount.toString(),
          style: GoogleFonts.roboto(),
        ),
        trailing: Checkbox(
          activeColor: Colors.grey,
          value: true,
          onChanged: (_) {},
        ),
      ),
    ];

    for (int i = 0; i < widget.group.participants.length; i++) {
      Users u = widget.group.participants[i];

      bool userSelected() {
        return selectedUserList.any((Users user) {
          return user.id == u.id;
        });
      }

      void checkToggled(bool? val) {
        toggleUserSelection(u);
      }

      bool selected = userSelected();

      participantListTiles.add(ListTile(
        contentPadding: EdgeInsets.zero,
        leading: ProfilePicture(
          name: u.full_name!,
          fontsize: 18,
          random: false,
          radius: 24,
        ),
        title: Text(
          u.full_name!,
          style: GoogleFonts.roboto(),
        ),
        subtitle: Text(
          selected ? payableAmount.toString() : '0',
          style: GoogleFonts.roboto(),
        ),
        trailing: Checkbox(
          value: selected,
          onChanged: checkToggled,
        ),
      ));
    }
    return participantListTiles;
  }
}

Widget _addCategoryButton(
  BuildContext context,
  List<CategoriesModel> _categories,
  ValueNotifier<CategoriesModel?> _categorySelected,
) {
  return InkWell(
    onTap: () async {
      CategoriesModel? value = await showSearch<CategoriesModel?>(
        context: context,
        delegate: addCategorySearchDelegate(
          categoryModel: _categories,
        ),
      );

      if (value != null) {
        _categorySelected.value = value;
      }
    },
    child: SizedBox(
      height: 50,
      width: 230,
      child: Card(
        color: Colors.white70,
        child: Center(
          child: ValueListenableBuilder(
            valueListenable: _categorySelected,
            builder:
                (BuildContext context, CategoriesModel? value, Widget? child) {
              String selectedVal = 'add_category'.tr;
              if (_categorySelected.value != null) {
                selectedVal = _categorySelected.value!.message;
              }
              return Text(selectedVal);
            },
          ),
        ),
      ),
    ),
  );
}
