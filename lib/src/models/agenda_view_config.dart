// lib/src/models/agenda_view_config.dart

/// Grouping mode for agenda view
enum AgendaGroupingMode {
  /// Flat chronological list - all appointments sorted by time
  chronological,

  /// Group by date - appointments organized under date headers
  byDate,

  /// Group by resource - appointments organized under resource headers
  byResource,

  /// Group by date, then resource - nested grouping (date > resource)
  byDateThenResource,

  /// Group by resource, then date - nested grouping (resource > date)
  byResourceThenDate,
}

/// Configuration specific to agenda view
class AgendaViewConfig {
  const AgendaViewConfig({
    this.groupingMode = AgendaGroupingMode.byDate,
    this.daysToShow = 7,
    this.showEmptyDays = false,
    this.showEmptyResources = false,
    this.compactMode = false,
    this.showResourceAvatar = true,
    this.showAppointmentTime = true,
    this.showAppointmentDuration = false,
    this.showResourceName = true,
    this.allowResourceFilter = true,
    this.allowDateRangeSelection = true,
    this.enableAppointmentTap = true,
    this.enableAppointmentLongPress = true,
    this.showPastAppointments = true,
    this.sortOrder = AgendaSortOrder.ascending,
    this.dateRangeMode = AgendaDateRangeMode.relative,
  });

  /// How to group appointments in the list
  final AgendaGroupingMode groupingMode;

  /// Number of days to display (only applies when dateRangeMode is relative)
  final int daysToShow;

  /// Show days with no appointments
  final bool showEmptyDays;

  /// Show resources with no appointments (when grouping by resource)
  final bool showEmptyResources;

  /// Use compact layout with less spacing
  final bool compactMode;

  /// Show resource avatar in appointment items
  final bool showResourceAvatar;

  /// Show appointment time
  final bool showAppointmentTime;

  /// Show appointment duration (e.g., "1 hour 30 minutes")
  final bool showAppointmentDuration;

  /// Show resource name in appointment items (useful in chronological mode)
  final bool showResourceName;

  /// Allow filtering by resource
  final bool allowResourceFilter;

  /// Allow selecting custom date range
  final bool allowDateRangeSelection;

  /// Enable tapping on appointments
  final bool enableAppointmentTap;

  /// Enable long press on appointments
  final bool enableAppointmentLongPress;

  /// Show appointments that have already passed
  final bool showPastAppointments;

  /// Sort order for appointments
  final AgendaSortOrder sortOrder;

  /// Date range mode - relative (from today) or custom range
  final AgendaDateRangeMode dateRangeMode;

  AgendaViewConfig copyWith({
    AgendaGroupingMode? groupingMode,
    int? daysToShow,
    bool? showEmptyDays,
    bool? showEmptyResources,
    bool? compactMode,
    bool? showResourceAvatar,
    bool? showAppointmentTime,
    bool? showAppointmentDuration,
    bool? showResourceName,
    bool? allowResourceFilter,
    bool? allowDateRangeSelection,
    bool? enableAppointmentTap,
    bool? enableAppointmentLongPress,
    bool? showPastAppointments,
    AgendaSortOrder? sortOrder,
    AgendaDateRangeMode? dateRangeMode,
  }) {
    return AgendaViewConfig(
      groupingMode: groupingMode ?? this.groupingMode,
      daysToShow: daysToShow ?? this.daysToShow,
      showEmptyDays: showEmptyDays ?? this.showEmptyDays,
      showEmptyResources: showEmptyResources ?? this.showEmptyResources,
      compactMode: compactMode ?? this.compactMode,
      showResourceAvatar: showResourceAvatar ?? this.showResourceAvatar,
      showAppointmentTime: showAppointmentTime ?? this.showAppointmentTime,
      showAppointmentDuration:
          showAppointmentDuration ?? this.showAppointmentDuration,
      showResourceName: showResourceName ?? this.showResourceName,
      allowResourceFilter: allowResourceFilter ?? this.allowResourceFilter,
      allowDateRangeSelection:
          allowDateRangeSelection ?? this.allowDateRangeSelection,
      enableAppointmentTap: enableAppointmentTap ?? this.enableAppointmentTap,
      enableAppointmentLongPress:
          enableAppointmentLongPress ?? this.enableAppointmentLongPress,
      showPastAppointments: showPastAppointments ?? this.showPastAppointments,
      sortOrder: sortOrder ?? this.sortOrder,
      dateRangeMode: dateRangeMode ?? this.dateRangeMode,
    );
  }
}

/// Sort order for agenda items
enum AgendaSortOrder {
  /// Oldest to newest
  ascending,

  /// Newest to oldest
  descending,
}

/// Date range mode for agenda view
enum AgendaDateRangeMode {
  /// Show relative date range (e.g., next 7 days from current date)
  relative,

  /// Show custom date range (specified by controller)
  custom,
}
