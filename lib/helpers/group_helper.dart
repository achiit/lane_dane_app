import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:lane_dane/api/group_services.dart';
import 'package:lane_dane/api/group_transaction_services.dart';
import 'package:lane_dane/app_controller.dart';
import 'package:lane_dane/main.dart';
import 'package:lane_dane/models/all_transaction.dart';
import 'package:lane_dane/models/categories_model.dart';
import 'package:lane_dane/models/group_model.dart';
import 'package:lane_dane/models/group_transaction.dart';
import 'package:lane_dane/models/transactions.dart';
import 'package:lane_dane/models/user_group_entity.dart';
import 'package:lane_dane/models/users.dart';
import 'package:lane_dane/utils/activity_amount.dart';
import 'package:lane_dane/utils/string_extensions.dart';

extension GroupHelper on AppController {
  void updateLocalFromServerResponse(
    Map<String, dynamic> data,
    GroupTransaction groupTransaction,
    List<TransactionsModel> personalTransactions,
  ) {
    Map<String, dynamic>? categoryMap = data['category'];
    List<dynamic> participantMapList = data['participants'];
    List<dynamic> personalTransactionMapList = data['personal_transactions'];

    CategoriesModel? category;
    if (categoryMap != null) {
      category = categoryController.updateOrCreate(
        message: categoryMap['name'],
        serverId: categoryMap['id'],
      );
    }

    List<Users> participantList = [];
    for (int i = 0; i < participantMapList.length; i++) {
      dynamic participantMap = participantMapList[i];
      dynamic personalTransactionMap = personalTransactionMapList[i];
      TransactionsModel existingPersonalTransaction =
          personalTransactions.firstWhere(
        (TransactionsModel t) {
          return t.user.target!.phoneNumber ==
              participantMap['phone_no'].toString().phoneNumber;
        },
      );
      Users user = userController.updateOrCreate(
        phoneNumber: participantMap['phone_no'].toString().phoneNumber,
        serverId: participantMap['id'],
        fullName: participantMap['full_name'] ?? participantMap['contact_name'],
      );

      transactionController.updateOrCreate(
        id: existingPersonalTransaction.id!,
        trUserId: personalTransactionMap['user_id'],
        amount: personalTransactionMap['amount'].toInt(),
        paymentStatus: personalTransactionMap['payment_status'],
        category: category,
        confirmation: personalTransactionMap['confirmation'],
        createdAt: DateTime.parse(personalTransactionMap['created_at']),
        updatedAt: DateTime.parse(personalTransactionMap['updated_at']),
        daneUserId: user.id!,
        laneUserId: personalTransactionMap['user_id'],
        serverId: personalTransactionMap['id'],
        user: user,
        groupTransactionId: groupTransaction.id,
      );

      participantList.add(user);
    }

    groupTransactionController.updateOrCreate(
      id: groupTransaction.id,
      serverId: data['id'],
      amount: data['amount'],
      creatorId: groupTransaction.creatorId,
      group: groupTransaction.group.target!,
      createdAt: DateTime.parse(data['created_at']),
      updatedAt: DateTime.parse(data['updated_at']),
      category: category,
      participantsToAdd: participantList,
    );
  }

  Groups groupFromServerMap(Map groupMap) {
    List<dynamic> userMapList = groupMap['group_users'];

    userMapList.removeWhere((dynamic element) {
      return element['id'] == user.id;
    });
    List<Users> userList = userMapList.map<Users>((dynamic u) {
      Users user = userController.updateOrCreate(
        serverId: u['id'],
        onBoardedAt: (u['onboarded_at'] != null)
            ? DateTime.parse(u['onboarded_at'])
            : null,
        fullName: u['full_name'] ?? u['phone_no'].toString(),
        phoneNumber: u['phone_no'].toString().phoneNumber,
      );
      return user;
    }).toList();

    Groups group = groupController.updateOrCreate(
      serverId: groupMap['id'],
      name: groupMap['name'],
      participants: userList,
      profilePic: groupMap['profile_pic'] ?? '',
      createdAt: DateTime.parse(groupMap['created_at']),
      updatedAt: DateTime.parse(groupMap['updated_at']),
    );
    usergroupController.updateOrCreate(
      entityId: group.id,
      amount: 0,
      name: group.groupName,
      type: UserGroupEntityType.group,
    );
    return group;
  }

