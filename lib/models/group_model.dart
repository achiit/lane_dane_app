import 'dart:convert';
import 'package:lane_dane/models/transaction_entity.dart';
import 'package:lane_dane/models/user_group_entity.dart';
import 'package:lane_dane/models/users.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class Groups implements TransactionEntity {
  @Id()
  int id;
  int serverId;

  String groupName;
  String groupProfilePic;

  ToMany<Users> participants = ToMany<Users>();

  DateTime createdAt;
  DateTime updatedAt;

  Groups({
    this.id = 0,
    this.serverId = 0,
    required this.groupName,
    required this.groupProfilePic,
    List<Users>? participantsToAdd,
    required this.createdAt,
    required this.updatedAt,
  }) {
    if (participantsToAdd != null) {
      participants.addAll(participantsToAdd);
    }
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'ob_id': id,
      'id': serverId,
      'name': groupName,
      'profile_pic': groupProfilePic,
      'participants': participants.map<Map<String, dynamic>>((Users u) {
        return u.toMap();
      }),
      'created_at': createdAt.toString(),
      'updated_at': updatedAt.toString(),
    };
  }

  factory Groups.fromMap(Map<String, dynamic> map) {
    List<Users> participantsToAdd =
        (map['participants'] ?? []).map<Users>((dynamic o) {
      return Users.fromMap(o);
    });
    return Groups(
      serverId: map['id'],
      groupName: map['name'],
      groupProfilePic: map['profile_pic'] ?? '',
      participantsToAdd: participantsToAdd,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Groups.fromJson(String source) =>
      Groups.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  int entityId() {
    return id;
  }

  @override
  String details() {
    return participants
        .map<String>((Users u) {
          return u.firstName;
        })
        .toList()
        .join(', ');
  }

  @override
  bool isActive() {
    return true;
  }

  @override
  String name() {
    return groupName;
  }

  @override
  UserGroupEntityType type() {
    return UserGroupEntityType.group;
  }

  int groupSize() {
    return participants.length + 1;
  }
}
