import 'package:lane_dane/main.dart';
import 'package:lane_dane/models/categories_model.dart';
import 'package:lane_dane/models/group_model.dart';
import 'package:lane_dane/models/group_transaction.dart';
import 'package:lane_dane/models/users.dart';
import 'package:lane_dane/objectbox.g.dart';
import 'package:lane_dane/utils/log_printer.dart';
import 'package:logger/logger.dart';

class GroupTransactionController {
  final Box<GroupTransaction> box = OBJECTBOX.store.box<GroupTransaction>();
  final Logger log = getLogger('GroupTransactionController');

  GroupTransaction create({
    int? id,
    int? serverId,
    required int creatorId,
    required int amount,
    required Groups group,
    required List<Users> participantsToAdd,
    CategoriesModel? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    GroupTransaction groupTransaction = GroupTransaction(
      id: id ?? 0,
      creatorId: creatorId,
      amount: amount,
      group: ToOne(targetId: group.id),
      category: ToOne(target: category),
      participantsToAdd: participantsToAdd,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );

    int insertedId = box.put(groupTransaction);
    if (serverId != null) {
      groupTransaction.serverId = serverId;
    } else {
      groupTransaction.serverId = insertedId * -1;
    }
    box.put(groupTransaction);

    return groupTransaction;
  }

  GroupTransaction? retrieveGroupTransactionFromServerId({
    required int serverId,
  }) {
    QueryBuilder<GroupTransaction> querybuilder =
        box.query(GroupTransaction_.serverId.equals(serverId));
    querybuilder.order(GroupTransaction_.serverId, flags: Order.descending);
    Query<GroupTransaction> query = querybuilder.build();
    return query.findFirst();
  }

  List<GroupTransaction> retrieveForGroupOrderByServerId(
      {required int groupId}) {
    QueryBuilder<GroupTransaction> querybuilder =
        box.query(GroupTransaction_.group.equals(groupId));
    querybuilder.order(GroupTransaction_.createdAt, flags: Order.descending);
    Query<GroupTransaction> query = querybuilder.build();
    return query.find();
  }

  List<GroupTransaction> retrieveWithNegativeServerId() {
    QueryBuilder<GroupTransaction> querybuilder =
        box.query(GroupTransaction_.serverId.lessThan(0));
    Query<GroupTransaction> query = querybuilder.build();
    return query.find();
  }

  GroupTransaction updateOrCreate({
    int? id,
    int? serverId,
    required int creatorId,
    required int amount,
    required Groups group,
    required List<Users> participantsToAdd,
    CategoriesModel? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    QueryBuilder<GroupTransaction> querybuilder = box.query(GroupTransaction_.id
        .equals(id ?? 0)
        .or(GroupTransaction_.serverId.equals(serverId ?? 0)));
    Query<GroupTransaction> query = querybuilder.build();

    GroupTransaction? existingTransaction = query.findFirst();
    GroupTransaction updatedTransaction;
    if (existingTransaction != null) {
      updatedTransaction = create(
        id: id ?? existingTransaction.id,
        serverId: serverId ?? existingTransaction.serverId,
        amount: amount,
        creatorId: creatorId,
        group: group,
        participantsToAdd: participantsToAdd,
        category: category ?? existingTransaction.category.target,
        createdAt: createdAt ?? existingTransaction.createdAt,
        updatedAt: updatedAt ?? existingTransaction.updatedAt,
      );
    } else {
      updatedTransaction = create(
        serverId: serverId,
        amount: amount,
        creatorId: creatorId,
        group: group,
        participantsToAdd: participantsToAdd,
        category: category,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    }

    return updatedTransaction;
  }

  GroupTransaction updateGroupTransactionParticipants({
    int? groupId,
    int? groupServerId,
    required List<Users> userList,
  }) {
    assert(groupId != null || groupServerId != null);
    QueryBuilder<GroupTransaction> querybuilder = box.query(GroupTransaction_.id
        .equals(groupId ?? 0)
        .or(GroupTransaction_.serverId.equals(groupServerId ?? 0)));
    Query<GroupTransaction> query = querybuilder.build();
    GroupTransaction? groupTransaction = query.findFirst();
    if (groupTransaction == null) {
      throw 'Group transaction does not exist with the given id';
    }
    groupTransaction.transactionParticipants.addAll(userList);
    box.put(groupTransaction);
    return groupTransaction;
  }

  void clear() {
    box.removeAll();
  }
}

extension StreamProvider on GroupTransactionController {
  Stream<Query<GroupTransaction>> streamAllForGroupIdSortByServerId(
      int groupId) {
    QueryBuilder<GroupTransaction> querybuilder =
        box.query(GroupTransaction_.group.equals(groupId));
    querybuilder.order(GroupTransaction_.createdAt, flags: Order.descending);
    Stream<Query<GroupTransaction>> stream = querybuilder.watch();
    return stream;
  }
}
