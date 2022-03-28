import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String toTimeString() {
    return DateFormat.Hms().format(this);
  }

  String toHumanString() {
    String result = "";
    if (hour > 0) result += "$hour giờ";
    if (minute > 0) result += " $minute phút";
    if (second > 0) result += " $second giây";
    if (hour == 0 && second == 0) return "$second giây";
    return result.trim();
  }
}
