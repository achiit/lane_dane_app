import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../utils/log_printer.dart';


// ! Response from the server
// {
//     "success": {
//         "token": "9|DcmaQco5SaylnXekoMyNIyGEWYc3Q8DeqWaGMATW",
//         "user": {
//             "id": 1,
//             "full_name": "Abdul raheem",
//             "fcm_token": null,
//             "phone_no": 9834030102,
//             "otp": "$2y$10$gKcRoN0Pea0VpwxVj9sshe34vh0YGjCpgMlYyAY7/SIVTLUBMn.ke",
//             "otp_expires_at": "2022-12-09 14:12:05",
//             "onboarded_at": "2022-12-05 17:12:28",
//             "email": null,
//             "profile_pic": null,
//             "is_demo_account": 0,
//             "created_at": "2022-12-05T17:12:11.000000Z",
//             "updated_at": "2022-12-09T13:52:05.000000Z",
//             "deleted_at": null
//         }
//     }
// }
class Auth extends ChangeNotifier {
  final log = getLogger('GetStorageHelper');
  final storage = GetStorage();
  String? _token;

  bool get isAuth {
    log.d(token);
    log.d(token != null);
    return token != null;
  }


  Future<void> saveUserAuthenticationData(Map<String, dynamic> userData) async {
    _token = token;
    final jsonData = json.encode(userData);
    log.d(jsonData);
    storage.write(
      'userData',
      userData,
    );
  }

  Future<String?> getToken() async {
    
    _token = storage.read('token');
    return _token;
  }

  String? get token {
    _token = storage.read('userData')?['token'];
    if (_token != null) {
      return _token;
    }
    return null;
  }

  logout() async {
    storage.remove('userData');
    _token = null;

    notifyListeners();
  }

//  ! Dont make any changes to the following func...as other func depends on the return type
  Future<Map<String, dynamic>> getUserData() async {
    Map<String, dynamic> userData = storage.read('userData');
    // log.d('getUserData $userData');
    return userData;
  }

  Future<Map<String, dynamic>> user() async {
    Map<String, dynamic> userData = storage.read('userData')['user'];
    log.d('user $userData');
    return userData;
  }

  Future<String> getUserId() async {
    Map<String, dynamic> user = await getUserData();
    log.d(' getUserId: ${user['user']['id']}');
    return user['user']['id'].toString();
  }

  Future<bool> tryAutoLogin() async {

    if (!storage.hasData('userData')) {
      log.d('No token found during auto-login');
      return false;
    }

    log.d('token found during auto-login');

    _token = storage.read('userData')['token'];
    log.d('$_token after reading from storage');
    notifyListeners();
    return true;
  }
}
