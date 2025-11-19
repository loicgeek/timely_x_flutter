// lib/src/utils/business_hours_calculator.dart

import 'package:flutter/foundation.dart';

import '../models/business_hours.dart';
import '../models/calendar_config.dart';

/// Utilities for calculating business hours and unavailability
class BusinessHoursCalculator {
  /// Get all unavailability periods for a resource on a specific date
  static List<({TimePeriod period, UnavailabilityStyle style})>
  getUnavailabilityPeriods({
    required BusinessHours? businessHours,
    required DateTime date,
    required CalendarConfig config,
  }) {
    if (businessHours == null) return [];

    final periods = <({TimePeriod period, UnavailabilityStyle style})>[];
    final dayStart = config.dayStartHour.toDouble();
    final dayEnd = config.dayEndHour.toDouble();

    // Add non-working hours
    if (businessHours.showNonWorkingHours) {
      final nonWorkingPeriods = businessHours.getNonWorkingPeriodsForDate(
        date,
        dayStart,
        dayEnd,
      );

      for (final period in nonWorkingPeriods) {
        periods.add((
          period: period,
          style: UnavailabilityStylePresets.standard.copyWith(
            showDebugLabel: kDebugMode,
          ),
        ));
      }
    }

    // Add unavailabilities (holidays, leave, etc.)
    final unavailabilities = businessHours.getUnavailabilitiesForDate(date);
    for (final unavailability in unavailabilities) {
      final timeRange = unavailability.getTimeRangeForDate(date);
      if (timeRange != null) {
        periods.add((
          period: timeRange,
          style:
              unavailability.style ??
              _getDefaultStyleForType(unavailability.type),
        ));
      }
    }

    return periods;
  }

  /// Get default style based on unavailability type
  static UnavailabilityStyle _getDefaultStyleForType(UnavailabilityType type) {
    switch (type) {
      case UnavailabilityType.nonWorkingHours:
        return UnavailabilityStylePresets.standard;
      case UnavailabilityType.break_:
        return UnavailabilityStylePresets.break_;
      case UnavailabilityType.holiday:
        return UnavailabilityStylePresets.holiday;
      case UnavailabilityType.leave:
        return UnavailabilityStylePresets.holiday;
      case UnavailabilityType.blocked:
        return UnavailabilityStylePresets.emphasized;
      case UnavailabilityType.maintenance:
        return UnavailabilityStylePresets.crossHatch;
      case UnavailabilityType.custom:
        return UnavailabilityStylePresets.standard;
    }
  }

  /// Check if a time slot is available (no unavailability)
  static bool isTimeSlotAvailable({
    required BusinessHours? businessHours,
    required DateTime startTime,
    required DateTime endTime,
  }) {
    if (businessHours == null) return true;

    // Check if within working hours
    final workingPeriods = businessHours.getWorkingPeriodsForDay(
      startTime.weekday,
    );

    if (workingPeriods.isEmpty) return false;

    final startHour = startTime.hour + (startTime.minute / 60.0);
    final endHour = endTime.hour + (endTime.minute / 60.0);

    // Check if time range falls within any working period
    bool withinWorkingHours = false;
    for (final period in workingPeriods) {
      if (startHour >= period.startTime && endHour <= period.endTime) {
        withinWorkingHours = true;
        break;
      }
    }

    if (!withinWorkingHours) return false;

    // Check unavailabilities
    final unavailabilities = businessHours.getUnavailabilitiesForDate(
      startTime,
    );

    for (final unavailability in unavailabilities) {
      final timeRange = unavailability.getTimeRangeForDate(startTime);
      if (timeRange != null) {
        // Check if there's any overlap
        if (startHour < timeRange.endTime && endHour > timeRange.startTime) {
          return false;
        }
      }
    }

    return true;
  }

  /// Snap appointment time to available slots
  static DateTime snapToAvailableSlot({
    required BusinessHours? businessHours,
    required DateTime proposedTime,
    required Duration duration,
    required int snapToMinutes,
  }) {
    if (businessHours == null) return proposedTime;

    final workingPeriods = businessHours.getWorkingPeriodsForDay(
      proposedTime.weekday,
    );

    if (workingPeriods.isEmpty) {
      // No working hours, return as-is
      return proposedTime;
    }

    final proposedHour = proposedTime.hour + (proposedTime.minute / 60.0);
    final durationHours = duration.inMinutes / 60.0;
    final endHour = proposedHour + durationHours;

    // Find suitable working period
    for (final period in workingPeriods) {
      if (proposedHour >= period.startTime &&
          endHour <= period.endTime &&
          isTimeSlotAvailable(
            businessHours: businessHours,
            startTime: proposedTime,
            endTime: proposedTime.add(duration),
          )) {
        return proposedTime;
      }

      // If proposed time is before working hours, snap to start
      if (proposedHour < period.startTime &&
          period.startTime + durationHours <= period.endTime) {
        final snappedHour = period.startTime;
        return DateTime(
          proposedTime.year,
          proposedTime.month,
          proposedTime.day,
          snappedHour.floor(),
          ((snappedHour % 1) * 60).round(),
        );
      }
    }

    // Couldn't find suitable slot
    return proposedTime;
  }

  /// Get next available time slot
  static DateTime? getNextAvailableSlot({
    required BusinessHours? businessHours,
    required DateTime startSearchTime,
    required Duration duration,
    int maxDaysToSearch = 30,
  }) {
    if (businessHours == null) return startSearchTime;

    DateTime currentDate = DateTime(
      startSearchTime.year,
      startSearchTime.month,
      startSearchTime.day,
    );

    for (int day = 0; day < maxDaysToSearch; day++) {
      final checkDate = currentDate.add(Duration(days: day));
      final workingPeriods = businessHours.getWorkingPeriodsForDay(
        checkDate.weekday,
      );

      for (final period in workingPeriods) {
        final durationHours = duration.inMinutes / 60.0;

        // Check if duration fits in this period
        if (period.duration >= durationHours) {
          final slotStart = DateTime(
            checkDate.year,
            checkDate.month,
            checkDate.day,
            period.startTime.floor(),
            ((period.startTime % 1) * 60).round(),
          );

          final slotEnd = slotStart.add(duration);

          if (isTimeSlotAvailable(
            businessHours: businessHours,
            startTime: slotStart,
            endTime: slotEnd,
          )) {
            return slotStart;
          }
        }
      }
    }

    return null;
  }
}
