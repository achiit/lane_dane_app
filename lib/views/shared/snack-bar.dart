import 'package:flutter/material.dart';

// String uri = 'http://192.168.0.12:3000'; // Dummy

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
    ),
  );
}
