// lib/src/models/business_hours.dart

import 'package:flutter/material.dart';

/// Represents a time period within a day
class TimePeriod {
  const TimePeriod({required this.startTime, required this.endTime})
    : assert(startTime < endTime, 'Start time must be before end time');

  /// Start time in hours (e.g., 9.0 for 9:00 AM, 13.5 for 1:30 PM)
  final double startTime;

  /// End time in hours
  final double endTime;

  /// Duration in hours
  double get duration => endTime - startTime;

  /// Check if a time falls within this period
  bool contains(double time) {
    return time >= startTime && time < endTime;
  }

  /// Check if this period overlaps with another
  bool overlaps(TimePeriod other) {
    return startTime < other.endTime && other.startTime < endTime;
  }

  TimePeriod copyWith({double? startTime, double? endTime}) {
    return TimePeriod(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  @override
  String toString() {
    return 'TimePeriod(startTime: $startTime, endTime: $endTime)';
  }
}

/// Type of unavailability
enum UnavailabilityType {
  /// Non-working hours (before/after business hours)
  nonWorkingHours,

  /// Break time (lunch, coffee break)
  break_,

  /// Holiday or day off
  holiday,

  /// Planned leave or vacation
  leave,

  /// Resource is blocked/busy
  blocked,

  /// Maintenance or other reason
  maintenance,

  /// Custom type
  custom,
}

/// Visual style for rendering unavailability
enum UnavailabilityPattern {
  /// Solid color fill
  solid,

  /// Diagonal lines (top-left to bottom-right)
  diagonalLines,

  /// Diagonal lines (top-right to bottom-left)
  diagonalLinesReverse,

  /// Cross-hatch pattern
  crossHatch,

  /// Horizontal lines
  horizontalLines,

  /// Vertical lines
  verticalLines,

  /// Dots pattern
  dots,

  /// Grid pattern
  grid,

  /// Custom pattern (use builder)
  custom,
}

/// Configuration for unavailability visual style
class UnavailabilityStyle {
  const UnavailabilityStyle({
    this.pattern = UnavailabilityPattern.diagonalLines,
    this.backgroundColor = const Color(0xFFF5F5F5),
    this.patternColor = const Color(0xFFE0E0E0),
    this.lineWidth = 1.0,
    this.lineSpacing = 8.0,
    this.opacity = 0.7,
    this.showBorder = true,
    this.borderColor = const Color(0xFFBDBDBD),
    this.borderWidth = 0.5,
    this.showDebugLabel = false,
    this.debugLabel,
  });

  final UnavailabilityPattern pattern;
  final Color backgroundColor;
  final Color patternColor;
  final double lineWidth;
  final double lineSpacing;
  final double opacity;
  final bool showBorder;
  final Color borderColor;
  final double borderWidth;
  final bool? showDebugLabel;
  final String? debugLabel;

  UnavailabilityStyle copyWith({
    UnavailabilityPattern? pattern,
    Color? backgroundColor,
    Color? patternColor,
    double? lineWidth,
    double? lineSpacing,
    double? opacity,
    bool? showBorder,
    Color? borderColor,
    double? borderWidth,
    bool? showDebugLabel,
    String? debugLabel,
  }) {
    return UnavailabilityStyle(
      pattern: pattern ?? this.pattern,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      patternColor: patternColor ?? this.patternColor,
      lineWidth: lineWidth ?? this.lineWidth,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      opacity: opacity ?? this.opacity,
      showBorder: showBorder ?? this.showBorder,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      showDebugLabel: showDebugLabel ?? this.showDebugLabel,
      debugLabel: debugLabel ?? this.debugLabel,
    );
  }
}

/// Represents a period of unavailability for a resource
class UnavailabilityPeriod {
  const UnavailabilityPeriod({
    required this.startTime,
    required this.endTime,
    this.type = UnavailabilityType.nonWorkingHours,
    this.label,
    this.style,
    this.isRecurring = false,
    this.recurringDays,
  });

  /// Start time (can be date-time or time-of-day)
  final DateTime startTime;

  /// End time
  final DateTime endTime;

  /// Type of unavailability
  final UnavailabilityType type;

  /// Optional label to display
  final String? label;

  /// Visual style (null = use default for type)
  final UnavailabilityStyle? style;

  /// Whether this recurs (e.g., every Monday)
  final bool isRecurring;

  /// Days of week when this recurs (1=Mon, 7=Sun)
  final List<int>? recurringDays;

  /// Check if this unavailability applies to a given date
  bool appliesTo(DateTime date) {
    if (isRecurring && recurringDays != null) {
      return recurringDays!.contains(date.weekday);
    }

    // Check if date falls within the period
    final dateOnly = DateTime(date.year, date.month, date.day);
    final startOnly = DateTime(startTime.year, startTime.month, startTime.day);
    final endOnly = DateTime(endTime.year, endTime.month, endTime.day);

    return (dateOnly.isAtSameMomentAs(startOnly) ||
            dateOnly.isAfter(startOnly)) &&
        (dateOnly.isAtSameMomentAs(endOnly) || dateOnly.isBefore(endOnly));
  }

  /// Get the time range for a specific date
  TimePeriod? getTimeRangeForDate(DateTime date) {
    if (!appliesTo(date)) return null;

    // Convert DateTime to decimal hours
    final startHour = startTime.hour + (startTime.minute / 60.0);
    final endHour = endTime.hour + (endTime.minute / 60.0);

    return TimePeriod(startTime: startHour, endTime: endHour);
  }
}

/// Business hours configuration for a resource
class BusinessHours {
  const BusinessHours({
    this.workingHours = const {
      DateTime.monday: [TimePeriod(startTime: 9.0, endTime: 17.0)],
      DateTime.tuesday: [TimePeriod(startTime: 9.0, endTime: 17.0)],
      DateTime.wednesday: [TimePeriod(startTime: 9.0, endTime: 17.0)],
      DateTime.thursday: [TimePeriod(startTime: 9.0, endTime: 17.0)],
      DateTime.friday: [TimePeriod(startTime: 9.0, endTime: 17.0)],
    },
    this.breaks = const [],
    this.unavailabilities = const [],
    this.showNonWorkingHours = true,
    this.showBreaks = true,
  });

  /// Working hours per day of week (1=Mon, 7=Sun)
  final Map<int, List<TimePeriod>> workingHours;

  /// Regular breaks (e.g., lunch break)
  final List<UnavailabilityPeriod> breaks;

  /// Additional unavailability periods (holidays, leave, etc.)
  final List<UnavailabilityPeriod> unavailabilities;

  /// Whether to show non-working hours as unavailable
  final bool showNonWorkingHours;

  /// Whether to show break times
  final bool showBreaks;

  /// Get working periods for a specific day
  List<TimePeriod> getWorkingPeriodsForDay(int weekday) {
    return workingHours[weekday] ?? [];
  }

  /// Get all unavailability periods for a specific date
  List<UnavailabilityPeriod> getUnavailabilitiesForDate(DateTime date) {
    final result = <UnavailabilityPeriod>[];

    // Add breaks if enabled
    if (showBreaks) {
      result.addAll(breaks.where((b) => b.appliesTo(date)));
    }

    // Add other unavailabilities
    result.addAll(unavailabilities.where((u) => u.appliesTo(date)));

    return result;
  }

  /// Get non-working periods for a specific date
  List<TimePeriod> getNonWorkingPeriodsForDate(
    DateTime date,
    double dayStart,
    double dayEnd,
  ) {
    if (!showNonWorkingHours) return [];

    final workingPeriods = getWorkingPeriodsForDay(date.weekday);
    if (workingPeriods.isEmpty) {
      // Entire day is non-working
      return [TimePeriod(startTime: dayStart, endTime: dayEnd)];
    }

    final nonWorking = <TimePeriod>[];

    // Sort working periods
    final sorted = List<TimePeriod>.from(workingPeriods)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    // Before first working period
    if (sorted.first.startTime > dayStart) {
      nonWorking.add(
        TimePeriod(startTime: dayStart, endTime: sorted.first.startTime),
      );
    }

    // Between working periods
    for (int i = 0; i < sorted.length - 1; i++) {
      nonWorking.add(
        TimePeriod(
          startTime: sorted[i].endTime,
          endTime: sorted[i + 1].startTime,
        ),
      );
    }

    // After last working period
    if (sorted.last.endTime < dayEnd) {
      nonWorking.add(
        TimePeriod(startTime: sorted.last.endTime, endTime: dayEnd),
      );
    }

    return nonWorking;
  }

  BusinessHours copyWith({
    Map<int, List<TimePeriod>>? workingHours,
    List<UnavailabilityPeriod>? breaks,
    List<UnavailabilityPeriod>? unavailabilities,
    bool? showNonWorkingHours,
    bool? showBreaks,
  }) {
    return BusinessHours(
      workingHours: workingHours ?? this.workingHours,
      breaks: breaks ?? this.breaks,
      unavailabilities: unavailabilities ?? this.unavailabilities,
      showNonWorkingHours: showNonWorkingHours ?? this.showNonWorkingHours,
      showBreaks: showBreaks ?? this.showBreaks,
    );
  }
}

/// Preset business hours configurations
class BusinessHoursPresets {
  /// Standard 9-5 Monday to Friday
  static BusinessHours standard = BusinessHours(
    workingHours: {
      DateTime.monday: [TimePeriod(startTime: 9.0, endTime: 17.0)],
      DateTime.tuesday: [TimePeriod(startTime: 9.0, endTime: 17.0)],
      DateTime.wednesday: [TimePeriod(startTime: 9.0, endTime: 17.0)],
      DateTime.thursday: [TimePeriod(startTime: 9.0, endTime: 17.0)],
      DateTime.friday: [TimePeriod(startTime: 9.0, endTime: 17.0)],
    },
    breaks: [
      UnavailabilityPeriod(
        startTime: DateTime(2023, 1, 1, 12, 0),
        endTime: DateTime(2023, 1, 1, 13, 0),
        type: UnavailabilityType.break_,
        label: 'Lunch Break',
        isRecurring: true,
        recurringDays: [
          DateTime.monday,
          DateTime.tuesday,
          DateTime.wednesday,
          DateTime.thursday,
          DateTime.friday,
        ],
      ),
    ],
  );

  /// Extended hours 8-6
  static const extended = BusinessHours(
    workingHours: {
      DateTime.monday: [TimePeriod(startTime: 8.0, endTime: 18.0)],
      DateTime.tuesday: [TimePeriod(startTime: 8.0, endTime: 18.0)],
      DateTime.wednesday: [TimePeriod(startTime: 8.0, endTime: 18.0)],
      DateTime.thursday: [TimePeriod(startTime: 8.0, endTime: 18.0)],
      DateTime.friday: [TimePeriod(startTime: 8.0, endTime: 18.0)],
    },
  );

  /// 24/7 availability
  static const alwaysAvailable = BusinessHours(
    workingHours: {
      DateTime.monday: [TimePeriod(startTime: 0.0, endTime: 24.0)],
      DateTime.tuesday: [TimePeriod(startTime: 0.0, endTime: 24.0)],
      DateTime.wednesday: [TimePeriod(startTime: 0.0, endTime: 24.0)],
      DateTime.thursday: [TimePeriod(startTime: 0.0, endTime: 24.0)],
      DateTime.friday: [TimePeriod(startTime: 0.0, endTime: 24.0)],
      DateTime.saturday: [TimePeriod(startTime: 0.0, endTime: 24.0)],
      DateTime.sunday: [TimePeriod(startTime: 0.0, endTime: 24.0)],
    },
    showNonWorkingHours: false,
  );

  /// Weekend availability only
  static const weekendOnly = BusinessHours(
    workingHours: {
      DateTime.saturday: [TimePeriod(startTime: 9.0, endTime: 17.0)],
      DateTime.sunday: [TimePeriod(startTime: 9.0, endTime: 17.0)],
    },
  );
}

/// Preset unavailability styles
class UnavailabilityStylePresets {
  /// Light gray diagonal lines (default)
  static const standard = UnavailabilityStyle(
    pattern: UnavailabilityPattern.diagonalLines,
    backgroundColor: Color(0xFFFAFAFA),
    patternColor: Color(0xFFE0E0E0),
    lineWidth: 1.0,
    lineSpacing: 8.0,
  );

  /// Darker diagonal lines for emphasis
  static const emphasized = UnavailabilityStyle(
    pattern: UnavailabilityPattern.diagonalLines,
    backgroundColor: Color(0xFFF5F5F5),
    patternColor: Color(0xFFBDBDBD),
    lineWidth: 1.5,
    lineSpacing: 6.0,
  );

  /// Cross-hatch pattern
  static const crossHatch = UnavailabilityStyle(
    pattern: UnavailabilityPattern.crossHatch,
    backgroundColor: Color(0xFFFAFAFA),
    patternColor: Color(0xFFCCCCCC),
    lineWidth: 1.0,
    lineSpacing: 10.0,
  );

  /// Solid light gray
  static const solid = UnavailabilityStyle(
    pattern: UnavailabilityPattern.solid,
    backgroundColor: Color(0xFFF0F0F0),
  );

  /// Red-tinted for holidays
  static const holiday = UnavailabilityStyle(
    pattern: UnavailabilityPattern.diagonalLines,
    backgroundColor: Color(0xFFFFEBEE),
    patternColor: Color(0xFFFFCDD2),
    lineWidth: 1.5,
    lineSpacing: 8.0,
  );

  /// Blue-tinted for breaks
  static const break_ = UnavailabilityStyle(
    pattern: UnavailabilityPattern.horizontalLines,
    backgroundColor: Color(0xFFE3F2FD),
    patternColor: Color(0xFFBBDEFB),
    lineWidth: 1.0,
    lineSpacing: 6.0,
  );

  /// Dots pattern for subtle indication
  static const subtle = UnavailabilityStyle(
    pattern: UnavailabilityPattern.dots,
    backgroundColor: Color(0xFFFAFAFA),
    patternColor: Color(0xFFE0E0E0),
    lineSpacing: 8.0,
    opacity: 0.5,
  );
}
