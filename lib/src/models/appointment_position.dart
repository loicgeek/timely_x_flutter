// lib/src/models/appointment_position.dart

import 'package:flutter/material.dart';
import 'calendar_appointment.dart';

/// Position and layout information for an appointment
class AppointmentPosition {
  const AppointmentPosition({
    required this.appointment,
    required this.rect,
    required this.overlapIndex,
    required this.totalOverlaps,
    this.widthMultiplier = 1.0,
    this.leftOffset = 0.0,
  });

  final CalendarAppointment appointment;
  final Rect rect; // Absolute position in the grid
  final int overlapIndex; // Position in overlap group (0-based)
  final int totalOverlaps; // Total number of overlapping appointments
  final double widthMultiplier; // 1.0 = full width, 0.5 = half, etc.
  final double leftOffset; // Offset from the left edge of the cell

  double get adjustedWidth => rect.width * widthMultiplier;

  double get adjustedLeft => rect.left + leftOffset;

  Rect get adjustedRect =>
      Rect.fromLTWH(adjustedLeft, rect.top, adjustedWidth, rect.height);

  AppointmentPosition copyWith({
    CalendarAppointment? appointment,
    Rect? rect,
    int? overlapIndex,
    int? totalOverlaps,
    double? widthMultiplier,
    double? leftOffset,
  }) {
    return AppointmentPosition(
      appointment: appointment ?? this.appointment,
      rect: rect ?? this.rect,
      overlapIndex: overlapIndex ?? this.overlapIndex,
      totalOverlaps: totalOverlaps ?? this.totalOverlaps,
      widthMultiplier: widthMultiplier ?? this.widthMultiplier,
      leftOffset: leftOffset ?? this.leftOffset,
    );
  }
}
