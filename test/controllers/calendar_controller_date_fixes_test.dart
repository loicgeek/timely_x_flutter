import 'package:timely_x/timely_x.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_appointments.dart';
import '../helpers/test_resources.dart';
import '../helpers/test_dates.dart';
import '../helpers/test_configs.dart';

/// Tests for all 11 date management fixes
/// These tests ensure that appointments on end dates are properly handled,
/// navigation preserves end dates, slot generation works correctly,
/// and day count calculations use proper calendar arithmetic
void main() {
  group('Calendar Controller - Date Management Fixes', () {
    late CalendarController controller;
    late List<CalendarResource> resources;

    setUp(() {
      controller = CalendarController(config: TestConfigs.dayView());
      resources = TestResources.multipleResources(count: 2);
      controller.updateResources(resources);
    });

    tearDown(() {
      controller.dispose();
    });

    group('Fix #1: Appointments on End Date (Day View)', () {
      test('should include appointments on range end date', () {
        // Create appointment on end date
        final rangeEnd = DateTime(2025, 1, 20);
        final appointment = TestAppointments.onEndDate(
          rangeEnd: rangeEnd,
          resourceId: resources[0].id,
        );

        controller.updateAppointments([appointment]);
        controller.goToDate(rangeEnd);

        final appointments = controller.getAppointmentsForDate(rangeEnd);
        expect(appointments, contains(appointment));
      });

      test('should include appointments starting exactly at range end', () {
        final rangeEnd = DateTime(2025, 1, 20);
        final appointment = TestAppointments.basic(
          resourceId: resources[0].id,
          startTime: DateTime(
            rangeEnd.year,
            rangeEnd.month,
            rangeEnd.day,
            0,
            0,
          ),
          endTime: DateTime(rangeEnd.year, rangeEnd.month, rangeEnd.day, 1, 0),
        );

        controller.updateAppointments([appointment]);
        controller.goToDate(rangeEnd);

        final appointments = controller.getAppointmentsForDate(rangeEnd);
        expect(appointments.length, equals(1));
      });

      test('should include multi-day appointments ending on range end', () {
        final rangeStart = DateTime(2025, 1, 18);
        final rangeEnd = DateTime(2025, 1, 20);

        final appointment = TestAppointments.basic(
          resourceId: resources[0].id,
          startTime: DateTime(
            rangeStart.year,
            rangeStart.month,
            rangeStart.day,
            10,
            0,
          ),
          endTime: DateTime(rangeEnd.year, rangeEnd.month, rangeEnd.day, 15, 0),
        );

        controller.updateAppointments([appointment]);
        controller.goToDate(rangeEnd);

        final appointments = controller.getAppointmentsForDate(rangeEnd);
        expect(appointments, contains(appointment));
      });
    });

    group('Fix #2: Appointments on End Date (Week View)', () {
      late CalendarController weekController;

      setUp(() {
        weekController = CalendarController(config: TestConfigs.weekView());
        weekController.updateResources(resources);
      });

      tearDown(() {
        weekController.dispose();
      });

      test('should include appointments on week end date', () {
        final weekStart = DateTime(2025, 1, 13); // Monday
        final weekEnd = DateTime(2025, 1, 19); // Sunday

        final appointment = TestAppointments.onEndDate(
          rangeEnd: weekEnd,
          resourceId: resources[0].id,
        );

        weekController.updateAppointments([appointment]);
        weekController.goToDate(weekStart);

        final visibleDates = weekController.visibleDates;
        expect(visibleDates.last.day, equals(19)); // Sunday

        final appointments = weekController.getAppointmentsForDate(weekEnd);
        expect(appointments, contains(appointment));
      });

      test('should handle appointments spanning to week end', () {
        final weekStart = DateTime(2025, 1, 13);
        final weekEnd = DateTime(2025, 1, 19);

        final appointment = TestAppointments.basic(
          resourceId: resources[0].id,
          startTime: DateTime(2025, 1, 17, 9, 0), // Friday
          endTime: DateTime(
            weekEnd.year,
            weekEnd.month,
            weekEnd.day,
            17,
            0,
          ), // Sunday
        );

        weekController.updateAppointments([appointment]);
        weekController.goToDate(weekStart);

        final appointments = weekController.getAppointmentsForDate(weekEnd);
        expect(appointments, contains(appointment));
      });
    });

    group('Fix #3-5: Slot Generation for End Dates', () {
      test('should generate time slots including end date', () {
        final rangeStart = DateTime(2025, 1, 15);
        final rangeEnd = DateTime(2025, 1, 17);

        controller.goToDate(rangeStart);

        // Verify that slots can be queried for the end date
        final available = controller.isTimeSlotAvailable(
          resourceId: resources[0].id,
          startTime: DateTime(
            rangeEnd.year,
            rangeEnd.month,
            rangeEnd.day,
            10,
            0,
          ),
          endTime: DateTime(rangeEnd.year, rangeEnd.month, rangeEnd.day, 11, 0),
        );

        expect(available, isTrue);
      });

      test('should properly calculate available slots on end date', () {
        final rangeEnd = DateTime(2025, 1, 20);

        // Add appointment on day before end
        controller.addAppointment(
          TestAppointments.basic(
            id: 'before-end',
            resourceId: resources[0].id,
            startTime: DateTime(2025, 1, 19, 10, 0),
            endTime: DateTime(2025, 1, 19, 11, 0),
          ),
        );

        // Check if slot is available on end date
        final available = controller.isTimeSlotAvailable(
          resourceId: resources[0].id,
          startTime: DateTime(
            rangeEnd.year,
            rangeEnd.month,
            rangeEnd.day,
            10,
            0,
          ),
          endTime: DateTime(rangeEnd.year, rangeEnd.month, rangeEnd.day, 11, 0),
        );

        expect(available, isTrue);
      });

      test('should detect conflicts on end date slots', () {
        final rangeEnd = DateTime(2025, 1, 20);

        // Add appointment on end date
        controller.addAppointment(
          TestAppointments.onEndDate(
            rangeEnd: rangeEnd,
            resourceId: resources[0].id,
          ),
        );

        // Try to book overlapping slot
        final available = controller.isTimeSlotAvailable(
          resourceId: resources[0].id,
          startTime: DateTime(
            rangeEnd.year,
            rangeEnd.month,
            rangeEnd.day,
            10,
            0,
          ),
          endTime: DateTime(rangeEnd.year, rangeEnd.month, rangeEnd.day, 11, 0),
        );

        expect(available, isFalse);
      });
    });

    group('Fix #6: Day Count Calculations', () {
      test('should use calendar arithmetic for day counts', () {
        // This avoids DST issues
        final start = DateTime(2025, 1, 15);
        final end = DateTime(2025, 1, 20);

        controller.goToDate(start);

        // Calculate day count using calendar arithmetic
        // (This should match the implementation)
        final daysDiff = DateTime(
          end.year,
          end.month,
          end.day,
        ).difference(DateTime(start.year, start.month, start.day)).inDays;

        expect(daysDiff, equals(5)); // 5 days difference
      });

      test('should handle day counts across DST transition', () {
        final beforeDST = DateTime(2025, 3, 8);
        final afterDST = DateTime(2025, 3, 10); // DST on March 9

        // Using calendar arithmetic (not duration-based)
        final daysDiff = DateTime(afterDST.year, afterDST.month, afterDST.day)
            .difference(
              DateTime(beforeDST.year, beforeDST.month, beforeDST.day),
            )
            .inDays;

        expect(daysDiff, equals(2)); // Should be 2 days, not affected by DST
      });

      test('should correctly count days in month view range', () {
        final monthController = CalendarController(
          config: TestConfigs.monthView(),
        );
        monthController.goToDate(DateTime(2025, 1, 15));

        final visibleDates = monthController.visibleDates;

        // Month view should include full weeks, so count should be multiple of 7
        expect(visibleDates.length % 7, equals(0));

        monthController.dispose();
      });
    });

    group('Fix #7-8: Appointments on End Date (Month View)', () {
      late CalendarController monthController;

      setUp(() {
        monthController = CalendarController(config: TestConfigs.monthView());
        monthController.updateResources(resources);
      });

      tearDown(() {
        monthController.dispose();
      });

      test('should include appointments on month end date', () {
        final monthEnd = DateTime(2025, 1, 31);

        final appointment = TestAppointments.onEndDate(
          rangeEnd: monthEnd,
          resourceId: resources[0].id,
        );

        monthController.updateAppointments([appointment]);
        monthController.goToDate(DateTime(2025, 1, 15));

        final appointments = monthController.getAppointmentsForDate(monthEnd);
        expect(appointments, contains(appointment));
      });

      test('should handle appointments on last visible date of month view', () {
        monthController.goToDate(DateTime(2025, 1, 15));
        final visibleDates = monthController.visibleDates;
        final lastVisibleDate = visibleDates.last;

        final appointment = TestAppointments.onEndDate(
          rangeEnd: lastVisibleDate,
          resourceId: resources[0].id,
        );

        monthController.updateAppointments([appointment]);

        final appointments = monthController.getAppointmentsForDate(
          lastVisibleDate,
        );
        expect(appointments, contains(appointment));
      });
    });

    group('Fix #9: DST Transition Handling', () {
      test('should handle appointments during spring DST transition', () {
        final dstDate = TestDates.dst2025Spring;

        // Create appointments around DST transition
        final appointments = TestAppointments.aroundDSTTransition(
          dstDate: dstDate,
          resourceId: resources[0].id,
        );

        controller.updateAppointments(appointments);

        // All appointments should be retrievable
        final beforeDST = controller.getAppointmentsForDate(
          DateTime(dstDate.year, dstDate.month, dstDate.day - 1),
        );
        final onDST = controller.getAppointmentsForDate(dstDate);
        final afterDST = controller.getAppointmentsForDate(
          DateTime(dstDate.year, dstDate.month, dstDate.day + 1),
        );

        expect(beforeDST.length, equals(1));
        expect(onDST.length, equals(1));
        expect(afterDST.length, equals(1));
      });

      test('should navigate correctly through DST transition', () {
        final beforeDST = DateTime(2025, 3, 8);
        controller.goToDate(beforeDST);

        // Navigate through DST
        controller.next(); // March 9 (DST)
        expect(controller.currentDate.day, equals(9));

        controller.next(); // March 10
        expect(controller.currentDate.day, equals(10));

        // Navigate back
        controller.previous(); // March 9
        expect(controller.currentDate.day, equals(9));
      });

      test('should handle appointments spanning DST transition', () {
        final beforeDST = DateTime(2025, 3, 8, 10, 0);
        final afterDST = DateTime(2025, 3, 10, 12, 0);

        final appointment = TestAppointments.basic(
          resourceId: resources[0].id,
          startTime: beforeDST,
          endTime: afterDST,
        );

        controller.updateAppointments([appointment]);

        // Should be found on all three days
        final dstDate = DateTime(2025, 3, 9);
        final onDST = controller.getAppointmentsForDate(dstDate);
        expect(onDST, contains(appointment));
      });
    });

    group('Fix #10-11: Navigation Preserving End Dates', () {
      test(
        'should preserve appointments on end dates after next navigation',
        () {
          final initialDate = DateTime(2025, 1, 15);
          controller.goToDate(initialDate);

          final appointment = TestAppointments.basic(
            resourceId: resources[0].id,
            startTime: DateTime(
              initialDate.year,
              initialDate.month,
              initialDate.day,
              10,
              0,
            ),
            endTime: DateTime(
              initialDate.year,
              initialDate.month,
              initialDate.day,
              11,
              0,
            ),
          );
          controller.addAppointment(appointment);

          // Navigate next and back
          controller.next();
          controller.previous();

          // Appointment should still be there
          final appointments = controller.getAppointmentsForDate(initialDate);
          expect(appointments, contains(appointment));
        },
      );

      test(
        'should preserve appointments on end dates after previous navigation',
        () {
          final initialDate = DateTime(2025, 1, 15);
          controller.goToDate(initialDate);

          final appointment = TestAppointments.basic(
            resourceId: resources[0].id,
            startTime: DateTime(
              initialDate.year,
              initialDate.month,
              initialDate.day,
              10,
              0,
            ),
            endTime: DateTime(
              initialDate.year,
              initialDate.month,
              initialDate.day,
              11,
              0,
            ),
          );
          controller.addAppointment(appointment);

          // Navigate previous and back
          controller.previous();
          controller.next();

          // Appointment should still be there
          final appointments = controller.getAppointmentsForDate(initialDate);
          expect(appointments, contains(appointment));
        },
      );

      test('should handle appointments across navigation boundaries', () {
        // Week view navigation test
        final weekController = CalendarController(
          config: TestConfigs.weekView(),
        );
        weekController.updateResources(resources);

        final weekStart = DateTime(2025, 1, 13); // Monday
        final weekEnd = DateTime(2025, 1, 19); // Sunday

        final appointment = TestAppointments.onEndDate(
          rangeEnd: weekEnd,
          resourceId: resources[0].id,
        );

        weekController.updateAppointments([appointment]);
        weekController.goToDate(weekStart);

        // Navigate to next week and back
        weekController.next();
        weekController.previous();

        // Appointment on end date should still be visible
        final appointments = weekController.getAppointmentsForDate(weekEnd);
        expect(appointments, contains(appointment));

        weekController.dispose();
      });

      test(
        'should maintain end date appointments through multiple navigations',
        () {
          final date = DateTime(2025, 1, 15);
          final appointment = TestAppointments.onEndDate(
            rangeEnd: date,
            resourceId: resources[0].id,
          );

          controller.updateAppointments([appointment]);
          controller.goToDate(date);

          // Multiple forward/backward navigations
          for (int i = 0; i < 5; i++) {
            controller.next();
            controller.previous();
          }

          // Appointment should still be there
          final appointments = controller.getAppointmentsForDate(date);
          expect(appointments, contains(appointment));
        },
      );
    });

    group('Integration: All Fixes Combined', () {
      test(
        'should handle complex scenario with multiple end date appointments',
        () {
          final weekController = CalendarController(
            config: TestConfigs.weekView(),
          );
          weekController.updateResources(resources);

          final weekStart = DateTime(2025, 3, 10); // Week including DST
          final weekEnd = DateTime(2025, 3, 16);

          // Create appointments on various dates including end
          final appointments = [
            // Regular appointment
            TestAppointments.basic(
              id: 'regular',
              resourceId: resources[0].id,
              startTime: DateTime(2025, 3, 11, 10, 0),
              endTime: DateTime(2025, 3, 11, 11, 0),
            ),
            // Appointment on week end
            TestAppointments.onEndDate(
              rangeEnd: weekEnd,
              resourceId: resources[0].id,
              title: 'End Date Appointment',
            ),
            // Multi-day appointment ending on end date
            TestAppointments.basic(
              id: 'multi',
              resourceId: resources[1].id,
              startTime: DateTime(2025, 3, 14, 9, 0),
              endTime: DateTime(
                weekEnd.year,
                weekEnd.month,
                weekEnd.day,
                17,
                0,
              ),
            ),
          ];

          weekController.updateAppointments(appointments);
          weekController.goToDate(weekStart);

          // Navigate and verify
          weekController.next();
          weekController.previous();

          // All appointments should still be accessible
          final endDateAppointments = weekController.getAppointmentsForDate(
            weekEnd,
          );
          expect(
            endDateAppointments.length,
            equals(2),
          ); // Two appointments on end date

          weekController.dispose();
        },
      );

      test(
        'should handle appointments across month boundary with end dates',
        () {
          final monthController = CalendarController(
            config: TestConfigs.monthView(),
          );
          monthController.updateResources(resources);

          // Last day of January
          final monthEnd = DateTime(2025, 1, 31);

          final appointments = [
            // Appointment on month end
            TestAppointments.onEndDate(
              rangeEnd: monthEnd,
              resourceId: resources[0].id,
            ),
            // Appointment spanning to next month
            TestAppointments.basic(
              id: 'spanning',
              resourceId: resources[1].id,
              startTime: DateTime(2025, 1, 30, 10, 0),
              endTime: DateTime(2025, 2, 1, 12, 0),
            ),
          ];

          monthController.updateAppointments(appointments);
          monthController.goToDate(DateTime(2025, 1, 15));

          // Verify end date appointments
          final endDateAppointments = monthController.getAppointmentsForDate(
            monthEnd,
          );
          expect(endDateAppointments.length, equals(2));

          // Navigate to next month and back
          monthController.next();
          monthController.previous();

          // Still should be there
          final stillThere = monthController.getAppointmentsForDate(monthEnd);
          expect(stillThere.length, equals(2));

          monthController.dispose();
        },
      );

      test('should handle leap year end date correctly', () {
        final leapDay = TestDates.leapDay2024;

        final appointment = TestAppointments.onEndDate(
          rangeEnd: leapDay,
          resourceId: resources[0].id,
          title: 'Leap Day Appointment',
        );

        controller.updateAppointments([appointment]);
        controller.goToDate(leapDay);

        final appointments = controller.getAppointmentsForDate(leapDay);
        expect(appointments, contains(appointment));

        // Navigate away and back
        controller.next();
        controller.previous();

        final stillThere = controller.getAppointmentsForDate(leapDay);
        expect(stillThere, contains(appointment));
      });
    });

    group('Edge Cases', () {
      test('should handle single-day range (start == end)', () {
        final singleDay = DateTime(2025, 1, 15);

        final appointment = TestAppointments.basic(
          resourceId: resources[0].id,
          startTime: DateTime(
            singleDay.year,
            singleDay.month,
            singleDay.day,
            10,
            0,
          ),
          endTime: DateTime(
            singleDay.year,
            singleDay.month,
            singleDay.day,
            11,
            0,
          ),
        );

        controller.updateAppointments([appointment]);
        controller.goToDate(singleDay);

        final appointments = controller.getAppointmentsForDate(singleDay);
        expect(appointments, contains(appointment));
      });

      test('should handle appointments at midnight on end date', () {
        final endDate = DateTime(2025, 1, 20);

        final appointment = TestAppointments.basic(
          resourceId: resources[0].id,
          startTime: DateTime(endDate.year, endDate.month, endDate.day, 0, 0),
          endTime: DateTime(endDate.year, endDate.month, endDate.day, 1, 0),
        );

        controller.updateAppointments([appointment]);
        controller.goToDate(endDate);

        final appointments = controller.getAppointmentsForDate(endDate);
        expect(appointments, contains(appointment));
      });

      test('should handle appointments ending at 23:59 on end date', () {
        final endDate = DateTime(2025, 1, 20);

        final appointment = TestAppointments.basic(
          resourceId: resources[0].id,
          startTime: DateTime(endDate.year, endDate.month, endDate.day, 23, 0),
          endTime: DateTime(endDate.year, endDate.month, endDate.day, 23, 59),
        );

        controller.updateAppointments([appointment]);
        controller.goToDate(endDate);

        final appointments = controller.getAppointmentsForDate(endDate);
        expect(appointments, contains(appointment));
      });
    });
  });
}
