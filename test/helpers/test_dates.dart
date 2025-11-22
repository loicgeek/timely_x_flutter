/// Helper class for creating test dates with various edge cases
class TestDates {
  // Standard test dates
  static DateTime get today => DateTime.now();
  static DateTime get yesterday => DateTime.now().subtract(Duration(days: 1));
  static DateTime get tomorrow => DateTime.now().add(Duration(days: 1));

  /// Creates a date at midnight
  static DateTime midnight(int year, int month, int day) {
    return DateTime(year, month, day, 0, 0, 0);
  }

  /// Creates a date at specific time
  static DateTime at(int year, int month, int day, int hour, [int minute = 0]) {
    return DateTime(year, month, day, hour, minute);
  }

  /// DST transition dates for US (2025)
  static DateTime get dst2025Spring => DateTime(2025, 3, 9); // March 9, 2025
  static DateTime get dst2025Fall => DateTime(2025, 11, 2); // November 2, 2025

  /// DST transition dates for US (2024)
  static DateTime get dst2024Spring => DateTime(2024, 3, 10);
  static DateTime get dst2024Fall => DateTime(2024, 11, 3);

  /// Leap year date
  static DateTime get leapDay2024 => DateTime(2024, 2, 29);
  static DateTime get leapDay2028 => DateTime(2028, 2, 29);

  /// Month boundary dates
  static DateTime get endOfJanuary2025 => DateTime(2025, 1, 31);
  static DateTime get startOfFebruary2025 => DateTime(2025, 2, 1);
  static DateTime get endOfFebruary2024 => DateTime(2024, 2, 29); // Leap year
  static DateTime get endOfFebruary2025 =>
      DateTime(2025, 2, 28); // Non-leap year

  /// Year boundary dates
  static DateTime get endOf2024 => DateTime(2024, 12, 31);
  static DateTime get startOf2025 => DateTime(2025, 1, 1);

  /// Creates a week range (Monday to Sunday)
  static DateRange weekRange(DateTime monday) {
    return DateRange(
      start: monday,
      end: DateTime(monday.year, monday.month, monday.day + 6),
    );
  }

  /// Creates a month range
  static DateRange monthRange(int year, int month) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0); // Last day of month
    return DateRange(start: start, end: end);
  }

  /// Creates a single day range
  static DateRange singleDayRange(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return DateRange(start: day, end: day);
  }

  /// Creates a date range spanning DST transition
  static DateRange dstTransitionRange({bool spring = true}) {
    if (spring) {
      // Range that includes spring DST transition
      return DateRange(
        start: DateTime(2025, 3, 7), // Before DST
        end: DateTime(2025, 3, 11), // After DST
      );
    } else {
      // Range that includes fall DST transition
      return DateRange(
        start: DateTime(2025, 10, 31), // Before DST
        end: DateTime(2025, 11, 4), // After DST
      );
    }
  }

  /// Creates a date range that spans multiple months
  static DateRange multiMonthRange() {
    return DateRange(start: DateTime(2025, 1, 15), end: DateTime(2025, 3, 15));
  }

  /// Creates a date range that spans a full year
  static DateRange fullYearRange(int year) {
    return DateRange(start: DateTime(year, 1, 1), end: DateTime(year, 12, 31));
  }

  /// Weekend dates
  static DateTime get saturday2025Jan11 => DateTime(2025, 1, 11);
  static DateTime get sunday2025Jan12 => DateTime(2025, 1, 12);

  /// Weekday dates
  static DateTime get monday2025Jan13 => DateTime(2025, 1, 13);
  static DateTime get friday2025Jan17 => DateTime(2025, 1, 17);

  /// Creates dates around month boundaries
  static List<DateTime> aroundMonthBoundary(int year, int month) {
    return [
      DateTime(year, month, 1), // First day of month
      DateTime(year, month, 15), // Mid-month
      DateTime(year, month + 1, 0), // Last day of month (using month+1, day 0)
    ];
  }

  /// Creates dates for a complete week starting from Monday
  static List<DateTime> completeWeek(DateTime monday) {
    return List.generate(7, (index) {
      return DateTime(monday.year, monday.month, monday.day + index);
    });
  }

  /// Creates dates for business days only (Mon-Fri)
  static List<DateTime> businessWeek(DateTime monday) {
    return List.generate(5, (index) {
      return DateTime(monday.year, monday.month, monday.day + index);
    });
  }

  /// Creates dates across different time zones (for testing)
  /// Returns same date but in different UTC offsets
  static List<DateTime> differentTimeZones(DateTime localDate) {
    return [
      localDate, // Local time
      localDate.toUtc(), // UTC
      localDate.toUtc().subtract(Duration(hours: 5)), // EST (UTC-5)
      localDate.toUtc().add(Duration(hours: 9)), // JST (UTC+9)
    ];
  }

  /// Edge case: February 29 on leap years
  static List<int> leapYears() => [2024, 2028, 2032, 2036, 2040];
  static List<int> nonLeapYears() => [2025, 2026, 2027, 2029, 2030];

  /// Creates a series of consecutive dates
  static List<DateTime> consecutiveDates(DateTime start, int count) {
    return List.generate(count, (index) {
      return DateTime(start.year, start.month, start.day + index);
    });
  }

  /// Creates dates at various times of day
  static List<DateTime> variousTimes(DateTime date) {
    return [
      DateTime(date.year, date.month, date.day, 0, 0), // Midnight
      DateTime(date.year, date.month, date.day, 6, 0), // Early morning
      DateTime(date.year, date.month, date.day, 9, 0), // Morning
      DateTime(date.year, date.month, date.day, 12, 0), // Noon
      DateTime(date.year, date.month, date.day, 15, 0), // Afternoon
      DateTime(date.year, date.month, date.day, 18, 0), // Evening
      DateTime(date.year, date.month, date.day, 23, 59), // End of day
    ];
  }

  /// Creates dates that test month lengths
  static Map<String, DateTime> monthEndDates(int year) {
    return {
      'january': DateTime(year, 1, 31),
      'february': DateTime(year, 2, year % 4 == 0 ? 29 : 28),
      'march': DateTime(year, 3, 31),
      'april': DateTime(year, 4, 30),
      'may': DateTime(year, 5, 31),
      'june': DateTime(year, 6, 30),
      'july': DateTime(year, 7, 31),
      'august': DateTime(year, 8, 31),
      'september': DateTime(year, 9, 30),
      'october': DateTime(year, 10, 31),
      'november': DateTime(year, 11, 30),
      'december': DateTime(year, 12, 31),
    };
  }
}

/// Date range helper class
class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({required this.start, required this.end});

  /// Number of days in the range (inclusive)
  int get dayCount {
    // Use calendar arithmetic to avoid DST issues
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day);
    return endDay.difference(startDay).inDays + 1;
  }

  /// List of all dates in the range (inclusive)
  List<DateTime> get dates {
    final result = <DateTime>[];
    DateTime current = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day);

    while (current.isBefore(endDay) || current.isAtSameMomentAs(endDay)) {
      result.add(current);
      current = DateTime(current.year, current.month, current.day + 1);
    }

    return result;
  }

  /// Check if a date is within the range (inclusive)
  bool contains(DateTime date) {
    final checkDay = DateTime(date.year, date.month, date.day);
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day);

    return (checkDay.isAfter(startDay) ||
            checkDay.isAtSameMomentAs(startDay)) &&
        (checkDay.isBefore(endDay) || checkDay.isAtSameMomentAs(endDay));
  }
}
