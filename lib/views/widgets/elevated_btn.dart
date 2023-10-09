import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/colors.dart';

class CustomButton extends StatefulWidget {
  final String buttonName;
  final dynamic Function() onPressed;

  const CustomButton({
    Key? key,
    required this.onPressed,
    required this.buttonName,
  }) : super(key: key);

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  late bool _loading;

  @override
  void initState() {
    super.initState();
    _loading = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        height: 50,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: greenColor,
          minimumSize: const Size(double.infinity, 50.0),
          maximumSize: const Size(double.infinity, 50.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      onPressed: () async {
        try {
          setState(() {
            _loading = true;
          });
          await widget.onPressed();
        } catch (err) {
          setState(() {
            _loading = false;
          });
          rethrow;
        } finally {
          if (mounted) {
            setState(() {
              _loading = false;
            });
          }
        }
      },
      child: Text(
        widget.buttonName,
        style: GoogleFonts.roboto(
          fontWeight: FontWeight.w700,
          fontSize: 20.0,
          letterSpacing: 0.5,
          color: Colors.white,
        ),
      ),
    );
  }
}
