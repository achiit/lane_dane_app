import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lane_dane/utils/colors.dart';

class CustomToggleButtons extends StatefulWidget {
  final void Function(int) onSelect;
  final List<String> options;
  final String? initialSelection;
  const CustomToggleButtons({
    Key? key,
    required this.onSelect,
    this.options = const ['', ''],
    this.initialSelection,
  }) : super(key: key);

  @override
  State<CustomToggleButtons> createState() => _CustomToggleButtonsState();
}

class _CustomToggleButtonsState extends State<CustomToggleButtons> {
  late List<bool> selectionStatus;
  late int length;

  @override
  initState() {
    super.initState();

    int initialSelectionIndex = 0;
    if (widget.initialSelection != null) {
      initialSelectionIndex = widget.options.indexWhere((String option) {
        return option.toLowerCase().tr ==
            widget.initialSelection!.toLowerCase().tr;
      });
    }

    length = widget.options.length;
    selectionStatus = List<bool>.generate(length, (int index) {
      if (index == initialSelectionIndex) {
        return true;
      }
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return ToggleButtons(
        fillColor: greenColor,
        color: greenColor,
        borderColor: greenColor,
        selectedBorderColor: greenColor,
        selectedColor: Colors.white,
        disabledColor: const Color.fromARGB(255, 240, 221, 221),
        borderRadius: BorderRadius.circular(8),
        constraints: BoxConstraints.expand(width: constraints.maxWidth * 0.49),
        isSelected: selectionStatus,
        onPressed: (int selectedIndex) {
          for (int index = 0; index < length; index++) {
            selectionStatus[index] = false;
          }
          selectionStatus[selectedIndex] = true;
          setState(() {});
          widget.onSelect(selectedIndex);
        },
        children: <Widget>[
          ...widget.options.map<Widget>((String option) {
            return Text(
              option,
              style: const TextStyle(fontSize: 16),
            );
          }).toList(),
        ],
      );
    });
  }
}
