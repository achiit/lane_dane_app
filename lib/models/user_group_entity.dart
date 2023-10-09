import 'package:objectbox/objectbox.dart';

enum UserGroupEntityType {
  unknown,
  user,
  group,
}

@Entity()
class UserGroupEntity {
  @Id()
  int id;
  int entityId;
  DateTime lastActivityTime;
  String name;
  String? profilePicture;
  int amount;

  @Transient()
  late UserGroupEntityType type;

  DateTime createdAt;
  DateTime updatedAt;

  UserGroupEntity({
    this.id = 0,
    required this.entityId,
    this.amount = 0,
    required this.lastActivityTime,
    required this.name,
    this.profilePicture,
    required this.createdAt,
    required this.updatedAt,
  });

  int get dbType {
    _checkTypeIsStable();
    return type.index;
  }

  set dbType(int index) {
    _checkTypeIsStable();
    if (index >= 0 && index <= UserGroupEntityType.values.length) {
      type = UserGroupEntityType.values[index];
    } else {
      type = UserGroupEntityType.unknown;
    }
  }

  void _checkTypeIsStable() {
    assert(UserGroupEntityType.unknown.index == 0);
    assert(UserGroupEntityType.user.index == 1);
    assert(UserGroupEntityType.group.index == 2);
  }
}
