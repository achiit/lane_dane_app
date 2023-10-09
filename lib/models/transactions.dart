// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'package:get/get.dart';
import 'package:lane_dane/app_controller.dart';
import 'package:lane_dane/models/group_transaction.dart';
import 'package:objectbox/objectbox.dart';

import 'package:lane_dane/models/users.dart';

import 'categories_model.dart';

// ignore_for_file: non_constant_identifier_names

// ignore_for_file: public_member_api_docs, sort_constructors_first
/*
This file shows what each transaction should look like
*/

enum TransactionType {
  Lane,
  Dane,
}

enum PaymentStatus {
  Done,
  Pending,
}

enum Confirmation {
  Requested, // Default
  Accepted,
  Declined,
}

@Entity()
class TransactionsModel {
  @Id()
  int? id;

  int tr_user_id;
  int? lane_user_id;
  int? dane_user_id;
  String amount;
  String paymentStatus;
  String? confirmation;
  DateTime createdAt;
  DateTime? updatedAt;
  DateTime? dueDate;

  @Unique()
  int? serverId;

  int? settleTransactionId;

  ToOne<Users> user = ToOne<Users>();
  ToOne<GroupTransaction> groupTransaction = ToOne<GroupTransaction>();
  ToOne<CategoriesModel> category = ToOne<CategoriesModel>();

  TransactionsModel({
    this.id,
    this.serverId,
    required this.tr_user_id,
    this.lane_user_id,
    this.dane_user_id,
    required this.amount,
    required this.paymentStatus,
    this.confirmation = 'Requested',
    required this.createdAt,
    this.dueDate,
    this.updatedAt,
    required this.settleTransactionId,
  });

  String get transactionType {
    AppController appController = Get.find();
    if (lane_user_id == appController.user.id) {
      return TransactionType.Lane.name;
    } else {
      return TransactionType.Dane.name;
    }
  }

  int? get contactId {
    return tr_user_id != lane_user_id ? lane_user_id : dane_user_id;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'tr_user_id': tr_user_id,
      'lane_user_id': lane_user_id,
      'dane_user_id': dane_user_id,
      'amount': amount,
      'paymentStatus': paymentStatus,
      'confirmation': confirmation,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'due_date': dueDate,
    };
  }

  factory TransactionsModel.fromMap(Map<String, dynamic> map) {
    TransactionsModel transaction = TransactionsModel(
      serverId: map['id'] != null ? map['id'] as int : null,
      tr_user_id: map['user_id'] as int,
      lane_user_id:
          map['lane_user_id'] != null ? map['lane_user_id'] as int : null,
      dane_user_id:
          map['dane_user_id'] != null ? map['dane_user_id'] as int : null,
      amount: map['amount'].toString(),
      paymentStatus: map['payment_status'] as String,
      confirmation: map['confirmation'] != null
          ? map['confirmation'] as String
          : Confirmation.Requested.name,
      createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String).toLocal()
          : null,
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
      settleTransactionId: map['settle_transaction_id'] ?? 0,
    );

    return transaction;
  }

  String toJson() => json.encode(toMap());

  factory TransactionsModel.fromJson(String source) =>
      TransactionsModel.fromMap(json.decode(source) as Map<String, dynamic>);

  void setdane(int daneUID) {
    dane_user_id = daneUID;
  }

  void setlane(int laneUID) {
    lane_user_id = laneUID;
  }

  void updateAmount(int amount) {
    this.amount = amount.toString();
  }

  void updateStatus(PaymentStatus status) {
    paymentStatus = PaymentStatus.values[status.index].name;
  }
}