  Groups createGroup({
    required String groupName,
    required String profilePicture,
    required List<Users> participants,
    bool commit = true,
  }) {
    GroupServices groupServices = GroupServices();
    Groups group = groupController.create(
      groupName: groupName,
      profilePicture: profilePicture,
      participants: participants,
    );

    groupServices
        .createGroup(name: group.groupName, participants: group.participants)
        .then((Map<String, dynamic> response) {
      Map<String, dynamic> groupData = response['success']['group'];
      Groups updatedGroup = groupController.updateOrCreate(
        id: group.id,
        serverId: groupData['id'],
        name: group.groupName,
        profilePic: group.groupProfilePic,
        participants: group.participants,
        createdAt: DateTime.parse(groupData['created_at']),
        updatedAt: DateTime.parse(groupData['updated_at']),
      );
    });

    usergroupController.create(
      amount: 0,
      entityId: group.id,
      name: group.groupName,
      type: UserGroupEntityType.group,
      lastActivityTime: group.updatedAt,
    );
    return group;
  }

  GroupTransaction createGroupTransaction({
    required int amount,
    required Groups group,
    required List<Users> participants,
    int? allTransactionId,
    CategoriesModel? category,
  }) {
    DateTime now = DateTime.now();
    GroupTransactionServices groupTransactionServices =
        GroupTransactionServices();
    GroupTransaction groupTransaction = groupTransactionController.create(
      creatorId: user.id,
      amount: amount,
      group: group,
      participantsToAdd: participants,
      category: category,
    );
    UserGroupEntity usergroup = usergroupController.updateOrCreate(
      entityId: group.id,
      name: group.groupName,
      type: UserGroupEntityType.group,
      amount: groupTransaction.amount,
      lastActivityTime: groupTransaction.updatedAt,
    );

    allTransactionController.updateOrReturn(
      id: allTransactionId,
      amount: amount.toString(),
      name: group.groupName,
      transactionType: 'lane',
      createdAt: groupTransaction.createdAt.toString(),
      updatedAt: groupTransaction.updatedAt.toString(),
      groupTransactionId: groupTransaction.id,
    );

    int splitAmount = amount ~/ participants.length;
    List<TransactionsModel> personalTransactions = [];
    for (int i = 0; i < participants.length; i++) {
      Users contact = participants[i];
      TransactionsModel transaction =
          transactionController.addSingleTransaction(
        tr_user_id: user.id,
        lane_user_id: user.id,
        dane_user_id: contact.id,
        targetUser: contact,
        amount: splitAmount.toString(),
        paymentStatus: PaymentStatus.Pending.name,
        confirmation: Confirmation.Requested.name,
        category: category,
        groupTransactionId: groupTransaction.id,
        createdAt: now,
        updatedAt: now,
      );
      AllTransactionObjectBox allTransaction =
          allTransactionController.addSingleInAllTransactions(
        amount: splitAmount.toString(),
        name: contact.full_name!,
        transactionType: TransactionType.Lane.name,
        createdAt: transaction.createdAt.toString(),
        updatedAt: transaction.updatedAt.toString(),
        transactionId: transaction.id,
        groupTransactionId: allTransactionId,
      );
      UserGroupEntity usergroup = usergroupController.updateOrCreate(
        name: contact.full_name!,
        entityId: contact.id!,
        type: UserGroupEntityType.user,
        lastActivityTime: transaction.updatedAt,
        amount: resolveAmountForActivity(
          splitAmount,
          TransactionType.Lane.name,
          PaymentStatus.Pending.name,
          Confirmation.Requested.name,
        ),
      );
      personalTransactions.add(transaction);
    }

    groupTransactionServices
        .createGroupTransaction(
      amount: amount,
      group: groupTransaction.group.target!,
      transactionParticipants: participants,
      category: category,
    )
        .then((Map<String, dynamic> response) {
      updateLocalFromServerResponse(
        response['success']['group_transaction'],
        groupTransaction,
        personalTransactions,
      );
    });

    return groupTransaction;
  }

  // Future<List<Groups>> fetchRemoteGroupList() async {
  //   GroupServices groupServices = GroupServices();
  //   DateTime lastGroupFetchTime = localstore.retrieveLastGroupFetchTime();
  //   List<dynamic> response = await groupServices.fetchGroupList(
  //     lastFetchTime: lastGroupFetchTime,
  //   );
  //   List<Groups> retrievedGroups = [];
  //   for (int i = 0; i < response.length; i++) {
  //     Map groupMap = response[i];
  //     Groups group = groupFromServerMap(groupMap);
  //     retrievedGroups.add(group);
  //   }
  //   if (retrievedGroups.isNotEmpty) {
  //     localstore.updateLastGroupFetchTime(retrievedGroups.last.updatedAt);
  //   }
  //   return retrievedGroups;
  // }

