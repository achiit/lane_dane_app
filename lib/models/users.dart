// ignore_for_file: non_constant_identifier_names

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:lane_dane/models/transaction_entity.dart';
import 'package:lane_dane/models/transactions.dart';
import 'package:lane_dane/models/user_group_entity.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class Users implements TransactionEntity {
  @Transient()
  static DateTime startOfTime = DateTime.fromMicrosecondsSinceEpoch(0);

  @Id()
  int? id;

  int? onboarded_at;
  String? full_name;
  int tapCount;

  DateTime onBoardedAt;

  // @Unique()
  String phone_no;

  @Transient()
  TransactionsModel? recentTransaction;
  int serverId;

  Users({
    this.id,
    this.serverId = 0,
    required this.phone_no,
    required this.onBoardedAt,
    required this.tapCount,
    this.full_name,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'onboarded_at': onboarded_at.toString(),
      'phone_no': phone_no,
      'full_name': full_name,
      'tap_count': tapCount,
    };
  }

  factory Users.fromMap(Map<String, dynamic> map) {
    return Users(
      serverId: map['id'] as int,
      onBoardedAt: map['onboarded_at'] != null
          ? DateTime.parse(map['onboarded_at'])
          : Users.startOfTime,
      phone_no: map['phone_no'].toString(),
      tapCount: map['tap_count'] ?? 0,
      full_name: map['full_name'] != null ? map['full_name'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Users.fromJson(String source) =>
      Users.fromMap(json.decode(source) as Map<String, dynamic>);

  String get phoneWithoutCode {
    String phone = phone_no.replaceAll(RegExp('[^0-9]'), '');
    if (phone.length >= 10) {
      phone = phone.substring(phone.length - 10);
    }
    return phone;
  }

  String get phoneWithCode {
    return '91$phoneWithoutCode';
  }

  String get phoneWithCodeFormat {
    return '+91 $phoneWithoutCode';
  }

  /// Returns the phone number as is saved.
  String get phoneNumberRaw {
    return phone_no.toString();
  }

  /// Returns the 10 digit phone number without country code.
  String get phoneNumber {
    String phone = phoneNumberRaw.replaceAll(RegExp('[^0-9]'), '');
    if (phone.length >= 10) {
      phone = phone.substring(phone.length - 10);
    }
    return phone;
  }

  /// Returns the phone number with the country code.
  String get phoneNumberWithCode {
    return '91$phoneNumber';
  }

  /// Returns the phone number with country code and proper format
  String get phoneNumberFormatted {
    return '+91 $phoneNumber';
  }

  String get firstName {
    return full_name!.split(' ')[0];
  }

  bool userRegistered() {
    return onBoardedAt.isAfter(Users.startOfTime);
  }

  @override
  int entityId() {
    return id!;
  }

  @override
  String details() {
    return phoneNumberFormatted;
  }

  @override
  bool isActive() {
    return userRegistered();
  }

  @override
  String name() {
    return full_name!;
  }

  @override
  UserGroupEntityType type() {
    return UserGroupEntityType.user;
  }
}
