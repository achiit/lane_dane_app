import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lane_dane/app_controller.dart';
import 'package:lane_dane/controllers/users_controller.dart';
import 'package:lane_dane/models/all_transaction.dart';
import 'package:lane_dane/models/transactions.dart';
import 'package:lane_dane/views/pages/selectContact.dart';
import 'package:lane_dane/views/pages/transaction/transaction_details.dart';
import 'package:lane_dane/views/widgets/all_transaction_list_builder.dart';
import 'package:lane_dane/utils/log_printer.dart';

class HomeSearchDelegate extends SearchDelegate {
  HomeSearchDelegate();

  final log = getLogger('homeSearchDelegate');
  final AppController appController = Get.find();

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (query.isEmpty) {
              close(context, null);
            } else {
              query = '';
            }
          },
        ),
      ];

  @override
  String get searchFieldLabel => "Search Transaction";

  /// * What you want to do when the user submits the search
  /// * This is the method that is called when the user submits the search
  /// This needs to return a widget, since what we are doing is returning a widget
  /// that will be displayed in the body of the search page
  /// Instead before displaying the widget, we are closing the search page taking the query with us
  /// and then returning the query to the previous page
  @override
  Widget buildResults(BuildContext context) {
    // close(context, query);
    // final categories = [];
    // final result =
    //     categories.where((element) => element.name.startsWith(query)).toList();

    // log.i('Result size ${result.length}');

    // if (result.isEmpty) {
    //   var category = CategoriesModel(id: -1, name: query);
    //   categories.add(category);
    //   log.i('Result size + ${result.length}');
    //   // close(context, category);
    // }

    List<AllTransactionObjectBox> completeList =
        appController.allTransactionController.getAllTransactions();

    List<AllTransactionObjectBox> filteredList =
        completeList.where((AllTransactionObjectBox t) {
      if (double.parse(t.amount)
          .toInt()
          .toString()
          .isCaseInsensitiveContains(query)) {
        /// Some transactions are parsed as strings containing double values.
        /// So convert them to int values and then back to string before
        /// comparing.
        return true;
      } else if (t.name.isCaseInsensitiveContains(query)) {
        return true;
      } else {
        return false;
      }
    }).toList();

    return listBuilder(filteredList);

    //  StreamBuilder<List<CategoriesModel>>(
    //   stream: Stream.fromIterable([categories]),
    //   builder: (context, snapshot) {
    //     if (snapshot.hasData) {
    //       return ListView.builder(
    //         itemCount: snapshot.data!.length,
    //         itemBuilder: (context, index) {
    //           return ListTile(
    //             title: Text(snapshot.data![index].name),
    //             onTap: () {
    //               Navigator.pop(context, snapshot.data![index]);
    //             },
    //           );
    //         },
    //       );
    //     } else {
    //       return const Center(child: CircularProgressIndicator());
    //     }
    //   },
    // );
  }

  /// * These are the search suggestions that are displayed when the user types in the search field
  /// or he doesnt type anything in the search field
  /// These siggestions are stored in a list of strings in the previous screen and passed to this as a parameter
  /// On query pressed we are adding the query to the list of suggestions
  /// ! But the added query is removed from the list of suggestions after a list and is not displayed in the search results
  /// It also provides user suggestion based on the first letter of the query
  /// If user types F -> all words in our list of suggestions that start with F are displayed in the search results page capital or Non-capital doesnt matter
  @override
  Widget buildSuggestions(BuildContext context) {
    // final _suggestions = categoryModel.where((element) =>
    //     element.name.toLowerCase().startsWith(query.toLowerCase()));
    // log.i('Suggestions ${_suggestions.length}');

    // List<String> suggestions = searchResults.where((searchResult) {
    // final result = searchResult.toLowerCase();
    // final input = query.toLowerCase();
    // return result.startsWith(input);
    // }).toList();
    return buildResults(context);
    // ListView.builder(
    //   itemCount: _suggestions.length,
    //   itemBuilder: ((context, index) {
    //     final result = _suggestions.elementAt(index);
    //     return ListTile(
    //       leading: const Icon(Icons.history, color: Color(0xFF128C7E)),
    //       trailing: const Icon(Icons.close, color: Color(0xFF128C7E)),
    //       title: Text(result.name),
    //       onTap: () {
    //         // query = suggestion;
    //         close(context, result);
    //         showSnackBar(context,
    //             'Object Passed: name: ${result.name} id: ${result.id}');
    //         // showResults(context);
    //       },
    //     );
    //   }),
    // );
  }

  Widget listBuilder(List<AllTransactionObjectBox> list) {
    return Align(
      alignment: Alignment.topCenter,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: list.length,
        itemBuilder: (context, index) {
          AllTransactionObjectBox alltransaction = list[index];
          bool isSms = alltransaction.transactionId.targetId == 0;

          TransactionsModel? transaction;
          if (!isSms) {
            transaction = appController.transactionController
                .retrieveOnly(alltransaction.transactionId.target?.id ?? 0);
          }

          return AllTransactionListTile(
            alltransaction: alltransaction,
            isSms: isSms,
            navigationCallback: () {
              if (isSms) {
                /// A map that is being passed to the next screen.
                final singleSmsData = {
                  'amount': alltransaction.amount,
                  'id': alltransaction.id
                };
                log.i(singleSmsData['id']);
                log.i(singleSmsData['amount']);
                Navigator.of(context).pushNamed(SelectContact.routeName,
                    arguments: singleSmsData);
              } else {
                Navigator.of(context).pushNamed(
                  TransactionDetails.routeName,
                  arguments: {
                    'transaction': transaction,
                    'contact':
                        UserHelper().retrieveOnly(transaction!.user.targetId),
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}
