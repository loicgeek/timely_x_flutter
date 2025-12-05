import 'dart:ui';

import 'package:timely_x/timely_x.dart';
import 'package:flutter/material.dart';

/// Helper class for creating test appointments
class TestAppointments {
  /// Creates a basic appointment
  static DefaultAppointment basic({
    String? id,
    String? resourceId,
    DateTime? startTime,
    DateTime? endTime,
    String? title,
    String? subtitle,
    Color? color,
  }) {
    final now = DateTime.now();
    return DefaultAppointment(
      id: id ?? 'apt-${DateTime.now().millisecondsSinceEpoch}',
      resourceId: resourceId ?? 'resource-1',
      title: title ?? 'Test Appointment',
      subtitle: subtitle,
      startTime: startTime ?? DateTime(now.year, now.month, now.day, 9, 0),
      endTime: endTime ?? DateTime(now.year, now.month, now.day, 10, 0),
      color: color ?? Colors.blue,
    );
  }

  /// Creates a full-day appointment
  static DefaultAppointment fullDay({
    String? id,
    String? resourceId,
    DateTime? date,
    String? title,
  }) {
    final targetDate = date ?? DateTime.now();
    return DefaultAppointment(
      id: id ?? 'fullday-${DateTime.now().millisecondsSinceEpoch}',
      resourceId: resourceId ?? 'resource-1',
      title: title ?? 'Full Day Event',
      startTime: DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        0,
        0,
      ),
      endTime: DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        23,
        59,
      ),
    );
  }

  /// Creates a multi-day appointment
  static DefaultAppointment multiDay({
    String? id,
    String? resourceId,
    DateTime? startDate,
    int durationDays = 3,
    String? title,
  }) {
    final start = startDate ?? DateTime.now();
    return DefaultAppointment(
      id: id ?? 'multiday-${DateTime.now().millisecondsSinceEpoch}',
      resourceId: resourceId ?? 'resource-1',
      title: title ?? 'Multi-Day Event',
      startTime: DateTime(start.year, start.month, start.day, 9, 0),
      endTime: DateTime(
        start.year,
        start.month,
        start.day + durationDays,
        17,
        0,
      ),
    );
  }

  /// Creates an appointment on end date (for testing end date inclusion)
  static DefaultAppointment onEndDate({
    required DateTime rangeEnd,
    String? resourceId,
    String? title,
  }) {
    return DefaultAppointment(
      id: 'enddate-${DateTime.now().millisecondsSinceEpoch}',
      resourceId: resourceId ?? 'resource-1',
      title: title ?? 'End Date Appointment',
      startTime: DateTime(rangeEnd.year, rangeEnd.month, rangeEnd.day, 10, 0),
      endTime: DateTime(rangeEnd.year, rangeEnd.month, rangeEnd.day, 11, 0),
    );
  }

  /// Creates an appointment that spans past midnight
  static DefaultAppointment pastMidnight({
    String? id,
    String? resourceId,
    DateTime? date,
    String? title,
  }) {
    final start = date ?? DateTime.now();
    return DefaultAppointment(
      id: id ?? 'midnight-${DateTime.now().millisecondsSinceEpoch}',
      resourceId: resourceId ?? 'resource-1',
      title: title ?? 'Late Night Event',
      startTime: DateTime(start.year, start.month, start.day, 23, 0),
      endTime: DateTime(start.year, start.month, start.day + 1, 2, 0),
    );
  }

  /// Creates a set of overlapping appointments
  static List<DefaultAppointment> overlapping({
    required String resourceId,
    required DateTime date,
    int count = 3,
  }) {
    return List.generate(count, (index) {
      return DefaultAppointment(
        id: 'overlap-$index-${DateTime.now().millisecondsSinceEpoch}',
        resourceId: resourceId,
        title: 'Overlapping Event ${index + 1}',
        startTime: DateTime(date.year, date.month, date.day, 10 + index, 0),
        endTime: DateTime(date.year, date.month, date.day, 12 + index, 0),
      );
    });
  }

  /// Creates a recurring pattern of appointments (for testing performance)
  static List<DefaultAppointment> recurringPattern({
    required String resourceId,
    required DateTime startDate,
    required int count,
    required Duration interval,
  }) {
    return List.generate(count, (index) {
      final start = startDate.add(interval * index);
      return DefaultAppointment(
        id: 'recurring-$index-${DateTime.now().millisecondsSinceEpoch}',
        resourceId: resourceId,
        title: 'Recurring Event ${index + 1}',
        startTime: start,
        endTime: start.add(Duration(hours: 1)),
      );
    });
  }

  /// Creates appointments across a date range (for testing date handling)
  static List<DefaultAppointment> acrossDateRange({
    required DateTime startDate,
    required DateTime endDate,
    required String resourceId,
    int appointmentsPerDay = 2,
  }) {
    final List<DefaultAppointment> appointments = [];
    DateTime current = startDate;
    int id = 0;

    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      for (int i = 0; i < appointmentsPerDay; i++) {
        appointments.add(
          DefaultAppointment(
            id: 'range-${id++}',
            resourceId: resourceId,
            title: 'Event ${id}',
            startTime: DateTime(
              current.year,
              current.month,
              current.day,
              9 + (i * 2),
              0,
            ),
            endTime: DateTime(
              current.year,
              current.month,
              current.day,
              10 + (i * 2),
              0,
            ),
          ),
        );
      }
      // Use calendar arithmetic to avoid DST issues
      current = DateTime(current.year, current.month, current.day + 1);
    }

    return appointments;
  }

  /// Creates appointments for DST transition testing
  static List<DefaultAppointment> aroundDSTTransition({
    required DateTime dstDate,
    required String resourceId,
  }) {
    return [
      // Day before DST
      DefaultAppointment(
        id: 'dst-before',
        resourceId: resourceId,
        title: 'Before DST',
        startTime: DateTime(
          dstDate.year,
          dstDate.month,
          dstDate.day - 1,
          10,
          0,
        ),
        endTime: DateTime(dstDate.year, dstDate.month, dstDate.day - 1, 11, 0),
      ),
      // Day of DST
      DefaultAppointment(
        id: 'dst-on',
        resourceId: resourceId,
        title: 'On DST',
        startTime: DateTime(dstDate.year, dstDate.month, dstDate.day, 10, 0),
        endTime: DateTime(dstDate.year, dstDate.month, dstDate.day, 11, 0),
      ),
      // Day after DST
      DefaultAppointment(
        id: 'dst-after',
        resourceId: resourceId,
        title: 'After DST',
        startTime: DateTime(
          dstDate.year,
          dstDate.month,
          dstDate.day + 1,
          10,
          0,
        ),
        endTime: DateTime(dstDate.year, dstDate.month, dstDate.day + 1, 11, 0),
      ),
    ];
  }

  /// Creates a large dataset for performance testing
  static List<DefaultAppointment> largeDataset({
    required List<String> resourceIds,
    required DateTime startDate,
    int daysToGenerate = 365,
    int appointmentsPerResourcePerDay = 5,
  }) {
    final List<DefaultAppointment> appointments = [];
    int id = 0;

    for (int day = 0; day < daysToGenerate; day++) {
      final date = DateTime(
        startDate.year,
        startDate.month,
        startDate.day + day,
      );

      for (final resourceId in resourceIds) {
        for (int apt = 0; apt < appointmentsPerResourcePerDay; apt++) {
          final startHour = 8 + (apt * 2);
          appointments.add(
            DefaultAppointment(
              id: 'large-${id++}',
              resourceId: resourceId,
              title: 'Appointment ${id}',
              startTime: DateTime(
                date.year,
                date.month,
                date.day,
                startHour,
                0,
              ),
              endTime: DateTime(
                date.year,
                date.month,
                date.day,
                startHour + 1,
                0,
              ),
            ),
          );
        }
      }
    }

    return appointments;
  }
}
