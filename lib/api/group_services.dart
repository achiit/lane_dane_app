import 'package:flutter/material.dart';
import 'package:lane_dane/models/users.dart';
import 'package:lane_dane/utils/constants.dart';
import 'package:lane_dane/helpers/auth.dart';
import 'package:logger/logger.dart';
import 'package:lane_dane/utils/log_printer.dart';
import 'package:lane_dane/api/http_services.dart';

class GroupServices {
  late final Auth auth;
  late final HttpServices services;
  late String? token;
  late final Logger log;
  late bool https;
  GroupServices() {
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

  Future<Map<String, dynamic>> createGroup({
    required String name,
    String? profilePic,
    required List<Users> participants,
  }) async {
    try {
      List<Map<String, dynamic>> participantList =
          participants.map<Map<String, dynamic>>((Users u) {
        return {
          'phone_no': u.phoneNumberWithCode,
          'full_name': u.full_name,
        };
      }).toList();

      Map<String, dynamic> response =
          await services.post('/api/create-group', body: {
        'group_name': name,
        'profile_pic': profilePic,
        'group_participants': participantList,
      });

      return response;
    } catch (err) {
      rethrow;
    }
  }

  Future<List<dynamic>> fetchGroupList({
    required DateTime lastFetchTime,
  }) async {
    try {
      Map<String, dynamic> response =
          await services.post('/api/fetch-groups', body: {
        'last_fetch_time': lastFetchTime.toString(),
      });
      print(response['success'].runtimeType);
      return response['success'];
    } catch (err) {
      rethrow;
    }
  }
}
