import 'package:lane_dane/main.dart';
import 'package:lane_dane/models/user_group_entity.dart';
import 'package:lane_dane/objectbox.g.dart';
import 'package:lane_dane/utils/log_printer.dart';
import 'package:logger/logger.dart';

class UserGroupEntityController {
  final Box<UserGroupEntity> box = OBJECTBOX.store.box<UserGroupEntity>();
  final Logger logger = getLogger('UserGroupEntityController');

  UserGroupEntity create({
    int? id,
    required int entityId,
    required UserGroupEntityType type,
    required int amount,
    DateTime? lastActivityTime,
    required String name,
    String? profilePicture,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool commit = true,
  }) {
    final DateTime now = DateTime.now();

    UserGroupEntity usergroup = UserGroupEntity(
      id: id ?? 0,
      entityId: entityId,
      amount: amount,
      lastActivityTime: lastActivityTime ?? now,
      name: name,
      profilePicture: profilePicture,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    )..type = type;
    if (!commit) {
      return usergroup;
    }

    box.put(usergroup);
    return usergroup;
  }

  UserGroupEntity updateOrCreate({
    int? id,
    required int entityId,
    required UserGroupEntityType type,
    required int amount,
    DateTime? lastActivityTime,
    required String name,
    String? profilePicture,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    QueryBuilder<UserGroupEntity> querybuilder = box.query(
        (UserGroupEntity_.id.equals(id ?? 0)).or(UserGroupEntity_.entityId
            .equals(entityId)
            .and(UserGroupEntity_.dbType.equals(type.index))));
    Query<UserGroupEntity> query = querybuilder.build();

    UserGroupEntity? retrievedEntity = query.findFirst();
    UserGroupEntity entity;
    if (retrievedEntity != null) {
      entity = create(
        id: retrievedEntity.id,
        entityId: entityId,
        type: type,
        amount: retrievedEntity.amount + amount,
        lastActivityTime: lastActivityTime ?? retrievedEntity.lastActivityTime,
        name: name,
        profilePicture: profilePicture ?? retrievedEntity.profilePicture,
        createdAt: createdAt ?? retrievedEntity.createdAt,
        updatedAt: updatedAt ?? retrievedEntity.updatedAt,
      );
    } else {
      entity = create(
        id: id,
        entityId: entityId,
        type: type,
        amount: amount,
        lastActivityTime: lastActivityTime,
        name: name,
        profilePicture: profilePicture,
      );
    }

    return entity;
  }

  List<UserGroupEntity> retrieveAllOrderByLastActivityTime() {
    QueryBuilder<UserGroupEntity> querybuilder = box.query();
    querybuilder.order(UserGroupEntity_.lastActivityTime,
        flags: Order.descending);
    Query<UserGroupEntity> query = querybuilder.build();

    return query.find();
  }

  void clear() {
    box.removeAll();
  }
}

extension StreamProviders on UserGroupEntityController {
  Stream<Query<UserGroupEntity>> streamAllOrderByLastActivityTime() {
    QueryBuilder<UserGroupEntity> querybuilder = box.query();
    querybuilder.order(UserGroupEntity_.lastActivityTime,
        flags: Order.descending);
    Stream<Query<UserGroupEntity>> query =
        querybuilder.watch(triggerImmediately: false);

    return query;
  }
}
