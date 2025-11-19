// lib/src/models/calendar_appointment.dart

import 'package:flutter/material.dart';

/// Abstract base class for calendar appointments
/// Extend this class to create your custom appointment model
abstract class CalendarAppointment {
  /// Unique identifier for the appointment
  String get id;

  /// Resource ID this appointment belongs to
  String get resourceId;

  /// Start date and time
  DateTime get startTime;

  /// End date and time
  DateTime get endTime;

  /// Title/name of the appointment
  String get title;

  /// Optional subtitle or description
  String? get subtitle => null;

  /// Background color for the appointment
  Color get color => Colors.blue;

  /// Status or category
  String? get status => null;

  /// Any custom data you want to attach
  Map<String, dynamic>? get customData => null;

  /// Duration of the appointment
  Duration get duration => endTime.difference(startTime);

  /// Check if this appointment overlaps with another
  bool overlapsWith(CalendarAppointment other) {
    return startTime.isBefore(other.endTime) &&
        other.startTime.isBefore(endTime) &&
        resourceId == other.resourceId;
  }

  /// Check if appointment is on a specific date
  bool isOnDate(DateTime date) {
    final appointmentDate = DateTime(
      startTime.year,
      startTime.month,
      startTime.day,
    );
    final checkDate = DateTime(date.year, date.month, date.day);
    return appointmentDate.isAtSameMomentAs(checkDate);
  }
}

/// Default implementation of CalendarAppointment
class DefaultAppointment extends CalendarAppointment {
  DefaultAppointment({
    required this.id,
    required this.resourceId,
    required this.startTime,
    required this.endTime,
    required this.title,
    this.subtitle,
    this.color = Colors.blue,
    this.status,
    this.customData,
  });

  @override
  final String id;

  @override
  final String resourceId;

  @override
  final DateTime startTime;

  @override
  final DateTime endTime;

  @override
  final String title;

  @override
  final String? subtitle;

  @override
  final Color color;

  @override
  final String? status;

  @override
  final Map<String, dynamic>? customData;

  DefaultAppointment copyWith({
    String? id,
    String? resourceId,
    DateTime? startTime,
    DateTime? endTime,
    String? title,
    String? subtitle,
    Color? color,
    String? status,
    Map<String, dynamic>? customData,
  }) {
    return DefaultAppointment(
      id: id ?? this.id,
      resourceId: resourceId ?? this.resourceId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      color: color ?? this.color,
      status: status ?? this.status,
      customData: customData ?? this.customData,
    );
  }
}
