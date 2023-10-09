import 'package:flutter/material.dart';
import 'package:lane_dane/models/categories_model.dart';
import 'package:lane_dane/models/group_model.dart';
import 'package:lane_dane/models/users.dart';
import 'package:lane_dane/utils/constants.dart';
import 'package:lane_dane/helpers/auth.dart';
import 'package:logger/logger.dart';
import 'package:lane_dane/utils/log_printer.dart';
import 'package:lane_dane/api/http_services.dart';

class GroupTransactionServices {
  late final Auth auth;
  late final HttpServices services;
  late String? token;
  late final Logger log;
  late bool https;
  GroupTransactionServices() {
    auth = Auth();
    token = auth.token;
    services = HttpServices(
      host: Constants.host,
      defaultHeader: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      defaultToHTTPS: Constants.defaultToHttps,
    );
    log = getLogger('AuthServices');
  }

  Future<Map<String, dynamic>> createGroupTransaction({
    required int amount,
    required Groups group,
    CategoriesModel? category,
    required List<Users> transactionParticipants,
  }) async {
    try {
      List<Map<String, dynamic>> participantList =
          transactionParticipants.map<Map<String, dynamic>>((Users u) {
        return {
          'id': u.serverId,
          'phone_no': u.phoneNumberWithCode,
          'full_name': u.full_name,
        };
      }).toList();

      Map<String, dynamic> response =
          await services.post('/api/create-group-transaction', body: {
        'amount': amount,
        'group_id': group.id,
        'category': category?.toMap(),
        'transaction_participants': participantList,
      });

      return response;
    } catch (err) {
      rethrow;
    }
  }

  Future<Map> fetchGroupTransactionList({
    required DateTime lastFetchTime,
  }) async {
    Map<String, dynamic> response =
        await services.post('/api/fetch-group-transactions', body: {
      'last_fetch_time': lastFetchTime.toString(),
    });

    return response['success'];
  }
}
