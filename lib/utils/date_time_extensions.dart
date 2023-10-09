import 'package:intl/intl.dart';

extension FormateDateToDigits on DateTime {
  String digitOnlyDate() {
    return DateFormat('dd-MM-yyyy').format(this);
  }

  bool sameDayAs(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool notSameDayAs(DateTime other) {
    return year != other.year || month != other.month || day != other.day;
  }

  String get toMMMMDDYYYY {
    const String dateFormatter = 'MMMM dd, y';
    DateFormat formatter = DateFormat(dateFormatter);
    return formatter.format(this);
  }

  String get toTimeDDMMMMYYYY {
    return DateFormat.jm().addPattern(', d MMMM, y').format(this);
  }
}
