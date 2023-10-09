import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class SmsTransactionModel {
  final int id;
  final String smsBody;
  final String transaction_type;
  final double amount;
  final DateTime date_time;
  final String accNumber;

  SmsTransactionModel({
    required this.id,
    required this.smsBody,
    required this.transaction_type,
    required this.amount,
    required this.date_time,
    required this.accNumber,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'smsBody': smsBody,
      'transaction_type': transaction_type,
      'amount': amount,
      'date_time': date_time,
      'accNumber': accNumber,
    };
  }

  factory SmsTransactionModel.fromMap(Map<String, dynamic> map) {
    return SmsTransactionModel(
      id: map['id'] as int,
      smsBody: map['smsBody'] as String,
      transaction_type: map['transaction_type'] as String,
      amount: map['amount'] as double,
      date_time: map['date_time'] as DateTime,
      accNumber: map['accNumber'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory SmsTransactionModel.fromJson(String source) =>
      SmsTransactionModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
