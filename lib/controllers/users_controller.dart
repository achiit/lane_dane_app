import 'package:lane_dane/controllers/contact_controller.dart';
import 'package:lane_dane/main.dart';
import 'package:lane_dane/objectbox.g.dart';
import 'package:lane_dane/models/users.dart';

class UserHelper {
  static List<Users> userList = [];
  final userBox = OBJECTBOX.store.box<Users>();

  Users addUser(
    String phoneNo,
    String fullName, {
    int? id,
    int? serverId,
    int? tapCount,
    DateTime? onBoardedAt,
  }) {
    final user = Users(
      phone_no: phoneNo,
      full_name: fullName,
      onBoardedAt: onBoardedAt ?? Users.startOfTime,
      tapCount: tapCount ?? 0,
    );
    user.id = id ?? 0;
    user.serverId = serverId ?? 0;
    // add user to the box
    int newId = userBox.put(user);
    if (serverId == null) {
      user.serverId = newId * -1;
      userBox.put(user);
    }
    return user;
  }

  Users updateOrCreate({
    int? id,
    int? serverId,
    DateTime? onBoardedAt,
    required String fullName,
    required String phoneNumber,
    int? tapCount,
  }) {
    QueryBuilder<Users> querybuilder = userBox.query(Users_.id
        .equals(id ?? 0)
        .or(Users_.serverId.equals(serverId ?? 0))
        .or(Users_.phone_no.equals(phoneNumber)));
    Query<Users> query = querybuilder.build();

    Users? existingUser = query.findFirst();
    Users newUser;
    if (existingUser != null) {
      newUser = addUser(
        phoneNumber,
        fullName,
        id: existingUser.id,
        serverId: serverId ?? existingUser.serverId,
        onBoardedAt: onBoardedAt ?? existingUser.onBoardedAt,
        tapCount: tapCount ?? existingUser.tapCount,
      );
    } else {
      newUser = addUser(
        phoneNumber,
        fullName,
        id: id,
        serverId: serverId,
        onBoardedAt: onBoardedAt,
        tapCount: tapCount,
      );
    }
    return newUser;
  }

  Users? retrieveOnly(int id) {
    Users? contact = userBox.get(id);
    return contact;
  }

  List<Users> retrieveAll({bool sortByName = true}) {
    QueryBuilder<Users> querybuilder = userBox.query();
    if (sortByName) {
      querybuilder.order(Users_.tapCount, flags: Order.descending);
      querybuilder.order(Users_.full_name);
    }
    List<Users> userList = querybuilder.build().find();
    return userList;
  }

  Users? retrieveUserFromPhoneNumber(String phone) {
    QueryBuilder<Users> querybuilder =
        userBox.query(Users_.phone_no.equals(phone));

    Users? user = querybuilder.build().findFirst();
    return user;
  }

  Users? retrieveUserFromServerId(int serverId) {
    QueryBuilder<Users> querybuilder =
        userBox.query(Users_.serverId.equals(serverId));
    Users? user = querybuilder.build().findFirst();
    return user;
  }

  Users? updateUserServerId({
    required int oldId,
    required int newId,
  }) {
    Users? user = retrieveUserFromServerId(oldId);
    if (user != null) {
      user.serverId = newId;
      userBox.put(user);
    }
    return user;
  }

  Users? updateUserIncrementTapCount(int userId) {
    Users? user = userBox.get(userId);
    if (user == null) {
      return null;
    }

    user.tapCount += 1;
    userBox.put(user);
    return user;
  }

  void clear() {
    userBox.removeAll();
  }
}

extension StreamProviders on UserHelper {
  Stream<Query<Users>> streamAllOrderByName() {
    QueryBuilder<Users> querybuilder = userBox.query();
    querybuilder.order(Users_.tapCount, flags: Order.descending);
    querybuilder.order(Users_.full_name);
    Stream<Query<Users>> stream = querybuilder.watch();
    return stream;
  }
}
