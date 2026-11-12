import 'package:intl/intl.dart';

class AppHelpers {
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  static String todayDateString() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  static String formatCoordinates(double? lat, double? lng) {
    if (lat == null || lng == null) return 'N/A';
    return '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
  }

  static String getAttendanceStatusLabel(String status) {
    switch (status) {
      case 'checked_in':
        return 'Checked In';
      case 'checked_out':
        return 'Checked Out';
      default:
        return 'Not Checked In';
    }
  }
}
