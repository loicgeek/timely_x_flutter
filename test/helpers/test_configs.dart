import 'dart:ui';

import 'package:timely_x/timely_x.dart';
import 'package:flutter/material.dart';

/// Helper class for creating test calendar configurations
class TestConfigs {
  /// Basic day view config
  static CalendarConfig dayView({
    int dayStartHour = 8,
    int dayEndHour = 18,
    double hourHeight = 60.0,
  }) {
    return CalendarConfig(
      viewType: CalendarViewType.day,
      dayStartHour: dayStartHour,
      dayEndHour: dayEndHour,
      hourHeight: hourHeight,
    );
  }

  /// Basic week view config
  static CalendarConfig weekView({
    WeekViewLayout layout = WeekViewLayout.resourcesFirst,
    int dayStartHour = 8,
    int dayEndHour = 18,
    bool showWeekends = true,
  }) {
    return CalendarConfig(
      viewType: CalendarViewType.week,
      weekViewLayout: layout,
      dayStartHour: dayStartHour,
      dayEndHour: dayEndHour,
      showWeekends: showWeekends,
    );
  }

  /// Basic month view config
  static CalendarConfig monthView({
    bool showWeekends = true,
    DateSelectionMode selectionMode = DateSelectionMode.none,
  }) {
    return CalendarConfig(
      viewType: CalendarViewType.month,
      showWeekends: showWeekends,
      dateSelectionMode: selectionMode,
    );
  }

  /// Basic agenda view config
  static CalendarConfig agendaView({
    AgendaGroupingMode groupBy = AgendaGroupingMode.byDate,
    bool showEmptyDates = false,
  }) {
    return CalendarConfig(
      viewType: CalendarViewType.agenda,
      agendaConfig: AgendaViewConfig(
        groupingMode: groupBy,
        showEmptyDays: showEmptyDates,
      ),
    );
  }

  /// 24-hour view config
  static CalendarConfig fullDayView() {
    return CalendarConfig(
      viewType: CalendarViewType.day,
      dayStartHour: 0,
      dayEndHour: 24,
      hourHeight: 60.0,
    );
  }

  /// Business hours config (9-5)
  static CalendarConfig businessHours() {
    return CalendarConfig(
      viewType: CalendarViewType.day,
      dayStartHour: 9,
      dayEndHour: 17,
      hourHeight: 80.0,
      timeSlotDuration: Duration(minutes: 30),
    );
  }

  /// Config with drag and drop enabled
  static CalendarConfig withDragDrop({
    bool enableSnapping = true,
    int snapToMinutes = 15,
  }) {
    return CalendarConfig(
      viewType: CalendarViewType.day,
      enableDragAndDrop: true,
      enableResize: true,
      enableSnapping: enableSnapping,
      snapToMinutes: snapToMinutes,
    );
  }

  /// Config with custom time slots
  static CalendarConfig withTimeSlots({
    required Duration slotDuration,
    int dayStartHour = 8,
    int dayEndHour = 18,
  }) {
    return CalendarConfig(
      viewType: CalendarViewType.day,
      timeSlotDuration: slotDuration,
      dayStartHour: dayStartHour,
      dayEndHour: dayEndHour,
      hourHeight: 60.0,
    );
  }

  /// Config that allows overlapping appointments
  static CalendarConfig allowOverlaps({int maxOverlaps = 4}) {
    return CalendarConfig(
      viewType: CalendarViewType.day,
      allowOverlapping: true,
      maxOverlaps: maxOverlaps,
    );
  }

  /// Config that prevents overlapping
  static CalendarConfig preventOverlaps() {
    return CalendarConfig(
      viewType: CalendarViewType.day,
      allowOverlapping: false,
    );
  }

  /// Config with custom column dimensions
  static CalendarConfig customDimensions({
    double minColumnWidth = 100.0,
    double maxColumnWidth = 300.0,
    double preferredColumnWidth = 150.0,
    double hourHeight = 60.0,
  }) {
    return CalendarConfig(
      viewType: CalendarViewType.day,
      minColumnWidth: minColumnWidth,
      maxColumnWidth: maxColumnWidth,
      preferredColumnWidth: preferredColumnWidth,
      hourHeight: hourHeight,
    );
  }

