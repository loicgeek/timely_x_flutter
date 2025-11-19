// lib/src/widgets/month_view.dart

import 'package:calendar2/calendar2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/date_time_utils.dart';

/// Calendar month view - shows a month overview with full interactions
class CalendarMonthView extends StatefulWidget {
  const CalendarMonthView({
    Key? key,
    required this.controller,
    required this.config,
    required this.theme,
    this.onAppointmentTap,
    this.onAppointmentLongPress,
    this.onAppointmentSecondaryTap,
    this.onCellTap,
    this.onCellLongPress,
    this.onDateHeaderTap,
    this.onDateSelectionChanged,
    this.onDateRangeChanged,
  }) : super(key: key);

  final CalendarController controller;
  final CalendarConfig config;
  final CalendarTheme theme;

  // Callbacks
  final OnAppointmentTap? onAppointmentTap;
  final OnAppointmentLongPress? onAppointmentLongPress;
  final OnAppointmentSecondaryTap? onAppointmentSecondaryTap;
  final OnCellTap? onCellTap;
  final OnCellLongPress? onCellLongPress;
  final OnDateHeaderTap? onDateHeaderTap;

  // Date selection callbacks
  final OnDateSelectionChanged? onDateSelectionChanged;
  final OnDateRangeChanged? onDateRangeChanged;

  @override
  State<CalendarMonthView> createState() => _CalendarMonthViewState();
}

