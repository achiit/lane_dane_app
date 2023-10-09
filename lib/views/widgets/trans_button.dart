import 'package:flutter/material.dart';

class TranButton extends StatelessWidget {
  TranButton(
      {Key? key,
      required this.text,
      required this.onPressed,
      this.height,
      this.foregroundColor,
      this.backgroundColor,
      this.width})
      : super(key: key);
  double? height;
  double? width;
  String text;
  Color? foregroundColor;
  Color? backgroundColor;
  VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
        style: OutlinedButton.styleFrom(
          primary: foregroundColor,
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
