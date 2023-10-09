// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class GroupUserModel {
  int? id;
  int groupId;
  int userContactId;
  GroupUserModel({
    this.id,
    required this.groupId,
    required this.userContactId,
  });

  // GroupUserModel copyWith({
  //   int? id,
  //   int? groupId,
  //   int? userContactId,
  // }) {
  //   return GroupUserModel(
  //     id: id ?? this.id,
  //     groupId: groupId ?? this.groupId,
  //     userContactId: userContactId ?? this.userContactId,
  //   );
  // }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      // 'id': id,
      'group_id': groupId,
      'user_contact_id': userContactId,
    };
  }

  factory GroupUserModel.fromMap(Map<String, dynamic> map) {
    return GroupUserModel(
      id: map['id'] != null ? map['id'] as int : null,
      groupId: map['groupId'] as int,
      userContactId: map['userContactId'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory GroupUserModel.fromJson(String source) =>
      GroupUserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  // @override
  // String toString() =>
  //     'GroupUserModel(id: $id, groupId: $groupId, userContactId: $userContactId)';

  // @override
  // bool operator ==(covariant GroupUserModel other) {
  //   if (identical(this, other)) return true;

  //   return other.id == id &&
  //       other.groupId == groupId &&
  //       other.userContactId == userContactId;
  // }

  // @override
  // int get hashCode => id.hashCode ^ groupId.hashCode ^ userContactId.hashCode;
}