class _CalendarMonthViewState extends State<CalendarMonthView> {
  DateTime? _hoveredDate;
  String? _hoveredAppointmentId;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMonthHeader(),
        Expanded(child: _buildMonthGrid()),
      ],
    );
  }

  Widget _buildMonthHeader() {
    // Generate weekday labels based on firstDayOfWeek setting
    final weekdayLabels = DateTimeUtils.getWeekdayNames(
      firstDayOfWeek: widget.config.firstDayOfWeek,
    );

    return Container(
      height: widget.theme.monthViewHeaderHeight,
      decoration: BoxDecoration(
        color: widget.theme.monthViewHeaderBackgroundColor,
        border: Border(
          bottom: BorderSide(color: widget.theme.gridLineColor, width: 2),
        ),
      ),
      child: Row(
        children: weekdayLabels.map((day) {
          return Expanded(
            child: Center(
              child: Text(day, style: widget.theme.weekdayTextStyle),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMonthGrid() {
    final monthStart = DateTimeUtils.getMonthStart(
      widget.controller.currentDate,
    );
    final firstWeekday = monthStart.weekday;
    final firstDayOfWeek = widget.config.firstDayOfWeek;

    // Calculate days to subtract to get to first day of week
    int daysToSubtract = (firstWeekday - firstDayOfWeek) % 7;
    if (daysToSubtract < 0) daysToSubtract += 7;

    // Use calendar day arithmetic (DST-safe)
    final gridStart = DateTime(
      monthStart.year,
      monthStart.month,
      monthStart.day - daysToSubtract,
    );

    // Calculate total cells (6 weeks max)
    final totalCells = 42;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: widget.theme.monthViewCellAspectRatio,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        // Use calendar day arithmetic instead of Duration (DST-safe)
        final date = DateTime(
          gridStart.year,
          gridStart.month,
          gridStart.day + index,
        );
        final isCurrentMonth =
            date.month == widget.controller.currentDate.month &&
            date.year == widget.controller.currentDate.year;
        final isToday = DateTimeUtils.isToday(date);
        final isWeekend = DateTimeUtils.isWeekend(date);
        final appointments = widget.controller.getAppointmentsForDate(date);
        final isHovered =
            _hoveredDate != null &&
            DateTimeUtils.isSameDay(_hoveredDate!, date);

        return _buildMonthCell(
          date: date,
          isCurrentMonth: isCurrentMonth,
          isToday: isToday,
          isWeekend: isWeekend,
          isHovered: isHovered,
          appointments: appointments,
        );
      },
    );
  }

  Widget _buildMonthCell({
    required DateTime date,
    required bool isCurrentMonth,
    required bool isToday,
    required bool isWeekend,
    required bool isHovered,
    required List<CalendarAppointment> appointments,
  }) {
    final isSelected = widget.controller.isDateSelected(date);
    final isRangeStart =
        widget.controller.selectionRangeStart != null &&
        DateTimeUtils.isSameDay(widget.controller.selectionRangeStart!, date);
    final isRangeEnd =
        widget.controller.selectionRangeEnd != null &&
        DateTimeUtils.isSameDay(widget.controller.selectionRangeEnd!, date);

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredDate = date),
      onExit: (_) => setState(() => _hoveredDate = null),
      child: GestureDetector(
        onTapDown: (details) =>
            _onCellTap(date, appointments, details.globalPosition),
        onLongPressDown: (details) =>
            _onCellLongPress(date, appointments, details.globalPosition),
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            color: _getCellBackgroundColor(
              isToday: isToday,
              isWeekend: isWeekend,
              isCurrentMonth: isCurrentMonth,
              isHovered: isHovered,
              isSelected: isSelected,
            ),
            border: _getCellBorder(
              isToday: isToday,
              isSelected: isSelected,
              isRangeStart: isRangeStart,
              isRangeEnd: isRangeEnd,
            ),
          ),
          padding: widget.theme.monthViewCellPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDayNumber(
                date: date,
                isToday: isToday,
                isCurrentMonth: isCurrentMonth,
                isWeekend: isWeekend,
                isSelected: isSelected,
              ),
              SizedBox(height: widget.theme.appointmentSpacing * 2),
              if (appointments.isNotEmpty)
                Expanded(child: _buildAppointmentsList(date, appointments)),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCellBackgroundColor({
    required bool isToday,
    required bool isWeekend,
    required bool isCurrentMonth,
    required bool isHovered,
    required bool isSelected,
  }) {
    if (isSelected) {
      return widget.config.dateSelectionMode == DateSelectionMode.range
          ? widget.theme.rangeSelectionColor
          : widget.theme.selectedDateBackgroundColor;
    }
    if (isToday) {
      return widget.theme.currentDayHighlight.withOpacity(0.3);
    }
    if (isHovered) {
      return widget.theme.hoverColor;
    }
    if (isWeekend && isCurrentMonth) {
      return widget.theme.weekendColor;
    }
    if (!isCurrentMonth) {
      return widget.theme.otherMonthGridBackgroundColor;
    }
    return widget.theme.gridBackgroundColor;
  }

  Border _getCellBorder({
    required bool isToday,
    required bool isSelected,
    required bool isRangeStart,
    required bool isRangeEnd,
  }) {
    if (isSelected &&
        widget.config.dateSelectionMode == DateSelectionMode.range) {
      // Range selection border
      if (isRangeStart || isRangeEnd) {
        return Border.all(
          color: widget.theme.selectedDateBorderColor,
          width: 2.0,
        );
      }
      return Border.all(
        color: widget.theme.rangeSelectionBorderColor,
        width: 1.0,
      );
    } else if (isSelected) {
      // Single/multiple selection border
      return Border.all(
        color: widget.theme.selectedDateBorderColor,
        width: 2.0,
      );
    } else if (isToday) {
      // Today border
      return Border.all(color: widget.theme.gridLineColor, width: 2.0);
    }
    // Default border
    return Border.all(color: widget.theme.gridLineColor, width: 0.5);
  }

  Widget _buildDayNumber({
    required DateTime date,
    required bool isToday,
    required bool isCurrentMonth,
    required bool isWeekend,
    required bool isSelected,
  }) {
    Color textColor;
    if (isSelected &&
        widget.config.dateSelectionMode != DateSelectionMode.range) {
      textColor = widget.theme.selectedDateTextColor;
    } else if (isToday) {
      textColor = Colors.white;
    } else if (isCurrentMonth) {
      textColor = isWeekend
          ? widget.theme.weekendTextColor
          : widget.theme.monthViewDayTextStyle.color!;
    } else {
      textColor = widget.theme.otherMonthDayColor;
    }

    return GestureDetector(
      onTap: () {
        widget.onDateHeaderTap?.call(
          DateHeaderTapData(date: date, globalPosition: Offset.zero),
        );
      },
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isToday
              ? widget.theme.todayHighlightColor
              : (isSelected &&
                        widget.config.dateSelectionMode !=
                            DateSelectionMode.range
                    ? widget.theme.selectedDateBackgroundColor
                    : Colors.transparent),
          shape: BoxShape.circle,
        ),
        child: Text(
          '${date.day}',
          style: widget.theme.monthViewDayTextStyle.copyWith(
            color: textColor,
            fontWeight: isToday || isSelected
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentsList(DateTime date, List appointments) {
    final maxVisible = widget.theme.monthViewMaxVisibleAppointments;
    final visibleCount = appointments.length > maxVisible
        ? maxVisible - 1
        : appointments.length;

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: appointments.length > maxVisible ? maxVisible : visibleCount,
      itemBuilder: (context, i) {
        // Show "+X more" on last item if there are more appointments
        if (i == maxVisible - 1 && appointments.length > maxVisible) {
          return _buildMoreIndicator(date, appointments);
        }

        return _buildAppointmentItem(date, appointments[i]);
      },
    );
  }

  Widget _buildAppointmentItem(DateTime date, appointment) {
    final isHovered = _hoveredAppointmentId == appointment.id;
    final isSelected =
        widget.controller.selectedAppointment?.id == appointment.id;

    // Get the first resource for this appointment (for callback)
    final resource = widget.controller.resources.firstWhere(
      (r) => r.id == appointment.resourceId,
      orElse: () => _createDefaultResource(appointment.resourceId),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredAppointmentId = appointment.id),
      onExit: (_) => setState(() => _hoveredAppointmentId = null),
      child: GestureDetector(
        onTap: () => _onAppointmentTap(appointment, resource),
        onLongPress: () => _onAppointmentLongPress(appointment, resource),
        onSecondaryTap: () => _onAppointmentSecondaryTap(appointment, resource),
        child: Container(
          margin: widget.theme.monthViewAppointmentMargin,
          padding: widget.theme.monthViewAppointmentPadding,
          decoration: BoxDecoration(
            color: isHovered
                ? appointment.color.withOpacity(0.9)
                : appointment.color,
            borderRadius: BorderRadius.circular(
              widget.theme.monthViewAppointmentBorderRadius,
            ),
            border: isSelected
                ? Border.all(
                    color:
                        widget.theme.appointmentTextStyle.color ?? Colors.white,
                    width: 2,
                  )
                : null,
          ),
          child: Row(
            children: [
              // Time indicator (optional)
              if (appointment.startTime.hour != 0 ||
                  appointment.startTime.minute != 0) ...[
                Text(
                  DateFormat(
                    widget.theme.timeFormat,
                  ).format(appointment.startTime),
                  style: widget.theme.monthViewAppointmentTextStyle.copyWith(
                    fontSize: 9,
                  ),
                ),
                SizedBox(width: 4),
              ],
              // Title
              Expanded(
                child: Text(
                  appointment.title,
                  style: widget.theme.monthViewAppointmentTextStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Resource indicator (if multiple resources)
              if (widget.controller.resources.length > 1) ...[
                SizedBox(width: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: resource.color ?? Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoreIndicator(DateTime date, List appointments) {
    final remaining =
        appointments.length - widget.theme.monthViewMaxVisibleAppointments + 1;

    return GestureDetector(
      onTap: () => _onMoreTap(date, appointments),
      child: Container(
        margin: widget.theme.monthViewAppointmentMargin,
        padding: widget.theme.monthViewAppointmentPadding,
        child: Text(
          '+$remaining more',
          style: widget.theme.monthViewMoreTextStyle.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Callback handlers
  void _onCellTap(
    DateTime date,
    List<CalendarAppointment> appointments,
    Offset globalPosition,
  ) {
    // Handle date selection based on mode
    if (widget.config.dateSelectionMode != DateSelectionMode.none) {
      widget.controller.selectDate(date);

      // Trigger callbacks
      widget.onDateSelectionChanged?.call(widget.controller.selectedDates);

      if (widget.config.dateSelectionMode == DateSelectionMode.range) {
        widget.onDateRangeChanged?.call(
          widget.controller.selectionRangeStart,
          widget.controller.selectionRangeEnd,
          widget.controller.selectedDates,
        );
      }
    }

    // Also trigger regular cell tap if provided
    if (widget.onCellTap == null) return;

    // Use first resource or create default
    final resource = widget.controller.resources.isNotEmpty
        ? widget.controller.resources.first
        : _createDefaultResource('default');

    widget.onCellTap!.call(
      CellTapData(
        resource: resource,
        dateTime: DateTime(
          date.year,
          date.month,
          date.day,
          0,
          0,
        ), // 9 AM default
        globalPosition: globalPosition,
        appointments: appointments,
      ),
    );
  }

  void _onCellLongPress(
    DateTime date,
    List<CalendarAppointment> appointments,
    Offset globalPosition,
  ) {
    if (widget.onCellLongPress == null) return;

    final resource = widget.controller.resources.isNotEmpty
        ? widget.controller.resources.first
        : _createDefaultResource('default');

    widget.onCellLongPress!.call(
      CellTapData(
        resource: resource,
        dateTime: DateTime(date.year, date.month, date.day, 0, 0),
        globalPosition: globalPosition,
        appointments: appointments,
      ),
    );
  }

  void _onAppointmentTap(appointment, CalendarResource resource) {
    // Select the appointment
    widget.controller.selectAppointment(appointment);

    if (widget.onAppointmentTap == null) return;

    widget.onAppointmentTap!.call(
      AppointmentTapData(
        appointment: appointment,
        resource: resource,
        globalPosition: Offset.zero,
      ),
    );
  }

  void _onAppointmentLongPress(appointment, CalendarResource resource) {
    if (widget.onAppointmentLongPress == null) return;

    widget.onAppointmentLongPress!.call(
      AppointmentLongPressData(
        appointment: appointment,
        resource: resource,
        globalPosition: Offset.zero,
      ),
    );
  }

  void _onAppointmentSecondaryTap(appointment, CalendarResource resource) {
    if (widget.onAppointmentSecondaryTap == null) return;

    widget.onAppointmentSecondaryTap!.call(
      AppointmentSecondaryTapData(
        appointment: appointment,
        resource: resource,
        globalPosition: Offset.zero,
      ),
    );
  }

  void _onMoreTap(DateTime date, List appointments) {
    // Show all appointments for this day in a dialog/bottom sheet
    _showDayAppointmentsDialog(date, appointments);
  }

  void _showDayAppointmentsDialog(DateTime date, List appointments) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: BoxConstraints(maxWidth: 400, maxHeight: 600),
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(date),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                '${appointments.length} appointment${appointments.length != 1 ? 's' : ''}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              SizedBox(height: 16),
              // Appointments list
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];
                    final resource = widget.controller.resources.firstWhere(
                      (r) => r.id == appointment.resourceId,
                      orElse: () =>
                          _createDefaultResource(appointment.resourceId),
                    );

                    return ListTile(
                      leading: Container(
                        width: 4,
                        height: 40,
                        color: appointment.color,
                      ),
                      title: Text(appointment.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${DateFormat(widget.theme.timeFormat).format(appointment.startTime)} - '
                            '${DateFormat(widget.theme.timeFormat).format(appointment.endTime)}',
                          ),
                          if (appointment.subtitle != null)
                            Text(appointment.subtitle!),
                          Text(
                            resource.name,
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _onAppointmentTap(appointment, resource);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to create default resource when needed
  CalendarResource _createDefaultResource(String id) {
    return _DefaultResource(id: id, name: 'Unknown');
  }
}

// Simple default resource for cases where resource is not found
class _DefaultResource extends CalendarResource {
  _DefaultResource({required this.id, required this.name});

  @override
  final String id;

  @override
  final String name;
}
