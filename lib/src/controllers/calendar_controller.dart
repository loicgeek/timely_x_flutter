// lib/src/controllers/calendar_controller.dart (Fixed)

import 'package:calendar2/src/models/agenda_view_config.dart';
import 'package:flutter/material.dart';
import '../models/calendar_appointment.dart';
import '../models/calendar_resource.dart';
import '../models/calendar_config.dart';
import '../models/calendar_view_type.dart';
import '../utils/date_time_utils.dart';

/// Controller for managing the calendar state across all view types
class CalendarController extends ChangeNotifier {
  CalendarController({DateTime? initialDate, required CalendarConfig config})
    : _currentDate = initialDate ?? DateTime.now(),
      _config = config;

  CalendarConfig _config;
  DateTime _currentDate;
  List<CalendarResource> _resources = [];
  List<CalendarAppointment> _appointments = [];
  CalendarAppointment? _selectedAppointment;
  DateTime? _hoveredCell;
  String? _hoveredResourceId;

  // Date selection for month view
  final Set<DateTime> _selectedDates = {};
  DateTime? _rangeStartDate;
  DateTime? _rangeEndDate;

  // Agenda-specific date range (when using custom date range mode)
  DateTime? _agendaStartDate;
  DateTime? _agendaEndDate;

  // Selected resource filter for agenda view
  Set<String> _selectedResourceIds = {};

  // Getters
  CalendarConfig get config => _config;
  DateTime get currentDate => _currentDate;
  CalendarViewType get viewType => _config.viewType;

  /// Get the effective start date based on current date and view type
  DateTime get viewStartDate {
    switch (_config.viewType) {
      case CalendarViewType.day:
        return DateTime(
          _currentDate.year,
          _currentDate.month,
          _currentDate.day,
        );
      case CalendarViewType.week:
        // Get start of week based on configured first day
        final weekday = _currentDate.weekday;
        final firstDay = _config.firstDayOfWeek;
        int daysToSubtract = (weekday - firstDay) % 7;
        if (daysToSubtract < 0) daysToSubtract += 7;

        return DateTime(
          _currentDate.year,
          _currentDate.month,
          _currentDate.day - daysToSubtract,
        );
      case CalendarViewType.month:
        return DateTime(_currentDate.year, _currentDate.month, 1);

      // For agenda view, return custom start date or today
      case CalendarViewType.agenda:
        if (_agendaStartDate != null) {
          return _agendaStartDate!;
        }
        // Use _currentDate instead of DateTime.now()
        return DateTime(
          _currentDate.year,
          _currentDate.month,
          _currentDate.day,
        );
    }
  }

  /// Get effective number of days to display
  int get effectiveNumberOfDays {
    if (_config.numberOfDays != null) return _config.numberOfDays!;

    switch (_config.viewType) {
      case CalendarViewType.day:
        return 1;
      case CalendarViewType.week:
        return 7;
      case CalendarViewType.month:
        final date = viewStartDate;
        final nextMonth = DateTime(date.year, date.month + 1, 1);
        return nextMonth.difference(date).inDays;
      case CalendarViewType.agenda:
        // Use agenda config or calculate from custom range
        if (_agendaStartDate != null && _agendaEndDate != null) {
          return _agendaEndDate!.difference(_agendaStartDate!).inDays + 1;
        }
        final agendaConfig = _config.agendaConfig ?? const AgendaViewConfig();
        return agendaConfig.daysToShow;
    }
  }

  /// Get visible dates for the current view
  List<DateTime> get visibleDates =>
      DateTimeUtils.generateDateRange(viewStartDate, effectiveNumberOfDays);

  List<CalendarResource> get resources => List.unmodifiable(_resources);
  List<CalendarAppointment> get appointments =>
      List.unmodifiable(_appointments);
  CalendarAppointment? get selectedAppointment => _selectedAppointment;
  DateTime? get hoveredCell => _hoveredCell;
  String? get hoveredResourceId => _hoveredResourceId;

