import 'package:lane_dane/main.dart';
import 'package:lane_dane/models/active_user.dart';
import 'package:lane_dane/models/users.dart';
import 'package:lane_dane/objectbox.g.dart';

class ActiveUserController {
  final box = OBJECTBOX.store.box<ActiveUser>();

  ActiveUser create({
    int? id,
    required Users user,
    DateTime? lastActivityTime,
  }) {
    ActiveUser newActiveUser = ActiveUser(
        id: id ?? 0,
        user: ToOne<Users>(target: user),
        lastActivityTime: lastActivityTime ?? DateTime.now());

    box.put(newActiveUser);

    return newActiveUser;
  }

  List<ActiveUser> retrieveAll() {
    return box.getAll();
  }

  List<ActiveUser> retrieveActiveUserList({bool sortedByTime = true}) {
    if (!sortedByTime) {
      return box.getAll();
    }

    QueryBuilder<ActiveUser> querybuilder = box.query();
    querybuilder.order(ActiveUser_.lastActivityTime, flags: Order.descending);
    Query<ActiveUser> query = querybuilder.build();

    List<ActiveUser> activeUserList = query.find();

    return activeUserList;
  }

  ActiveUser? retrieveActiveUser(int id) {
    return box.get(id);
  }

  ActiveUser updateOrCreate({
    int? id,
    required Users user,
    DateTime? lastActivityTime,
  }) {
    QueryBuilder<ActiveUser> querybuilder = box.query(ActiveUser_.id
        .equals(id ?? 0)
        .or(ActiveUser_.user.equals(user.id ?? 0)));
    Query<ActiveUser> query = querybuilder.build();

    ActiveUser? existingActiveUser = query.findFirst();
    ActiveUser updatedActiveUser;
    if (existingActiveUser != null) {
      updatedActiveUser = update(
        id: existingActiveUser.id,
        user: user,
        newLastActivityTime:
            lastActivityTime ?? existingActiveUser.lastActivityTime,
      );
    } else {
      updatedActiveUser = create(
        id: id,
        user: user,
        lastActivityTime: lastActivityTime,
      );
    }

    return updatedActiveUser;
  }

  ActiveUser update({
    required int id,
    Users? user,
    DateTime? newLastActivityTime,
  }) {
    ActiveUser? activeuser = box.get(id);
    if (activeuser == null) {
      throw 'USER_DOES_NOT_EXIST';
    }

    if (user != null) {
      activeuser.user.target = user;
    }
    if (newLastActivityTime != null) {
      activeuser.lastActivityTime = newLastActivityTime;
    }
    box.put(activeuser);

    return activeuser;
  }

  bool deleteActiveUser(int id) {
    return box.remove(id);
  }

  void clear() {
    box.removeAll();
  }
}
