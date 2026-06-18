import 'package:intl/intl.dart';

String formatDate(String dateStr) {
  try {
    final date = DateTime.parse(dateStr);
    return DateFormat("d 'de' MMMM 'de' yyyy", 'es').format(date);
  } catch (_) {
    return dateStr;
  }
}

String formatDateShort(String dateStr) {
  try {
    final date = DateTime.parse(dateStr);
    return DateFormat("d MMM", 'es').format(date);
  } catch (_) {
    return dateStr;
  }
}

String getTodayDateString() {
  final now = DateTime.now();
  return DateFormat('yyyy-MM-dd').format(now);
}

String getDayName(String dateStr) {
  try {
    final date = DateTime.parse(dateStr);
    return DateFormat('EEEE', 'es').format(date);
  } catch (_) {
    return '';
  }
}

bool isToday(String dateStr) {
  return dateStr == getTodayDateString();
}

String subtractDays(String dateStr, int days) {
  try {
    final date = DateTime.parse(dateStr);
    final result = date.subtract(Duration(days: days));
    return DateFormat('yyyy-MM-dd').format(result);
  } catch (_) {
    return dateStr;
  }
}

String addDays(String dateStr, int days) {
  try {
    final date = DateTime.parse(dateStr);
    final result = date.add(Duration(days: days));
    return DateFormat('yyyy-MM-dd').format(result);
  } catch (_) {
    return dateStr;
  }
}

int daysBetween(String from, String to) {
  try {
    final fromDate = DateTime.parse(from);
    final toDate = DateTime.parse(to);
    return toDate.difference(fromDate).inDays.abs();
  } catch (_) {
    return 0;
  }
}
