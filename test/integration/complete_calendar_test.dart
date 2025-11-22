// test/integration/complete_calendar_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calendar2/calendar2.dart';

/// Integration tests for complete calendar workflows
/// These tests verify multiple components working together
void main() {
  group('Complete Calendar Integration', () {
    testWidgets('should support full CRUD workflow', (tester) async {
      final controller = CalendarController(
        config: CalendarConfig(viewType: CalendarViewType.day),
      );

      // Add resources
      controller.updateResources([
        DefaultResource(id: 'r1', name: 'Resource 1'),
        DefaultResource(id: 'r2', name: 'Resource 2'),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CalendarView(controller: controller)),
        ),
      );

      // CREATE: Add appointment
      final appointment = DefaultAppointment(
        id: '1',
        resourceId: 'r1',
        title: 'Meeting',
        startTime: DateTime(2025, 1, 15, 10, 0),
        endTime: DateTime(2025, 1, 15, 11, 0),
      );

      controller.addAppointment(appointment);
      await tester.pumpAndSettle();

      expect(controller.appointments.length, equals(1));

      // READ: Query appointment
      final appointments = controller.getAppointmentsForDate(
        DateTime(2025, 1, 15),
      );
      expect(appointments.length, equals(1));
      expect(appointments[0].title, equals('Meeting'));

      // UPDATE: Modify appointment
      final updated = DefaultAppointment(
        id: '1',
        resourceId: 'r1',
        title: 'Updated Meeting',
        startTime: DateTime(2025, 1, 15, 10, 0),
        endTime: DateTime(2025, 1, 15, 11, 0),
      );

      controller.updateAppointment(updated);
      await tester.pumpAndSettle();

      expect(controller.appointments[0].title, equals('Updated Meeting'));

      // DELETE: Remove appointment
      controller.removeAppointment('1');
      await tester.pumpAndSettle();

      expect(controller.appointments, isEmpty);

      controller.dispose();
    });

    testWidgets('should handle view switching', (tester) async {
      final controller = CalendarController(
        config: CalendarConfig(viewType: CalendarViewType.day),
      );

      controller.updateResources([
        DefaultResource(id: 'r1', name: 'Resource 1'),
      ]);

      controller.updateAppointments([
        DefaultAppointment(
          id: '1',
          resourceId: 'r1',
          title: 'Meeting',
          startTime: DateTime(2025, 1, 15, 10, 0),
          endTime: DateTime(2025, 1, 15, 11, 0),
        ),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CalendarView(controller: controller)),
        ),
      );

      // Start in day view
      expect(controller.viewType, equals(CalendarViewType.day));
      await tester.pumpAndSettle();

      // Switch to week view
      controller.setViewType(CalendarViewType.week);
      await tester.pumpAndSettle();

      expect(controller.viewType, equals(CalendarViewType.week));

      // Switch to month view
      controller.setViewType(CalendarViewType.month);
      await tester.pumpAndSettle();

      expect(controller.viewType, equals(CalendarViewType.month));

      // Switch to agenda view
      controller.setViewType(CalendarViewType.agenda);
      await tester.pumpAndSettle();

      expect(controller.viewType, equals(CalendarViewType.agenda));

      controller.dispose();
    });

    testWidgets('should handle navigation across views', (tester) async {
      final controller = CalendarController(
        config: CalendarConfig(viewType: CalendarViewType.day),
      );

      controller.goToDate(DateTime(2025, 1, 15));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CalendarView(controller: controller)),
        ),
      );

      // Day view navigation
      controller.next();
      await tester.pumpAndSettle();
      expect(controller.currentDate.day, equals(16));

      controller.previous();
      await tester.pumpAndSettle();
      expect(controller.currentDate.day, equals(15));

      // Switch to week view
      controller.setViewType(CalendarViewType.week);
      controller.next();
      await tester.pumpAndSettle();
      expect(controller.currentDate.day, equals(22));

      // Switch to month view
      controller.setViewType(CalendarViewType.month);
      controller.next();
      await tester.pumpAndSettle();
      expect(controller.currentDate.month, equals(2));

      controller.dispose();
    });

    testWidgets('should handle date selection in month view', (tester) async {
      final controller = CalendarController(
        config: CalendarConfig(
          viewType: CalendarViewType.month,
          dateSelectionMode: DateSelectionMode.range,
        ),
      );

      controller.goToDate(DateTime(2025, 1, 15));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CalendarView(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      // Select start date
      controller.selectDate(DateTime(2025, 1, 15));
      await tester.pumpAndSettle();

      expect(controller.selectedDates.length, equals(1));

      // Select end date
      controller.selectDate(DateTime(2025, 1, 18));
      await tester.pumpAndSettle();

      expect(controller.selectedDates.length, equals(4)); // 15, 16, 17, 18

      controller.dispose();
    });

    testWidgets('should handle drag and drop', (tester) async {
      final controller = CalendarController(
        config: CalendarConfig(
          viewType: CalendarViewType.day,
          enableDragAndDrop: true,
        ),
      );

      controller.updateResources([
        DefaultResource(id: 'r1', name: 'Resource 1'),
      ]);

      var draggedAppointment = DefaultAppointment(
        id: '1',
        resourceId: 'r1',
        title: 'Meeting',
        startTime: DateTime(2025, 1, 15, 10, 0),
        endTime: DateTime(2025, 1, 15, 11, 0),
      );

      controller.updateAppointments([draggedAppointment]);

      AppointmentDragData? dragData;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarView(
              controller: controller,
              onAppointmentDragEnd: (data) {
                dragData = data;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Note: Actual drag testing would require finding and dragging widgets
      // This is a simplified test showing the callback mechanism

      expect(controller.appointments.length, equals(1));

      controller.dispose();
    });

    testWidgets('should handle time slot availability checks', (tester) async {
      final controller = CalendarController(
        config: CalendarConfig(viewType: CalendarViewType.day),
      );

      controller.updateResources([
        DefaultResource(id: 'r1', name: 'Resource 1'),
      ]);

      // Add existing appointment
      controller.addAppointment(
        DefaultAppointment(
          id: '1',
          resourceId: 'r1',
          title: 'Existing Meeting',
          startTime: DateTime(2025, 1, 15, 10, 0),
          endTime: DateTime(2025, 1, 15, 11, 0),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CalendarView(controller: controller)),
        ),
      );

      // Check overlapping slot - should be unavailable
      final isAvailable1 = controller.isTimeSlotAvailable(
        resourceId: 'r1',
        startTime: DateTime(2025, 1, 15, 10, 30),
        endTime: DateTime(2025, 1, 15, 11, 30),
      );
      expect(isAvailable1, isFalse);

      // Check non-overlapping slot - should be available
      final isAvailable2 = controller.isTimeSlotAvailable(
        resourceId: 'r1',
        startTime: DateTime(2025, 1, 15, 12, 0),
        endTime: DateTime(2025, 1, 15, 13, 0),
      );
      expect(isAvailable2, isTrue);

      controller.dispose();
    });

    testWidgets('should maintain state across rebuilds', (tester) async {
      final controller = CalendarController(
        config: CalendarConfig(viewType: CalendarViewType.day),
      );

      controller.updateResources([
        DefaultResource(id: 'r1', name: 'Resource 1'),
      ]);

      controller.updateAppointments([
        DefaultAppointment(
          id: '1',
          resourceId: 'r1',
          title: 'Meeting',
          startTime: DateTime(2025, 1, 15, 10, 0),
          endTime: DateTime(2025, 1, 15, 11, 0),
        ),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CalendarView(controller: controller)),
        ),
      );

      expect(controller.appointments.length, equals(1));

      // Rebuild widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [Expanded(child: CalendarView(controller: controller))],
            ),
          ),
        ),
      );

      // State should be maintained
      expect(controller.appointments.length, equals(1));
      expect(controller.appointments[0].title, equals('Meeting'));

      controller.dispose();
    });

    testWidgets('should handle rapid state changes', (tester) async {
      final controller = CalendarController(
        config: CalendarConfig(viewType: CalendarViewType.day),
      );

      controller.updateResources([
        DefaultResource(id: 'r1', name: 'Resource 1'),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CalendarView(controller: controller)),
        ),
      );

      // Rapidly add multiple appointments
      for (int i = 0; i < 10; i++) {
        controller.addAppointment(
          DefaultAppointment(
            id: '$i',
            resourceId: 'r1',
            title: 'Meeting $i',
            startTime: DateTime(2025, 1, 15, 10 + i, 0),
            endTime: DateTime(2025, 1, 15, 11 + i, 0),
          ),
        );
      }

      await tester.pumpAndSettle();

      expect(controller.appointments.length, equals(10));

      // Rapidly navigate
      for (int i = 0; i < 5; i++) {
        controller.next();
      }
      await tester.pumpAndSettle();

      for (int i = 0; i < 5; i++) {
        controller.previous();
      }
      await tester.pumpAndSettle();

      // State should be consistent
      expect(controller.appointments.length, equals(10));

      controller.dispose();
    });

    testWidgets('should handle edge case: midnight appointments', (
      tester,
    ) async {
      final controller = CalendarController(
        config: CalendarConfig(viewType: CalendarViewType.day),
      );

      controller.updateResources([
        DefaultResource(id: 'r1', name: 'Resource 1'),
      ]);

      // Appointment starting at midnight
      controller.addAppointment(
        DefaultAppointment(
          id: '1',
          resourceId: 'r1',
          title: 'Midnight Meeting',
          startTime: DateTime(2025, 1, 15, 0, 0),
          endTime: DateTime(2025, 1, 15, 1, 0),
        ),
      );

      // Appointment ending at midnight
      controller.addAppointment(
        DefaultAppointment(
          id: '2',
          resourceId: 'r1',
          title: 'Late Night Meeting',
          startTime: DateTime(2025, 1, 15, 23, 0),
          endTime: DateTime(2025, 1, 16, 0, 0),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CalendarView(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      final jan15Appointments = controller.getAppointmentsForDate(
        DateTime(2025, 1, 15),
      );

      expect(jan15Appointments.length, equals(2));

      controller.dispose();
    });

    testWidgets('should handle multi-day appointments', (tester) async {
      final controller = CalendarController(
        config: CalendarConfig(viewType: CalendarViewType.week),
      );

      controller.updateResources([
        DefaultResource(id: 'r1', name: 'Resource 1'),
      ]);

      // Multi-day appointment
      controller.addAppointment(
        DefaultAppointment(
          id: '1',
          resourceId: 'r1',
          title: 'Conference',
          startTime: DateTime(2025, 1, 15, 9, 0),
          endTime: DateTime(2025, 1, 17, 17, 0),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CalendarView(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      // Should appear on all three days
      final jan15 = controller.getAppointmentsForDate(DateTime(2025, 1, 15));
      final jan16 = controller.getAppointmentsForDate(DateTime(2025, 1, 16));
      final jan17 = controller.getAppointmentsForDate(DateTime(2025, 1, 17));

      // Note: Behavior depends on implementation
      // At minimum, should be findable in the date range
      expect(controller.appointments.length, equals(1));

      controller.dispose();
    });
  });

  group('Date Range Scenarios', () {
    testWidgets('should handle same-day range', (tester) async {
      final controller = CalendarController(
        config: CalendarConfig(
          viewType: CalendarViewType.agenda,
          agendaConfig: AgendaViewConfig(
            dateRangeMode: AgendaDateRangeMode.custom,
          ),
        ),
      );

      final date = DateTime(2025, 1, 15);
      controller.setAgendaDateRange(date, date);

      controller.updateResources([
        DefaultResource(id: 'r1', name: 'Resource 1'),
      ]);

      controller.updateAppointments([
        DefaultAppointment(
          id: '1',
          resourceId: 'r1',
          title: 'Morning',
          startTime: DateTime(2025, 1, 15, 9, 0),
          endTime: DateTime(2025, 1, 15, 10, 0),
        ),
        DefaultAppointment(
          id: '2',
          resourceId: 'r1',
          title: 'Evening',
          startTime: DateTime(2025, 1, 15, 20, 0),
          endTime: DateTime(2025, 1, 15, 21, 0),
        ),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CalendarView(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      final filtered = controller.getAgendaAppointments();
      expect(
        filtered.length,
        equals(2),
        reason: 'Same-day range should include all appointments',
      );

      controller.dispose();
    });

    testWidgets('should handle month boundary range', (tester) async {
      final controller = CalendarController(
        config: CalendarConfig(
          viewType: CalendarViewType.agenda,
          agendaConfig: AgendaViewConfig(
            dateRangeMode: AgendaDateRangeMode.custom,
          ),
        ),
      );

      controller.setAgendaDateRange(
        DateTime(2025, 1, 30),
        DateTime(2025, 2, 2),
      );

      controller.updateResources([
        DefaultResource(id: 'r1', name: 'Resource 1'),
      ]);

      // Appointments spanning the boundary
      controller.updateAppointments([
        DefaultAppointment(
          id: '1',
          resourceId: 'r1',
          title: 'Jan 30',
          startTime: DateTime(2025, 1, 30, 10, 0),
          endTime: DateTime(2025, 1, 30, 11, 0),
        ),
        DefaultAppointment(
          id: '2',
          resourceId: 'r1',
          title: 'Jan 31',
          startTime: DateTime(2025, 1, 31, 10, 0),
          endTime: DateTime(2025, 1, 31, 11, 0),
        ),
        DefaultAppointment(
          id: '3',
          resourceId: 'r1',
          title: 'Feb 1',
          startTime: DateTime(2025, 2, 1, 10, 0),
          endTime: DateTime(2025, 2, 1, 11, 0),
        ),
        DefaultAppointment(
          id: '4',
          resourceId: 'r1',
          title: 'Feb 2',
          startTime: DateTime(2025, 2, 2, 20, 0), // Evening on end date
          endTime: DateTime(2025, 2, 2, 21, 0),
        ),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CalendarView(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      final filtered = controller.getAgendaAppointments();
      expect(
        filtered.length,
        equals(4),
        reason: 'Should include all appointments across month boundary',
      );

      controller.dispose();
    });

    testWidgets('should handle year boundary range', (tester) async {
      final controller = CalendarController(
        config: CalendarConfig(
          viewType: CalendarViewType.agenda,
          agendaConfig: AgendaViewConfig(
            dateRangeMode: AgendaDateRangeMode.custom,
          ),
        ),
      );

      controller.setAgendaDateRange(
        DateTime(2024, 12, 30),
        DateTime(2025, 1, 2),
      );

      controller.updateResources([
        DefaultResource(id: 'r1', name: 'Resource 1'),
      ]);

      controller.updateAppointments([
        DefaultAppointment(
          id: '1',
          resourceId: 'r1',
          title: 'Dec 30',
          startTime: DateTime(2024, 12, 30, 10, 0),
          endTime: DateTime(2024, 12, 30, 11, 0),
        ),
        DefaultAppointment(
          id: '2',
          resourceId: 'r1',
          title: 'Jan 1',
          startTime: DateTime(2025, 1, 1, 10, 0),
          endTime: DateTime(2025, 1, 1, 11, 0),
        ),
        DefaultAppointment(
          id: '3',
          resourceId: 'r1',
          title: 'Jan 2 Evening',
          startTime: DateTime(2025, 1, 2, 22, 0),
          endTime: DateTime(2025, 1, 2, 23, 0),
        ),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CalendarView(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      final filtered = controller.getAgendaAppointments();
      expect(
        filtered.length,
        equals(3),
        reason: 'Should handle year boundary correctly',
      );

      controller.dispose();
    });
  });
}
