import 'package:flutter/material.dart';
import 'package:lane_dane/utils/constants.dart';
import 'package:logger/logger.dart';
import 'package:lane_dane/utils/log_printer.dart';
import 'package:lane_dane/api/http_services.dart';

class AuthServices {
  late final HttpServices services;
  late final Logger log;
  late bool https;
  AuthServices() {
    services = HttpServices(
      host: Constants.host,
      defaultHeader: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      defaultToHTTPS: Constants.defaultToHttps,
    );
    log = getLogger('AuthServices');
  }

  Future<Map<String, dynamic>> getOtp({
    BuildContext? context,
    required int phone,
  }) async {
    try {
      Map<String, dynamic> responseBody = await services.post(
        '/api/verify-contact',
        query: {
          'phone_no': phone.toString(),
        },
      );

      return responseBody;
    } catch (err) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register({
    BuildContext? context,
    required int phone,
    required String full_name,
    required String otp,
    required bool businessAccount,
    required String? fcmToken,
  }) async {
    try {
      Map<String, dynamic> responseBody = await services.post(
        '/api/register',
        body: {
          'phone_no': phone.toString(),
          'full_name': full_name,
          'otp': otp,
          'business_account': businessAccount,
          'fcm_token': fcmToken,
        },
      );
      return responseBody;
    } catch (err) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login({
    BuildContext? context,
    required int phone,
    required String otp,
    required String? fcmToken,
  }) async {
    try {
      Map<String, dynamic> responseBody =
          await services.post('/api/login', query: {
        'phone_no': phone.toString(),
        'otp': otp,
        'fcm_token': fcmToken,
      });
      return responseBody;
    } catch (err) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> refreshToken(
      String newToken, String bearer) async {
    try {
      Map<String, dynamic> responseBody = await services.post(
        '/api/refresh-fcmtoken',
        header: {
          'Authorization': 'Bearer $bearer',
        },
        body: {
          'fcm_token': newToken,
        },
      );

      return responseBody;
    } catch (err) {
      log.e(err.toString());
      rethrow;
    }
  }
}

// //* @suhailbilalo Local IP
// // String address = 'http://192.168.100.32:8000';

// //* Main Server
String address = 'https://lanedane.vue-technologies.com';

// //* @Abood2284 Local IP
// // String address = 'http://192.168.0.12:8080';

// // *@abdulaziz local IP
// // String address = 'http://localhost:8000';

// class AuthServices {
//   final log = getLogger('AuthServices');

//   Future<Map<String, dynamic>> getOtp(
//       {required BuildContext context, required int phone}) async {
//     Map<String, dynamic> response = {};
//     try {
//       //print('https://'+address+'/api/verify-contact?phone_no=$phone');
//       var res = await http.post(
//           Uri.parse('$address/api/verify-contact?phone_no=$phone'),
//           headers: <String, String>{'Accept': 'application/json'});
//       print(res.statusCode);
//       log.d(res.body);
//       log.d('message');
//       log.d(jsonDecode(res.body));

//       if (res.statusCode >= 500) {
//         throw ServerError(
//           message:
//               'Failed to generate One Time Password. A server error was recieved.',
//           response: res,
//         );
//       }
//       if (res.statusCode > 299 || res.statusCode < 200) {
//         throw RequestError(
//           message:
//               'Failed to generate One Time Password. A request error was recieved.',
//           response: res,
//         );
//       }

//       httpErrorHandler(
//           res: res,
//           context: context,
//           onSuccess: () {
//             response = jsonDecode(res.body);
//           });
//       return response;
//     } catch (e) {
//       log.e(e.toString());
//       rethrow;
//     }
//   }

//   Future<Map<String, dynamic>?> register({
//     required BuildContext context,
//     required int phone,
//     required String full_name,
//     required String otp,
//   }) async {
//     Map<String, dynamic>? response;
//     try {
//       var res = await http.post(
//           Uri.parse(
//               '$address/api/register?phone_no=$phone&otp=$otp&full_name=$full_name'),
//           headers: <String, String>{'Accept': 'application/json'});
//       log.i(res.statusCode);

//       if (res.statusCode > 500) {
//         throw ServerError(
//           message: 'Failed to register the user. A server error was recieved.',
//           response: res,
//         );
//       }
//       if (res.statusCode == 401) {
//         throw UnauthorizedError(
//             message:
//                 'Could not authenticate user. Unregistered phone number or invalid One Time Password',
//             response: res);
//       }
//       if (res.statusCode > 299 || res.statusCode < 200) {
//         throw RequestError(
//           message: 'Failed to register the user. A request error was recieved.',
//           response: res,
//         );
//       }

//       httpErrorHandler(
//           res: res,
//           context: context,
//           onSuccess: () {
//             response = jsonDecode(res.body);
//           });
//     } catch (e) {
//       log.e(e.toString());
//       rethrow;
//     }
//     return response;
//   }

//   Future<Map<String, dynamic>?> login({
//     required BuildContext context,
//     required int phone,
//     required String otp,
//   }) async {
//     Map<String, dynamic>? response;
//     try {
//       var res = await http.post(
//           Uri.parse('$address/api/login?phone_no=$phone&otp=$otp'),
//           headers: <String, String>{'Accept': 'application/json'});

//       log.i(res.statusCode);

//       if (res.statusCode > 500) {
//         throw ServerError(
//           message:
//               'Failed to verify One Time Password. A server error was recieved.',
//           response: res,
//         );
//       }
//       if (res.statusCode == 401) {
//         throw UnauthorizedError(
//             message:
//                 'Could not authenticate user. Unregistered phone number or invalid One Time Password',
//             response: res);
//       }
//       if (res.statusCode > 299 || res.statusCode < 200) {
//         throw RequestError(
//           message:
//               'Failed to verify One Time Password. A request error was recieved.',
//           response: res,
//         );
//       }

//       httpErrorHandler(
//           res: res,
//           context: context,
//           onSuccess: () {
//             response = jsonDecode(res.body);
//           });
//       return response;
//     } catch (e) {
//       log.e(e.toString());
//       rethrow;
//     }
//   }

//   Future<Map<String, dynamic>?> getUserID(String phone) async {
//     Map<String, dynamic>? response;
//     var res = await http.post(
//         Uri.parse('$address/api/user-contact?contact_no=$phone'),
//         headers: <String, String>{'Accept': 'application/json'});
//     log.i('status-code:' + res.statusCode.toString());
//     response = jsonDecode(res.body);
//     log.i(response?.length);
//     //int userid = response?.values.first;
//     //log.d(userid);
//     if (res.statusCode == 200) {
//       return response;
//     } else {
//       return null;
//     }
//   }

// // ! MOVED TO contact_services.dart file by @Abood2284
//   // insertUserContacts(String userContacts) async {
//   //   Map<String, dynamic>? response;
//   //   var res = await http.post(Uri.parse('$address/api/v1/fetch-contacts'),
//   //       headers: <String, String>{
//   //         'Accept': 'application/json',
//   //         'Content-type': "application/json",
//   //         'Authorization': 'Bearer 1|y35mK4iLyCJNWBtgEJWPYGWWcjY0WftC28qvA2Q1'
//   //       },
//   //       body: userContacts);
//   //   log.i('status-code:' + res.body);
//   //   //response = jsonDecode(res.body);
//   //   log.i(response?.length);
//   //   //int userid = response?.values.first;
//   //   //log.d(userid);
//   //   if (res.statusCode == 200) {
//   //     return response;
//   //   } else {
//   //     return null;
//   //   }
//   // }
// }

