import 'package:lane_dane/models/all_transaction.dart';
import 'package:lane_dane/models/transactions.dart';

import '../main.dart';
import '../objectbox.g.dart';

class AllTransactionController {
  static final allTnxBox = OBJECTBOX.store.box<AllTransactionObjectBox>();

  Box<AllTransactionObjectBox> get box => allTnxBox;

  void addMultipleInAllTransactions(List<AllTransactionObjectBox> allTnx) {
    allTnxBox.putMany(allTnx);
  }

  void addMultipleTransactions(List<TransactionsModel> transactionList) {
    for (TransactionsModel transaction in transactionList) {
      AllTransactionObjectBox? instance =
          retrieveOnlyTransactionModelId(transaction);
      if (instance == null) {
        addSingleInAllTransactions(
          transactionType: transaction.transactionType,
          amount: transaction.amount,
          name: transaction.user.target?.full_name! ?? '',
          createdAt: transaction.createdAt.toString(),
          updatedAt: transaction.updatedAt?.toString(),
          transactionId: transaction.id,
        );
      }
    }
  }

  AllTransactionObjectBox addSingleInAllTransactions({
    int? id,
    int? transactionId,
    int? groupTransactionId,
    String? smsBody,
    required String amount,
    required String name,
    required String transactionType,
    required String createdAt,
    String? profilePic,
    String? updatedAt,
  }) {
    AllTransactionObjectBox object = AllTransactionObjectBox(
      id: id ?? 0,
      smsBody: smsBody,
      transactionType: transactionType,
      amount: double.parse(amount).toInt().toString(),
      profilePic: profilePic,
      name: name,
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt) : null,
    );
    object.transactionId.targetId = transactionId;
    object.groupTransaction.targetId = groupTransactionId;
    allTnxBox.put(object);
    return object;
  }

  AllTransactionObjectBox updateOrCreate({
    int? id,
    int? transactionId,
    int? groupTransactionId,
    String? smsBody,
    required String amount,
    required String name,
    required String transactionType,
    required String createdAt,
    String? profilePic,
    String? updatedAt,
  }) {
    QueryBuilder<AllTransactionObjectBox> querybuilder = allTnxBox.query(
        AllTransactionObjectBox_.id.equals(id ?? 0).or(AllTransactionObjectBox_
            .transactionId
            .equals(transactionId ?? -1)
            .or(AllTransactionObjectBox_.groupTransaction
                .equals(groupTransactionId ?? -1))));
    Query<AllTransactionObjectBox> query = querybuilder.build();

    AllTransactionObjectBox? existingAllTransaction = query.findFirst();
    AllTransactionObjectBox newAllTransaction;
    if (existingAllTransaction != null) {
      newAllTransaction = addSingleInAllTransactions(
        id: existingAllTransaction.id,
        transactionId:
            transactionId ?? existingAllTransaction.transactionId.targetId,
        smsBody: smsBody ?? existingAllTransaction.smsBody,
        amount: amount,
        name: name,
        transactionType: transactionType,
        createdAt: createdAt,
        profilePic: profilePic ?? existingAllTransaction.profilePic,
        updatedAt: updatedAt ?? DateTime.now().toString(),
      );
    } else {
      newAllTransaction = addSingleInAllTransactions(
        transactionId: transactionId,
        smsBody: smsBody,
        amount: amount,
        name: name,
        transactionType: transactionType,
        createdAt: createdAt,
        profilePic: profilePic,
        updatedAt: updatedAt ?? DateTime.now().toString(),
      );
    }
    return newAllTransaction;
  }

  AllTransactionObjectBox? updateOrReturn({
    int? id,
    int? transactionId,
    int? groupTransactionId,
    String? smsBody,
    required String amount,
    required String name,
    required String transactionType,
    required String createdAt,
    String? profilePic,
    String? updatedAt,
  }) {
    if (id == 0 || id == null) {
      return null;
    }
    AllTransactionObjectBox? existingAllTransaction = box.get(id);
    if (existingAllTransaction == null) {
      return null;
    }
    existingAllTransaction = addSingleInAllTransactions(
      id: existingAllTransaction.id,
      transactionId:
          transactionId ?? existingAllTransaction.transactionId.targetId,
      groupTransactionId: groupTransactionId ??
          existingAllTransaction.groupTransaction.targetId,
      smsBody: smsBody ?? existingAllTransaction.smsBody,
      amount: amount,
      name: name,
      transactionType: transactionType,
      createdAt: createdAt,
      profilePic: profilePic ?? existingAllTransaction.profilePic,
      updatedAt: updatedAt ?? DateTime.now().toString(),
    );
    return existingAllTransaction;
  }

  List<AllTransactionObjectBox> getAllTransactions() {
    return allTnxBox.getAll();
  }

  List<AllTransactionObjectBox> retrieveAllNonRequestedTransactions({
    bool sorted = true,
  }) {
    QueryBuilder<AllTransactionObjectBox> queryBuilder = box.query();

    /*
     * Need to somehow filter requested transactions below without losing the
     * list sms transactions. 
     */
    // queryBuilder.link<TransactionsModel>(
    //     AllTransactionObjectBox_.transactionId,
    //     TransactionsModel_.confirmation
    //         .equals('requested', caseSensitive: false));

    queryBuilder.order(AllTransactionObjectBox_.createdAt,
        flags: Order.descending);

    Query<AllTransactionObjectBox> query = queryBuilder.build();
    List<AllTransactionObjectBox> nonRequestedTransactionList = query.find();

    return nonRequestedTransactionList;
  }

  List<AllTransactionObjectBox> retrieveAllNonDeclinedTransactions({
    bool sorted = true,
  }) {
    QueryBuilder<AllTransactionObjectBox> queryBuilder = box.query();

    /*
     * Need to somehow filter requested transactions below without losing the
     * list sms transactions. 
     */
    // queryBuilder.link<TransactionsModel>(
    //     AllTransactionObjectBox_.transactionId,
    //     TransactionsModel_.confirmation
    //         .equals('requested', caseSensitive: false));

    queryBuilder.order(AllTransactionObjectBox_.createdAt,
        flags: Order.descending);

    Query<AllTransactionObjectBox> query = queryBuilder.build();
    List<AllTransactionObjectBox> nonRequestedTransactionList = query.find();

    return nonRequestedTransactionList
        .where((AllTransactionObjectBox alltransaction) {
      if (!alltransaction.transactionId.hasValue) {
        return true;
      } else {
        return alltransaction.transactionId.target!.confirmation!
                .toLowerCase() !=
            Confirmation.Declined.name.toLowerCase();
      }
    }).toList();
  }

  AllTransactionObjectBox? retrieveOnly(int id) {
    AllTransactionObjectBox? transaction = box.get(id);
    return transaction;
  }

  AllTransactionObjectBox? retrieveLatestSmsTransaction() {
    QueryBuilder<AllTransactionObjectBox> querybuilder = box.query(
        AllTransactionObjectBox_.transactionId
            .equals(0)
            .and(AllTransactionObjectBox_.groupTransaction.equals(0)));
    querybuilder.order(AllTransactionObjectBox_.createdAt);
    Query<AllTransactionObjectBox> query = querybuilder.build();
    List<AllTransactionObjectBox> smsTransactionList = query.find();
    if (smsTransactionList.isEmpty) {
      return null;
    } else {
      return smsTransactionList.last;
    }
  }

  /// Returns an AllTransactionObjectBox? for a given id
  /// If an equivalent AllTransactionObjectBox exists for a supplied TransactionsModel,
  /// then an AllTransactionObjectBox is returned
  /// If no AllTransactionObjectBox exists for a supplied TransactionsModel,
  /// then null is returned
  AllTransactionObjectBox? retrieveOnlyTransactionModelId(TransactionsModel t) {
    QueryBuilder<AllTransactionObjectBox> queryBuilder =
        box.query(AllTransactionObjectBox_.transactionId.equals(t.id!));
    AllTransactionObjectBox? allTransactionInstance =
        queryBuilder.build().findFirst();
    return allTransactionInstance;
  }

  AllTransactionObjectBox updateTransaction(
    AllTransactionObjectBox transaction, {
    int? transactionId,
    String? name,
    TransactionType? transactionType,
  }) {
    // update with arguments provided and commit
    // return object with updated values
    if (transactionId != null) {
      transaction.updateTransactionId(transactionId);
    }
    if (name != null) {
      transaction.updateName(name);
    }
    if (transactionType != null) {
      transaction.updateTransactionType(transactionType);
    }
    transaction.updatedAt = DateTime.now();
    box.put(transaction);
    return transaction;
  }

  /// Returns a non 0 id if an object was removed. If it was not present,
  /// or could not be removed, returns 0 instead.
  int deleteAllTransactionWithTransactionId(int id) {
    QueryBuilder<AllTransactionObjectBox> querybuilder =
        box.query(AllTransactionObjectBox_.transactionId.equals(id));
    Query<AllTransactionObjectBox> query = querybuilder.build();
    AllTransactionObjectBox? allTransaction = query.findFirst();

    if (allTransaction == null) {
      return 0;
    } else {
      box.remove(allTransaction.id!);
      return allTransaction.id!;
    }
  }

  List<AllTransactionObjectBox> retrieveAllSmsTransactions() {
    QueryBuilder<AllTransactionObjectBox> querybuilder = box.query(
        AllTransactionObjectBox_.transactionId
            .equals(0)
            .and(AllTransactionObjectBox_.groupTransaction.equals(0)));
    querybuilder.order(AllTransactionObjectBox_.createdAt,
        flags: Order.descending);
    Query<AllTransactionObjectBox> query = querybuilder.build();
    List<AllTransactionObjectBox> smsTransactionList = query.find();
    return smsTransactionList;
  }

  void remove(int id) {
    box.remove(id);
  }

  void clear() {
    box.removeAll();
  }
}

extension StreamProviders on AllTransactionController {
  Stream<Query<AllTransactionObjectBox>> streamAllSmsTransactions() {
    QueryBuilder<AllTransactionObjectBox> querybuilder = box.query(
        AllTransactionObjectBox_.transactionId
            .equals(0)
            .and(AllTransactionObjectBox_.groupTransaction.equals(0)));
    querybuilder.order(AllTransactionObjectBox_.createdAt,
        flags: Order.descending);
    Stream<Query<AllTransactionObjectBox>> stream = querybuilder.watch();
    return stream;
  }
}
