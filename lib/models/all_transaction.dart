import 'dart:convert';

import 'package:lane_dane/models/group_transaction.dart';
import 'package:lane_dane/models/transactions.dart';
import 'package:objectbox/objectbox.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
@Entity()
class AllTransactionObjectBox {
  @Id()
  int? id;

  final String? smsBody;
  String transactionType;
  final String amount;
  final String? profilePic;
  String name;
  DateTime createdAt;
  DateTime? updatedAt;

  ToOne<TransactionsModel> transactionId = ToOne<TransactionsModel>();
  ToOne<GroupTransaction> groupTransaction = ToOne<GroupTransaction>();

  AllTransactionObjectBox({
    this.id,
    this.smsBody,
    required this.transactionType,
    required this.amount,
    this.profilePic,
    required this.name,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'smsBody': smsBody,
      'transactionType': transactionType,
      'amount': amount,
      'profilePic': profilePic,
      'name': name,
      'transactionId': transactionId.target?.id ?? 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory AllTransactionObjectBox.fromMap(Map<String, dynamic> map) {
    return AllTransactionObjectBox(
      id: map['id'],
      smsBody: map['smsBody'],
      transactionType: map['transactionType'] as String,
      amount: map['amount'] as String,
      profilePic: map['profilePic'],
      name: map['name'] as String,
      createdAt: (map['createdAt'] is int
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : map['createdAt'] as DateTime),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
          : map['createdAt'] as DateTime,
    );
  }

  String toJson() => json.encode(toMap());

  factory AllTransactionObjectBox.fromJson(String source) =>
      AllTransactionObjectBox.fromMap(
          json.decode(source) as Map<String, dynamic>);

  void updateTransactionId(int id) {
    transactionId.targetId = id;
  }

  void updateName(String? name) {
    this.name = name ?? this.name;
  }

  void updateTransactionType(TransactionType type) {
    transactionType = TransactionType.values[type.index].name;
  }
}
