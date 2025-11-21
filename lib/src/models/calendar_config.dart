// lib/src/models/calendar_config.dart (Fixed)

import 'agenda_view_config.dart';
import 'calendar_view_type.dart';
import 'week_view_layout.dart';

/// Configuration for the calendar view
class CalendarConfig {
  const CalendarConfig({
    this.startDate,
    this.viewType = CalendarViewType.week,
    this.weekViewLayout = WeekViewLayout.resourcesFirst,
    this.numberOfDays,
    this.dayStartHour = 0,
    this.dayEndHour = 24,
    this.hourHeight = 100.0,
    this.minColumnWidth = 120.0,
    this.maxColumnWidth = 300.0,
    this.preferredColumnWidth = 180.0,
    this.timeColumnWidth = 70.0,
    this.resourceHeaderHeight = 100.0,
    this.dateHeaderHeight = 60.0,
    this.allDayEventHeight = 60.0,
    this.timeSlotDuration = const Duration(minutes: 30),
    this.showWeekends = true,
    this.showAllDaySection = false,
    this.enableSnapping = true,
    this.snapToMinutes = 15,
    this.enableDragAndDrop = true,
    this.enableResize = true,
    this.allowOverlapping = true,
    this.maxOverlaps = 4,
    this.dateSelectionMode = DateSelectionMode.none,
    this.firstDayOfWeek = DateTime.monday,
    this.agendaConfig,
  });

  /// Starting date for the view
  final DateTime? startDate;

  /// Type of view (day, week, month, agenda)
  final CalendarViewType viewType;

  /// Layout mode for week view (resources-first or days-first)
  final WeekViewLayout weekViewLayout;

  /// Number of days to display (overrides viewType default if provided)
  final int? numberOfDays;

  /// Hour to start the day at (0-23)
  final int dayStartHour;

  /// Hour to end the day at (1-24)
  final int dayEndHour;

  /// Height of each hour in pixels
  final double hourHeight;

  /// Minimum width for columns (day view: resources, week view: days)
  final double minColumnWidth;

  /// Maximum width for columns
  final double maxColumnWidth;

  /// Preferred width for columns
  final double preferredColumnWidth;

  /// Width of the time column on the left
  final double timeColumnWidth;

  /// Height of the resource header (day view)
  final double resourceHeaderHeight;

  /// Height of the date header (week view)
  final double dateHeaderHeight;

  /// Height of all-day event section
  final double allDayEventHeight;

  /// Duration of each time slot for snapping
  final Duration timeSlotDuration;

  /// Whether to show weekends
  final bool showWeekends;

  /// Whether to show all-day events section
  final bool showAllDaySection;

  /// Enable snapping to time slots when dragging
  final bool enableSnapping;

  /// Snap to nearest X minutes
  final int snapToMinutes;

  /// Enable drag and drop for appointments
  final bool enableDragAndDrop;

  /// Enable resizing appointments
  final bool enableResize;

  /// Allow appointments to overlap
  final bool allowOverlapping;

  /// Maximum number of overlapping appointments
  final int maxOverlaps;

  /// Date selection mode for month view
  final DateSelectionMode dateSelectionMode;

  /// First day of the week (1 = Monday, 7 = Sunday)
  /// Follows Dart's DateTime.weekday convention
  final int firstDayOfWeek;

  /// Configuration for agenda view (when viewType is agenda)
  final AgendaViewConfig? agendaConfig;

  /// Total height of the grid
  double get totalGridHeight {
    final hours = dayEndHour - dayStartHour;
    return hours * hourHeight;
  }

