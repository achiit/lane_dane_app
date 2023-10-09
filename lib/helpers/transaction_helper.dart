import 'dart:async';
import 'package:get/get.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:lane_dane/api/transaction_services.dart';
import 'package:lane_dane/app_controller.dart';
import 'package:lane_dane/errors/unauthorized_error.dart';
import 'package:lane_dane/models/group_transaction.dart';
import 'package:lane_dane/models/transactions.dart';
import 'package:lane_dane/models/all_transaction.dart';
import 'package:lane_dane/models/user_group_entity.dart';
import 'package:lane_dane/models/users.dart';
import 'package:lane_dane/models/categories_model.dart';
import 'package:lane_dane/utils/activity_amount.dart';
import 'package:lane_dane/utils/string_extensions.dart';

extension TransactionHelper on AppController {
  // Future<void> loadSmsTransactions() async {
  //   if (permissions.smsReadPermission) {
  //     List<AllTransactionObjectBox> smsTransactionList =
  //         await smsControllerConcurrentEngine.getAndStoreSms();
  //     log.d('sms loaded');
  //   }
  // }

  TransactionsModel createTransaction({
    required String amount,
    required Users contact,
    required String transactionType,
    required String paymentStatus,
    String? transactionStatus,
    CategoriesModel? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    int? existingAllTransactionId,
  }) {
    TransactionsModel transaction = transactionController.addSingleTransaction(
      amount: amount,
      category: category,
      targetUser: contact,
      paymentStatus: paymentStatus,
      tr_user_id: user.id,
      lane_user_id: transactionType.toLowerCase() ==
              TransactionType.Lane.name.toString().toLowerCase()
          ? user.id
          : contact.serverId,
      dane_user_id: transactionType.toLowerCase() ==
              TransactionType.Dane.name.toString().toLowerCase()
          ? user.id
          : contact.serverId,
      confirmation: Confirmation.Requested.name,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      dueDate: dueDate,
      settleTransactionId: null,
    );

    AllTransactionObjectBox allTransaction =
        allTransactionController.updateOrCreate(
      id: existingAllTransactionId,
      transactionId: transaction.id,
      smsBody: null,
      amount: transaction.amount,
      name: transaction.user.target!.full_name!,
      createdAt: transaction.createdAt.toString(),
      transactionType: transaction.transactionType,
    );

    UserGroupEntity usergroup = usergroupController.updateOrCreate(
      entityId: contact.id!,
      amount: resolveAmountForActivity(
        int.parse(amount),
        transactionType,
        paymentStatus,
        Confirmation.Requested.name,
      ),
      name: contact.full_name!,
      type: UserGroupEntityType.user,
      lastActivityTime: transaction.updatedAt,
    );

    addTransactionInRemote(transaction, contact);

    return transaction;
  }

  Future<void> updateTransactionStatus(
      TransactionsModel transaction, Confirmation confirmation) async {
    try {
      TransactionServices services = TransactionServices();

      if (confirmation == Confirmation.Accepted) {
        transactionController.acceptTransaction(transaction);
      } else if (confirmation == Confirmation.Declined) {
        transactionController.declineTransaction(transaction);
      }

      await services.remoteConfirmTransaction(transaction, confirmation);

      UserGroupEntity usergroup = usergroupController.updateOrCreate(
        entityId: transaction.user.target!.id!,
        amount: resolveAmountForActivity(
            int.parse(transaction.amount),
            transaction.transactionType,
            transaction.paymentStatus,
            transaction.confirmation!),
        name: transaction.user.target!.full_name!,
        type: UserGroupEntityType.user,
        lastActivityTime: transaction.updatedAt,
      );
    } catch (err) {
      transactionController.resetConfirmationStatus(transaction);
      rethrow;
    }
  }

