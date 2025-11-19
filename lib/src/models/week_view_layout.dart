// lib/src/models/week_view_layout.dart

/// Layout mode for week view
enum WeekViewLayout {
  /// Resources first, then days for each resource (default)
  /// Layout: Resource1[Day1, Day2...], Resource2[Day1, Day2...]
  resourcesFirst,

  /// Days first, then resources for each day
  /// Layout: Day1[Resource1, Resource2...], Day2[Resource1, Resource2...]
  daysFirst,
}