  /// Week view with days first layout
  static CalendarConfig weekDaysFirst({bool showWeekends = true}) {
    return CalendarConfig(
      viewType: CalendarViewType.week,
      weekViewLayout: WeekViewLayout.daysFirst,
      showWeekends: showWeekends,
    );
  }

  /// Week view with resources first layout
  static CalendarConfig weekResourcesFirst({bool showWeekends = true}) {
    return CalendarConfig(
      viewType: CalendarViewType.week,
      weekViewLayout: WeekViewLayout.resourcesFirst,
      showWeekends: showWeekends,
    );
  }

  /// Week view without weekends
  static CalendarConfig businessWeek() {
    return CalendarConfig(
      viewType: CalendarViewType.week,
      showWeekends: false,
      dayStartHour: 9,
      dayEndHour: 17,
    );
  }

  /// Config with multiple date selection
  static CalendarConfig multiDateSelection() {
    return CalendarConfig(
      viewType: CalendarViewType.month,
      dateSelectionMode: DateSelectionMode.multiple,
    );
  }

  /// Config with range selection
  static CalendarConfig rangeSelection() {
    return CalendarConfig(
      viewType: CalendarViewType.month,
      dateSelectionMode: DateSelectionMode.range,
    );
  }

  /// Config with single date selection
  static CalendarConfig singleDateSelection() {
    return CalendarConfig(
      viewType: CalendarViewType.month,
      dateSelectionMode: DateSelectionMode.single,
    );
  }

  /// Config with business hours
  static CalendarConfig withBusinessHours({
    required List<BusinessHours> businessHours,
  }) {
    return CalendarConfig(viewType: CalendarViewType.day);
  }

  /// Config with available slots
  static CalendarConfig withAvailableSlots({
    required List<AvailableSlot> availableSlots,
  }) {
    return CalendarConfig(viewType: CalendarViewType.day);
  }

  /// Config optimized for mobile
  static CalendarConfig mobileOptimized() {
    return CalendarConfig(
      viewType: CalendarViewType.day,
      minColumnWidth: 80.0,
      maxColumnWidth: 200.0,
      preferredColumnWidth: 120.0,
      hourHeight: 50.0,
      resourceHeaderHeight: 60.0,
      dateHeaderHeight: 50.0,
      timeColumnWidth: 50.0,
    );
  }

  /// Config optimized for desktop
  static CalendarConfig desktopOptimized() {
    return CalendarConfig(
      viewType: CalendarViewType.week,
      minColumnWidth: 150.0,
      maxColumnWidth: 400.0,
      preferredColumnWidth: 200.0,
      hourHeight: 60.0,
      resourceHeaderHeight: 80.0,
      dateHeaderHeight: 60.0,
      timeColumnWidth: 70.0,
    );
  }

  /// Config for performance testing
  static CalendarConfig performance() {
    return CalendarConfig(
      viewType: CalendarViewType.week,
      minColumnWidth: 100.0,
      maxColumnWidth: 150.0,
      hourHeight: 40.0, // Reduced for faster rendering
      enableDragAndDrop: false, // Disable for performance
      enableResize: false,
    );
  }

  /// Config with all features enabled
  static CalendarConfig fullFeatures() {
    return CalendarConfig(
      viewType: CalendarViewType.day,
      enableDragAndDrop: true,
      enableResize: true,
      enableSnapping: true,
      snapToMinutes: 15,
      allowOverlapping: true,
      maxOverlaps: 5,
      showWeekends: true,
      dayStartHour: 0,
      dayEndHour: 24,
      timeSlotDuration: Duration(minutes: 30),
    );
  }

  /// Minimal config for testing basics
  static CalendarConfig minimal() {
    return CalendarConfig(viewType: CalendarViewType.day);
  }
}

/// Helper for creating test themes
class TestThemes {
  /// Default theme
  static CalendarTheme get defaultTheme => CalendarTheme();

  /// Dark theme
  static CalendarTheme get dark => CalendarTheme(
    gridBackgroundColor: Color(0xFF121212),
    gridLineColor: Color(0xFF424242),
  );

  /// High contrast theme
  static CalendarTheme get highContrast => CalendarTheme(
    gridBackgroundColor: Colors.white,
    gridLineColor: Colors.black,
  );

  /// Colorful theme
  static CalendarTheme get colorful =>
      CalendarTheme(todayHighlightColor: Colors.amber);
}