  Future<void> addTransactionInRemote(
    TransactionsModel transaction,
    Users contact,
  ) async {
    try {
      TransactionServices services = TransactionServices();
      Map<String, dynamic> serverResponse = await services
          .remoteAddTransaction(
        transaction,
        contact,
      )
          .onError(
        (err, stack) {
          Timer(const Duration(minutes: 5), () {
            addTransactionInRemote(transaction, contact);
          });
          return {};
        },
      );

      TransactionsModel parsedTransaction =
          transactionFromServerResponse(serverResponse['transaction']);
      AllTransactionObjectBox allTransaction =
          allTransactionController.retrieveOnlyTransactionModelId(transaction)!;
      allTransactionController.updateTransaction(allTransaction,
          transactionId: parsedTransaction.id!);
      transactionController.deleteTransaction(transaction.id!);
    } catch (err, stacktrace) {
      FirebaseCrashlytics.instance.recordError(err, stacktrace);
    }
  }

  TransactionsModel transactionFromServerResponse(
    Map<String, dynamic> transactionMap,
  ) {
    Users contact = user.id == transactionMap['lane_user_id']
        ? Users.fromMap(transactionMap['dane_user'])
        : Users.fromMap(transactionMap['lane_user']);
    TransactionsModel transaction = TransactionsModel.fromMap(transactionMap);

    Map<String, dynamic> laneUser = transactionMap['lane_user'];
    Map<String, dynamic> daneUser = transactionMap['dane_user'];

    Map<String, dynamic> targetUserMap =
        laneUser['id'] == user.id ? daneUser : laneUser;

    Map<String, dynamic>? categoryMap = transactionMap['category'];

    Users targetUser = userController.updateOrCreate(
      serverId: targetUserMap['id'],
      fullName: targetUserMap['full_name'] ?? transactionMap['fallback_name'],
      phoneNumber: targetUserMap['phone_no'].toString().phoneNumber,
      onBoardedAt: targetUserMap['onboarded_at'] != null
          ? DateTime.parse(targetUserMap['onboarded_at'])
          : null,
    );

    CategoriesModel? category;
    if (categoryMap != null) {
      category = categoryController.updateOrCreate(
        id: transaction.category.target?.id,
        serverId: categoryMap['id'],
        message: categoryMap['name'],
      );
    }

    GroupTransaction? groupTransaction;
    if (transactionMap['group_transaction_id'] != null) {
      groupTransaction =
          groupTransactionController.retrieveGroupTransactionFromServerId(
        serverId: transactionMap['group_transaction_id'],
      );
    }

    String fallbackDate = DateTime.now().toString();
    TransactionsModel updatedTransaction = transactionController.updateOrCreate(
      id: transaction.id,
      serverId: transactionMap['id'],
      trUserId: transactionMap['user_id'],
      laneUserId: laneUser['id'],
      daneUserId: daneUser['id'],
      amount: double.parse(transactionMap['amount'].toString()).toInt(),
      paymentStatus: transactionMap['payment_status'],
      confirmation: transactionMap['confirmation'],
      user: targetUser,
      category: category,
      createdAt: DateTime.parse(transactionMap['created_at'] ?? fallbackDate),
      updatedAt: DateTime.parse(transactionMap['updated_at'] ?? fallbackDate),
      dueDate: transactionMap['due_date'] != null
          ? DateTime.parse(transactionMap['due_date'])
          : null,
      settleTransactionId: transactionMap['settle_transaction_id'],
      groupTransactionId: groupTransaction?.id,
    );

    return updatedTransaction;
  }

