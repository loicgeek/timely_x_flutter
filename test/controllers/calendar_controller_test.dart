import 'package:timely_x/timely_x.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_appointments.dart';
import '../helpers/test_resources.dart';
import '../helpers/test_dates.dart';
import '../helpers/test_configs.dart';

void main() {
  group('CalendarController', () {
    late CalendarController controller;

    setUp(() {
      controller = CalendarController(config: TestConfigs.dayView());
    });

    tearDown(() {
      controller.dispose();
    });

    group('Initialization', () {
      test('should initialize with default values', () {
        expect(controller.currentDate, isNotNull);
        expect(controller.viewType, equals(CalendarViewType.day));
        expect(controller.resources, isEmpty);
        expect(controller.appointments, isEmpty);
        expect(controller.selectedAppointment, isNull);
      });

      test('should initialize with custom date', () {
        final customDate = DateTime(2025, 6, 15);
        final customController = CalendarController(
          initialDate: customDate,
          config: TestConfigs.dayView(),
        );

        expect(customController.currentDate.year, equals(2025));
        expect(customController.currentDate.month, equals(6));
        expect(customController.currentDate.day, equals(15));

        customController.dispose();
      });

      test('should initialize with provided config', () {
        final config = TestConfigs.weekView();
        final customController = CalendarController(config: config);

        expect(customController.viewType, equals(CalendarViewType.week));
        customController.dispose();
      });
    });

    group('Navigation', () {
      test('should navigate to next day', () {
        final initialDate = DateTime(2025, 1, 15);
        controller.goToDate(initialDate);

        controller.next();

        expect(controller.currentDate.year, equals(2025));
        expect(controller.currentDate.month, equals(1));
        expect(controller.currentDate.day, equals(16));
      });

      test('should navigate to previous day', () {
        final initialDate = DateTime(2025, 1, 15);
        controller.goToDate(initialDate);

        controller.previous();

        expect(controller.currentDate.year, equals(2025));
        expect(controller.currentDate.month, equals(1));
        expect(controller.currentDate.day, equals(14));
      });

      test('should navigate to next week', () {
        final weekController = CalendarController(
          config: TestConfigs.weekView(),
        );
        final initialDate = DateTime(2025, 1, 13); // Monday
        weekController.goToDate(initialDate);

        weekController.next();

        expect(weekController.currentDate.year, equals(2025));
        expect(weekController.currentDate.month, equals(1));
        expect(weekController.currentDate.day, equals(20)); // Next Monday

        weekController.dispose();
      });

      test('should navigate to previous week', () {
        final weekController = CalendarController(
          config: TestConfigs.weekView(),
        );
        final initialDate = DateTime(2025, 1, 13); // Monday
        weekController.goToDate(initialDate);

        weekController.previous();

        expect(weekController.currentDate.year, equals(2025));
        expect(weekController.currentDate.month, equals(1));
        expect(weekController.currentDate.day, equals(6)); // Previous Monday

        weekController.dispose();
      });

      test('should navigate to next month', () {
        final monthController = CalendarController(
          config: TestConfigs.monthView(),
        );
        final initialDate = DateTime(2025, 1, 15);
        monthController.goToDate(initialDate);

        monthController.next();

        expect(monthController.currentDate.year, equals(2025));
        expect(monthController.currentDate.month, equals(2));

        monthController.dispose();
      });

      test('should navigate to previous month', () {
        final monthController = CalendarController(
          config: TestConfigs.monthView(),
        );
        final initialDate = DateTime(2025, 1, 15);
        monthController.goToDate(initialDate);

        monthController.previous();

        expect(monthController.currentDate.year, equals(2024));
        expect(monthController.currentDate.month, equals(12));

        monthController.dispose();
      });

      test('should go to today', () {
        final pastDate = DateTime(2020, 1, 1);
        controller.goToDate(pastDate);

        controller.goToToday();

        final today = DateTime.now();
        expect(controller.currentDate.year, equals(today.year));
        expect(controller.currentDate.month, equals(today.month));
        expect(controller.currentDate.day, equals(today.day));
      });

      test('should go to specific date', () {
        final targetDate = DateTime(2025, 7, 4);
        controller.goToDate(targetDate);

        expect(controller.currentDate.year, equals(2025));
        expect(controller.currentDate.month, equals(7));
        expect(controller.currentDate.day, equals(4));
      });

      test('should handle month boundaries correctly', () {
        controller.goToDate(DateTime(2025, 1, 31));
        controller.next();
        expect(controller.currentDate.month, equals(2));
        expect(controller.currentDate.day, equals(1));
      });

      test('should handle year boundaries correctly', () {
        controller.goToDate(DateTime(2024, 12, 31));
        controller.next();
        expect(controller.currentDate.year, equals(2025));
        expect(controller.currentDate.month, equals(1));
        expect(controller.currentDate.day, equals(1));
      });
    });

    group('View Type', () {
      test('should change view type', () {
        controller.setViewType(CalendarViewType.week);
        expect(controller.viewType, equals(CalendarViewType.week));

        controller.setViewType(CalendarViewType.month);
        expect(controller.viewType, equals(CalendarViewType.month));

        controller.setViewType(CalendarViewType.day);
        expect(controller.viewType, equals(CalendarViewType.day));
      });

      test('should notify listeners when view type changes', () {
        bool notified = false;
        controller.addListener(() {
          notified = true;
        });

        controller.setViewType(CalendarViewType.week);

        expect(notified, isTrue);
      });
    });

    group('Resources Management', () {
      test('should update resources', () {
        final resources = TestResources.multipleResources(count: 3);
        controller.updateResources(resources);

        expect(controller.resources.length, equals(3));
        expect(controller.resources, equals(resources));
      });

      test('should notify listeners when resources change', () {
        bool notified = false;
        controller.addListener(() {
          notified = true;
        });

        final resources = TestResources.multipleResources(count: 2);
        controller.updateResources(resources);

        expect(notified, isTrue);
      });

      test('should clear resources', () {
        final resources = TestResources.multipleResources(count: 3);
        controller.updateResources(resources);

        controller.updateResources([]);

        expect(controller.resources, isEmpty);
      });
    });

    group('Appointments Management', () {
      late List<CalendarResource> resources;

      setUp(() {
        resources = TestResources.multipleResources(count: 2);
        controller.updateResources(resources);
      });

      test('should update appointments', () {
        final appointments = [
          TestAppointments.basic(resourceId: resources[0].id),
          TestAppointments.basic(resourceId: resources[1].id),
        ];

        controller.updateAppointments(appointments);

        expect(controller.appointments.length, equals(2));
        expect(controller.appointments, equals(appointments));
      });

      test('should add appointment', () {
        final appointment = TestAppointments.basic(resourceId: resources[0].id);
        controller.addAppointment(appointment);

        expect(controller.appointments.length, equals(1));
        expect(controller.appointments.first, equals(appointment));
      });

      test('should add multiple appointments', () {
        final apt1 = TestAppointments.basic(
          id: 'apt1',
          resourceId: resources[0].id,
        );
        final apt2 = TestAppointments.basic(
          id: 'apt2',
          resourceId: resources[1].id,
        );

        controller.addAppointment(apt1);
        controller.addAppointment(apt2);

        expect(controller.appointments.length, equals(2));
      });

      test('should update existing appointment', () {
        final original = TestAppointments.basic(
          id: 'apt1',
          resourceId: resources[0].id,
          title: 'Original',
        );
        controller.addAppointment(original);

        final updated = DefaultAppointment(
          id: 'apt1',
          resourceId: resources[0].id,
          title: 'Updated',
          startTime: original.startTime,
          endTime: original.endTime,
        );
        controller.updateAppointment(updated);

        expect(controller.appointments.length, equals(1));
        expect(controller.appointments.first.title, equals('Updated'));
      });

      test('should remove appointment by ID', () {
        final apt1 = TestAppointments.basic(
          id: 'apt1',
          resourceId: resources[0].id,
        );
        final apt2 = TestAppointments.basic(
          id: 'apt2',
          resourceId: resources[1].id,
        );
        controller.updateAppointments([apt1, apt2]);

        controller.removeAppointment('apt1');

        expect(controller.appointments.length, equals(1));
        expect(controller.appointments.first.id, equals('apt2'));
      });

      test('should notify listeners when appointments change', () {
        int notificationCount = 0;
        controller.addListener(() {
          notificationCount++;
        });

        controller.addAppointment(
          TestAppointments.basic(resourceId: resources[0].id),
        );
        controller.addAppointment(
          TestAppointments.basic(resourceId: resources[1].id),
        );

        expect(notificationCount, equals(2));
      });

      test('should clear all appointments', () {
        controller.updateAppointments([
          TestAppointments.basic(id: 'apt1', resourceId: resources[0].id),
          TestAppointments.basic(id: 'apt2', resourceId: resources[1].id),
        ]);

        controller.updateAppointments([]);

        expect(controller.appointments, isEmpty);
      });
    });

    group('Appointment Selection', () {
      late CalendarAppointment appointment;

      setUp(() {
        final resources = TestResources.multipleResources(count: 1);
        controller.updateResources(resources);
        appointment = TestAppointments.basic(resourceId: resources[0].id);
        controller.addAppointment(appointment);
      });

      test('should select appointment', () {
        controller.selectAppointment(appointment);
        expect(controller.selectedAppointment, equals(appointment));
      });

      test('should deselect appointment', () {
        controller.selectAppointment(appointment);
        controller.selectAppointment(null);
        expect(controller.selectedAppointment, isNull);
      });

      test('should notify listeners when selection changes', () {
        bool notified = false;
        controller.addListener(() {
          notified = true;
        });

        controller.selectAppointment(appointment);
        expect(notified, isTrue);
      });
    });

    group('Queries', () {
      late List<CalendarResource> resources;
      late List<CalendarAppointment> appointments;

      setUp(() {
        resources = TestResources.multipleResources(count: 2);
        controller.updateResources(resources);

        final date = DateTime(2025, 1, 15);
        appointments = [
          TestAppointments.basic(
            id: 'apt1',
            resourceId: resources[0].id,
            startTime: DateTime(date.year, date.month, date.day, 9, 0),
            endTime: DateTime(date.year, date.month, date.day, 10, 0),
          ),
          TestAppointments.basic(
            id: 'apt2',
            resourceId: resources[0].id,
            startTime: DateTime(date.year, date.month, date.day, 14, 0),
            endTime: DateTime(date.year, date.month, date.day, 15, 0),
          ),
          TestAppointments.basic(
            id: 'apt3',
            resourceId: resources[1].id,
            startTime: DateTime(date.year, date.month, date.day, 10, 0),
            endTime: DateTime(date.year, date.month, date.day, 11, 0),
          ),
        ];
        controller.updateAppointments(appointments);
      });

      test('should get appointments for specific resource and date', () {
        final date = DateTime(2025, 1, 15);
        final result = controller.getAppointmentsForResourceDate(
          resources[0].id,
          date,
        );

        expect(result.length, equals(2));
        expect(result.map((a) => a.id), containsAll(['apt1', 'apt2']));
      });

      test('should get appointments for specific date', () {
        final date = DateTime(2025, 1, 15);
        final result = controller.getAppointmentsForDate(date);

        expect(result.length, equals(3));
      });

      test('should get appointments for specific resource', () {
        final result = controller.getAppointmentsForResource(resources[0].id);

        expect(result.length, equals(2));
        expect(result.every((a) => a.resourceId == resources[0].id), isTrue);
      });

      test('should return empty list when no appointments found', () {
        final futureDate = DateTime(2099, 12, 31);
        final result = controller.getAppointmentsForDate(futureDate);

        expect(result, isEmpty);
      });
    });

    group('Time Slot Availability', () {
      late List<CalendarResource> resources;

      setUp(() {
        resources = TestResources.multipleResources(count: 2);
        controller.updateResources(resources);

        controller.addAppointment(
          TestAppointments.basic(
            id: 'existing',
            resourceId: resources[0].id,
            startTime: DateTime(2025, 1, 15, 10, 0),
            endTime: DateTime(2025, 1, 15, 11, 0),
          ),
        );
      });

      test('should detect available time slot', () {
        final available = controller.isTimeSlotAvailable(
          resourceId: resources[0].id,
          startTime: DateTime(2025, 1, 15, 9, 0),
          endTime: DateTime(2025, 1, 15, 10, 0),
        );

        expect(available, isTrue);
      });

      test('should detect conflicting time slot', () {
        final available = controller.isTimeSlotAvailable(
          resourceId: resources[0].id,
          startTime: DateTime(2025, 1, 15, 10, 30),
          endTime: DateTime(2025, 1, 15, 11, 30),
        );

        expect(available, isFalse);
      });

      test('should detect adjacent time slots as available', () {
        final available = controller.isTimeSlotAvailable(
          resourceId: resources[0].id,
          startTime: DateTime(2025, 1, 15, 11, 0),
          endTime: DateTime(2025, 1, 15, 12, 0),
        );

        expect(available, isTrue);
      });

      test('should exclude specified appointment from conflict check', () {
        final available = controller.isTimeSlotAvailable(
          resourceId: resources[0].id,
          startTime: DateTime(2025, 1, 15, 10, 0),
          endTime: DateTime(2025, 1, 15, 11, 0),
          excludeAppointmentId: 'existing',
        );

        expect(available, isTrue);
      });

      test('should consider different resources as available', () {
        final available = controller.isTimeSlotAvailable(
          resourceId: resources[1].id, // Different resource
          startTime: DateTime(2025, 1, 15, 10, 0),
          endTime: DateTime(2025, 1, 15, 11, 0),
        );

        expect(available, isTrue);
      });
    });

    group('View Period Description', () {
      test('should generate day view description', () {
        controller.goToDate(DateTime(2025, 1, 15));
        final description = controller.getViewPeriodDescription();

        expect(description, contains('January'));
        expect(description, contains('15'));
        expect(description, contains('2025'));
      });

      test('should generate week view description', () {
        final weekController = CalendarController(
          config: TestConfigs.weekView(),
        );
        weekController.goToDate(DateTime(2025, 1, 13)); // Monday

        final description = weekController.getViewPeriodDescription();

        expect(description, contains('Jan'));
        expect(description, contains('13'));
        expect(description, contains('19')); // Sunday

        weekController.dispose();
      });

      test('should generate month view description', () {
        final monthController = CalendarController(
          config: TestConfigs.monthView(),
        );
        monthController.goToDate(DateTime(2025, 1, 15));

        final description = monthController.getViewPeriodDescription();

        expect(description, contains('January'));
        expect(description, contains('2025'));

        monthController.dispose();
      });
    });

    group('Visible Dates', () {
      test('should return single date for day view', () {
        controller.goToDate(DateTime(2025, 1, 15));
        final visible = controller.visibleDates;

        expect(visible.length, equals(1));
        expect(visible.first.day, equals(15));
      });

      test('should return week dates for week view', () {
        final weekController = CalendarController(
          config: TestConfigs.weekView(),
        );
        weekController.goToDate(DateTime(2025, 1, 13)); // Monday

        final visible = weekController.visibleDates;

        expect(visible.length, equals(7)); // Mon-Sun with weekends
        expect(visible.first.day, equals(13)); // Monday
        expect(visible.last.day, equals(19)); // Sunday

        weekController.dispose();
      });

      test('should exclude weekends when configured', () {
        final weekController = CalendarController(
          config: TestConfigs.weekView(showWeekends: false),
        );
        weekController.goToDate(DateTime(2025, 1, 13)); // Monday

        final visible = weekController.visibleDates;

        expect(visible.length, equals(5)); // Mon-Fri only
        expect(visible.first.day, equals(13)); // Monday
        expect(visible.last.day, equals(17)); // Friday

        weekController.dispose();
      });

      test('should return month dates for month view', () {
        final monthController = CalendarController(
          config: TestConfigs.monthView(),
        );
        monthController.goToDate(DateTime(2025, 1, 15));

        final visible = monthController.visibleDates;

        expect(visible.length, greaterThan(28));
        expect(visible.first.month, equals(1));

        monthController.dispose();
      });
    });

    group('Listener Management', () {
      test('should add and remove listeners', () {
        int callCount = 0;
        void listener() {
          callCount++;
        }

        controller.addListener(listener);
        controller.next();
        expect(callCount, equals(1));

        controller.removeListener(listener);
        controller.next();
        expect(callCount, equals(1)); // Should not increase
      });

      test('should notify multiple listeners', () {
        int count1 = 0;
        int count2 = 0;

        controller.addListener(() => count1++);
        controller.addListener(() => count2++);

        controller.next();

        expect(count1, equals(1));
        expect(count2, equals(1));
      });
    });

    group('Disposal', () {
      test('should not throw after disposal', () {
        controller.dispose();

        // These should not throw
        expect(() => controller.currentDate, returnsNormally);
        expect(() => controller.appointments, returnsNormally);
        expect(() => controller.resources, returnsNormally);
      });

      test('should not notify listeners after disposal', () {
        int callCount = 0;
        controller.addListener(() => callCount++);

        controller.dispose();
        controller.next(); // Should not trigger listener

        expect(callCount, equals(0));
      });
    });
  });
}
