import 'package:intl/intl.dart';

String dayDifference(DateTime now, DateTime compare) {
  var format = DateFormat("dd-MM-yyyy");
  var diff = format
      .parse(format.format(compare))
      .difference(format.parse(format.format(now)))
      .inDays;

  if (diff == 0) {
    return "Today";
  } else if (diff == -1) {
    return "Yesterday";
  } else if (diff == 1) {
    return "Tomorrow";
  } else if (diff < 0) {
    return "${-diff} days ago";
  }
  return "In $diff days";
}