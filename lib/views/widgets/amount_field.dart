import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AmountField extends StatefulWidget {
  final TextEditingController controller;
  const AmountField({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends State<AmountField> {
  late int length;
  late FocusNode focus;

  @override
  void initState() {
    super.initState();
    length = widget.controller.text.length;
    focus = FocusNode();
    focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24 * length + 48 + 48 + (length == 0 ? 24 : 0),
      child: TextFormField(
        onChanged: (String input) {
          setState(() {
            length = input.length;
          });
        },
        maxLines: 1,
        focusNode: focus,
        keyboardType: TextInputType.number,
        controller: widget.controller,
        decoration: InputDecoration(
          // border: InputBorder.none,
          prefixIcon: const Icon(
            Icons.currency_rupee,
            size: 28,
            color: Colors.black,
          ),
          hintStyle: GoogleFonts.roboto(
            color: const Color(0xFF000000).withOpacity(0.25),
          ),
          hintText: '0',
        ),
        style: const TextStyle(
          fontSize: 48,
        ),
      ),
    );
  }
}
