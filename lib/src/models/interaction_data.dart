// lib/src/models/interaction_data.dart

import 'package:flutter/material.dart';
import 'calendar_appointment.dart';
import 'calendar_resource.dart';

/// Data for appointment tap interaction
class AppointmentTapData {
  const AppointmentTapData({
    required this.appointment,
    required this.resource,
    required this.globalPosition,
  });

  final CalendarAppointment appointment;
  final CalendarResource resource;
  final Offset globalPosition;
}

/// Data for appointment long press interaction
class AppointmentLongPressData {
  const AppointmentLongPressData({
    required this.appointment,
    required this.resource,
    required this.globalPosition,
  });

  final CalendarAppointment appointment;
  final CalendarResource resource;
  final Offset globalPosition;
}

/// Data for appointment secondary tap (right-click)
class AppointmentSecondaryTapData {
  const AppointmentSecondaryTapData({
    required this.appointment,
    required this.resource,
    required this.globalPosition,
  });

  final CalendarAppointment appointment;
  final CalendarResource resource;
  final Offset globalPosition;
}

/// Data for empty cell tap
class CellTapData {
  const CellTapData({
    required this.resource,
    required this.dateTime,
    required this.globalPosition,
    this.appointments = const [],
  });

  final CalendarResource resource;
  final DateTime dateTime;
  final Offset globalPosition;
  final List<CalendarAppointment> appointments;
}

/// Data for appointment drag
class AppointmentDragData {
  const AppointmentDragData({
    required this.appointment,
    required this.oldResource,
    required this.newResource,
    required this.oldStartTime,
    required this.oldEndTime,
    required this.newStartTime,
    required this.newEndTime,
  });

  final CalendarAppointment appointment;
  final CalendarResource oldResource;
  final CalendarResource newResource;
  final DateTime oldStartTime;
  final DateTime oldEndTime;
  final DateTime newStartTime;
  final DateTime newEndTime;

  Duration get timeDifference => newStartTime.difference(oldStartTime);
  bool get resourceChanged => oldResource.id != newResource.id;
}

/// Data for appointment resize
class AppointmentResizeData {
  const AppointmentResizeData({
    required this.appointment,
    required this.resource,
    required this.oldStartTime,
    required this.oldEndTime,
    required this.newStartTime,
    required this.newEndTime,
    required this.resizeEdge,
  });

  final CalendarAppointment appointment;
  final CalendarResource resource;
  final DateTime oldStartTime;
  final DateTime oldEndTime;
  final DateTime newStartTime;
  final DateTime newEndTime;
  final ResizeEdge resizeEdge;

  Duration get durationDifference {
    final oldDuration = oldEndTime.difference(oldStartTime);
    final newDuration = newEndTime.difference(newStartTime);
    return newDuration - oldDuration;
  }
}

enum ResizeEdge { top, bottom }

/// Data for resource header tap
class ResourceHeaderTapData {
  const ResourceHeaderTapData({
    required this.resource,
    required this.globalPosition,
  });

  final CalendarResource resource;
  final Offset globalPosition;
}

/// Data for date header tap
class DateHeaderTapData {
  const DateHeaderTapData({required this.date, required this.globalPosition});

  final DateTime date;
  final Offset globalPosition;
}