  Future<List<GroupTransaction>> fetchRemoteGroupTransactionList() async {
    GroupTransactionServices groupTransactionServices =
        GroupTransactionServices();
    DateTime lastGroupTransactionFetchTime =
        localstore.retrieveLastGroupTransactionTime();

    Map response = await groupTransactionServices.fetchGroupTransactionList(
      lastFetchTime: lastGroupTransactionFetchTime,
    );
    List<dynamic> groupTransactionMapList = response['group_transactions'];

    List<GroupTransaction> retrievedGroupTransactions = [];
    for (int i = 0; i < groupTransactionMapList.length; i++) {
      dynamic groupTransactionMap = groupTransactionMapList[i];
      dynamic groupMap = groupTransactionMap['group'];
      List<dynamic> personalTransactionMapList =
          groupTransactionMap['personal_transactions'];

      Groups group = groupFromServerMap(groupMap);
      GroupTransaction groupTransaction =
          groupTransactionController.updateOrCreate(
        serverId: groupTransactionMap['id'],
        amount: groupTransactionMap['amount'],
        creatorId: groupTransactionMap['user_id'],
        createdAt: DateTime.parse(groupTransactionMap['created_at']),
        updatedAt: DateTime.parse(groupTransactionMap['updated_at']),
        group: group,
        participantsToAdd: [],
      );

      for (int j = 0; j < personalTransactionMapList.length; j++) {
        Map personalTransactionMap = personalTransactionMapList[j];

        Users targetUser;
        if (personalTransactionMap['lane_user_id'] == user.id) {
          targetUser = userController.retrieveUserFromServerId(
              personalTransactionMap['dane_user_id'])!;
        } else {
          targetUser = userController.retrieveUserFromServerId(
              personalTransactionMap['lane_user_id'])!;
        }

        transactionController.updateOrCreate(
          serverId: personalTransactionMap['id'],
          amount: personalTransactionMap['amount'].toInt(),
          laneUserId: personalTransactionMap['lane_user_id'],
          daneUserId: personalTransactionMap['dane_user_id'],
          trUserId: personalTransactionMap['user_id'],
          paymentStatus: personalTransactionMap['payment_status'],
          user: targetUser,
          groupTransactionId: groupTransaction.id,
          confirmation: personalTransactionMap['confirmation'],
          settleTransactionId: personalTransactionMap['settle_transaction_id'],
          createdAt: DateTime.parse(personalTransactionMap['created_at']),
          updatedAt: DateTime.parse(personalTransactionMap['updated_at']),
          dueDate: personalTransactionMap['due_date'] != null
              ? DateTime.parse(personalTransactionMap['due_date'])
              : null,
          category: null,
        );
      }

      usergroupController.updateOrCreate(
        entityId: group.id,
        amount: resolveAmountForActivity(
          groupTransaction.amount,
          'lane',
          'pending',
          'requested',
        ),
        name: group.groupName,
        type: UserGroupEntityType.group,
        lastActivityTime: groupTransaction.updatedAt,
      );
      retrievedGroupTransactions.add(groupTransaction);
    }

    List<dynamic> participants = response['participants'];
    for (int i = 0; i < participants.length; i++) {
      Map participant = participants[i];
      if (participant['id'] == user.id) {
        continue;
      }
      Users participantUser =
          userController.retrieveUserFromServerId(participant['id'])!;
      groupTransactionController.updateGroupTransactionParticipants(
        groupServerId: participant['group_transaction_id'],
        userList: [participantUser],
      );
    }
    if (retrievedGroupTransactions.isNotEmpty) {
      localstore
          .updateLastGroupFetchTime(retrievedGroupTransactions.last.updatedAt);
    }

    return retrievedGroupTransactions;
  }

  Future<void> resendFailedGroupTransactions() async {
    GroupServices groupServices = GroupServices();
    GroupTransactionServices groupTransactionServices =
        GroupTransactionServices();

    List<GroupTransaction> unsentTransactions =
        groupTransactionController.retrieveWithNegativeServerId();

    for (int i = 0; i < unsentTransactions.length; i++) {
      try {
        GroupTransaction t = unsentTransactions[i];
        List<TransactionsModel> pt =
            transactionController.retrieveForGroupTransactionId(t.id);

        Groups g = t.group.target!;
        if (g.serverId.isNegative) {
          await groupServices
              .createGroup(name: g.groupName, participants: g.participants)
              .then((Map<String, dynamic> response) {
            Map<String, dynamic> groupData = response['success']['group'];
            Groups updatedGroup = groupController.updateOrCreate(
              id: g.id,
              serverId: groupData['id'],
              name: g.groupName,
              profilePic: g.groupProfilePic,
              participants: g.participants,
              createdAt: DateTime.parse(groupData['created_at']),
              updatedAt: DateTime.parse(groupData['updated_at']),
            );
          });
        }
        await groupTransactionServices
            .createGroupTransaction(
          amount: t.amount,
          group: g,
          transactionParticipants: t.transactionParticipants,
        )
            .then((Map<String, dynamic> response) {
          updateLocalFromServerResponse(
            response['success']['group_transaction'],
            t,
            pt,
          );
        });
      } catch (err, stacktrace) {
        FirebaseCrashlytics.instance.recordError(err, stacktrace);
        continue;
      }
    }
  }
}
