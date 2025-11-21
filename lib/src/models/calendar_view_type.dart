// lib/src/models/calendar_view_type.dart

/// Type of calendar view
enum CalendarViewType {
  /// Shows a single day with all resources
  day,

  /// Shows a week (7 days) with resources
  week,

  /// Shows a month overview
  month,

  /// Shows chronological list of appointments (agenda/schedule view)
  agenda,
}

/// Date selection mode for month view
enum DateSelectionMode {
  /// No date selection
  none,

  /// Select a single date at a time
  single,

  /// Select multiple dates
  multiple,

  /// Select a range of dates (start and end)
  range,
}

/// Configuration specific to each view type
class ViewTypeConfig {
  const ViewTypeConfig({
    required this.viewType,
    this.numberOfDays,
    this.showAllDaySection = true,
    this.compactMode = false,
  });

  final CalendarViewType viewType;
  final int? numberOfDays; // null = auto based on view type
  final bool showAllDaySection;
  final bool compactMode;

  /// Get effective number of days based on view type
  int getEffectiveDays() {
    if (numberOfDays != null) return numberOfDays!;

    switch (viewType) {
      case CalendarViewType.day:
        return 1;
      case CalendarViewType.week:
        return 7;
      case CalendarViewType.month:
        return 30; // Will be calculated dynamically for actual implementation
      case CalendarViewType.agenda:
        return 7; // Default to 7 days for agenda view
    }
  }

  ViewTypeConfig copyWith({
    CalendarViewType? viewType,
    int? numberOfDays,
    bool? showAllDaySection,
    bool? compactMode,
  }) {
    return ViewTypeConfig(
      viewType: viewType ?? this.viewType,
      numberOfDays: numberOfDays ?? this.numberOfDays,
      showAllDaySection: showAllDaySection ?? this.showAllDaySection,
      compactMode: compactMode ?? this.compactMode,
    );
  }
}