  Future<void> retrieveTransactionsFromServer() async {
    TransactionServices services = TransactionServices();
    DateTime lastUpdate = localstore.retrieveLastTransactionTime();

    List<dynamic> transactionMapList = [];
    try {
      transactionMapList = await services.getRemoteTransactions(lastUpdate);
    } on UnauthorizedError {
      logout();
      Get.snackbar(
          'Session timeout', 'Please log in again to keep using the app');
    } catch (err, stack) {
      FirebaseCrashlytics.instance.recordError(
        err,
        stack,
        fatal: false,
        printDetails: true,
        reason: 'Failed to retrieve transactions from the server',
        information: [],
      );
    }

    for (Map<String, dynamic> transactionMap in transactionMapList) {
      try {
        if (transactionMap['deleted_at'] != null) {
          TransactionsModel? transactionToDelete = transactionController
              .retrieveServerIdTransaction(transactionMap['id']);
          if (transactionToDelete != null) {
            int deletedAllTransactionId = allTransactionController
                .deleteAllTransactionWithTransactionId(transactionToDelete.id!);
            transactionController.deleteTransaction(transactionToDelete.id!);
          }
          continue;
        }

        TransactionsModel newTransaction =
            transactionFromServerResponse(transactionMap);

        AllTransactionObjectBox allTransaction =
            allTransactionController.updateOrCreate(
          transactionId: newTransaction.id,
          amount: newTransaction.amount,
          name: newTransaction.user.target?.full_name ??
              transactionMap['fallback_name'],
          transactionType: newTransaction.transactionType,
          createdAt: newTransaction.createdAt.toString(),
          updatedAt: newTransaction.updatedAt.toString(),
        );

        UserGroupEntity usergroup = usergroupController.updateOrCreate(
          entityId: newTransaction.user.target!.id!,
          amount: resolveAmountForActivity(
            int.parse(newTransaction.amount),
            newTransaction.transactionType,
            newTransaction.paymentStatus,
            newTransaction.confirmation!,
          ),
          name: newTransaction.user.target!.full_name!,
          type: UserGroupEntityType.user,
          lastActivityTime: newTransaction.updatedAt,
        );

        lastUpdate = newTransaction.updatedAt ?? newTransaction.createdAt;
      } catch (err) {
        log.e(err);
        continue;
      }
    }
    localstore.updateLastTransactionTime(lastUpdate);
  }

  TransactionsModel settleTransaction({
    required String amount,
    required Users contact,
    required String transactionType,
    required String paymentStatus,
    String? transactionStatus,
    CategoriesModel? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    required int existingTransactionId,
  }) {
    TransactionsModel transaction = transactionController.addSingleTransaction(
      amount: amount,
      category: category,
      targetUser: contact,
      paymentStatus: paymentStatus,
      tr_user_id: user.id,
      lane_user_id: transactionType.toLowerCase() ==
              TransactionType.Lane.name.toString().toLowerCase()
          ? user.id
          : contact.serverId,
      dane_user_id: transactionType.toLowerCase() ==
              TransactionType.Dane.name.toString().toLowerCase()
          ? user.id
          : contact.serverId,
      confirmation: Confirmation.Requested.name,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      settleTransactionId: existingTransactionId,
    );

    AllTransactionObjectBox allTransaction =
        allTransactionController.updateOrCreate(
      id: null,
      transactionId: transaction.id,
      smsBody: null,
      amount: transaction.amount,
      name: transaction.user.target!.full_name!,
      createdAt: transaction.createdAt.toString(),
      transactionType: transaction.transactionType,
    );

    remoteSettleTransaction(transaction, existingTransactionId);

    UserGroupEntity usergroup = usergroupController.updateOrCreate(
      entityId: transaction.user.target!.id!,
      amount: resolveAmountForActivity(
        int.parse(amount),
        transactionType,
        paymentStatus,
        Confirmation.Requested.name,
      ),
      name: transaction.user.target!.full_name!,
      type: UserGroupEntityType.user,
      lastActivityTime: transaction.updatedAt,
    );

    return transaction;
  }

  void remoteSettleTransaction(
    TransactionsModel transaction,
    int exsitingTransactionId,
  ) async {
    try {
      TransactionServices services = TransactionServices();
      Map<String, dynamic> serverResponse = await services.settleUpTransaction(
        transaction,
        exsitingTransactionId,
      );

      TransactionsModel parsedTransaction =
          transactionFromServerResponse(serverResponse);
      AllTransactionObjectBox allTransaction =
          allTransactionController.retrieveOnlyTransactionModelId(transaction)!;
      allTransactionController.updateTransaction(allTransaction,
          transactionId: parsedTransaction.id!);
      transactionController.deleteTransaction(transaction.id!);
    } catch (err, stacktrace) {
      FirebaseCrashlytics.instance.recordError(err, stacktrace);
    }
  }

  Future<void> resendFailedTransactions() async {
    List<TransactionsModel> unsentTransactions =
        transactionController.getUnsentTransactions();

    for (int i = 0; i < unsentTransactions.length; i++) {
      try {
        TransactionsModel t = unsentTransactions[i];
        Users u = t.user.target!;
        addTransactionInRemote(t, u);
      } catch (err, stacktrace) {
        FirebaseCrashlytics.instance.recordError(err, stacktrace);
        continue;
      }
    }
  }
}
