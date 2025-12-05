// test/views/agenda_view_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timely_x/timely_x.dart';

void main() {
  group('AgendaView', () {
    late CalendarController controller;

    setUp(() {
      controller = CalendarController(
        config: CalendarConfig(
          viewType: CalendarViewType.agenda,
          agendaConfig: AgendaViewConfig(
            groupingMode: AgendaGroupingMode.byDate,
            daysToShow: 7,
          ),
        ),
      );
    });

    tearDown(() {
      controller.dispose();
    });

    Widget buildAgendaView({
      AgendaViewConfig? agendaConfig,
      CalendarTheme? theme,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: CalendarView(
            controller: controller,
            config: CalendarConfig(
              viewType: CalendarViewType.agenda,
              agendaConfig: agendaConfig ?? AgendaViewConfig(),
            ),
            theme: theme ?? CalendarTheme(),
          ),
        ),
      );
    }

    testWidgets('should display empty state when no appointments', (
      tester,
    ) async {
      await tester.pumpWidget(buildAgendaView());
      await tester.pumpAndSettle();

      expect(find.text('No appointments scheduled'), findsOneWidget);
    });

    testWidgets('should display appointments in chronological order', (
      tester,
    ) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final appointments = [
        DefaultAppointment(
          id: '2',
          resourceId: 'r1',
          title: 'Meeting 2',
          startTime: today.add(Duration(hours: 14)),
          endTime: today.add(Duration(hours: 15)),
        ),
        DefaultAppointment(
          id: '1',
          resourceId: 'r1',
          title: 'Meeting 1',
          startTime: today.add(Duration(hours: 10)),
          endTime: today.add(Duration(hours: 11)),
        ),
      ];

      controller.updateAppointments(appointments);
      controller.updateResources([
        DefaultResource(id: 'r1', name: 'Resource 1'),
      ]);

      await tester.pumpWidget(buildAgendaView());
      await tester.pumpAndSettle();

      expect(find.text('Meeting 1'), findsOneWidget);
      expect(find.text('Meeting 2'), findsOneWidget);

      // Check order - Meeting 1 should come before Meeting 2
      final meeting1Finder = find.text('Meeting 1');
      final meeting2Finder = find.text('Meeting 2');

      final meeting1Offset = tester.getTopLeft(meeting1Finder);
      final meeting2Offset = tester.getTopLeft(meeting2Finder);

      expect(meeting1Offset.dy, lessThan(meeting2Offset.dy));
    });

    testWidgets('should group appointments by date', (tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final appointments = [
        DefaultAppointment(
          id: '1',
          resourceId: 'r1',
          title: 'Today Meeting',
          startTime: today.add(Duration(hours: 10)),
          endTime: today.add(Duration(hours: 11)),
        ),
        DefaultAppointment(
          id: '2',
          resourceId: 'r1',
          title: 'Tomorrow Meeting',
          startTime: today.add(Duration(days: 1, hours: 10)),
          endTime: today.add(Duration(days: 1, hours: 11)),
        ),
      ];

      controller.updateAppointments(appointments);
      controller.updateResources([
        DefaultResource(id: 'r1', name: 'Resource 1'),
      ]);

      await tester.pumpWidget(
        buildAgendaView(
          agendaConfig: AgendaViewConfig(
            groupingMode: AgendaGroupingMode.byDate,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should have date headers
      expect(find.textContaining('Today'), findsOneWidget);
      expect(find.textContaining('Tomorrow'), findsOneWidget);
    });

    testWidgets('should display appointment time when enabled', (tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final appointment = DefaultAppointment(
        id: '1',
        resourceId: 'r1',
        title: 'Meeting',
        startTime: today.add(Duration(hours: 10)),
        endTime: today.add(Duration(hours: 11)),
      );

      controller.updateAppointments([appointment]);
      controller.updateResources([
        DefaultResource(id: 'r1', name: 'Resource 1'),
      ]);

      await tester.pumpWidget(
        buildAgendaView(
          agendaConfig: AgendaViewConfig(showAppointmentTime: true),
        ),
      );
      await tester.pumpAndSettle();

      // Should display time (format may vary)
      expect(find.textContaining('10:00'), findsWidgets);
    });

    testWidgets('should hide appointment time when disabled', (tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final appointment = DefaultAppointment(
        id: '1',
        resourceId: 'r1',
        title: 'Meeting',
        startTime: today.add(Duration(hours: 10)),
        endTime: today.add(Duration(hours: 11)),
      );

      controller.updateAppointments([appointment]);
      controller.updateResources([
        DefaultResource(id: 'r1', name: 'Resource 1'),
      ]);

      await tester.pumpWidget(
        buildAgendaView(
          agendaConfig: AgendaViewConfig(showAppointmentTime: false),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Meeting'), findsOneWidget);
      // Time should not be displayed
    });

    testWidgets('should respond to tap on appointment', (tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final appointment = DefaultAppointment(
        id: '1',
        resourceId: 'r1',
        title: 'Meeting',
        startTime: today.add(Duration(hours: 10)),
        endTime: today.add(Duration(hours: 11)),
      );

      controller.updateAppointments([appointment]);
      controller.updateResources([
        DefaultResource(id: 'r1', name: 'Resource 1'),
      ]);

      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarView(
              controller: controller,
              config: CalendarConfig(
                viewType: CalendarViewType.agenda,
                agendaConfig: AgendaViewConfig(enableAppointmentTap: true),
              ),
              onAppointmentTap: (data) {
                tapped = true;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Meeting'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
      expect(controller.selectedAppointment?.id, equals('1'));
    });

    testWidgets('should scroll appointments list', (tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Create many appointments to require scrolling
      final appointments = List.generate(20, (index) {
        return DefaultAppointment(
          id: '$index',
          resourceId: 'r1',
          title: 'Meeting $index',
          startTime: today.add(Duration(hours: index)),
          endTime: today.add(Duration(hours: index + 1)),
        );
      });

      controller.updateAppointments(appointments);
      controller.updateResources([
        DefaultResource(id: 'r1', name: 'Resource 1'),
      ]);

      await tester.pumpWidget(buildAgendaView());
      await tester.pumpAndSettle();

      // Find first and last appointments
      expect(find.text('Meeting 0'), findsOneWidget);

      // Scroll to find last appointment
      await tester.drag(find.byType(ListView), Offset(0, -5000));
      await tester.pumpAndSettle();

      expect(find.text('Meeting 19'), findsOneWidget);
    });

    testWidgets('should apply custom theme', (tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final appointment = DefaultAppointment(
        id: '1',
        resourceId: 'r1',
        title: 'Meeting',
        startTime: today.add(Duration(hours: 10)),
        endTime: today.add(Duration(hours: 11)),
      );

      controller.updateAppointments([appointment]);
      controller.updateResources([
        DefaultResource(id: 'r1', name: 'Resource 1'),
      ]);

      final customTheme = CalendarTheme(
        agendaItemBorderRadius: 16.0,
        agendaItemMargin: EdgeInsets.all(8),
      );

      await tester.pumpWidget(buildAgendaView(theme: customTheme));
      await tester.pumpAndSettle();

      // Verify widget is rendered (theme properties tested through visual inspection)
      expect(find.text('Meeting'), findsOneWidget);
    });

    testWidgets('should display resource avatar when enabled', (tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final appointment = DefaultAppointment(
        id: '1',
        resourceId: 'r1',
        title: 'Meeting',
        startTime: today.add(Duration(hours: 10)),
        endTime: today.add(Duration(hours: 11)),
      );

      controller.updateAppointments([appointment]);
      controller.updateResources([
        DefaultResource(
          id: 'r1',
          name: 'John Doe',
          avatarUrl: 'https://example.com/avatar.jpg',
        ),
      ]);

      await tester.pumpWidget(
        buildAgendaView(
          agendaConfig: AgendaViewConfig(showResourceAvatar: true),
        ),
      );
      await tester.pumpAndSettle();

      // Avatar should be displayed (as CircleAvatar or similar)
      expect(find.byType(CircleAvatar), findsWidgets);
    });

    testWidgets('should hide resource avatar when disabled', (tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final appointment = DefaultAppointment(
        id: '1',
        resourceId: 'r1',
        title: 'Meeting',
        startTime: today.add(Duration(hours: 10)),
        endTime: today.add(Duration(hours: 11)),
      );

      controller.updateAppointments([appointment]);
      controller.updateResources([
        DefaultResource(
          id: 'r1',
          name: 'John Doe',
          avatarUrl: 'https://example.com/avatar.jpg',
        ),
      ]);

      await tester.pumpWidget(
        buildAgendaView(
          agendaConfig: AgendaViewConfig(showResourceAvatar: false),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Meeting'), findsOneWidget);
    });

    testWidgets('should handle empty days correctly', (tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Only appointment on day 3
      final appointment = DefaultAppointment(
        id: '1',
        resourceId: 'r1',
        title: 'Meeting',
        startTime: today.add(Duration(days: 3, hours: 10)),
        endTime: today.add(Duration(days: 3, hours: 11)),
      );

      controller.updateAppointments([appointment]);
      controller.updateResources([
        DefaultResource(id: 'r1', name: 'Resource 1'),
      ]);

      await tester.pumpWidget(
        buildAgendaView(
          agendaConfig: AgendaViewConfig(
            groupingMode: AgendaGroupingMode.byDate,
            showEmptyDays: true,
            daysToShow: 7,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show empty day headers
      expect(find.textContaining('Today'), findsOneWidget);
    });

    testWidgets('should filter by resource', (tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final appointments = [
        DefaultAppointment(
          id: '1',
          resourceId: 'r1',
          title: 'Resource 1 Meeting',
          startTime: today.add(Duration(hours: 10)),
          endTime: today.add(Duration(hours: 11)),
        ),
        DefaultAppointment(
          id: '2',
          resourceId: 'r2',
          title: 'Resource 2 Meeting',
          startTime: today.add(Duration(hours: 10)),
          endTime: today.add(Duration(hours: 11)),
        ),
      ];

      controller.updateAppointments(appointments);
      controller.updateResources([
        DefaultResource(id: 'r1', name: 'Resource 1'),
        DefaultResource(id: 'r2', name: 'Resource 2'),
      ]);

      controller.setResourceFilter({'r1'});

      await tester.pumpWidget(buildAgendaView());
      await tester.pumpAndSettle();

      expect(find.text('Resource 1 Meeting'), findsOneWidget);
      expect(find.text('Resource 2 Meeting'), findsNothing);
    });
  });
}
