import 'package:lane_dane/models/user_group_entity.dart';

abstract class TransactionEntity {
  int entityId();
  String name();
  String details();
  bool isActive();
  UserGroupEntityType type();
}
