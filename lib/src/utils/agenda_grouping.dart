// lib/src/utils/agenda_grouping.dart

import '../models/agenda_view_config.dart';
import '../models/calendar_appointment.dart';
import '../models/calendar_resource.dart';

import '../utils/date_time_utils.dart';

/// Represents a grouped section in the agenda view
class AgendaGroup {
  const AgendaGroup({
    required this.key,
    required this.header,
    required this.items,
    this.subGroups,
  });

  /// Unique key for the group (e.g., date string or resource ID)
  final String key;

  /// Header information for the group
  final AgendaGroupHeader header;

  /// Items in this group
  final List<AgendaItem> items;

  /// Sub-groups for nested grouping modes
  final List<AgendaGroup>? subGroups;

  /// Whether this group has any items (including in subgroups)
  bool get hasItems {
    if (items.isNotEmpty) return true;
    if (subGroups != null) {
      return subGroups!.any((group) => group.hasItems);
    }
    return false;
  }
}

/// Header information for an agenda group
class AgendaGroupHeader {
  const AgendaGroupHeader({
    required this.title,
    this.subtitle,
    this.date,
    this.resource,
    this.itemCount = 0,
  });

  /// Main title for the header
  final String title;

  /// Optional subtitle
  final String? subtitle;

  /// Associated date (for date groups)
  final DateTime? date;

  /// Associated resource (for resource groups)
  final CalendarResource? resource;

  /// Number of items in this group
  final int itemCount;
}

/// Represents a single appointment in the agenda list
class AgendaItem {
  const AgendaItem({
    required this.appointment,
    required this.resource,
    this.showResource = false,
    this.showDate = false,
  });

  /// The appointment
  final CalendarAppointment appointment;

  /// Associated resource
  final CalendarResource resource;

  /// Whether to show resource information in this item
  final bool showResource;

  /// Whether to show date information in this item
  final bool showDate;
}

/// Utility class for grouping appointments in agenda view
class AgendaGroupingUtils {
  /// Group appointments based on the specified mode
  static List<AgendaGroup> groupAppointments({
    required List<CalendarAppointment> appointments,
    required List<CalendarResource> resources,
    required AgendaGroupingMode mode,
    required bool showEmptyDays,
    required bool showEmptyResources,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    // Create resource lookup map
    final resourceMap = <String, CalendarResource>{};
    for (final resource in resources) {
      resourceMap[resource.id] = resource;
    }

    // Filter and sort appointments
    final filteredAppointments =
        appointments
            .where(
              (apt) =>
                  !apt.startTime.isAfter(endDate) &&
                  !apt.endTime.isBefore(startDate),
            )
            .toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime));

