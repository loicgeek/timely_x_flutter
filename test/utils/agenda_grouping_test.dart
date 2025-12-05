import 'package:timely_x/timely_x.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_appointments.dart';
import '../helpers/test_resources.dart';

/// Tests for AgendaGroupingUtils
/// Covers all grouping modes, date ranges, and edge cases
void main() {
  group('AgendaGroupingUtils', () {
    late List<CalendarResource> resources;
    late List<CalendarAppointment> appointments;
    late DateTime startDate;
    late DateTime endDate;

    setUp(() {
      resources = TestResources.multipleResources(count: 3);
      startDate = DateTime(2025, 1, 13); // Monday
      endDate = DateTime(2025, 1, 19); // Sunday

      // Create appointments across the week
      appointments = [
        // Monday - Multiple resources
        TestAppointments.basic(
          id: 'mon-r1',
          resourceId: resources[0].id,
          title: 'Monday Meeting 1',
          startTime: DateTime(2025, 1, 13, 9, 0),
          endTime: DateTime(2025, 1, 13, 10, 0),
        ),
        TestAppointments.basic(
          id: 'mon-r2',
          resourceId: resources[1].id,
          title: 'Monday Meeting 2',
          startTime: DateTime(2025, 1, 13, 10, 0),
          endTime: DateTime(2025, 1, 13, 11, 0),
        ),
        // Wednesday - Single resource
        TestAppointments.basic(
          id: 'wed-r1',
          resourceId: resources[0].id,
          title: 'Wednesday Meeting',
          startTime: DateTime(2025, 1, 15, 14, 0),
          endTime: DateTime(2025, 1, 15, 15, 0),
        ),
        // Friday - Multiple appointments, same resource
        TestAppointments.basic(
          id: 'fri-r1-1',
          resourceId: resources[0].id,
          title: 'Friday Morning',
          startTime: DateTime(2025, 1, 17, 9, 0),
          endTime: DateTime(2025, 1, 17, 10, 0),
        ),
        TestAppointments.basic(
          id: 'fri-r1-2',
          resourceId: resources[0].id,
          title: 'Friday Afternoon',
          startTime: DateTime(2025, 1, 17, 14, 0),
          endTime: DateTime(2025, 1, 17, 15, 0),
        ),
      ];
    });

    group('Chronological Grouping', () {
      test(
        'should create single group with all appointments sorted by time',
        () {
          final groups = AgendaGroupingUtils.groupAppointments(
            appointments: appointments,
            resources: resources,
            mode: AgendaGroupingMode.chronological,
            showEmptyDays: false,
            showEmptyResources: false,
            startDate: startDate,
            endDate: endDate,
          );

          expect(groups.length, equals(1));
          expect(groups[0].items.length, equals(5));
          expect(groups[0].header.title, equals('All Appointments'));
          expect(groups[0].header.itemCount, equals(5));
        },
      );

      test('should sort appointments chronologically', () {
        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: appointments.reversed.toList(), // Reverse order
          resources: resources,
          mode: AgendaGroupingMode.chronological,
          showEmptyDays: false,
          showEmptyResources: false,
          startDate: startDate,
          endDate: endDate,
        );

        final items = groups[0].items;
        // Should be sorted by start time
        expect(items[0].appointment.id, equals('mon-r1')); // Monday 9am
        expect(items[1].appointment.id, equals('mon-r2')); // Monday 10am
        expect(items[2].appointment.id, equals('wed-r1')); // Wednesday 2pm
        expect(items[3].appointment.id, equals('fri-r1-1')); // Friday 9am
        expect(items[4].appointment.id, equals('fri-r1-2')); // Friday 2pm
      });

      test('should include resource and date in items', () {
        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: appointments,
          resources: resources,
          mode: AgendaGroupingMode.chronological,
          showEmptyDays: false,
          showEmptyResources: false,
          startDate: startDate,
          endDate: endDate,
        );

        final item = groups[0].items[0];
        expect(item.showResource, isTrue);
        expect(item.showDate, isTrue);
        expect(item.resource, isNotNull);
      });

      test('should handle empty appointment list', () {
        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: [],
          resources: resources,
          mode: AgendaGroupingMode.chronological,
          showEmptyDays: false,
          showEmptyResources: false,
          startDate: startDate,
          endDate: endDate,
        );

        expect(groups.length, equals(1));
        expect(groups[0].items, isEmpty);
        expect(groups[0].hasItems, isFalse);
      });
    });

    group('Group By Date', () {
      test('should create group for each date with appointments', () {
        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: appointments,
          resources: resources,
          mode: AgendaGroupingMode.byDate,
          showEmptyDays: false,
          showEmptyResources: false,
          startDate: startDate,
          endDate: endDate,
        );

        // Should have 3 groups (Mon, Wed, Fri)
        expect(groups.length, equals(3));

        // Verify dates
        expect(groups[0].header.date?.day, equals(13)); // Monday
        expect(groups[1].header.date?.day, equals(15)); // Wednesday
        expect(groups[2].header.date?.day, equals(17)); // Friday
      });

      test('should show empty days when enabled', () {
        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: appointments,
          resources: resources,
          mode: AgendaGroupingMode.byDate,
          showEmptyDays: true, // Show all days
          showEmptyResources: false,
          startDate: startDate,
          endDate: endDate,
        );

        // Should have 7 groups (all days in week)
        expect(groups.length, equals(7));

        // Check empty days have no items
        expect(groups[1].items, isEmpty); // Tuesday
        expect(groups[1].hasItems, isFalse);
      });

      test('should group multiple appointments on same date', () {
        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: appointments,
          resources: resources,
          mode: AgendaGroupingMode.byDate,
          showEmptyDays: false,
          showEmptyResources: false,
          startDate: startDate,
          endDate: endDate,
        );

        // Monday should have 2 appointments
        final mondayGroup = groups.firstWhere((g) => g.header.date?.day == 13);
        expect(mondayGroup.items.length, equals(2));
        expect(mondayGroup.header.itemCount, equals(2));

        // Friday should have 2 appointments
        final fridayGroup = groups.firstWhere((g) => g.header.date?.day == 17);
        expect(fridayGroup.items.length, equals(2));
      });

      test('should format date headers correctly', () {
        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: appointments,
          resources: resources,
          mode: AgendaGroupingMode.byDate,
          showEmptyDays: false,
          showEmptyResources: false,
          startDate: startDate,
          endDate: endDate,
        );

        final mondayGroup = groups[0];
        expect(mondayGroup.header.title, contains('Monday'));
        expect(mondayGroup.header.title, contains('January'));
        expect(mondayGroup.header.title, contains('13'));
      });

      test('should include relative date text in subtitle', () {
        final today = DateTime.now();
        final todayAppointments = [
          TestAppointments.basic(
            resourceId: resources[0].id,
            startTime: DateTime(today.year, today.month, today.day, 10, 0),
            endTime: DateTime(today.year, today.month, today.day, 11, 0),
          ),
        ];

        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: todayAppointments,
          resources: resources,
          mode: AgendaGroupingMode.byDate,
          showEmptyDays: false,
          showEmptyResources: false,
          startDate: DateTime(today.year, today.month, today.day),
          endDate: DateTime(today.year, today.month, today.day),
        );

        expect(groups[0].header.subtitle, equals('Today'));
      });

      test('should show resource info in items', () {
        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: appointments,
          resources: resources,
          mode: AgendaGroupingMode.byDate,
          showEmptyDays: false,
          showEmptyResources: false,
          startDate: startDate,
          endDate: endDate,
        );

        final item = groups[0].items[0];
        expect(item.showResource, isTrue);
        expect(item.showDate, isFalse); // Date already shown in header
      });
    });

    group('Group By Resource', () {
      test('should create group for each resource with appointments', () {
        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: appointments,
          resources: resources,
          mode: AgendaGroupingMode.byResource,
          showEmptyDays: false,
          showEmptyResources: false,
          startDate: startDate,
          endDate: endDate,
        );

        // Should have 2 groups (resources 0 and 1 have appointments)
        expect(groups.length, equals(2));
      });

      test('should show empty resources when enabled', () {
        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: appointments,
          resources: resources,
          mode: AgendaGroupingMode.byResource,
          showEmptyDays: false,
          showEmptyResources: true, // Show all resources
          startDate: startDate,
          endDate: endDate,
        );

        // Should have 3 groups (all resources)
        expect(groups.length, equals(3));

        // Third resource should have no items
        expect(groups[2].items, isEmpty);
        expect(groups[2].hasItems, isFalse);
      });

      test('should group appointments by resource', () {
        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: appointments,
          resources: resources,
          mode: AgendaGroupingMode.byResource,
          showEmptyDays: false,
          showEmptyResources: false,
          startDate: startDate,
          endDate: endDate,
        );

        // Resource 0 should have 4 appointments
        final resource0Group = groups.firstWhere(
          (g) => g.header.resource?.id == resources[0].id,
        );
        expect(resource0Group.items.length, equals(4));
        expect(resource0Group.header.itemCount, equals(4));

        // Resource 1 should have 1 appointment
        final resource1Group = groups.firstWhere(
          (g) => g.header.resource?.id == resources[1].id,
        );
        expect(resource1Group.items.length, equals(1));
      });

      test('should use resource name as header title', () {
        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: appointments,
          resources: resources,
          mode: AgendaGroupingMode.byResource,
          showEmptyDays: false,
          showEmptyResources: false,
          startDate: startDate,
          endDate: endDate,
        );

        expect(groups[0].header.title, equals(resources[0].name));
        expect(groups[0].header.resource, equals(resources[0]));
      });

      test('should show date info in items', () {
        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: appointments,
          resources: resources,
          mode: AgendaGroupingMode.byResource,
          showEmptyDays: false,
          showEmptyResources: false,
          startDate: startDate,
          endDate: endDate,
        );

        final item = groups[0].items[0];
        expect(item.showDate, isTrue);
        expect(item.showResource, isFalse); // Resource already shown in header
      });
    });

    group('Group By Date Then Resource (Nested)', () {
      test('should create date groups with resource subgroups', () {
        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: appointments,
          resources: resources,
          mode: AgendaGroupingMode.byDateThenResource,
          showEmptyDays: false,
          showEmptyResources: false,
          startDate: startDate,
          endDate: endDate,
        );

        // Should have 3 date groups (Mon, Wed, Fri)
        expect(groups.length, equals(3));

        // Monday should have 2 resource subgroups
        final mondayGroup = groups[0];
        expect(mondayGroup.subGroups, isNotNull);
        expect(mondayGroup.subGroups!.length, equals(2));
        expect(mondayGroup.items, isEmpty); // Items in subgroups
      });

      test('should nest resources under dates', () {
        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: appointments,
          resources: resources,
          mode: AgendaGroupingMode.byDateThenResource,
          showEmptyDays: false,
          showEmptyResources: false,
          startDate: startDate,
          endDate: endDate,
        );

        final mondayGroup = groups[0];
        final subGroup1 = mondayGroup.subGroups![0];

        expect(subGroup1.header.resource, isNotNull);
        expect(subGroup1.items.isNotEmpty, isTrue);
      });

      test('should show empty resources in subgroups when enabled', () {
        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: appointments,
          resources: resources,
          mode: AgendaGroupingMode.byDateThenResource,
          showEmptyDays: false,
          showEmptyResources: true, // Show all resources
          startDate: startDate,
          endDate: endDate,
        );

        // Wednesday should have 3 resource subgroups (only 1 has items)
        final wedGroup = groups.firstWhere((g) => g.header.date?.day == 15);
        expect(wedGroup.subGroups!.length, equals(3));

        // Two should be empty
        final emptySubgroups = wedGroup.subGroups!
            .where((sg) => sg.items.isEmpty)
            .toList();
        expect(emptySubgroups.length, equals(2));
      });

      test('should calculate hasItems correctly with subgroups', () {
        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: appointments,
          resources: resources,
          mode: AgendaGroupingMode.byDateThenResource,
          showEmptyDays: true, // Show empty days
          showEmptyResources: false,
          startDate: startDate,
          endDate: endDate,
        );

        // Days with appointments should have items
        final mondayGroup = groups.firstWhere((g) => g.header.date?.day == 13);
        expect(mondayGroup.hasItems, isTrue);

        // Empty days should not have items
        final tuesdayGroup = groups.firstWhere((g) => g.header.date?.day == 14);
        expect(tuesdayGroup.hasItems, isFalse);
      });

      test('should not show resource or date in nested items', () {
        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: appointments,
          resources: resources,
          mode: AgendaGroupingMode.byDateThenResource,
          showEmptyDays: false,
          showEmptyResources: false,
          startDate: startDate,
          endDate: endDate,
        );

        final item = groups[0].subGroups![0].items[0];
        expect(item.showResource, isFalse); // Already in header
        expect(item.showDate, isFalse); // Already in parent header
      });
    });

    group('Group By Resource Then Date (Nested)', () {
      test('should create resource groups with date subgroups', () {
        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: appointments,
          resources: resources,
          mode: AgendaGroupingMode.byResourceThenDate,
          showEmptyDays: false,
          showEmptyResources: false,
          startDate: startDate,
          endDate: endDate,
        );

        // Should have 2 resource groups
        expect(groups.length, equals(2));

        // Resource 0 should have date subgroups
        final resource0Group = groups[0];
        expect(resource0Group.subGroups, isNotNull);
        expect(resource0Group.subGroups!.length, greaterThan(0));
        expect(resource0Group.items, isEmpty); // Items in subgroups
      });

      test('should nest dates under resources', () {
        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: appointments,
          resources: resources,
          mode: AgendaGroupingMode.byResourceThenDate,
          showEmptyDays: false,
          showEmptyResources: false,
          startDate: startDate,
          endDate: endDate,
        );

        final resource0Group = groups[0];
        final subGroup1 = resource0Group.subGroups![0];

        expect(subGroup1.header.date, isNotNull);
        expect(subGroup1.items.isNotEmpty, isTrue);
      });

      test('should show empty days in subgroups when enabled', () {
        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: appointments,
          resources: resources,
          mode: AgendaGroupingMode.byResourceThenDate,
          showEmptyDays: true, // Show all days
          showEmptyResources: false,
          startDate: startDate,
          endDate: endDate,
        );

        // Resource 0 should have 7 date subgroups (all days)
        final resource0Group = groups[0];
        expect(resource0Group.subGroups!.length, equals(7));
      });

      test('should calculate resource item counts correctly', () {
        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: appointments,
          resources: resources,
          mode: AgendaGroupingMode.byResourceThenDate,
          showEmptyDays: false,
          showEmptyResources: false,
          startDate: startDate,
          endDate: endDate,
        );

        // Resource 0 has 4 appointments total
        expect(groups[0].header.itemCount, equals(4));

        // Resource 1 has 1 appointment total
        expect(groups[1].header.itemCount, equals(1));
      });
    });

    group('Date Range Filtering', () {
      test('should only include appointments within date range', () {
        final outOfRangeAppointments = [
          ...appointments,
          TestAppointments.basic(
            id: 'before',
            resourceId: resources[0].id,
            startTime: DateTime(2025, 1, 10, 9, 0), // Before startDate
            endTime: DateTime(2025, 1, 10, 10, 0),
          ),
          TestAppointments.basic(
            id: 'after',
            resourceId: resources[0].id,
            startTime: DateTime(2025, 1, 25, 9, 0), // After endDate
            endTime: DateTime(2025, 1, 25, 10, 0),
          ),
        ];

        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: outOfRangeAppointments,
          resources: resources,
          mode: AgendaGroupingMode.chronological,
          showEmptyDays: false,
          showEmptyResources: false,
          startDate: startDate,
          endDate: endDate,
        );

        // Should only have the original 5 appointments
        expect(groups[0].items.length, equals(5));
      });

      test('should include appointments on start date', () {
        final appointmentOnStart = TestAppointments.basic(
          id: 'on-start',
          resourceId: resources[0].id,
          startTime: DateTime(
            startDate.year,
            startDate.month,
            startDate.day,
            0,
            0,
          ),
          endTime: DateTime(
            startDate.year,
            startDate.month,
            startDate.day,
            1,
            0,
          ),
        );

        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: [appointmentOnStart],
          resources: resources,
          mode: AgendaGroupingMode.chronological,
          showEmptyDays: false,
          showEmptyResources: false,
          startDate: startDate,
          endDate: endDate,
        );

        expect(groups[0].items.length, equals(1));
        expect(groups[0].items[0].appointment.id, equals('on-start'));
      });

      test('should include appointments on end date', () {
        final appointmentOnEnd = TestAppointments.basic(
          id: 'on-end',
          resourceId: resources[0].id,
          startTime: DateTime(endDate.year, endDate.month, endDate.day, 23, 0),
          endTime: DateTime(endDate.year, endDate.month, endDate.day, 23, 59),
        );

        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: [appointmentOnEnd],
          resources: resources,
          mode: AgendaGroupingMode.chronological,
          showEmptyDays: false,
          showEmptyResources: false,
          startDate: startDate,
          endDate: endDate,
        );

        expect(groups[0].items.length, equals(1));
        expect(groups[0].items[0].appointment.id, equals('on-end'));
      });

      test('should include appointments spanning the date range', () {
        final spanningAppointment = TestAppointments.basic(
          id: 'spanning',
          resourceId: resources[0].id,
          startTime: DateTime(
            startDate.year,
            startDate.month,
            startDate.day - 1,
            10,
            0,
          ),
          endTime: DateTime(
            endDate.year,
            endDate.month,
            endDate.day + 1,
            10,
            0,
          ),
        );

        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: [spanningAppointment],
          resources: resources,
          mode: AgendaGroupingMode.chronological,
          showEmptyDays: false,
          showEmptyResources: false,
          startDate: startDate,
          endDate: endDate,
        );

        expect(groups[0].items.length, equals(1));
      });
    });

    group('Edge Cases', () {
      test('should handle single day range', () {
        final singleDayAppointments = [
          TestAppointments.basic(
            resourceId: resources[0].id,
            startTime: DateTime(2025, 1, 15, 10, 0),
            endTime: DateTime(2025, 1, 15, 11, 0),
          ),
        ];

        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: singleDayAppointments,
          resources: resources,
          mode: AgendaGroupingMode.byDate,
          showEmptyDays: false,
          showEmptyResources: false,
          startDate: DateTime(2025, 1, 15),
          endDate: DateTime(2025, 1, 15),
        );

        expect(groups.length, equals(1));
        expect(groups[0].header.date?.day, equals(15));
      });

      test('should handle no resources', () {
        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: appointments,
          resources: [],
          mode: AgendaGroupingMode.byResource,
          showEmptyDays: false,
          showEmptyResources: false,
          startDate: startDate,
          endDate: endDate,
        );

        expect(groups, isEmpty);
      });

      test('should handle appointments at midnight', () {
        final midnightAppointments = [
          TestAppointments.basic(
            resourceId: resources[0].id,
            startTime: DateTime(2025, 1, 15, 0, 0),
            endTime: DateTime(2025, 1, 15, 1, 0),
          ),
        ];

        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: midnightAppointments,
          resources: resources,
          mode: AgendaGroupingMode.byDate,
          showEmptyDays: false,
          showEmptyResources: false,
          startDate: DateTime(2025, 1, 15),
          endDate: DateTime(2025, 1, 15),
        );

        expect(groups.length, equals(1));
        expect(groups[0].items.length, equals(1));
      });

      test('should handle multi-day appointments', () {
        final multiDayAppointment = TestAppointments.multiDay(
          resourceId: resources[0].id,
          startDate: DateTime(2025, 1, 14),
          durationDays: 3,
        );

        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: [multiDayAppointment],
          resources: resources,
          mode: AgendaGroupingMode.byDate,
          showEmptyDays: true,
          showEmptyResources: false,
          startDate: startDate,
          endDate: endDate,
        );

        // Should appear in the first day's group
        final tuesdayGroup = groups.firstWhere((g) => g.header.date?.day == 14);
        expect(tuesdayGroup.items.length, equals(1));
      });

      test('should handle appointments past midnight', () {
        final pastMidnightAppointment = TestAppointments.pastMidnight(
          resourceId: resources[0].id,
          date: DateTime(2025, 1, 15),
        );

        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: [pastMidnightAppointment],
          resources: resources,
          mode: AgendaGroupingMode.byDate,
          showEmptyDays: true,
          showEmptyResources: false,
          startDate: DateTime(2025, 1, 15),
          endDate: DateTime(2025, 1, 16),
        );

        // Should appear on the start date
        final wednesdayGroup = groups.firstWhere(
          (g) => g.header.date?.day == 15,
        );
        expect(wednesdayGroup.items.length, equals(1));
      });

      test('should handle large number of appointments', () {
        final largeAppointmentSet = TestAppointments.acrossDateRange(
          startDate: startDate,
          endDate: endDate,
          resourceId: resources[0].id,
          appointmentsPerDay: 10,
        );

        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: largeAppointmentSet,
          resources: resources,
          mode: AgendaGroupingMode.chronological,
          showEmptyDays: false,
          showEmptyResources: false,
          startDate: startDate,
          endDate: endDate,
        );

        // Should handle all appointments
        expect(groups[0].items.length, equals(largeAppointmentSet.length));
      });
    });

    group('Relative Date Text', () {
      test('should show "Today" for current date', () {
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);

        final todayAppointment = TestAppointments.basic(
          resourceId: resources[0].id,
          startTime: DateTime(
            todayDate.year,
            todayDate.month,
            todayDate.day,
            10,
            0,
          ),
          endTime: DateTime(
            todayDate.year,
            todayDate.month,
            todayDate.day,
            11,
            0,
          ),
        );

        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: [todayAppointment],
          resources: resources,
          mode: AgendaGroupingMode.byDate,
          showEmptyDays: false,
          showEmptyResources: false,
          startDate: todayDate,
          endDate: todayDate,
        );

        expect(groups[0].header.subtitle, equals('Today'));
      });

      test('should show "Tomorrow" for next day', () {
        final today = DateTime.now();
        final tomorrow = DateTime(today.year, today.month, today.day + 1);

        final tomorrowAppointment = TestAppointments.basic(
          resourceId: resources[0].id,
          startTime: DateTime(
            tomorrow.year,
            tomorrow.month,
            tomorrow.day,
            10,
            0,
          ),
          endTime: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 11, 0),
        );

        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: [tomorrowAppointment],
          resources: resources,
          mode: AgendaGroupingMode.byDate,
          showEmptyDays: false,
          showEmptyResources: false,
          startDate: tomorrow,
          endDate: tomorrow,
        );

        expect(groups[0].header.subtitle, equals('Tomorrow'));
      });

      test('should show "Yesterday" for previous day', () {
        final today = DateTime.now();
        final yesterday = DateTime(today.year, today.month, today.day - 1);

        final yesterdayAppointment = TestAppointments.basic(
          resourceId: resources[0].id,
          startTime: DateTime(
            yesterday.year,
            yesterday.month,
            yesterday.day,
            10,
            0,
          ),
          endTime: DateTime(
            yesterday.year,
            yesterday.month,
            yesterday.day,
            11,
            0,
          ),
        );

        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: [yesterdayAppointment],
          resources: resources,
          mode: AgendaGroupingMode.byDate,
          showEmptyDays: false,
          showEmptyResources: false,
          startDate: yesterday,
          endDate: yesterday,
        );

        expect(groups[0].header.subtitle, equals('Yesterday'));
      });

      test('should show relative days for near future', () {
        final today = DateTime.now();
        final inThreeDays = DateTime(today.year, today.month, today.day + 3);

        final futureAppointment = TestAppointments.basic(
          resourceId: resources[0].id,
          startTime: DateTime(
            inThreeDays.year,
            inThreeDays.month,
            inThreeDays.day,
            10,
            0,
          ),
          endTime: DateTime(
            inThreeDays.year,
            inThreeDays.month,
            inThreeDays.day,
            11,
            0,
          ),
        );

        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: [futureAppointment],
          resources: resources,
          mode: AgendaGroupingMode.byDate,
          showEmptyDays: false,
          showEmptyResources: false,
          startDate: inThreeDays,
          endDate: inThreeDays,
        );

        expect(groups[0].header.subtitle, equals('In 3 days'));
      });

      test('should show empty subtitle for distant dates', () {
        final distantFuture = DateTime(2026, 6, 15);

        final distantAppointment = TestAppointments.basic(
          resourceId: resources[0].id,
          startTime: DateTime(
            distantFuture.year,
            distantFuture.month,
            distantFuture.day,
            10,
            0,
          ),
          endTime: DateTime(
            distantFuture.year,
            distantFuture.month,
            distantFuture.day,
            11,
            0,
          ),
        );

        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: [distantAppointment],
          resources: resources,
          mode: AgendaGroupingMode.byDate,
          showEmptyDays: false,
          showEmptyResources: false,
          startDate: distantFuture,
          endDate: distantFuture,
        );

        expect(groups[0].header.subtitle, equals(''));
      });
    });

    group('Group Keys', () {
      test('should use unique keys for date groups', () {
        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: appointments,
          resources: resources,
          mode: AgendaGroupingMode.byDate,
          showEmptyDays: false,
          showEmptyResources: false,
          startDate: startDate,
          endDate: endDate,
        );

        final keys = groups.map((g) => g.key).toList();
        final uniqueKeys = keys.toSet();

        expect(keys.length, equals(uniqueKeys.length)); // All keys unique
      });

      test('should use resource ID as key for resource groups', () {
        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: appointments,
          resources: resources,
          mode: AgendaGroupingMode.byResource,
          showEmptyDays: false,
          showEmptyResources: false,
          startDate: startDate,
          endDate: endDate,
        );

        expect(groups[0].key, equals(resources[0].id));
        expect(groups[1].key, equals(resources[1].id));
      });

      test('should use composite keys for nested groups', () {
        final groups = AgendaGroupingUtils.groupAppointments(
          appointments: appointments,
          resources: resources,
          mode: AgendaGroupingMode.byDateThenResource,
          showEmptyDays: false,
          showEmptyResources: false,
          startDate: startDate,
          endDate: endDate,
        );

        final mondayGroup = groups[0];
        final subGroupKey = mondayGroup.subGroups![0].key;

        // Should contain both date and resource ID
        expect(subGroupKey, contains('2025-01-13'));
        expect(subGroupKey, contains(resources[0].id));
      });
    });
  });
}
