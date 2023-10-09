import 'dart:convert';
import 'package:lane_dane/models/categories_model.dart';
import 'package:lane_dane/models/group_model.dart';
import 'package:lane_dane/models/users.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class GroupTransaction {
  @Id()
  int id;
  int creatorId;

  int serverId;
  int amount;

  DateTime createdAt;
  DateTime updatedAt;

  ToMany<Users> transactionParticipants = ToMany<Users>();
  ToOne<Groups> group = ToOne<Groups>();
  ToOne<CategoriesModel> category = ToOne<CategoriesModel>();

  GroupTransaction({
    this.id = 0,
    this.serverId = 0,
    required this.creatorId,
    required this.amount,
    required this.group,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    List<Users>? participantsToAdd,
  }) {
    if (participantsToAdd != null) {
      transactionParticipants.addAll(participantsToAdd);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'ob_id': id,
      'id': serverId,
      'amount': amount,
      'group': group.targetId,
      'category': category.target?.toMap(),
      'participants':
          transactionParticipants.map<Map<String, dynamic>>((Users u) {
        return u.toMap();
      }).toList(),
      'created_at': createdAt.toString(),
      'updated_at': updatedAt.toString(),
    };
  }

  factory GroupTransaction.fromMap(Map<String, dynamic> m) {
    return GroupTransaction(
      serverId: m['id'],
      creatorId: m['user_id'],
      amount: m['amount'],
      group: ToOne(targetId: m['group']),
      category: ToOne(target: CategoriesModel.fromMap(m['category'])),
      participantsToAdd:
          m['participants'].map<Users>((Map<String, dynamic> userMap) {
        return Users.fromMap(userMap);
      }).toList(),
      createdAt: m['created_at'] ?? DateTime.now(),
      updatedAt: m['updated_at'] ?? DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory GroupTransaction.fromJson(String source) =>
      GroupTransaction.fromMap(json.decode(source) as Map<String, dynamic>);

  int get participantCount {
    return transactionParticipants.length + 1;
  }
}
