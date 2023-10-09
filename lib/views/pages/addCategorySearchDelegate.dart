import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lane_dane/controllers/category_controller.dart';

import '../../utils/log_printer.dart';
import '../../models/categories_model.dart';
import '../shared/snack-bar.dart';

class addCategorySearchDelegate extends SearchDelegate<CategoriesModel?> {
  addCategorySearchDelegate({required this.categoryModel});

  final List<CategoriesModel> categoryModel;

  final log = getLogger('addCategorySearchDelegate');

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
  String get searchFieldLabel => 'enter_category'.tr;

  /// * What you want to do when the user submits the search
  /// * This is the method that is called when the user submits the search
  /// This needs to return a widget, since what we are doing is returning a widget
  /// that will be displayed in the body of the search page
  /// Instead before displaying the widget, we are closing the search page taking the query with us
  /// and then returning the query to the previous page
  @override
  Widget buildResults(BuildContext context) {
    final categories = categoryModel;
    final result = categories
        .where((element) => element.message.startsWith(query))
        .toList();

    log.i('Result size ${result.length}');

    if (result.isEmpty) {
      CategoriesModel category =
          CategoryController().create(categoryName: query);
      result.add(category);
      categories.add(category);
      log.i('Result size + ${result.length}');
      // close(context, category);
    }

    return buildSuggestions(context);

    // close(context, query);
    return StreamBuilder<List<CategoriesModel>>(
      stream: Stream.fromIterable([result]),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(snapshot.data![index].message),
                onTap: () {
                  Navigator.pop(context, snapshot.data![index]);
                },
              );
            },
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );

    // return ListView.builder(
    //   itemCount: result.length,
    //   itemBuilder: (context, index) {
    //     return ListTile(
    //       onTap: () {
    //         log.i(result[index]);
    //         close(context, result[index].name);
    //       },
    //       title: Text(result[index].name),
    //     );
    //   },
    // );
  }

  /// * These are the search suggestions that are displayed when the user types in the search field
  /// or he doesn't type anything in the search field
  /// These suggestions are stored in a list of strings in the previous screen and passed to this as a parameter
  /// On query pressed we are adding the query to the list of suggestions
  /// ! But the added query is removed from the list of suggestions after a list and is not displayed in the search results
  /// It also provides user suggestion based on the first letter of the query
  /// If user types F -> all words in our list of suggestions that start with F are displayed in the search results page capital or Non-capital doesn't matter
  @override
  Widget buildSuggestions(BuildContext context) {
    final _suggestions = categoryModel.where((CategoriesModel element) {
      return element.message.isCaseInsensitiveContains(query);
    }).toList();

    if (!_suggestions.any((CategoriesModel c) {
          return c.message == query;
        }) &&
        query.isNotEmpty) {
      CategoriesModel category =
          CategoriesModel(message: query, lastAccessed: DateTime.now());
      _suggestions.insert(0, category);
    }

    log.i('Suggestions ${_suggestions.length}');

    // List<String> suggestions = searchResults.where((searchResult) {
    // final result = searchResult.toLowerCase();
    // final input = query.toLowerCase();
    // return result.startsWith(input);
    // }).toList();

    return ListView.builder(
      itemCount: _suggestions.length,
      itemBuilder: ((context, index) {
        var result = _suggestions.elementAt(index);
        return ListTile(
          leading: const Icon(Icons.history, color: Color(0xFF128C7E)),
          // trailing: const Icon(Icons.close, color: Color(0xFF128C7E)),
          title: Text(result.message),
          onTap: () {
            CategoryController categoryController = CategoryController();
            if (result.id == null) {
              result = categoryController.create(categoryName: result.message);
              _suggestions.add(result);
            }
            result.lastAccessed = DateTime.now();
            categoryController.update(result);
            categoryModel.remove(result);
            categoryModel.insert(0, result);
            // query = suggestion;
            close(context, result);
            // showResults(context);
          },
        );
      }),
    );
  }
}
