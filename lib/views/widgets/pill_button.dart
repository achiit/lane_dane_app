import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lane_dane/utils/colors.dart';

class PillButton extends StatefulWidget {
  final dynamic Function() callback;
  final String buttonText;
  const PillButton({
    Key? key,
    required this.callback,
    required this.buttonText,
  }) : super(key: key);

  @override
  State<PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<PillButton> {
  late bool processing;

  @override
  void initState() {
    super.initState();
    processing = false;
  }

  Future<void> onPress() async {
    if (mounted) {
      setState(() {
        processing = true;
      });
    }
    try {
      await widget.callback();
    } catch (err) {
      rethrow;
    } finally {
      if (mounted) {
        setState(() {
          processing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const double height = 50;
    return processing
        ? const SizedBox(
            height: height,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : GestureDetector(
            onTap: onPress,
            child: Container(
              height: height,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(50)),
                color: greenColor,
              ),
              child: Center(
                child: Text(
                  widget.buttonText,
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          );
  }
}
