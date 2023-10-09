import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:http/http.dart' as http;
import 'package:lane_dane/controllers/contact_controller.dart';
import 'package:lane_dane/errors/request_error.dart';
import 'package:lane_dane/errors/unauthorized_error.dart';
import 'package:lane_dane/helpers/auth.dart';
import 'package:lane_dane/models/users.dart';
import 'package:lane_dane/utils/constants.dart';
import 'package:lane_dane/views/shared/http_error_handling.dart';
import 'package:lane_dane/views/shared/snack-bar.dart';

import '../utils/log_printer.dart';

//* @suhailbilalo Local IP
// String address = 'http://192.168.100.32:8000';

//* Main Server
String address = 'https://lanedane.vue-technologies.com';

//* @Abood2284 Local IP
// String address = 'http://172.20.10.2:8080';
// String address = 'http://192.168.254.131:8080';
//* @Abood2284 Local Token
// 1|6HTV29VfaHUqNLhdqyVRcMfuv8ItifIDM2SnCCKV

// String address = 'http://localhost:8000';

class ContactServices {
  final log = getLogger('Contact Services');

  /// Fetching all the contacts from the backend.
  Future<List<Users>> getContacts(
      {required BuildContext context, required int userId}) async {
    final List<Users> userContactsFromBackend = [];
    try {
      var res = await http
          .get(Uri.parse('$address/user/get-contacts?user_id=$userId'));
      httpErrorHandler(
          res: res,
          context: context,
          onSuccess: () {
            for (int i = 0; i < jsonDecode(res.body).length; i++) {
              userContactsFromBackend.add(
                Users.fromJson(
                  jsonEncode(
                    jsonDecode(res.body)[i],
                  ),
                ),
              );
            }
          });
    } catch (e) {
      showSnackBar(context, e.toString() + 'in contactServices.dart');
    }
    return userContactsFromBackend;
  }

  /// Sync local contact list with server user list
  ///
  /// Pass a list of Contact objects in arguments.
  /// Returns a list of map objects that contains contact details from server
  /// Preferably use this to only sync newly created contacts
  Future<dynamic> syncContacts(List<Contact> userContacts) async {
    final String? token = await Auth().token;

    if (token == null) {
      throw 'NOT_AUTHORIZED';
    }

    List<Map<String, dynamic>> contactMapList =
        userContacts.map((Contact contact) {
      return {
        "contact_no": contact.formattedPhoneNumber,
        "id": null,
        "contact_name": contact.displayName,
      };
    }).toList();

    http.Response response = await http.post(
      Uri.parse('$address/api/fetch-contacts'),
      headers: <String, String>{
        'Content-type': "application/json",
        'Authorization': "Bearer $token",
        'Accept': 'application/json',
      },
      body: json.encode({
        "contacts_data": contactMapList,
      }),
    );

    log.i('status-code:' + response.statusCode.toString());
    //int userid = response?.values.first;
    //log.d(userid);
    log.d(response.body);
    log.close();
    if (response.statusCode == 401) {
      throw UnauthorizedError(
          message: 'Session timed out, log in again', response: response);
    }
    if (response.statusCode != 200) {
      throw RequestError(
          message: 'Failed to sync contacts, try again later',
          response: response);
    }
    Map<String, dynamic> responseBody = jsonDecode(response.body);
    if (!responseBody.containsKey('success')) {
      throw RequestError(
          message: 'Server responded with invalid data, try again later',
          response: response);
    }
    Map<String, dynamic> successBody = responseBody['success'];
    if (!successBody.containsKey('users')) {
      throw RequestError(
          message: 'Server responded with invalid data, try again later',
          response: response);
    }
    List<dynamic> usersBody = successBody['users'];

    return usersBody;
  }

  // Future<void> postContacts({
  //   required BuildContext context,
  //   required List<UserContacts> contacts_data,
  // }) async {
  //   try {
  //     var url = DOMAIN + '/api/fetch-contact';
  //     // for (var element in contacts_data) {
  //     // log.i(element.toJson());
  //     // }
  //     await http
  //         .post(
  //       Uri.parse(url),
  //       headers: {
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //       body: jsonEncode(contacts_data),
  //     )
  //         .then((http.Response res) {
  //       log.d('Response: ' + res.body);
  //       final int statusCode = res.statusCode;
  //       if (statusCode < 200 || statusCode > 400) {
  //         throw Exception("Error while fetching data");
  //       }
  //       var result = jsonDecode(res.body);
  //       return UserContacts.fromJson(result['success']);
  //       // return UserContacts.fromJson(jsonDecode(res.body));
  //     });
  //   } catch (e) {
  //     log.e(e.toString());
  //     // showSnackBar(context, e.toString() + 'in contactServices.dart');
  //   }
  // }
}