    switch (mode) {
      case AgendaGroupingMode.chronological:
        return _groupChronological(filteredAppointments, resourceMap);

      case AgendaGroupingMode.byDate:
        return _groupByDate(
          filteredAppointments,
          resourceMap,
          startDate,
          endDate,
          showEmptyDays,
        );

      case AgendaGroupingMode.byResource:
        return _groupByResource(
          filteredAppointments,
          resources,
          resourceMap,
          showEmptyResources,
        );

      case AgendaGroupingMode.byDateThenResource:
        return _groupByDateThenResource(
          filteredAppointments,
          resources,
          resourceMap,
          startDate,
          endDate,
          showEmptyDays,
          showEmptyResources,
        );

      case AgendaGroupingMode.byResourceThenDate:
        return _groupByResourceThenDate(
          filteredAppointments,
          resources,
          resourceMap,
          startDate,
          endDate,
          showEmptyResources,
          showEmptyDays,
        );
    }
  }

  /// Chronological grouping - flat list sorted by time
  static List<AgendaGroup> _groupChronological(
    List<CalendarAppointment> appointments,
    Map<String, CalendarResource> resourceMap,
  ) {
    final items = appointments
        .map(
          (apt) => AgendaItem(
            appointment: apt,
            resource: resourceMap[apt.resourceId]!,
            showResource: true,
            showDate: true,
          ),
        )
        .toList();

    return [
      AgendaGroup(
        key: 'all',
        header: AgendaGroupHeader(
          title: 'All Appointments',
          itemCount: items.length,
        ),
        items: items,
      ),
    ];
  }

  /// Group by date
  static List<AgendaGroup> _groupByDate(
    List<CalendarAppointment> appointments,
    Map<String, CalendarResource> resourceMap,
    DateTime startDate,
    DateTime endDate,
    bool showEmptyDays,
  ) {
    final groups = <AgendaGroup>[];
    final appointmentsByDate = <String, List<CalendarAppointment>>{};

    // Group appointments by date
    for (final apt in appointments) {
      final dateKey = DateTimeUtils.formatDate(apt.startTime, 'yyyy-MM-dd');
      appointmentsByDate.putIfAbsent(dateKey, () => []).add(apt);
    }

    // Generate date range
    var currentDate = startDate;
    while (!currentDate.isAfter(endDate)) {
      final dateKey = DateTimeUtils.formatDate(currentDate, 'yyyy-MM-dd');
      final dayAppointments = appointmentsByDate[dateKey] ?? [];

      if (dayAppointments.isNotEmpty || showEmptyDays) {
        final items = dayAppointments
            .map(
              (apt) => AgendaItem(
                appointment: apt,
                resource: resourceMap[apt.resourceId]!,
                showResource: true,
              ),
            )
            .toList();

        groups.add(
          AgendaGroup(
            key: dateKey,
            header: AgendaGroupHeader(
              title: DateTimeUtils.formatDate(currentDate, 'EEEE, MMMM d'),
              subtitle: _getRelativeDateText(currentDate),
              date: currentDate,
              itemCount: items.length,
            ),
            items: items,
          ),
        );
      }

      currentDate = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day + 1,
      );
    }

    return groups;
  }

  /// Group by resource
  static List<AgendaGroup> _groupByResource(
    List<CalendarAppointment> appointments,
    List<CalendarResource> resources,
    Map<String, CalendarResource> resourceMap,
    bool showEmptyResources,
  ) {
    final groups = <AgendaGroup>[];
    final appointmentsByResource = <String, List<CalendarAppointment>>{};

    // Group appointments by resource
    for (final apt in appointments) {
      appointmentsByResource.putIfAbsent(apt.resourceId, () => []).add(apt);
    }

    // Create group for each resource
    for (final resource in resources) {
      final resourceAppointments = appointmentsByResource[resource.id] ?? [];

      if (resourceAppointments.isNotEmpty || showEmptyResources) {
        final items = resourceAppointments
            .map(
              (apt) => AgendaItem(
                appointment: apt,
                resource: resource,
                showDate: true,
              ),
            )
            .toList();

        groups.add(
          AgendaGroup(
            key: resource.id,
            header: AgendaGroupHeader(
              title: resource.name,
              subtitle: resource.category,
              resource: resource,
              itemCount: items.length,
            ),
            items: items,
          ),
        );
      }
    }

    return groups;
  }

  /// Group by date, then resource (nested)
  static List<AgendaGroup> _groupByDateThenResource(
    List<CalendarAppointment> appointments,
    List<CalendarResource> resources,
    Map<String, CalendarResource> resourceMap,
    DateTime startDate,
    DateTime endDate,
    bool showEmptyDays,
    bool showEmptyResources,
  ) {
    final groups = <AgendaGroup>[];

    var currentDate = startDate;
    while (!currentDate.isAfter(endDate)) {
      final dateKey = DateTimeUtils.formatDate(currentDate, 'yyyy-MM-dd');
      final dayAppointments = appointments
          .where((apt) => DateTimeUtils.isSameDay(apt.startTime, currentDate))
          .toList();

      if (dayAppointments.isNotEmpty || showEmptyDays) {
        // Group this day's appointments by resource
        final appointmentsByResource = <String, List<CalendarAppointment>>{};
        for (final apt in dayAppointments) {
          appointmentsByResource.putIfAbsent(apt.resourceId, () => []).add(apt);
        }

        final subGroups = <AgendaGroup>[];
        for (final resource in resources) {
          final resourceAppointments =
              appointmentsByResource[resource.id] ?? [];

          if (resourceAppointments.isNotEmpty || showEmptyResources) {
            final items = resourceAppointments
                .map((apt) => AgendaItem(appointment: apt, resource: resource))
                .toList();

            subGroups.add(
              AgendaGroup(
                key: '${dateKey}_${resource.id}',
                header: AgendaGroupHeader(
                  title: resource.name,
                  resource: resource,
                  itemCount: items.length,
                ),
                items: items,
              ),
            );
          }
        }

        groups.add(
          AgendaGroup(
            key: dateKey,
            header: AgendaGroupHeader(
              title: DateTimeUtils.formatDate(currentDate, 'EEEE, MMMM d'),
              subtitle: _getRelativeDateText(currentDate),
              date: currentDate,
              itemCount: dayAppointments.length,
            ),
            items: [],
            subGroups: subGroups,
          ),
        );
      }

      currentDate = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day + 1,
      );
    }

    return groups;
  }

  /// Group by resource, then date (nested)
  static List<AgendaGroup> _groupByResourceThenDate(
    List<CalendarAppointment> appointments,
    List<CalendarResource> resources,
    Map<String, CalendarResource> resourceMap,
    DateTime startDate,
    DateTime endDate,
    bool showEmptyResources,
    bool showEmptyDays,
  ) {
    final groups = <AgendaGroup>[];

    for (final resource in resources) {
      final resourceAppointments = appointments
          .where((apt) => apt.resourceId == resource.id)
          .toList();

      if (resourceAppointments.isNotEmpty || showEmptyResources) {
        // Group this resource's appointments by date
        final appointmentsByDate = <String, List<CalendarAppointment>>{};
        for (final apt in resourceAppointments) {
          final dateKey = DateTimeUtils.formatDate(apt.startTime, 'yyyy-MM-dd');
          appointmentsByDate.putIfAbsent(dateKey, () => []).add(apt);
        }

        final subGroups = <AgendaGroup>[];
        var currentDate = startDate;
        while (!currentDate.isAfter(endDate)) {
          final dateKey = DateTimeUtils.formatDate(currentDate, 'yyyy-MM-dd');
          final dayAppointments = appointmentsByDate[dateKey] ?? [];

          if (dayAppointments.isNotEmpty || showEmptyDays) {
            final items = dayAppointments
                .map((apt) => AgendaItem(appointment: apt, resource: resource))
                .toList();

            subGroups.add(
              AgendaGroup(
                key: '${resource.id}_$dateKey',
                header: AgendaGroupHeader(
                  title: DateTimeUtils.formatDate(currentDate, 'EEEE, MMMM d'),
                  subtitle: _getRelativeDateText(currentDate),
                  date: currentDate,
                  itemCount: items.length,
                ),
                items: items,
              ),
            );
          }

          currentDate = DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day + 1,
          );
        }

        groups.add(
          AgendaGroup(
            key: resource.id,
            header: AgendaGroupHeader(
              title: resource.name,
              subtitle: resource.category,
              resource: resource,
              itemCount: resourceAppointments.length,
            ),
            items: [],
            subGroups: subGroups,
          ),
        );
      }
    }

    return groups;
  }

  /// Get relative date text (e.g., "Today", "Tomorrow", "Yesterday")
  static String _getRelativeDateText(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final compareDate = DateTime(date.year, date.month, date.day);

    final difference = compareDate.difference(today).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference == -1) return 'Yesterday';
    if (difference > 1 && difference <= 7) {
      return 'In $difference days';
    }
    if (difference < -1 && difference >= -7) {
      return '${-difference} days ago';
    }

    return '';
  }
}
