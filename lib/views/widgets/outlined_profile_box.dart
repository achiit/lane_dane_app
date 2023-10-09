import 'package:flutter/material.dart';

import '../../utils/colors.dart';

class OutlinedProfile extends StatefulWidget {
  const OutlinedProfile({Key? key, required this.text, required this.chipText})
      : super(key: key);
  final String text;
  final String chipText;

  @override
  State<OutlinedProfile> createState() => _OutlinedProfileState();
}

class _OutlinedProfileState extends State<OutlinedProfile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.06,
      width: MediaQuery.of(context).size.width * 0.43,
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        border: Border.all(color: greenColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints boxConstraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.text,
              style: TextStyle(fontSize: boxConstraints.minWidth * 0.08),
            ),
            Container(
              padding: const EdgeInsets.all(2.9),
              height: 20.0,
              width: boxConstraints.minWidth * 0.4,
              decoration: BoxDecoration(
                color: lightGreenColor,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Center(
                child: Text(
                  widget.chipText,
                  style: const TextStyle(color: Colors.white, fontSize: 13.0),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
