// lib/src/utils/overlap_calculator.dart

import '../models/calendar_appointment.dart';
import '../models/appointment_position.dart';
import 'package:flutter/material.dart';

/// Calculates overlapping appointments and their positions
class OverlapCalculator {
  /// Group appointments by overlaps and calculate positions
  static List<AppointmentPosition> calculatePositions({
    required List<CalendarAppointment> appointments,
    required double cellWidth,
    required double cellLeft,
    required double hourHeight,
    required DateTime dayStart,
  }) {
    if (appointments.isEmpty) return [];

    // Sort appointments by start time
    final sorted = List<CalendarAppointment>.from(appointments)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    // Find overlap groups
    final groups = _findOverlapGroups(sorted);

    // Calculate positions for each group
    final List<AppointmentPosition> positions = [];
    for (final group in groups) {
      positions.addAll(
        _calculateGroupPositions(
          appointments: group,
          cellWidth: cellWidth,
          cellLeft: cellLeft,
          hourHeight: hourHeight,
          dayStart: dayStart,
        ),
      );
    }

    return positions;
  }

  /// Find groups of overlapping appointments
  static List<List<CalendarAppointment>> _findOverlapGroups(
    List<CalendarAppointment> appointments,
  ) {
    final List<List<CalendarAppointment>> groups = [];
    final Set<String> processed = {};

    for (final appointment in appointments) {
      if (processed.contains(appointment.id)) continue;

      final group = <CalendarAppointment>[appointment];
      processed.add(appointment.id);

      // Find all appointments that overlap with any in the current group
      bool foundOverlap = true;
      while (foundOverlap) {
        foundOverlap = false;
        for (final other in appointments) {
          if (processed.contains(other.id)) continue;

          // Check if 'other' overlaps with any in the group
          if (group.any((a) => a.overlapsWith(other))) {
            group.add(other);
            processed.add(other.id);
            foundOverlap = true;
          }
        }
      }

      groups.add(group);
    }

    return groups;
  }

  /// Calculate positions for appointments in an overlap group
  static List<AppointmentPosition> _calculateGroupPositions({
    required List<CalendarAppointment> appointments,
    required double cellWidth,
    required double cellLeft,
    required double hourHeight,
    required DateTime dayStart,
  }) {
    if (appointments.isEmpty) return [];
    if (appointments.length == 1) {
      return [
        _createPosition(
          appointment: appointments[0],
          cellWidth: cellWidth,
          cellLeft: cellLeft,
          hourHeight: hourHeight,
          dayStart: dayStart,
          index: 0,
          total: 1,
        ),
      ];
    }

    // Sort by start time, then by duration (longer first)
    final sorted = List<CalendarAppointment>.from(appointments)
      ..sort((a, b) {
        final startCompare = a.startTime.compareTo(b.startTime);
        if (startCompare != 0) return startCompare;
        return b.duration.compareTo(a.duration);
      });

    // Assign columns using a greedy algorithm
    final columns = <List<CalendarAppointment>>[];

    for (final appointment in sorted) {
      bool placed = false;

      // Try to place in existing column
      for (final column in columns) {
        if (_canPlaceInColumn(appointment, column)) {
          column.add(appointment);
          placed = true;
          break;
        }
      }

      // Create new column if needed
      if (!placed) {
        columns.add([appointment]);
      }
    }

    // Calculate positions based on columns
    final positions = <AppointmentPosition>[];
    final totalColumns = columns.length;
    final columnWidth = cellWidth / totalColumns;

    for (int i = 0; i < columns.length; i++) {
      for (final appointment in columns[i]) {
        // Try to expand width if possible
        int expandedWidth = 1;
        for (int j = i + 1; j < columns.length; j++) {
          if (_canExpand(appointment, columns[j])) {
            expandedWidth++;
          } else {
            break;
          }
        }

        positions.add(
          _createPosition(
            appointment: appointment,
            cellWidth: cellWidth,
            cellLeft: cellLeft,
            hourHeight: hourHeight,
            dayStart: dayStart,
            index: i,
            total: totalColumns,
            widthMultiplier: expandedWidth / totalColumns,
          ),
        );
      }
    }

    return positions;
  }

  /// Check if appointment can be placed in a column without overlap
  static bool _canPlaceInColumn(
    CalendarAppointment appointment,
    List<CalendarAppointment> column,
  ) {
    return !column.any((a) => a.overlapsWith(appointment));
  }

  /// Check if appointment can expand into a column
  static bool _canExpand(
    CalendarAppointment appointment,
    List<CalendarAppointment> column,
  ) {
    return !column.any((a) => a.overlapsWith(appointment));
  }

  /// Create position object for an appointment
  static AppointmentPosition _createPosition({
    required CalendarAppointment appointment,
    required double cellWidth,
    required double cellLeft,
    required double hourHeight,
    required DateTime dayStart,
    required int index,
    required int total,
    double widthMultiplier = 1.0,
  }) {
    // Calculate vertical position
    final minutesFromStart = appointment.startTime
        .difference(dayStart)
        .inMinutes;
    final top = (minutesFromStart / 60) * hourHeight;

    final duration = appointment.duration.inMinutes;
    final height = (duration / 60) * hourHeight;

    // Calculate horizontal position
    final columnWidth = cellWidth / total;
    final leftOffset = columnWidth * index;
    final width = cellWidth * widthMultiplier;

    return AppointmentPosition(
      appointment: appointment,
      rect: Rect.fromLTWH(cellLeft, top, cellWidth, height),
      overlapIndex: index,
      totalOverlaps: total,
      widthMultiplier: widthMultiplier,
      leftOffset: leftOffset,
    );
  }
}
