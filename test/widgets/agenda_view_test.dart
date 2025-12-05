import 'dart:ui';

import 'package:timely_x/timely_x.dart';
import 'package:timely_x/src/widgets/agenda_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_appointments.dart';
import '../helpers/test_resources.dart';
import '../helpers/test_configs.dart';

/// Tests for AgendaView widget
/// Covers rendering, interactions, grouping modes, and empty states
void main() {
  group('AgendaView', () {
    late CalendarController controller;
    late List<CalendarResource> resources;
    late List<CalendarAppointment> appointments;

    setUp(() {
      controller = CalendarController(config: TestConfigs.agendaView());

      resources = TestResources.multipleResources(count: 3);
      controller.updateResources(resources);

      // Create test appointments
      appointments = [
        TestAppointments.basic(
          id: 'apt1',
          resourceId: resources[0].id,
          title: 'Team Meeting',
          startTime: DateTime(2025, 1, 15, 10, 0),
          endTime: DateTime(2025, 1, 15, 11, 0),
        ),
        TestAppointments.basic(
          id: 'apt2',
          resourceId: resources[1].id,
          title: 'Client Call',
          startTime: DateTime(2025, 1, 15, 14, 0),
          endTime: DateTime(2025, 1, 15, 15, 0),
        ),
        TestAppointments.basic(
          id: 'apt3',
          resourceId: resources[0].id,
          title: 'Code Review',
          startTime: DateTime(2025, 1, 16, 9, 0),
          endTime: DateTime(2025, 1, 16, 10, 0),
        ),
        TestAppointments.basic(
          id: 'apt4',
          resourceId: resources[0].id,
          title: 'Code Review',
          startTime: DateTime(2025, 1, 22, 9, 0),
          endTime: DateTime(2025, 1, 22, 10, 0),
        ),
      ];

      controller.updateAppointments(appointments);
    });

    tearDown(() {
      controller.dispose();
    });

    group('Rendering', () {
      testWidgets('should render agenda view', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: AgendaView(controller: controller)),
          ),
        );

        expect(find.byType(AgendaView), findsOneWidget);
        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('should display appointments', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: AgendaView(controller: controller)),
          ),
        );

        await tester.pumpAndSettle();

        // Should find appointment titles
        expect(find.text('Team Meeting'), findsOneWidget);
        expect(find.text('Client Call'), findsOneWidget);
        expect(find.text('Code Review'), findsOneWidget);
      });

      testWidgets('should render with custom theme', (tester) async {
        final customTheme = CalendarTheme();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AgendaView(controller: controller, theme: customTheme),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(AgendaView), findsOneWidget);
      });

      testWidgets('should update when controller changes', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: AgendaView(controller: controller)),
          ),
        );

        await tester.pumpAndSettle();

        // Add new appointment
        final newAppointment = TestAppointments.basic(
          id: 'new-apt',
          resourceId: resources[0].id,
          title: 'New Meeting',
          startTime: DateTime(2025, 1, 17, 10, 0),
          endTime: DateTime(2025, 1, 17, 11, 0),
        );

        controller.addAppointment(newAppointment);
        await tester.pumpAndSettle();

        // Should display new appointment
        expect(find.text('New Meeting'), findsOneWidget);
      });
    });

    group('Empty State', () {
      testWidgets('should show empty state when no appointments', (
        tester,
      ) async {
        // Create controller with no appointments
        final emptyController = CalendarController(
          config: TestConfigs.agendaView(),
        );
        emptyController.updateResources(resources);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: AgendaView(controller: emptyController)),
          ),
        );

        await tester.pumpAndSettle();

        // Should show empty state message
        expect(find.text('No appointments scheduled'), findsOneWidget);

        emptyController.dispose();
      });

      testWidgets('should use custom empty state builder', (tester) async {
        final emptyController = CalendarController(
          config: TestConfigs.agendaView(),
        );
        emptyController.updateResources(resources);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AgendaView(
                controller: emptyController,
                agendaEmptyStateBuilder: (context, message) {
                  return Center(child: Text('Custom Empty: $message'));
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.textContaining('Custom Empty:'), findsOneWidget);

        emptyController.dispose();
      });

      testWidgets(
        'should show "No upcoming appointments" message when past disabled',
        (tester) async {
          final emptyController = CalendarController(
            config: CalendarConfig(
              viewType: CalendarViewType.agenda,
              agendaConfig: AgendaViewConfig(
                showPastAppointments: false, // Don't show past
              ),
            ),
          );
          emptyController.updateResources(resources);

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(body: AgendaView(controller: emptyController)),
            ),
          );

          await tester.pumpAndSettle();

          expect(find.text('No upcoming appointments'), findsOneWidget);

          emptyController.dispose();
        },
      );
    });

    group('Grouping Modes', () {
      testWidgets('should group by date', (tester) async {
        final dateGroupController = CalendarController(
          config: CalendarConfig(
            viewType: CalendarViewType.agenda,
            agendaConfig: AgendaViewConfig(
              groupingMode: AgendaGroupingMode.byDate,
            ),
          ),
        );
        dateGroupController.updateResources(resources);
        dateGroupController.updateAppointments(appointments);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: AgendaView(controller: dateGroupController)),
          ),
        );

        await tester.pumpAndSettle();

        // Should show date headers
        expect(find.textContaining('January'), findsWidgets);

        dateGroupController.dispose();
      });

      testWidgets('should group by resource', (tester) async {
        final resourceGroupController = CalendarController(
          config: CalendarConfig(
            viewType: CalendarViewType.agenda,
            agendaConfig: AgendaViewConfig(
              groupingMode: AgendaGroupingMode.byResource,
            ),
          ),
        );
        resourceGroupController.updateResources(resources);
        resourceGroupController.updateAppointments(appointments);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AgendaView(controller: resourceGroupController),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should show resource names
        expect(find.text(resources[0].name), findsOneWidget);
        expect(find.text(resources[1].name), findsOneWidget);

        resourceGroupController.dispose();
      });

      testWidgets('should handle chronological mode', (tester) async {
        final chronoController = CalendarController(
          config: CalendarConfig(
            viewType: CalendarViewType.agenda,
            agendaConfig: AgendaViewConfig(
              groupingMode: AgendaGroupingMode.chronological,
            ),
          ),
        );
        chronoController.updateResources(resources);
        chronoController.updateAppointments(appointments);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: AgendaView(controller: chronoController)),
          ),
        );

        await tester.pumpAndSettle();

        // Should show all appointments header
        expect(find.text('All Appointments'), findsOneWidget);

        chronoController.dispose();
      });
    });

    group('Interactions', () {
      testWidgets('should handle appointment tap', (tester) async {
        AppointmentTapData? tappedData;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AgendaView(
                controller: controller,
                onAppointmentTap: (data) {
                  tappedData = data;
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tap on first appointment
        await tester.tap(find.text('Team Meeting'));
        await tester.pumpAndSettle();

        expect(tappedData, isNotNull);
        expect(tappedData!.appointment.title, equals('Team Meeting'));
        expect(tappedData!.resource.id, equals(resources[0].id));
      });

      testWidgets('should handle appointment long press', (tester) async {
        AppointmentLongPressData? longPressData;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AgendaView(
                controller: controller,
                onAppointmentLongPress: (data) {
                  longPressData = data;
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Long press on first appointment
        await tester.longPress(find.text('Team Meeting'));
        await tester.pumpAndSettle();

        expect(longPressData, isNotNull);
        expect(longPressData!.appointment.title, equals('Team Meeting'));
      });

      testWidgets('should handle secondary tap', (tester) async {
        AppointmentSecondaryTapData? secondaryTapData;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AgendaView(
                controller: controller,
                onAppointmentSecondaryTap: (data) {
                  secondaryTapData = data;
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Right click on first appointment
        await tester.tap(find.text('Team Meeting'), buttons: kSecondaryButton);
        await tester.pumpAndSettle();

        expect(secondaryTapData, isNotNull);
        expect(secondaryTapData!.appointment.title, equals('Team Meeting'));
      });

      testWidgets('should select appointment on tap', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: AgendaView(controller: controller)),
          ),
        );

        await tester.pumpAndSettle();

        // Initial state - no selection
        expect(controller.selectedAppointment, isNull);

        // Tap appointment
        await tester.tap(find.text('Team Meeting'));
        await tester.pumpAndSettle();

        // Should be selected
        expect(controller.selectedAppointment, isNotNull);
        expect(controller.selectedAppointment!.title, equals('Team Meeting'));
      });

      testWidgets('should respect enableAppointmentTap config', (tester) async {
        final disabledController = CalendarController(
          config: CalendarConfig(
            viewType: CalendarViewType.agenda,
            agendaConfig: AgendaViewConfig(
              enableAppointmentTap: false, // Disabled
            ),
          ),
        );
        disabledController.updateResources(resources);
        disabledController.updateAppointments(appointments);

        AppointmentTapData? tappedData;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AgendaView(
                controller: disabledController,
                onAppointmentTap: (data) {
                  tappedData = data;
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Try to tap
        await tester.tap(find.text('Team Meeting'));
        await tester.pumpAndSettle();

        // Should not trigger
        expect(tappedData, isNull);

        disabledController.dispose();
      });

      testWidgets('should respect enableAppointmentLongPress config', (
        tester,
      ) async {
        final disabledController = CalendarController(
          config: CalendarConfig(
            viewType: CalendarViewType.agenda,
            agendaConfig: AgendaViewConfig(
              enableAppointmentLongPress: false, // Disabled
            ),
          ),
        );
        disabledController.updateResources(resources);
        disabledController.updateAppointments(appointments);

        AppointmentLongPressData? longPressData;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AgendaView(
                controller: disabledController,
                onAppointmentLongPress: (data) {
                  longPressData = data;
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Try to long press
        await tester.longPress(find.text('Team Meeting'));
        await tester.pumpAndSettle();

        // Should not trigger
        expect(longPressData, isNull);

        disabledController.dispose();
      });
    });

    group('Hover State', () {
      testWidgets('should track hovered item', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: AgendaView(controller: controller)),
          ),
        );

        await tester.pumpAndSettle();

        // Simulate hover
        final gesture = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
        );
        await gesture.addPointer(
          location: tester.getCenter(find.text('Team Meeting')),
        );
        await tester.pumpAndSettle();

        // Widget should handle hover
        // (State is internal, so we just verify no errors)
        expect(find.byType(AgendaView), findsOneWidget);

        await gesture.removePointer();
      });
    });

    group('Custom Builders', () {
      testWidgets('should use custom date header builder', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AgendaView(
                controller: controller,
                agendaDateHeaderBuilder: (context, header, isTopLevel) {
                  return Container(
                    padding: EdgeInsets.all(16),
                    child: Text('Custom Date: ${header.title}'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.textContaining('Custom Date:'), findsWidgets);
      });

      testWidgets('should use custom resource header builder', (tester) async {
        final resourceController = CalendarController(
          config: CalendarConfig(
            viewType: CalendarViewType.agenda,
            agendaConfig: AgendaViewConfig(
              groupingMode: AgendaGroupingMode.byResource,
            ),
          ),
        );
        resourceController.updateResources(resources);
        resourceController.updateAppointments(appointments);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AgendaView(
                controller: resourceController,
                agendaResourceHeaderBuilder: (context, header, isTopLevel) {
                  return Container(
                    padding: EdgeInsets.all(16),
                    child: Text('Custom Resource: ${header.title}'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.textContaining('Custom Resource:'), findsWidgets);

        resourceController.dispose();
      });

      testWidgets('should use custom item builder', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AgendaView(
                controller: controller,
                agendaItemBuilder: (context, item, isSelected, isHovered) {
                  return Container(
                    padding: EdgeInsets.all(8),
                    child: Text('Custom Item: ${item.appointment.title}'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.textContaining('Custom Item:'), findsWidgets);
      });
    });

    group('Date Range', () {
      testWidgets('should handle relative date range mode', (tester) async {
        final relativeController = CalendarController(
          config: CalendarConfig(
            viewType: CalendarViewType.agenda,
            agendaConfig: AgendaViewConfig(
              dateRangeMode: AgendaDateRangeMode.relative,
              daysToShow: 7,
            ),
          ),
        );
        relativeController.updateResources(resources);
        relativeController.updateAppointments(appointments);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: AgendaView(controller: relativeController)),
          ),
        );

        await tester.pumpAndSettle();

        // Should render without errors
        expect(find.byType(AgendaView), findsOneWidget);

        relativeController.dispose();
      });

      testWidgets('should handle custom date range mode', (tester) async {
        final customController = CalendarController(
          config: CalendarConfig(
            viewType: CalendarViewType.agenda,
            agendaConfig: AgendaViewConfig(
              dateRangeMode: AgendaDateRangeMode.custom,
            ),
          ),
        );
        customController.updateResources(resources);
        customController.updateAppointments(appointments);

        // Set custom date range
        customController.setAgendaDateRange(
          DateTime(2025, 1, 15),
          DateTime(2025, 1, 20),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: AgendaView(controller: customController)),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(AgendaView), findsOneWidget);

        customController.dispose();
      });
    });

    group('Scrolling', () {
      testWidgets('should be scrollable', (tester) async {
        // Create many appointments to force scrolling
        final manyAppointments = List.generate(
          30,
          (index) => TestAppointments.basic(
            id: 'apt-$index',
            resourceId: resources[0].id,
            title: 'Meeting $index',
            startTime: DateTime(2025, 1, 15 + index, 10, 0),
            endTime: DateTime(2025, 1, 15 + index, 11, 0),
          ),
        );

        final scrollController = CalendarController(
          config: TestConfigs.agendaView(),
        );
        scrollController.updateResources(resources);
        scrollController.updateAppointments(manyAppointments);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: AgendaView(controller: scrollController)),
          ),
        );

        await tester.pumpAndSettle();

        // Should be scrollable
        expect(find.byType(ListView), findsOneWidget);

        scrollController.dispose();
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle appointments on end date', (tester) async {
        final endDateAppointment = TestAppointments.onEndDate(
          rangeEnd: DateTime(2025, 1, 20),
          resourceId: resources[0].id,
          title: 'End Date Meeting',
        );

        controller.updateAppointments([endDateAppointment]);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: AgendaView(controller: controller)),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('End Date Meeting'), findsOneWidget);
      });

      testWidgets('should handle multi-day appointments', (tester) async {
        final multiDayAppointment = TestAppointments.multiDay(
          resourceId: resources[0].id,
          startDate: DateTime(2025, 1, 15),
          durationDays: 3,
          title: 'Multi-Day Event',
        );

        controller.updateAppointments([multiDayAppointment]);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: AgendaView(controller: controller)),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Multi-Day Event'), findsOneWidget);
      });

      testWidgets('should handle appointments past midnight', (tester) async {
        final pastMidnightAppointment = TestAppointments.pastMidnight(
          resourceId: resources[0].id,
          date: DateTime(2025, 1, 15),
          title: 'Late Night Meeting',
        );

        controller.updateAppointments([pastMidnightAppointment]);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: AgendaView(controller: controller)),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Late Night Meeting'), findsOneWidget);
      });

      testWidgets('should handle no resources', (tester) async {
        final noResourceController = CalendarController(
          config: TestConfigs.agendaView(),
        );
        noResourceController.updateAppointments(appointments);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: AgendaView(controller: noResourceController)),
          ),
        );

        await tester.pumpAndSettle();

        // Should show empty state or handle gracefully
        expect(find.byType(AgendaView), findsOneWidget);

        noResourceController.dispose();
      });
    });

    group('Disposal', () {
      testWidgets('should dispose properly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: AgendaView(controller: controller)),
          ),
        );

        await tester.pumpAndSettle();

        // Remove widget
        await tester.pumpWidget(MaterialApp(home: Scaffold(body: Container())));

        await tester.pumpAndSettle();

        // Should dispose without errors
      });

      testWidgets('should remove controller listener on dispose', (
        tester,
      ) async {
        int notificationCount = 0;
        controller.addListener(() {
          notificationCount++;
        });

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: AgendaView(controller: controller)),
          ),
        );

        await tester.pumpAndSettle();

        // Dispose widget
        await tester.pumpWidget(MaterialApp(home: Scaffold(body: Container())));

        await tester.pumpAndSettle();

        final previousCount = notificationCount;

        // Trigger controller change
        controller.addAppointment(
          TestAppointments.basic(resourceId: resources[0].id),
        );

        // AgendaView listener should not be called (it was removed)
        // Only our test listener should be called
        expect(notificationCount, equals(previousCount + 1));
      });
    });
  });
}
