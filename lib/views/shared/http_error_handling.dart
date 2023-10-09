import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'snack-bar.dart';

void httpErrorHandler({
  required http.Response res,
  required BuildContext context,
  required VoidCallback onSuccess,
}) {
  switch (res.statusCode) {
    case 200:
      onSuccess();
      break;
    case 404:
      showSnackBar(
        context,
        json.decode(res.body)['message'],
      );
      break;
    case 500:
      showSnackBar(
        context,
        json.decode(res.body)['message'],
      );
      break;
    default:
  }
}
