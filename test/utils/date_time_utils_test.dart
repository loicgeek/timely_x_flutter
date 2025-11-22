// test/utils/date_time_utils_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:calendar2/src/utils/date_time_utils.dart';

void main() {
  group('DateTimeUtils', () {
    group('getWeekStart', () {
      test('should return Monday for Wednesday (Monday first)', () {
        final wednesday = DateTime(2025, 1, 15); // Wednesday

        final weekStart = DateTimeUtils.getWeekStart(wednesday);

        expect(weekStart.weekday, equals(DateTime.monday));
        expect(weekStart.day, equals(13));
      });

      test('should return Sunday for Wednesday (Sunday first)', () {
        final wednesday = DateTime(2025, 1, 15);

        final weekStart = DateTimeUtils.getWeekStart(
          wednesday,
          firstDayOfWeek: DateTime.sunday,
        );

        expect(weekStart.weekday, equals(DateTime.sunday));
        expect(weekStart.day, equals(12));
      });

      test('should return same date if already start of week', () {
        final monday = DateTime(2025, 1, 13);

        final weekStart = DateTimeUtils.getWeekStart(monday);

        expect(weekStart.day, equals(monday.day));
      });

      test('should handle year boundaries', () {
        final friday = DateTime(2025, 1, 3); // Friday, week starts in 2024

        final weekStart = DateTimeUtils.getWeekStart(friday);

        expect(weekStart.year, equals(2024));
        expect(weekStart.month, equals(12));
        expect(weekStart.day, equals(30));
      });
    });

    group('generateDateRange', () {
      test('should generate correct number of dates', () {
        final startDate = DateTime(2025, 1, 1);

        final dates = DateTimeUtils.generateDateRange(startDate, 7);

        expect(dates.length, equals(7));
      });

      test('should generate sequential dates', () {
        final startDate = DateTime(2025, 1, 1);

        final dates = DateTimeUtils.generateDateRange(startDate, 3);

        expect(dates[0].day, equals(1));
        expect(dates[1].day, equals(2));
        expect(dates[2].day, equals(3));
      });

      test('should handle month boundaries', () {
        final startDate = DateTime(2025, 1, 30);

        final dates = DateTimeUtils.generateDateRange(startDate, 3);

        expect(dates[0].day, equals(30));
        expect(dates[1].day, equals(31));
        expect(dates[2].month, equals(2));
        expect(dates[2].day, equals(1));
      });

      test('should normalize times to midnight', () {
        final startDate = DateTime(2025, 1, 1, 14, 30);

        final dates = DateTimeUtils.generateDateRange(startDate, 2);

        expect(dates[0].hour, equals(0));
        expect(dates[0].minute, equals(0));
        expect(dates[1].hour, equals(0));
      });
    });

    group('snapToInterval', () {
      test('should snap to 15-minute intervals', () {
        final time = DateTime(2025, 1, 15, 10, 7);

        final snapped = DateTimeUtils.snapToInterval(time, 15);

        expect(snapped.hour, equals(10));
        expect(snapped.minute, equals(0));
      });

      test('should snap up when closer', () {
        final time = DateTime(2025, 1, 15, 10, 23);

        final snapped = DateTimeUtils.snapToInterval(time, 15);

        expect(snapped.hour, equals(10));
        expect(snapped.minute, equals(30));
      });

      test('should snap to 30-minute intervals', () {
        final time = DateTime(2025, 1, 15, 10, 17);

        final snapped = DateTimeUtils.snapToInterval(time, 30);

        expect(snapped.hour, equals(10));
        expect(snapped.minute, equals(30));
      });

      test('should handle hour boundaries', () {
        final time = DateTime(2025, 1, 15, 10, 53);

        final snapped = DateTimeUtils.snapToInterval(time, 15);

        expect(snapped.hour, equals(11));
        expect(snapped.minute, equals(0));
      });
    });

    group('isSameDay', () {
      test('should return true for same day different times', () {
        final date1 = DateTime(2025, 1, 15, 10, 0);
        final date2 = DateTime(2025, 1, 15, 20, 0);

        expect(DateTimeUtils.isSameDay(date1, date2), isTrue);
      });

      test('should return false for different days', () {
        final date1 = DateTime(2025, 1, 15);
        final date2 = DateTime(2025, 1, 16);

        expect(DateTimeUtils.isSameDay(date1, date2), isFalse);
      });

      test('should return false for same time different days', () {
        final date1 = DateTime(2025, 1, 15, 10, 0);
        final date2 = DateTime(2025, 1, 16, 10, 0);

        expect(DateTimeUtils.isSameDay(date1, date2), isFalse);
      });
    });

    group('isToday', () {
      test('should return true for today', () {
        final today = DateTime.now();

        expect(DateTimeUtils.isToday(today), isTrue);
      });

      test('should return false for yesterday', () {
        final yesterday = DateTime.now().subtract(Duration(days: 1));

        expect(DateTimeUtils.isToday(yesterday), isFalse);
      });

      test('should return false for tomorrow', () {
        final tomorrow = DateTime.now().add(Duration(days: 1));

        expect(DateTimeUtils.isToday(tomorrow), isFalse);
      });
    });

    group('isWeekend', () {
      test('should return true for Saturday', () {
        final saturday = DateTime(2025, 1, 11);

        expect(DateTimeUtils.isWeekend(saturday), isTrue);
      });

      test('should return true for Sunday', () {
        final sunday = DateTime(2025, 1, 12);

        expect(DateTimeUtils.isWeekend(sunday), isTrue);
      });

      test('should return false for weekdays', () {
        final monday = DateTime(2025, 1, 13);
        final tuesday = DateTime(2025, 1, 14);
        final wednesday = DateTime(2025, 1, 15);
        final thursday = DateTime(2025, 1, 16);
        final friday = DateTime(2025, 1, 17);

        expect(DateTimeUtils.isWeekend(monday), isFalse);
        expect(DateTimeUtils.isWeekend(tuesday), isFalse);
        expect(DateTimeUtils.isWeekend(wednesday), isFalse);
        expect(DateTimeUtils.isWeekend(thursday), isFalse);
        expect(DateTimeUtils.isWeekend(friday), isFalse);
      });
    });

    group('toDecimalHours', () {
      test('should convert full hours', () {
        final time = DateTime(2025, 1, 15, 14, 0);

        expect(DateTimeUtils.toDecimalHours(time), equals(14.0));
      });

      test('should convert half hours', () {
        final time = DateTime(2025, 1, 15, 14, 30);

        expect(DateTimeUtils.toDecimalHours(time), equals(14.5));
      });

      test('should convert quarter hours', () {
        final time = DateTime(2025, 1, 15, 14, 15);

        expect(DateTimeUtils.toDecimalHours(time), equals(14.25));
      });

      test('should handle midnight', () {
        final time = DateTime(2025, 1, 15, 0, 0);

        expect(DateTimeUtils.toDecimalHours(time), equals(0.0));
      });
    });

    group('fromDecimalHours', () {
      test('should create time from full hours', () {
        final date = DateTime(2025, 1, 15);

        final time = DateTimeUtils.fromDecimalHours(date, 14.0);

        expect(time.hour, equals(14));
        expect(time.minute, equals(0));
      });

      test('should create time from half hours', () {
        final date = DateTime(2025, 1, 15);

        final time = DateTimeUtils.fromDecimalHours(date, 14.5);

        expect(time.hour, equals(14));
        expect(time.minute, equals(30));
      });

      test('should create time from decimal minutes', () {
        final date = DateTime(2025, 1, 15);

        final time = DateTimeUtils.fromDecimalHours(date, 14.25);

        expect(time.hour, equals(14));
        expect(time.minute, equals(15));
      });
    });

    group('calculateVerticalOffset', () {
      test('should calculate offset for start of day', () {
        final time = DateTime(2025, 1, 15, 8, 0);
        final dayStart = DateTime(2025, 1, 15, 8, 0);

        final offset = DateTimeUtils.calculateVerticalOffset(
          time: time,
          dayStart: dayStart,
          hourHeight: 100.0,
        );

        expect(offset, equals(0.0));
      });

      test('should calculate offset for one hour later', () {
        final time = DateTime(2025, 1, 15, 9, 0);
        final dayStart = DateTime(2025, 1, 15, 8, 0);

        final offset = DateTimeUtils.calculateVerticalOffset(
          time: time,
          dayStart: dayStart,
          hourHeight: 100.0,
        );

        expect(offset, equals(100.0));
      });

      test('should calculate offset for half hour', () {
        final time = DateTime(2025, 1, 15, 8, 30);
        final dayStart = DateTime(2025, 1, 15, 8, 0);

        final offset = DateTimeUtils.calculateVerticalOffset(
          time: time,
          dayStart: dayStart,
          hourHeight: 100.0,
        );

        expect(offset, equals(50.0));
      });
    });

    group('calculateTimeFromOffset', () {
      test('should calculate time from zero offset', () {
        final dayStart = DateTime(2025, 1, 15, 8, 0);

        final time = DateTimeUtils.calculateTimeFromOffset(
          offset: 0.0,
          dayStart: dayStart,
          hourHeight: 100.0,
        );

        expect(time.hour, equals(8));
        expect(time.minute, equals(0));
      });

      test('should calculate time from one hour offset', () {
        final dayStart = DateTime(2025, 1, 15, 8, 0);

        final time = DateTimeUtils.calculateTimeFromOffset(
          offset: 100.0,
          dayStart: dayStart,
          hourHeight: 100.0,
        );

        expect(time.hour, equals(9));
        expect(time.minute, equals(0));
      });

      test('should calculate time from half hour offset', () {
        final dayStart = DateTime(2025, 1, 15, 8, 0);

        final time = DateTimeUtils.calculateTimeFromOffset(
          offset: 50.0,
          dayStart: dayStart,
          hourHeight: 100.0,
        );

        expect(time.hour, equals(8));
        expect(time.minute, equals(30));
      });
    });

    group('formatDate', () {
      test('should format with standard pattern', () {
        final date = DateTime(2025, 1, 15);

        final formatted = DateTimeUtils.formatDate(date, 'yyyy-MM-dd');

        expect(formatted, equals('2025-01-15'));
      });

      test('should format with text month', () {
        final date = DateTime(2025, 1, 15);

        final formatted = DateTimeUtils.formatDate(date, 'MMMM d, yyyy');

        expect(formatted, equals('January 15, 2025'));
      });

      test('should format with day of week', () {
        final wednesday = DateTime(2025, 1, 15);

        final formatted = DateTimeUtils.formatDate(wednesday, 'EEEE');

        expect(formatted, equals('Wednesday'));
      });
    });

    group('getDaysInMonth', () {
      test('should return 31 for January', () {
        final date = DateTime(2025, 1, 15);

        expect(DateTimeUtils.getDaysInMonth(date), equals(31));
      });

      test('should return 28 for February (non-leap year)', () {
        final date = DateTime(2025, 2, 15);

        expect(DateTimeUtils.getDaysInMonth(date), equals(28));
      });

      test('should return 29 for February (leap year)', () {
        final date = DateTime(2024, 2, 15);

        expect(DateTimeUtils.getDaysInMonth(date), equals(29));
      });

      test('should return 30 for April', () {
        final date = DateTime(2025, 4, 15);

        expect(DateTimeUtils.getDaysInMonth(date), equals(30));
      });
    });

    group('getMonthStart', () {
      test('should return first day of month', () {
        final date = DateTime(2025, 1, 15);

        final monthStart = DateTimeUtils.getMonthStart(date);

        expect(monthStart.day, equals(1));
        expect(monthStart.month, equals(1));
      });

      test('should preserve year', () {
        final date = DateTime(2025, 12, 31);

        final monthStart = DateTimeUtils.getMonthStart(date);

        expect(monthStart.year, equals(2025));
        expect(monthStart.month, equals(12));
        expect(monthStart.day, equals(1));
      });
    });

    group('getMonthEnd', () {
      test('should return last day of January', () {
        final date = DateTime(2025, 1, 15);

        final monthEnd = DateTimeUtils.getMonthEnd(date);

        expect(monthEnd.day, equals(31));
      });

      test('should return last day of February (non-leap)', () {
        final date = DateTime(2025, 2, 15);

        final monthEnd = DateTimeUtils.getMonthEnd(date);

        expect(monthEnd.day, equals(28));
      });

      test('should return last day of February (leap)', () {
        final date = DateTime(2024, 2, 15);

        final monthEnd = DateTimeUtils.getMonthEnd(date);

        expect(monthEnd.day, equals(29));
      });
    });

    group('addDays', () {
      test('should add days correctly', () {
        final date = DateTime(2025, 1, 15, 10, 30);

        final newDate = DateTimeUtils.addDays(date, 5);

        expect(newDate.day, equals(20));
        expect(newDate.hour, equals(10));
        expect(newDate.minute, equals(30));
      });

      test('should handle month boundaries', () {
        final date = DateTime(2025, 1, 30);

        final newDate = DateTimeUtils.addDays(date, 5);

        expect(newDate.month, equals(2));
        expect(newDate.day, equals(4));
      });

      test('should handle year boundaries', () {
        final date = DateTime(2024, 12, 30);

        final newDate = DateTimeUtils.addDays(date, 5);

        expect(newDate.year, equals(2025));
        expect(newDate.month, equals(1));
        expect(newDate.day, equals(4));
      });

      test('should handle negative days', () {
        final date = DateTime(2025, 1, 15);

        final newDate = DateTimeUtils.addDays(date, -5);

        expect(newDate.day, equals(10));
      });

      test('should preserve time components (DST-safe)', () {
        final date = DateTime(2025, 1, 15, 14, 30, 45);

        final newDate = DateTimeUtils.addDays(date, 1);

        expect(newDate.hour, equals(14));
        expect(newDate.minute, equals(30));
        expect(newDate.second, equals(45));
      });
    });

    group('subtractDays', () {
      test('should subtract days correctly', () {
        final date = DateTime(2025, 1, 15);

        final newDate = DateTimeUtils.subtractDays(date, 5);

        expect(newDate.day, equals(10));
      });

      test('should handle month boundaries', () {
        final date = DateTime(2025, 2, 3);

        final newDate = DateTimeUtils.subtractDays(date, 5);

        expect(newDate.month, equals(1));
        expect(newDate.day, equals(29));
      });
    });

    group('addMonths', () {
      test('should add months correctly', () {
        final date = DateTime(2025, 1, 15, 10, 30);

        final newDate = DateTimeUtils.addMonths(date, 3);

        expect(newDate.month, equals(4));
        expect(newDate.day, equals(15));
        expect(newDate.hour, equals(10));
      });

      test('should handle year boundaries', () {
        final date = DateTime(2024, 11, 15);

        final newDate = DateTimeUtils.addMonths(date, 3);

        expect(newDate.year, equals(2025));
        expect(newDate.month, equals(2));
      });

      test('should handle day overflow', () {
        final date = DateTime(2025, 1, 31);

        final newDate = DateTimeUtils.addMonths(date, 1);

        // February 31 doesn't exist, should overflow to March
        expect(newDate.month, greaterThanOrEqualTo(2));
      });
    });

    group('getWeekdayNames', () {
      test('should return short names starting with Monday', () {
        final names = DateTimeUtils.getWeekdayNames();

        expect(names.length, equals(7));
        expect(names[0], equals('Mon'));
        expect(names[6], equals('Sun'));
      });

      test('should return long names starting with Monday', () {
        final names = DateTimeUtils.getWeekdayNames(short: false);

        expect(names[0], equals('Monday'));
        expect(names[6], equals('Sunday'));
      });

      test('should start with Sunday when specified', () {
        final names = DateTimeUtils.getWeekdayNames(
          firstDayOfWeek: DateTime.sunday,
        );

        expect(names[0], equals('Sun'));
        expect(names[6], equals('Sat'));
      });

      test('should handle Wednesday as first day', () {
        final names = DateTimeUtils.getWeekdayNames(
          firstDayOfWeek: DateTime.wednesday,
        );

        expect(names[0], equals('Wed'));
        expect(names[6], equals('Tue'));
      });
    });

    group('DST Handling', () {
      test('addDays should work correctly during DST transition', () {
        // Spring forward: March 10, 2024 at 2 AM in US
        final beforeDST = DateTime(2024, 3, 9, 10, 0);

        final afterDST = DateTimeUtils.addDays(beforeDST, 2);

        expect(afterDST.day, equals(11));
        expect(
          afterDST.hour,
          equals(10),
          reason: 'Should preserve hour despite DST transition',
        );
      });

      test('should calculate date range across DST correctly', () {
        final startDate = DateTime(2024, 3, 9);

        final dates = DateTimeUtils.generateDateRange(startDate, 3);

        expect(dates.length, equals(3));
        expect(dates[0].day, equals(9));
        expect(dates[1].day, equals(10)); // DST transition day
        expect(dates[2].day, equals(11));
      });
    });

    group('Leap Year Handling', () {
      test('should correctly identify leap year', () {
        final leap2024 = DateTime(2024, 2, 15);
        final nonLeap2025 = DateTime(2025, 2, 15);

        expect(DateTimeUtils.getDaysInMonth(leap2024), equals(29));
        expect(DateTimeUtils.getDaysInMonth(nonLeap2025), equals(28));
      });

      test('should handle Feb 29 in leap year', () {
        final feb29 = DateTime(2024, 2, 29);

        final nextDay = DateTimeUtils.addDays(feb29, 1);

        expect(nextDay.month, equals(3));
        expect(nextDay.day, equals(1));
      });
    });
  });
}