  /// Get selected dates (normalized to date-only without time)
  Set<DateTime> get selectedDates =>
      _selectedDates.map((d) => DateTime(d.year, d.month, d.day)).toSet();

  /// Get selection range start date
  DateTime? get selectionRangeStart => _rangeStartDate;

  /// Get selection range end date
  DateTime? get selectionRangeEnd => _rangeEndDate;

  /// Get agenda start date (for custom date range mode)
  DateTime? get agendaStartDate => _agendaStartDate;

  /// Get agenda end date (for custom date range mode)
  DateTime? get agendaEndDate => _agendaEndDate;

  /// Get selected resource IDs for filtering
  Set<String> get selectedResourceIds => Set.unmodifiable(_selectedResourceIds);

  /// Get filtered appointments based on selected resources
  List<CalendarAppointment> get filteredAppointments {
    if (_selectedResourceIds.isEmpty) {
      return _appointments;
    }
    return _appointments
        .where((apt) => _selectedResourceIds.contains(apt.resourceId))
        .toList();
  }

  /// Check if a date is selected
  bool isDateSelected(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    // Check direct selection
    if (_selectedDates.any(
      (d) =>
          d.year == normalizedDate.year &&
          d.month == normalizedDate.month &&
          d.day == normalizedDate.day,
    )) {
      return true;
    }

    // Check range selection
    if (_rangeStartDate != null && _rangeEndDate != null) {
      final start = DateTime(
        _rangeStartDate!.year,
        _rangeStartDate!.month,
        _rangeStartDate!.day,
      );
      final end = DateTime(
        _rangeEndDate!.year,
        _rangeEndDate!.month,
        _rangeEndDate!.day,
      );

      return (normalizedDate.isAtSameMomentAs(start) ||
              normalizedDate.isAfter(start)) &&
          (normalizedDate.isAtSameMomentAs(end) ||
              normalizedDate.isBefore(end));
    }

    return false;
  }

  /// Get range start date (for range selection mode)
  DateTime? get rangeStartDate => _rangeStartDate;

  /// Get range end date (for range selection mode)
  DateTime? get rangeEndDate => _rangeEndDate;

  /// Check if a date is in the selected range
  bool isDateInRange(DateTime date) {
    if (_rangeStartDate == null || _rangeEndDate == null) return false;

    final normalizedDate = DateTime(date.year, date.month, date.day);
    final start = DateTime(
      _rangeStartDate!.year,
      _rangeStartDate!.month,
      _rangeStartDate!.day,
    );
    final end = DateTime(
      _rangeEndDate!.year,
      _rangeEndDate!.month,
      _rangeEndDate!.day,
    );

    return (normalizedDate.isAtSameMomentAs(start) ||
            normalizedDate.isAfter(start)) &&
        (normalizedDate.isAtSameMomentAs(end) || normalizedDate.isBefore(end));
  }

  /// Update configuration
  void updateConfig(CalendarConfig config) {
    _config = config;
    notifyListeners();
  }

  /// Change view type
  void setViewType(CalendarViewType viewType) {
    _config = _config.copyWith(viewType: viewType);
    notifyListeners();
  }

  /// Update resources
  void updateResources(List<CalendarResource> resources) {
    _resources = resources;
    notifyListeners();
  }

  /// Update appointments
  void updateAppointments(List<CalendarAppointment> appointments) {
    _appointments = appointments;
    notifyListeners();
  }

  /// Add a single appointment
  void addAppointment(CalendarAppointment appointment) {
    _appointments.add(appointment);
    notifyListeners();
  }

  /// Update a single appointment
  void updateAppointment(CalendarAppointment appointment) {
    final index = _appointments.indexWhere((a) => a.id == appointment.id);
    if (index != -1) {
      _appointments[index] = appointment;
      notifyListeners();
    }
  }

