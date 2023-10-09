import 'package:get/get.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:lane_dane/app_controller.dart';
import 'package:lane_dane/controllers/active_user_controller.dart';
import 'package:lane_dane/controllers/user_group_entity_controller.dart';
import 'package:lane_dane/models/active_user.dart';
import 'package:lane_dane/models/transactions.dart';
import 'package:lane_dane/models/user_group_entity.dart';
import 'package:lane_dane/models/users.dart';
import 'package:lane_dane/utils/activity_amount.dart';

class ActiveUserToUserGroupEntityMigration {
  ActiveUserController activeUserController = ActiveUserController();
  AppController appController = Get.find();

  bool needToMigrate() {
    List<ActiveUser> activeUserList = activeUserController.retrieveAll();
    return activeUserList.isNotEmpty;
  }

  List<ActiveUser> getList() {
    List<ActiveUser> activeUserList = activeUserController.retrieveAll();
    return activeUserList;
  }

  UserGroupEntity toUserGroupEntity(ActiveUser activeuser) {
    Users user = activeuser.user.target!;
    List<TransactionsModel> transactionList =
        appController.transactionController.retrieveUserTransaction(user.id!);
    int amount =
        transactionList.fold<int>(0, (int previous, TransactionsModel t) {
      return (previous +
          resolveAmountForActivity(
            int.parse(t.amount),
            t.transactionType,
            t.paymentStatus,
            t.confirmation!,
          ));
    });
    UserGroupEntity usergroup =
        appController.usergroupController.updateOrCreate(
      entityId: user.id!,
      amount: amount,
      name: user.full_name!,
      type: UserGroupEntityType.user,
      lastActivityTime: activeuser.lastActivityTime,
    );
    return usergroup;
  }

  void clear() {
    activeUserController.clear();
  }

  bool migrate() {
    if (!needToMigrate()) {
      return true;
    }

    List<ActiveUser> list = getList();

    for (int i = 0; i < list.length; i++) {
      ActiveUser activeuser = list[i];
      try {
        UserGroupEntity usergroup = toUserGroupEntity(activeuser);
      } catch (err, stack) {
        FirebaseCrashlytics.instance.recordError(
          err,
          stack,
          printDetails: true,
          fatal: false,
          information: [
            list.length,
            i,
            activeuser.id,
            activeuser.lastActivityTime,
            activeuser.user.target?.full_name! ?? 'no target user',
            activeuser.user.target?.phoneNumber ?? 'no target user'
          ],
          reason: 'Error when migrating active users to user group',
        );
      }
    }
    clear();
    return true;
  }
}