  /// Calculate column width for the given viewport and resources
  ColumnDimensions calculateColumnDimensions({
    required double viewportWidth,
    required int numberOfResources,
    required int effectiveNumberOfDays,
  }) {
    if (numberOfResources == 0) {
      return ColumnDimensions(
        columnWidth: preferredColumnWidth,
        requiresHorizontalScroll: false,
        totalContentWidth: timeColumnWidth + preferredColumnWidth,
      );
    }

    // Calculate total columns based on view type
    int totalColumns;
    switch (viewType) {
      case CalendarViewType.day:
        // Day view: one column per resource
        totalColumns = numberOfResources;
        break;
      case CalendarViewType.week:
        // Week view: resources × days
        totalColumns = numberOfResources * effectiveNumberOfDays;
        break;
      case CalendarViewType.month:
        // Month view: different layout (grid)
        totalColumns = 7; // Days of week
        break;
      case CalendarViewType.agenda:
        // Agenda view: list layout, no column calculation needed
        // Return default dimensions as agenda view doesn't use columns
        return ColumnDimensions(
          columnWidth: viewportWidth,
          requiresHorizontalScroll: false,
          totalContentWidth: viewportWidth,
        );
    }

    final availableWidth = viewportWidth - timeColumnWidth - 16;
    final calculatedWidth = availableWidth / totalColumns;

    double finalWidth;
    bool needsScroll;

    if (calculatedWidth >= preferredColumnWidth) {
      finalWidth = calculatedWidth.clamp(minColumnWidth, maxColumnWidth);
      needsScroll = false;
    } else if (calculatedWidth >= minColumnWidth) {
      finalWidth = calculatedWidth;
      needsScroll = false;
    } else {
      finalWidth = minColumnWidth;
      needsScroll = true;
    }

    final totalWidth = (finalWidth * totalColumns) + timeColumnWidth;

    return ColumnDimensions(
      columnWidth: finalWidth,
      requiresHorizontalScroll: needsScroll,
      totalContentWidth: totalWidth,
    );
  }

  CalendarConfig copyWith({
    DateTime? startDate,
    CalendarViewType? viewType,
    WeekViewLayout? weekViewLayout,
    int? numberOfDays,
    int? dayStartHour,
    int? dayEndHour,
    double? hourHeight,
    double? minColumnWidth,
    double? maxColumnWidth,
    double? preferredColumnWidth,
    double? timeColumnWidth,
    double? resourceHeaderHeight,
    double? dateHeaderHeight,
    double? allDayEventHeight,
    Duration? timeSlotDuration,
    bool? showWeekends,
    bool? showAllDaySection,
    bool? enableSnapping,
    int? snapToMinutes,
    bool? enableDragAndDrop,
    bool? enableResize,
    bool? allowOverlapping,
    int? maxOverlaps,
    DateSelectionMode? dateSelectionMode,
    int? firstDayOfWeek,
    AgendaViewConfig? agendaConfig,
  }) {
    return CalendarConfig(
      startDate: startDate ?? this.startDate,
      viewType: viewType ?? this.viewType,
      weekViewLayout: weekViewLayout ?? this.weekViewLayout,
      numberOfDays: numberOfDays ?? this.numberOfDays,
      dayStartHour: dayStartHour ?? this.dayStartHour,
      dayEndHour: dayEndHour ?? this.dayEndHour,
      hourHeight: hourHeight ?? this.hourHeight,
      minColumnWidth: minColumnWidth ?? this.minColumnWidth,
      maxColumnWidth: maxColumnWidth ?? this.maxColumnWidth,
      preferredColumnWidth: preferredColumnWidth ?? this.preferredColumnWidth,
      timeColumnWidth: timeColumnWidth ?? this.timeColumnWidth,
      resourceHeaderHeight: resourceHeaderHeight ?? this.resourceHeaderHeight,
      dateHeaderHeight: dateHeaderHeight ?? this.dateHeaderHeight,
      allDayEventHeight: allDayEventHeight ?? this.allDayEventHeight,
      timeSlotDuration: timeSlotDuration ?? this.timeSlotDuration,
      showWeekends: showWeekends ?? this.showWeekends,
      showAllDaySection: showAllDaySection ?? this.showAllDaySection,
      enableSnapping: enableSnapping ?? this.enableSnapping,
      snapToMinutes: snapToMinutes ?? this.snapToMinutes,
      enableDragAndDrop: enableDragAndDrop ?? this.enableDragAndDrop,
      enableResize: enableResize ?? this.enableResize,
      allowOverlapping: allowOverlapping ?? this.allowOverlapping,
      maxOverlaps: maxOverlaps ?? this.maxOverlaps,
      dateSelectionMode: dateSelectionMode ?? this.dateSelectionMode,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
      agendaConfig: agendaConfig ?? this.agendaConfig,
    );
  }
}

/// Column dimensions calculation result
class ColumnDimensions {
  const ColumnDimensions({
    required this.columnWidth,
    required this.requiresHorizontalScroll,
    required this.totalContentWidth,
  });

  final double columnWidth;
  final bool requiresHorizontalScroll;
  final double totalContentWidth;
}
