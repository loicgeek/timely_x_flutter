// lib/src/utils/date_time_utils.dart (add formatting)

import 'package:intl/intl.dart';

/// Utility functions for date and time operations
class DateTimeUtils {
  /// Get the start of week containing the given date
  /// [firstDayOfWeek] uses DateTime weekday constants (1=Monday, 7=Sunday)
  static DateTime getWeekStart(
    DateTime date, {
    int firstDayOfWeek = DateTime.monday,
  }) {
    final weekday = date.weekday;
    // Calculate days to subtract to get to first day of week
    int daysToSubtract = (weekday - firstDayOfWeek) % 7;
    if (daysToSubtract < 0) daysToSubtract += 7;

    return DateTime(date.year, date.month, date.day - daysToSubtract);
  }

  /// Generate a list of dates starting from startDate
  static List<DateTime> generateDateRange(
    DateTime startDate,
    int numberOfDays,
  ) {
    return List.generate(
      numberOfDays,
      (index) =>
          DateTime(startDate.year, startDate.month, startDate.day + index),
    );
  }

  /// Snap time to nearest interval
  static DateTime snapToInterval(DateTime dateTime, int minutes) {
    final totalMinutes = dateTime.hour * 60 + dateTime.minute;
    final snappedMinutes = (totalMinutes / minutes).round() * minutes;

    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      snappedMinutes ~/ 60,
      snappedMinutes % 60,
    );
  }

  /// Check if two dates are the same day
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Check if a date is today
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// Check if a date is a weekend
  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  /// Get time as decimal hours (e.g., 14:30 = 14.5)
  static double toDecimalHours(DateTime dateTime) {
    return dateTime.hour + (dateTime.minute / 60.0);
  }

  /// Create DateTime from decimal hours on a specific date
  static DateTime fromDecimalHours(DateTime date, double hours) {
    final wholeHours = hours.floor();
    final minutes = ((hours - wholeHours) * 60).round();

    return DateTime(date.year, date.month, date.day, wholeHours, minutes);
  }

  /// Calculate the offset in pixels from the start of day
  static double calculateVerticalOffset({
    required DateTime time,
    required DateTime dayStart,
    required double hourHeight,
  }) {
    final minutesFromStart = time.difference(dayStart).inMinutes;
    return (minutesFromStart / 60.0) * hourHeight;
  }

  /// Calculate time from vertical offset
  static DateTime calculateTimeFromOffset({
    required double offset,
    required DateTime dayStart,
    required double hourHeight,
  }) {
    final hours = offset / hourHeight;
    final minutes = (hours * 60).round();
    return dayStart.add(Duration(minutes: minutes));
  }

  /// Format date with pattern
  static String formatDate(DateTime date, String pattern) {
    return DateFormat(pattern).format(date);
  }

  /// Get number of days in month
  static int getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  /// Get first day of month
  static DateTime getMonthStart(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get last day of month
  static DateTime getMonthEnd(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  /// Add days to a date using calendar arithmetic (DST-safe)
  /// This method adds calendar days, not 24-hour periods.
  /// Use this instead of date.add(Duration(days: n)) to avoid DST issues.
  static DateTime addDays(DateTime date, int days) {
    return DateTime(
      date.year,
      date.month,
      date.day + days,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }

  /// Subtract days from a date using calendar arithmetic (DST-safe)
  static DateTime subtractDays(DateTime date, int days) {
    return addDays(date, -days);
  }

  /// Add months to a date (DST-safe)
  static DateTime addMonths(DateTime date, int months) {
    return DateTime(
      date.year,
      date.month + months,
      date.day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }

  /// Get weekday names in order starting from firstDayOfWeek
  /// Returns short names (Mon, Tue, etc.) by default
  static List<String> getWeekdayNames({
    int firstDayOfWeek = DateTime.monday,
    bool short = true,
  }) {
    final shortNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final longNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    final names = short ? shortNames : longNames;
    final List<String> reorderedNames = [];

    for (int i = 0; i < 7; i++) {
      final dayIndex = ((firstDayOfWeek - 1 + i) % 7);
      reorderedNames.add(names[dayIndex]);
    }

    return reorderedNames;
  }
}