  /// Remove an appointment
  void removeAppointment(String appointmentId) {
    _appointments.removeWhere((a) => a.id == appointmentId);
    if (_selectedAppointment?.id == appointmentId) {
      _selectedAppointment = null;
    }
    notifyListeners();
  }

  /// Navigate to next period (based on view type)
  void next() {
    switch (_config.viewType) {
      case CalendarViewType.day:
        _currentDate = DateTimeUtils.addDays(_currentDate, 1);
        break;
      case CalendarViewType.week:
        _currentDate = DateTimeUtils.addDays(_currentDate, 7);
        break;
      case CalendarViewType.month:
        _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
        break;
      case CalendarViewType.agenda:
        final agendaConfig = _config.agendaConfig ?? const AgendaViewConfig();
        nextAgendaPeriod(agendaConfig.daysToShow);
        break;
    }
    notifyListeners();
  }

  /// Navigate to previous period (based on view type)
  void previous() {
    switch (_config.viewType) {
      case CalendarViewType.day:
        _currentDate = DateTimeUtils.subtractDays(_currentDate, 1);
        break;
      case CalendarViewType.week:
        _currentDate = DateTimeUtils.subtractDays(_currentDate, 7);
        break;
      case CalendarViewType.month:
        _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
        break;
      case CalendarViewType.agenda:
        final agendaConfig = _config.agendaConfig ?? const AgendaViewConfig();
        previousAgendaPeriod(agendaConfig.daysToShow);
        break;
    }
    notifyListeners();
  }

  /// Navigate to today
  void goToToday() {
    _currentDate = DateTime.now();
    notifyListeners();
  }

  /// Navigate to specific date
  void goToDate(DateTime date) {
    _currentDate = date;
    notifyListeners();
  }

  /// Select an appointment
  void selectAppointment(CalendarAppointment? appointment) {
    _selectedAppointment = appointment;
    notifyListeners();
  }

  /// Set hovered cell
  void setHoveredCell(DateTime? dateTime, String? resourceId) {
    _hoveredCell = dateTime;
    _hoveredResourceId = resourceId;
    notifyListeners();
  }

  /// Select a date (behavior depends on selection mode)
  void selectDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    switch (_config.dateSelectionMode) {
      case DateSelectionMode.none:
        return;

      case DateSelectionMode.single:
        _selectedDates.clear();
        _selectedDates.add(normalizedDate);
        _rangeStartDate = null;
        _rangeEndDate = null;
        break;

      case DateSelectionMode.multiple:
        if (!_selectedDates.add(normalizedDate)) {
          _selectedDates.remove(normalizedDate);
        }
        _rangeStartDate = null;
        _rangeEndDate = null;
        break;

      case DateSelectionMode.range:
        if (_rangeStartDate == null) {
          // First click - set start
          _rangeStartDate = normalizedDate;
          _rangeEndDate = null;
          _selectedDates.clear();
          _selectedDates.add(normalizedDate);
        } else if (_rangeEndDate == null) {
          // Second click - set end and fill range
          if (normalizedDate.isBefore(_rangeStartDate!)) {
            _rangeEndDate = _rangeStartDate;
            _rangeStartDate = normalizedDate;
          } else {
            _rangeEndDate = normalizedDate;
          }
          _fillDateRange();
        } else {
          // Third click - reset and start new range
          _rangeStartDate = normalizedDate;
          _rangeEndDate = null;
          _selectedDates.clear();
          _selectedDates.add(normalizedDate);
        }
        break;
    }

