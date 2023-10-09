import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

class LocalStore {
  /*
   * Field names
   */

  static const String lastTransactionTimeKey = 'last-update';
  static const String lastSmsQuery = 'last-sms-query';
  static const String userLocale = 'user-locale';
  static const String fieldTransactionsCreatedCounter =
      'created-transaction-counter-field';
  static const String fieldLastGroupFetchTime = 'last-group-fetch-time';
  static const String fieldLastGroupTransactionFetchTime =
      'last-group-transaction-fetch-time';

  GetStorage store = GetStorage();
  LocalStore();

  /*
   * Methods to read and update the last time transactions were retrieved
   */

  DateTime retrieveLastTransactionTime() {
    DateTime lastTransactionTime;

    if (store.hasData(lastTransactionTimeKey)) {
      lastTransactionTime =
          DateTime.parse(store.read(lastTransactionTimeKey)).toUtc();
    } else {
      lastTransactionTime = DateTime.parse("2022-01-01").toUtc();
    }

    return lastTransactionTime;
  }

  void updateLastTransactionTime(DateTime lastTransactionTime) {
    store.write(lastTransactionTimeKey, lastTransactionTime.toString());
  }

  /*
   * Methods to read and update the last time sms was parsed 
   */

  DateTime retrieveLastSmsTime() {
    DateTime lastSmsQueryTime;

    if (store.hasData(lastSmsQuery.toString())) {
      lastSmsQueryTime = DateTime.parse(store.read(lastSmsQuery));
    } else {
      lastSmsQueryTime = DateTime.parse('1970-01-01');
    }

    return lastSmsQueryTime;
  }

  void updateLastSmsTime(DateTime lastSmsTime) {
    store.write(lastSmsQuery, lastSmsTime.toString());
  }

  /*
   * Methods to read and update the device locale preferred by the user
   */

  Locale getLocale() {
    Locale retrievedLocale;

    if (store.hasData(userLocale)) {
      List<String> localeString = store.read<String>(userLocale)!.split('_');
      retrievedLocale = Locale(localeString[0], localeString[1]);
    } else {
      retrievedLocale = Get.deviceLocale ?? const Locale('en', 'US');
    }

    return retrievedLocale;
  }

  void updateLocale(Locale locale) {
    store.write(userLocale, locale.toString());
  }

  /*
   * Methods to read and update the number of times a user has created 
   * transactions
   */

  int retrieveTransactionsCreatedCounter() {
    int counter;
    if (store.hasData(fieldTransactionsCreatedCounter)) {
      counter = store.read(fieldTransactionsCreatedCounter);
    } else {
      counter = 0;
    }

    return counter;
  }

  void updateTransactionsCreatedCounter(int counter) {
    store.write(fieldTransactionsCreatedCounter, counter);
  }

  /*
   * Methods to read and update the last time group list was fetched from server 
   */
  DateTime retrieveLastGroupFetchTime() {
    DateTime lastGroupFetchTime;
    if (store.hasData(fieldLastGroupFetchTime)) {
      lastGroupFetchTime = DateTime.parse(store.read(fieldLastGroupFetchTime));
    } else {
      lastGroupFetchTime = DateTime.parse('1970-01-01');
    }
    return lastGroupFetchTime;
  }

  void updateLastGroupFetchTime(DateTime lastGroupFetchTime) {
    store.write(fieldLastGroupFetchTime, lastGroupFetchTime.toString());
  }

  /*
   * Methods to read and update the last time group transactions were fetched
   * from server 
   */
  DateTime retrieveLastGroupTransactionTime() {
    DateTime lastGroupTransactionTime;
    if (store.hasData(fieldLastGroupTransactionFetchTime)) {
      lastGroupTransactionTime =
          DateTime.parse(store.read(fieldLastGroupTransactionFetchTime));
    } else {
      lastGroupTransactionTime = DateTime.parse('1970-01-01');
    }
    return lastGroupTransactionTime;
  }

  void updateLastGroupTransactionTime(DateTime lastGroupTransactionTime) {
    store.write(fieldLastGroupTransactionFetchTime, lastGroupTransactionTime);
  }

  /*
   * Clears the local storage. 
   */

  void clear() {
    store.erase();
  }
}
