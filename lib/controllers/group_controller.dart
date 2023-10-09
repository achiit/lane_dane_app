import 'package:logger/logger.dart';
import 'package:lane_dane/utils/log_printer.dart';
import 'package:lane_dane/models/group_model.dart';
import 'package:lane_dane/models/users.dart';
import 'package:lane_dane/main.dart';
import 'package:lane_dane/objectbox.g.dart';

class GroupController {
  final Box<Groups> box = OBJECTBOX.store.box<Groups>();
  final Logger log = getLogger('group-controller');

  Groups create({
    int? id,
    int? serverId,
    required String groupName,
    required String profilePicture,
    required List<Users> participants,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool commit = true,
  }) {
    DateTime now = DateTime.now();
    Groups group = Groups(
      id: id ?? 0,
      serverId: serverId ?? 0,
      groupName: groupName,
      groupProfilePic: profilePicture,
      participantsToAdd: participants,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
    if (!commit) {
      return group;
    }

    int newId = box.put(group);
    if (serverId != null) {
      return group;
    }

    group.serverId = newId * -1;
    box.put(group);
    return group;
  }

  Groups? retrieveGroup(int id) {
    return box.get(id);
  }

  Groups? retrieveGroupByServerId(int id) {
    QueryBuilder<Groups> querybuilder = box.query(Groups_.serverId.equals(id));
    Query<Groups> query = querybuilder.build();
    Groups? group = query.findFirst();
    return group;
  }

  List<Groups> retrieveAll() {
    QueryBuilder<Groups> querybuilder = box.query();
    querybuilder.order(Groups_.groupName);
    Query<Groups> query = querybuilder.build();

    return query.find();
  }

  Groups updateServerId({required int groupId, required int newServerId}) {
    Groups groupToUpdate = box.get(groupId)!;
    groupToUpdate.serverId = newServerId;
    box.put(groupToUpdate);
    return groupToUpdate;
  }

  Groups updateOrCreate({
    int? id,
    int? serverId,
    required String name,
    required String profilePic,
    required List<Users> participants,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    QueryBuilder<Groups> querybuilder = box.query(
        Groups_.id.equals(id ?? 0).or(Groups_.serverId.equals(serverId ?? 0)));
    Query<Groups> query = querybuilder.build();

    Groups? existingGroup = query.findFirst();
    Groups updatedGroup;
    if (existingGroup != null) {
      updatedGroup = create(
        id: existingGroup.id,
        serverId: serverId ?? existingGroup.serverId,
        groupName: name,
        profilePicture: profilePic,
        participants: participants,
        createdAt: createdAt ?? existingGroup.createdAt,
        updatedAt: updatedAt ?? existingGroup.updatedAt,
      );
    } else {
      updatedGroup = create(
        serverId: serverId,
        groupName: name,
        profilePicture: profilePic,
        participants: participants,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    }

    return updatedGroup;
  }

  bool remove({
    required int id,
  }) {
    return box.remove(id);
  }

  void clear() {
    box.removeAll();
  }
}

extension StreamProviders on GroupController {
  Stream<Query<Groups>> streamAllOrderByName() {
    QueryBuilder<Groups> querybuilder = box.query();
    querybuilder.order(Groups_.serverId);
    Stream<Query<Groups>> stream = querybuilder.watch();
    return stream;
  }
}
