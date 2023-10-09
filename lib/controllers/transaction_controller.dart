// import 'dart:isolate';

import 'package:lane_dane/api/transaction_services.dart';
import 'package:lane_dane/models/categories_model.dart';
import 'package:lane_dane/models/transactions.dart';
import 'package:lane_dane/utils/log_printer.dart';
import 'package:logger/logger.dart';

import '../main.dart';
import '../objectbox.g.dart';
import '../models/users.dart';

class TransactionController {
  static final transactionBox = OBJECTBOX.store.box<TransactionsModel>();
  Logger log = getLogger('transaction-controller');
  final String lastUpdateKey = 'last-update';
  Box<TransactionsModel> get box => transactionBox;

  TransactionsModel addSingleTransaction({
    required int tr_user_id,
    int? lane_user_id,
    int? dane_user_id,
    required String amount,
    required String paymentStatus,
    required CategoriesModel? category,
    required String confirmation,
    Users? targetUser,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    int? serverId,
    int? groupTransactionId,
    int? id,
    int? settleTransactionId,
  }) {
    TransactionsModel object = TransactionsModel(
      id: id ?? 0,
      tr_user_id: tr_user_id,
      lane_user_id: lane_user_id,
      dane_user_id: dane_user_id,
      amount: double.parse(amount).toInt().toString(),
      paymentStatus: paymentStatus,
      confirmation: confirmation,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
      dueDate: dueDate,
      serverId: serverId ?? 0,
      settleTransactionId: settleTransactionId,
    );

    object.groupTransaction.targetId = groupTransactionId;
    object.user.target = targetUser;
    object.category.target = category;

    int newId = transactionBox.put(object);
    if (serverId == null) {
      object.serverId = (newId * -1);
      transactionBox.put(object);
    }
    return object;
  }

  TransactionsModel updateOrCreate({
    int? id,
    int? serverId,
    int? groupTransactionId,
    required int trUserId,
    required int laneUserId,
    required int daneUserId,
    required int amount,
    required String paymentStatus,
    required Users user,
    String? confirmation,
    CategoriesModel? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    int? settleTransactionId,
  }) {
    QueryBuilder<TransactionsModel> querybuilder = transactionBox.query(
        TransactionsModel_.id
            .equals(id ?? 0)
            .or(TransactionsModel_.serverId.equals(serverId ?? 0)));
    Query<TransactionsModel> query = querybuilder.build();

    TransactionsModel? existingTransaction = query.findFirst();
    TransactionsModel newTransaction;
    if (existingTransaction != null) {
      newTransaction = addSingleTransaction(
        id: existingTransaction.id,
        serverId: serverId ?? existingTransaction.serverId,
        groupTransactionId: groupTransactionId ??
            existingTransaction.groupTransaction.target?.id,
        tr_user_id: trUserId,
        lane_user_id: laneUserId,
        dane_user_id: daneUserId,
        amount: amount.toString(),
        paymentStatus: paymentStatus,
        confirmation: confirmation ??
            (existingTransaction.confirmation ?? Confirmation.Requested.name),
        targetUser: user,
        category: category ?? existingTransaction.category.target,
        createdAt: createdAt ?? existingTransaction.createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
        dueDate: dueDate ?? existingTransaction.dueDate,
        settleTransactionId:
            settleTransactionId ?? existingTransaction.settleTransactionId,
      );
    } else {
      newTransaction = addSingleTransaction(
        serverId: serverId,
        groupTransactionId: groupTransactionId,
        tr_user_id: trUserId,
        lane_user_id: laneUserId,
        dane_user_id: daneUserId,
        amount: amount.toString(),
        paymentStatus: paymentStatus,
        confirmation: confirmation ?? Confirmation.Requested.name,
        targetUser: user,
        category: category,
        createdAt: createdAt,
        updatedAt: updatedAt,
        dueDate: dueDate,
        settleTransactionId: settleTransactionId,
      );
    }

    return newTransaction;
  }

  List<TransactionsModel> getAllTransactions() {
    return transactionBox.getAll();
  }

  TransactionsModel? retrieveOnly(int id) {
    TransactionsModel? t = box.get(id);
    return t;
  }

  TransactionsModel? retrieveServerIdTransaction(int? serverId) {
    if (serverId == null) {
      return null;
    }
    QueryBuilder<TransactionsModel> query =
        transactionBox.query(TransactionsModel_.serverId.equals(serverId));
    TransactionsModel? transactionList = query.build().findFirst();

    return transactionList;
  }

  /// Take Users.id as an argument
  ///
  /// Returns a list of transactions associated with the given Users.id
  List<TransactionsModel> retrieveUserTransaction(int id) {
    QueryBuilder<TransactionsModel> query =
        transactionBox.query(TransactionsModel_.user.equals(id));
    query.order(TransactionsModel_.createdAt, flags: Order.descending);
    List<TransactionsModel> transactionList = query.build().find();

    return transactionList;
  }

  List<TransactionsModel> retrieveForGroupTransactionId(
      int groupTransactionId) {
    QueryBuilder<TransactionsModel> query = transactionBox
        .query(TransactionsModel_.groupTransaction.equals(groupTransactionId));
    query.order(TransactionsModel_.createdAt, flags: Order.descending);
    List<TransactionsModel> transactionList = query.build().find();

    return transactionList;
  }

  TransactionsModel acceptTransaction(TransactionsModel transaction) {
    transaction.confirmation = 'Accepted';
    box.put(transaction);
    return transaction;
  }

  TransactionsModel declineTransaction(TransactionsModel transaction) {
    transaction.confirmation = 'Declined';
    box.put(transaction);
    return transaction;
  }

  void resetConfirmationStatus(TransactionsModel transaction) {
    transaction.confirmation = Confirmation.Requested.name;
    box.put(transaction);
  }

  List<TransactionsModel> getUnsentTransactions() {
    QueryBuilder<TransactionsModel> querybuilder = box.query(TransactionsModel_
        .serverId
        .lessOrEqual(0)
        .and(TransactionsModel_.groupTransaction.equals(0)));
    Query<TransactionsModel> query = querybuilder.build();
    return query.find();
  }

  bool deleteTransaction(int id) {
    return box.remove(id);
  }

  /// Returns a non 0 id if an object was removed. If it was not present,
  /// or could not be removed, returns 0 instead.
  int deleteTransactionWithServerId(int serverId) {
    QueryBuilder<TransactionsModel> querybuilder =
        box.query(TransactionsModel_.serverId.equals(serverId));
    Query<TransactionsModel> query = querybuilder.build();
    TransactionsModel? transaction = query.findFirst();

    if (transaction == null) {
      return 0;
    } else {
      box.remove(transaction.id!);
      return transaction.id!;
    }
  }

  bool remove(int id) {
    return box.remove(id);
  }

  void clear() {
    box.removeAll();
  }
}

extension StreamProviders on TransactionController {
  Stream<Query<TransactionsModel>> streamAllForUserIdSortByServerId(
      int userId) {
    QueryBuilder<TransactionsModel> querybuilder =
        box.query(TransactionsModel_.user.equals(userId));
    querybuilder.order(TransactionsModel_.createdAt, flags: Order.descending);
    Stream<Query<TransactionsModel>> stream = querybuilder.watch();
    return stream;
  }
}
