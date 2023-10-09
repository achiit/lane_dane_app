// ignore_for_file: public_member_api_docs, sort_constructors_first, non_constant_identifier_names
import 'dart:convert';

import 'package:lane_dane/models/users.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class UserContactsObjectBoxModel {
  @Id()
  int? id;

  int contact_user_id;
  int user_id;
  String contact_name;

  final users = ToMany<Users>();

  UserContactsObjectBoxModel({
    this.id,
    required this.contact_user_id,
    required this.user_id,
    required this.contact_name,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'contact_user_id': contact_user_id,
      'user_id': user_id,
      'contact_name': contact_name,
    };
  }

  factory UserContactsObjectBoxModel.fromMap(Map<String, dynamic> map) {
    return UserContactsObjectBoxModel(
      id: map['id'] != null ? map['id'] as int : null,
      contact_user_id: map['contact_user_id'] as int,
      user_id: map['user_id'] as int,
      contact_name: map['contact_name'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserContactsObjectBoxModel.fromJson(String source) =>
      UserContactsObjectBoxModel.fromMap(
          json.decode(source) as Map<String, dynamic>);
}
