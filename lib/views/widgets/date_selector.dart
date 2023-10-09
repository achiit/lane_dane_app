import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lane_dane/utils/assets.dart';
import 'package:lane_dane/utils/colors.dart';
import 'package:lane_dane/utils/date_time_extensions.dart';

class DateController extends ChangeNotifier {
  DateTime? _date;

  DateController({DateTime? initial}) {
    _date = initial;
  }

  DateTime? get date {
    return _date;
  }

  bool get isNull {
    return _date == null;
  }

  bool get isNotNull {
    return _date != null;
  }

  set date(DateTime? newDate) {
    _date = newDate;
    notifyListeners();
  }

  String formatDate() {
    if (isNotNull) {
      return _date!.digitOnlyDate();
    } else {
      return '';
    }
  }

  void change(DateTime? newDate) {
    date = newDate;
  }
}

class DateInputField extends StatefulWidget {
  final DateController dateController;
  DateInputField({
    Key? key,
    required this.dateController,
  }) : super(key: key);

  @override
  State<DateInputField> createState() => _DateInputFieldState();
}

class _DateInputFieldState extends State<DateInputField> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.dateController.addListener(update);
  }

  @override
  void dispose() {
    widget.dateController.removeListener(update);
    super.dispose();
  }

  void update() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    DateTime today = DateTime.now();
    DateTime selectedDate = today.add(const Duration(days: 1));

    _textController.text = widget.dateController.formatDate();

    if (widget.dateController.isNull) {
      return Container();
    }

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: constraints.maxWidth - 48,
            child: TextFormField(
              controller: _textController,
              decoration: const InputDecoration(
                isCollapsed: true,
                disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.only(bottom: 4),
              ),
              style: GoogleFonts.roboto(
                fontSize: 18,
              ),
              enabled: false,
            ),
          ),
          SizedBox(
            width: 32,
            child: IconButton(
              onPressed: () {
                widget.dateController.date = null;
              },
              icon: Icon(
                Icons.clear,
                color: greenColor,
                size: 32,
              ),
            ),
          ),
        ],
      );
    });
  }
}

class CalendarIcon extends StatelessWidget {
  static const double defaultSize = 24;

  final DateController dateController;
  final double size;

  const CalendarIcon({
    Key? key,
    required this.dateController,
    this.size = CalendarIcon.defaultSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();

    return IconButton(
      icon: Image.asset(
        Assets.imagesCalendarIcon,
      ),
      onPressed: () async {
        DateTime? returnedDate = await showDatePicker(
          context: context,
          initialDate:
              dateController.isNotNull ? dateController.date! : DateTime.now(),
          firstDate: today,
          lastDate: today.add(
            const Duration(days: 28),
          ),
          helpText: 'Due Date',
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: ThemeData(
                primarySwatch: Colors.grey,
                splashColor: Colors.black,
                colorScheme: ColorScheme.light(
                  primary: greenColor,
                ),
                dialogBackgroundColor: Colors.white,
              ),
              child: child ?? Container(),
            );
          },
        );
        if (returnedDate != null) {
          dateController.date = returnedDate;
        }
      },
    );
  }
}