    notifyListeners();
  }

  /// Toggle date selection (for multiple mode)
  void toggleDateSelection(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    if (_selectedDates.any(
      (d) =>
          d.year == normalizedDate.year &&
          d.month == normalizedDate.month &&
          d.day == normalizedDate.day,
    )) {
      _selectedDates.removeWhere(
        (d) =>
            d.year == normalizedDate.year &&
            d.month == normalizedDate.month &&
            d.day == normalizedDate.day,
      );
    } else {
      _selectedDates.add(normalizedDate);
    }

    notifyListeners();
  }

  /// Clear all selected dates
  void clearDateSelection() {
    _selectedDates.clear();
    _rangeStartDate = null;
    _rangeEndDate = null;
    notifyListeners();
  }

  /// Set multiple dates as selected
  void setSelectedDates(List<DateTime> dates) {
    _selectedDates.clear();
    for (final date in dates) {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      _selectedDates.add(normalizedDate);
    }
    _rangeStartDate = null;
    _rangeEndDate = null;
    notifyListeners();
  }

  /// Set date range
  void setDateRange(DateTime start, DateTime end) {
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day);

    if (normalizedEnd.isBefore(normalizedStart)) {
      _rangeStartDate = normalizedEnd;
      _rangeEndDate = normalizedStart;
    } else {
      _rangeStartDate = normalizedStart;
      _rangeEndDate = normalizedEnd;
    }

    _fillDateRange();
    notifyListeners();
  }

  /// Fill dates between range start and end
  void _fillDateRange() {
    if (_rangeStartDate == null || _rangeEndDate == null) return;

    _selectedDates.clear();

    // Calculate number of days in range
    final daysDifference = _rangeEndDate!.difference(_rangeStartDate!).inDays;

    // Use calendar arithmetic to avoid DST issues
    for (int i = 0; i <= daysDifference; i++) {
      final date = DateTime(
        _rangeStartDate!.year,
        _rangeStartDate!.month,
        _rangeStartDate!.day + i,
      );
      _selectedDates.add(date);
    }
  }

  /// Get appointments for a specific resource and date
  List<CalendarAppointment> getAppointmentsForResourceDate(
    String resourceId,
    DateTime date,
  ) {
    return _appointments
        .where(
          (a) =>
              a.resourceId == resourceId &&
              DateTimeUtils.isSameDay(a.startTime, date),
        )
        .toList();
  }

  /// Get all appointments for a specific date
  List<CalendarAppointment> getAppointmentsForDate(DateTime date) {
    return _appointments
        .where((a) => DateTimeUtils.isSameDay(a.startTime, date))
        .toList();
  }

  /// Get all appointments for a specific resource
  List<CalendarAppointment> getAppointmentsForResource(String resourceId) {
    return _appointments.where((a) => a.resourceId == resourceId).toList();
  }

  /// Check if a time slot is available for a resource
  bool isTimeSlotAvailable({
    required String resourceId,
    required DateTime startTime,
    required DateTime endTime,
    String? excludeAppointmentId,
  }) {
    final resourceAppointments = _appointments
        .where(
          (a) => a.resourceId == resourceId && a.id != excludeAppointmentId,
        )
        .toList();

    for (final appointment in resourceAppointments) {
      if (startTime.isBefore(appointment.endTime) &&
          endTime.isAfter(appointment.startTime)) {
        return false;
      }
    }

    return true;
  }

  /// Get view period description (e.g., "Nov 14-20, 2025")
  String getViewPeriodDescription([
    String? dateHeaderFormat,
    String? weekPeriodFormat,
    String? monthFormat,
  ]) {
    final headerFormat = dateHeaderFormat ?? 'MMMM d, yyyy';
    final weekFormat = weekPeriodFormat ?? 'MMM d';
    final monthFormatStr = monthFormat ?? 'MMMM yyyy';

    switch (_config.viewType) {
      case CalendarViewType.day:
        return DateTimeUtils.formatDate(_currentDate, headerFormat);
      case CalendarViewType.week:
        final start = viewStartDate;
        final end = DateTimeUtils.addDays(start, effectiveNumberOfDays - 1);
        if (start.month == end.month) {
          return '${DateTimeUtils.formatDate(start, weekFormat)}-${DateTimeUtils.formatDate(end, 'd, yyyy')}';
        } else {
          return '${DateTimeUtils.formatDate(start, weekFormat)} - ${DateTimeUtils.formatDate(end, '$weekFormat, yyyy')}';
        }
      case CalendarViewType.month:
        return DateTimeUtils.formatDate(_currentDate, monthFormatStr);
      case CalendarViewType.agenda:
        return getAgendaViewPeriodDescription();
    }
  }

  // ============================================================================
  // Additional Methods for Agenda View
  // ============================================================================

  /// Set custom date range for agenda view
  void setAgendaDateRange(DateTime startDate, DateTime endDate) {
    // Normalize start date to beginning of day
    _agendaStartDate = DateTime(startDate.year, startDate.month, startDate.day);

    // CRITICAL FIX: Extend end date to end of day
    // This ensures appointments later in the day are included in the range
    _agendaEndDate = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      23,
      59,
      59,
      999,
    );

    notifyListeners();
  }

  /// Clear custom date range (will use relative mode)
  void clearAgendaDateRange() {
    _agendaStartDate = null;
    _agendaEndDate = null;
    notifyListeners();
  }

  /// Navigate to next period in agenda view
  void nextAgendaPeriod(int days) {
    if (_config.viewType != CalendarViewType.agenda) return;

    if (_agendaStartDate != null && _agendaEndDate != null) {
      // Custom date range mode - shift by specified days
      // CRITICAL: Preserve start of day for start date
      _agendaStartDate = DateTime(
        _agendaStartDate!.year,
        _agendaStartDate!.month,
        _agendaStartDate!.day + days,
      );

      // CRITICAL FIX: Preserve end of day for end date
      // Without this, navigation would reset end date to midnight
      _agendaEndDate = DateTime(
        _agendaEndDate!.year,
        _agendaEndDate!.month,
        _agendaEndDate!.day + days,
        23, // End of day
        59,
        59,
        999,
      );
    } else {
      // Relative mode - just update current date
      _currentDate = DateTime(
        _currentDate.year,
        _currentDate.month,
        _currentDate.day + days,
      );
    }
    notifyListeners();
  }

  /// Navigate to previous period in agenda view
  void previousAgendaPeriod(int days) {
    if (_config.viewType != CalendarViewType.agenda) return;

    if (_agendaStartDate != null && _agendaEndDate != null) {
      // Custom date range mode - shift by specified days
      // CRITICAL: Preserve start of day for start date
      _agendaStartDate = DateTime(
        _agendaStartDate!.year,
        _agendaStartDate!.month,
        _agendaStartDate!.day - days,
      );

      // CRITICAL FIX: Preserve end of day for end date
      // Without this, navigation would reset end date to midnight
      _agendaEndDate = DateTime(
        _agendaEndDate!.year,
        _agendaEndDate!.month,
        _agendaEndDate!.day - days,
        23, // End of day
        59,
        59,
        999,
      );
    } else {
      // Relative mode - just update current date
      _currentDate = DateTime(
        _currentDate.year,
        _currentDate.month,
        _currentDate.day - days,
      );
    }
    notifyListeners();
  }

  /// Set resource filter for agenda view
  void setResourceFilter(Set<String> resourceIds) {
    _selectedResourceIds = Set.from(resourceIds);
    notifyListeners();
  }

  /// Add resource to filter
  void addResourceToFilter(String resourceId) {
    _selectedResourceIds.add(resourceId);
    notifyListeners();
  }

  /// Remove resource from filter
  void removeResourceFromFilter(String resourceId) {
    _selectedResourceIds.remove(resourceId);
    notifyListeners();
  }

  /// Toggle resource filter
  void toggleResourceFilter(String resourceId) {
    if (_selectedResourceIds.contains(resourceId)) {
      _selectedResourceIds.remove(resourceId);
    } else {
      _selectedResourceIds.add(resourceId);
    }
    notifyListeners();
  }

  /// Clear resource filter (show all resources)
  void clearResourceFilter() {
    _selectedResourceIds.clear();
    notifyListeners();
  }

  /// Check if resource is filtered
  bool isResourceFiltered(String resourceId) {
    if (_selectedResourceIds.isEmpty) return true; // No filter = all shown
    return _selectedResourceIds.contains(resourceId);
  }

  /// Get appointments for agenda view (respects filters and date range)
  List<CalendarAppointment> getAgendaAppointments({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final start = startDate ?? _agendaStartDate;
    var end = endDate ?? _agendaEndDate;

    var filtered = _appointments;

    // Apply resource filter
    if (_selectedResourceIds.isNotEmpty) {
      filtered = filtered
          .where((apt) => _selectedResourceIds.contains(apt.resourceId))
          .toList();
    }

    // Apply date range filter
    if (start != null && end != null) {
      // CRITICAL FIX: Extend end date to end of day to include all appointments on that day
      // Without this, appointments later in the day would be excluded
      end = DateTime(end.year, end.month, end.day, 23, 59, 59, 999);
      filtered = filtered
          .where(
            (apt) =>
                !apt.startTime.isAfter(end!) && !apt.endTime.isBefore(start),
          )
          .toList();
    }

    // Sort by start time
    filtered.sort((a, b) => a.startTime.compareTo(b.startTime));

    return filtered;
  }

  /// Get agenda view period description

  String getAgendaViewPeriodDescription([String? dateFormat]) {
    final format = dateFormat ?? 'MMM d, yyyy';

    if (_agendaStartDate != null && _agendaEndDate != null) {
      // === 1. Custom Date Range Mode (Logic is already good) ===
      if (DateTimeUtils.isSameDay(_agendaStartDate!, _agendaEndDate!)) {
        return DateTimeUtils.formatDate(_agendaStartDate!, format);
      } else if (_agendaStartDate!.month == _agendaEndDate!.month) {
        return '${DateTimeUtils.formatDate(_agendaStartDate!, 'MMM d')} - '
            '${DateTimeUtils.formatDate(_agendaEndDate!, 'd, yyyy')}';
      } else {
        return '${DateTimeUtils.formatDate(_agendaStartDate!, 'MMM d')} - '
            '${DateTimeUtils.formatDate(_agendaEndDate!, 'MMM d, yyyy')}';
      }
    } else {
      // === 2. Relative Mode (FIXED LOGIC) ===

      // Get the actual period start date (from controller's _currentDate)
      final startDate = viewStartDate;

      // Get the number of days to show from the config
      final agendaConfig = _config.agendaConfig ?? const AgendaViewConfig();
      final days = agendaConfig.daysToShow;

      // Calculate the end date for the displayed period.
      // Use calendar arithmetic on startDate to find the exact end date.
      final endDate = DateTimeUtils.addDays(startDate, days - 1);

      // If the start date is today, we can use simple descriptions
      final today = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );
      if (DateTimeUtils.isSameDay(startDate, today) &&
          !agendaConfig.showPastAppointments) {
        if (days == 1) {
          return 'Today';
        } else {
          // Return 'Next X days' only if the period starts today and looks forward
          return 'Next $days days';
        }
      }

      // For all other cases (including navigated periods), display the date range:
      final weekFormat = 'MMM d';
      final yearFormat = 'MMM d, yyyy';

      if (DateTimeUtils.isSameDay(startDate, endDate)) {
        return DateTimeUtils.formatDate(
          startDate,
          format,
        ); // Should only happen if days=1 and navigated
      } else if (startDate.month == endDate.month &&
          startDate.year == endDate.year) {
        // Example: Dec 1 - 7, 2025
        return '${DateTimeUtils.formatDate(startDate, weekFormat)} - '
            '${DateTimeUtils.formatDate(endDate, 'd, yyyy')}';
      } else {
        // Example: Dec 25, 2025 - Jan 5, 2026
        return '${DateTimeUtils.formatDate(startDate, weekFormat)} - '
            '${DateTimeUtils.formatDate(endDate, yearFormat)}';
      }
    }
  }
}
