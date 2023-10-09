import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lane_dane/app_controller.dart';
import 'package:lane_dane/api/http_services.dart';
import 'package:lane_dane/errors/improper_data_recieved.dart';
import 'package:lane_dane/helpers/auth.dart';
import 'package:lane_dane/models/users.dart';
import 'package:lane_dane/models/auth_user.dart';
import 'package:lane_dane/utils/log_printer.dart';
import 'package:lane_dane/utils/constants.dart';
import 'package:lane_dane/utils/date_time_extensions.dart';
import 'package:logger/logger.dart';
import 'package:lane_dane/models/transactions.dart';

class TransactionServices {
  late final Logger log;
  late final Auth auth;
  late final HttpServices services;
  late String? token;
  late bool https;

  TransactionServices() {
    log = getLogger('AuthServices');
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
  }

  Future<List<dynamic>> getRemoteTransactions(
    DateTime after,
  ) async {
    try {
      Map<String, dynamic> responseBody = await services.post(
        '/api/fetch-transactions',
        body: {
          'last_transaction_fetch': DateFormat('y-M-d H:m:s').format(after),
        },
      );

      if (!responseBody.containsKey('success')) {
        throw ImproperDataRecieved(
          message:
              'Failed to fetch transactions. The server responded with invalid data',
          missingData: 'success',
          object: responseBody,
        );
      }
      Map<String, dynamic> responseSuccess = responseBody['success'];
      if (!responseSuccess.containsKey('transactions')) {
        throw ImproperDataRecieved(
          message:
              'Failed to fetch transactions. The server responded with invalid data',
          missingData: 'transactions',
          object: responseBody,
        );
      }
      List<dynamic> responseTransactions = responseSuccess['transactions'];
      return responseTransactions;
    } catch (err) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> remoteAddTransaction(
    TransactionsModel transaction,
    Users user,
  ) async {
    final AppController appController = Get.find();
    AuthUser authUser = appController.user;

    int creatorId = authUser.id;
    String creatorPhoneNumber = authUser.phoneNumberWithCode.toString();
    String creatorName = authUser.fullName;

    bool laneIsCreator =
        transaction.transactionType == TransactionType.Lane.name;
    try {
      Map<String, dynamic> responseBody = await services.post(
        '/api/save-transaction',
        body: {
          "transaction": {
            "id": transaction.id,
            "amount": transaction.amount,
            "payment_status": transaction.paymentStatus,
            "due_date": transaction.dueDate != null
                ? DateFormat('yyyy-MM-dd').format(transaction.dueDate!)
                : null,
            "lane_user": transaction.lane_user_id,
            "dane_user": transaction.dane_user_id,
          },
          "category": transaction.category.target?.message == null
              ? null
              : {
                  "id": -1,
                  "name": transaction.category.target?.message,
                },
          "laneUser": {
            "id": laneIsCreator ? creatorId : user.serverId,
            "phone_no":
                laneIsCreator ? creatorPhoneNumber : user.phoneNumberWithCode,
            "full_name": laneIsCreator ? creatorName : user.full_name,
          },
          "daneUser": {
            "id": laneIsCreator ? user.serverId : creatorId,
            "phone_no":
                laneIsCreator ? user.phoneNumberWithCode : creatorPhoneNumber,
            "full_name": laneIsCreator ? user.full_name : creatorName,
          },
        },
      );

      if (!responseBody.containsKey('success')) {
        throw ImproperDataRecieved(
          message:
              'Failed to create transaction. The server responded with invalid data',
          missingData: 'success',
          object: responseBody,
        );
      }
      Map<String, dynamic> responseSuccess = responseBody['success'];
      if (!responseSuccess.containsKey('transaction') &&
          !responseSuccess.containsKey('category') &&
          !responseSuccess.containsKey('lane_user') &&
          !responseSuccess.containsKey('dane_user')) {
        throw ImproperDataRecieved(
          message:
              'Failed to create transaction. The server responded with invalid data',
          missingData: 'transaction || category || lane_user || dane_user',
          object: responseSuccess,
        );
      }
      return responseSuccess;
    } catch (err) {
      rethrow;
    }
  }

  Future<bool> remoteConfirmTransaction(
    TransactionsModel transaction,
    Confirmation confirmation,
  ) async {
    try {
      List<dynamic> responseBody = await services.post(
        '/api/confirm-transaction',
        body: {
          "server_id": transaction.serverId,
          "confirmation": confirmation.name.toLowerCase(),
        },
      );

      bool responseSuccessStatus = responseBody[0] == 'success';
      return responseSuccessStatus;
    } catch (err) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> settleUpTransaction(
    TransactionsModel transaction,
    int settledTransactionId,
  ) async {
    final AppController appController = Get.find();
    AuthUser authUser = appController.user;

    int creatorId = authUser.id;
    String creatorPhoneNumber = authUser.phoneNumberWithCode.toString();
    String creatorName = authUser.fullName;

    bool laneIsCreator =
        transaction.transactionType == TransactionType.Lane.name;

    Users user = transaction.user.target!;
    try {
      dynamic responseBody = await services.post(
        '/api/settle-up',
        body: {
          'server_id': settledTransactionId,
          "transaction": {
            "id": transaction.id,
            "amount": transaction.amount,
            "payment_status": transaction.paymentStatus,
            "due_date": transaction.dueDate != null
                ? DateFormat('yyyy-MM-dd').format(transaction.dueDate!)
                : null,
            "lane_user": transaction.lane_user_id,
            "dane_user": transaction.dane_user_id,
          },
          "category": transaction.category.target?.message == null
              ? null
              : {
                  "id": -1,
                  "name": transaction.category.target?.message,
                },
          "laneUser": {
            "id": laneIsCreator ? creatorId : user.serverId,
            "phone_no":
                laneIsCreator ? creatorPhoneNumber : user.phoneNumberWithCode,
            "full_name": laneIsCreator ? creatorName : user.full_name,
          },
          "daneUser": {
            "id": laneIsCreator ? user.serverId : creatorId,
            "phone_no":
                laneIsCreator ? user.phoneNumberWithCode : creatorPhoneNumber,
            "full_name": laneIsCreator ? user.full_name : creatorName,
          },
        },
      );
      return responseBody['success']['transaction'];
    } catch (err) {
      rethrow;
    }
  }
}






// class TransactionServices {
//   //* This will fetch all contacts frocm the backend   --> GET REQUEST
//   Future<List<dynamic>> getRemoteTransactions(
//     DateTime after,
//   ) async {
//     String? token = Auth().token;
//     http.Response response = await http.post(
//       Uri.parse('$address/api/fetch-transactions'),
//       headers: {
//         'Accept': 'application/json',
//         'Authorization': 'Bearer $token',
//         'Content-type': 'application/json',
//       },
//       body: json.encode({
//         'last_transaction_fetch': DateFormat('y-M-d H:m:s').format(after),
//       }),
//     );

//     if (response.statusCode >= 500) {
//       throw ServerError(
//         message: 'A server error was recieved while making this request',
//         response: response,
//       );
//     }
//     if (response.statusCode > 401) {
//       throw UnauthorizedError(
//         message: 'Session timed out, log in again',
//         response: response,
//       );
//     }
//     if (response.statusCode > 299 || response.statusCode < 200) {
//       throw RequestError(
//         message: 'Failed to fetch transactions from server',
//         response: response,
//       );
//     }

//     Map<String, dynamic> responseBody = json.decode(response.body);
//     if (!responseBody.containsKey('success')) {
//       throw RequestError(
//         message:
//             'Failed to fetch transactions. The server responded with invalid data',
//         response: response,
//       );
//     }
//     Map<String, dynamic> responseSuccess = responseBody['success'];
//     if (!responseSuccess.containsKey('transactions')) {
//       throw RequestError(
//         message:
//             'Failed to fetch transactions. The server responded with invalid data',
//         response: response,
//       );
//     }
//     List<dynamic> responseTransactions = responseSuccess['transactions'];
//     return responseTransactions;
//   }

//   Future<Map<String, dynamic>> remoteAddTransaction(
//     TransactionsModel transaction,
//     Users user,
//   ) async {
//     String? token = Auth().token;
//     Map<String, dynamic> userData = await Auth().getUserData();
//     int creatorId = userData['user']['id'];
//     String creatorPhoneNumber = userData['user']['phone_no'].toString();
//     String creatorName = userData['user']['full_name'];

//     bool laneIsCreator =
//         transaction.transactionType == TransactionType.Lane.name;

//     http.Response response = await http.post(
//       Uri.parse('$address/api/save-transaction'),
//       headers: {
//         'Content-type': "application/json",
//         'Authorization': "Bearer $token",
//         'Accept': 'application/json',
//       },
//       body: json.encode(
//         {
//           "transaction": {
//             "id": transaction.id,
//             "amount": transaction.amount,
//             "payment_status": transaction.paymentStatus,
//             "lane_user": transaction.lane_user_id,
//             "dane_user": transaction.dane_user_id,
//           },
//           "category": transaction.category.target?.message == null
//               ? null
//               : {
//                   "id": -1,
//                   "name": transaction.category.target?.message,
//                 },
//           "laneUser": {
//             "id": laneIsCreator ? creatorId : user.serverId,
//             "phone_no":
//                 laneIsCreator ? creatorPhoneNumber : '91${user.phone_no}',
//             "full_name": laneIsCreator ? creatorName : user.full_name,
//           },
//           "daneUser": {
//             "id": laneIsCreator ? user.serverId : creatorId,
//             "phone_no":
//                 laneIsCreator ? '91${user.phone_no}' : creatorPhoneNumber,
//             "full_name": laneIsCreator ? user.full_name : creatorName,
//           },
//         },
//       ),
//     );

//     if (response.statusCode >= 500) {
//       throw ServerError(
//         message: 'A server error was recieved while making this request',
//         response: response,
//       );
//     }
//     if (response.statusCode > 401) {
//       throw UnauthorizedError(
//         message: 'Session timed out, log in again',
//         response: response,
//       );
//     }
//     if (response.statusCode > 299 || response.statusCode < 200) {
//       throw RequestError(
//         message: 'Failed to create transaction',
//         response: response,
//       );
//     }

//     Map<String, dynamic> responseBody = json.decode(response.body);
//     if (!responseBody.containsKey('success')) {
//       throw RequestError(
//         message:
//             'Failed to create transaction. The server responded with invalid data',
//         response: response,
//       );
//     }
//     Map<String, dynamic> responseSuccess = responseBody['success'];
//     if (!responseSuccess.containsKey('transaction') &&
//         !responseSuccess.containsKey('category') &&
//         !responseSuccess.containsKey('lane_user') &&
//         !responseSuccess.containsKey('dane_user')) {
//       throw ServerError(
//           message:
//               'Failed to create transaction. The server responded with invalid data',
//           response: response);
//     }
//     return responseSuccess;
//   }

//   Future<bool> remoteConfirmTransaction(
//       TransactionsModel transaction, Confirmation confirmation) async {
//     String? token = Auth().token;

//     http.Response response = await http.post(
//       Uri.parse('$address/api/confirm-transaction'),
//       headers: {
//         'Content-type': "application/json",
//         'Authorization': "Bearer $token",
//         'Accept': 'application/json',
//       },
//       body: json.encode({
//         "server_id": transaction.serverId,
//         "confirmation": confirmation.name.toLowerCase(),
//       }),
//     );

//     if (response.statusCode >= 500) {
//       throw ServerError(
//         message: 'A server error was recieved while making this request',
//         response: response,
//       );
//     }
//     if (response.statusCode >= 401) {
//       throw UnauthorizedError(
//         message: 'Session timed out, log in again',
//         response: response,
//       );
//     }
//     if (response.statusCode > 299 || response.statusCode < 200) {
//       throw RequestError(
//         message: 'Failed to confirm transaction',
//         response: response,
//       );
//     }

//     List<dynamic> responseBody = json.decode(response.body);

//     bool responseSuccessStatus = responseBody[0] == 'success';
//     return responseSuccessStatus;
//   }

// // * To put contacts on the backend -> POST request
//   // Future<void> postTransactions({
//   //   int? local_id,
//   //   required BuildContext context,
//   //   required int user_id,
//   //   required int user_contact_id,
//   //   required int amount,
//   //   required String confirmation,
//   //   required String transaction_type,
//   //   required String payment_status,
//   //   required int category_id,
//   // }) async {
//   //   try {
//   //     TransactionsModel userTnx = TransactionsModel(
//   //       amount: amount.toString(),
//   //       paymentStatus: payment_status,
//   //       tr_user_id: user_id,
//   //       confirmation: confirmation,

//   //       category_id: category_id,
//   //     );

//   //     var response = await http.post(
//   //       Uri.parse('$DOMAIN/api/post-transaction'),
//   //       headers: {
//   //         'Content-Type': 'application/json; charset=UTF-8',
//   //       },
//   //       body: userTnx.toJson(),
//   //     );

//   //     httpErrorHandler(
//   //       res: response,
//   //       context: context,
//   //       onSuccess: () {
//   //         showSnackBar(context, 'Transaction posted success');
//   //       },
//   //     );
//   //   } catch (e) {
//   //     showSnackBar(context, e.toString() + ' in TransactionServices.dart');
//   //   }
//   // }
// }
