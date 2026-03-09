// lib/src/gestures/grid_gesture_detector.dart
//
// Single top-level gesture + drop handler for the entire calendar grid.
// Used by BOTH CalendarDayView and CalendarWeekView.
//
// One GestureDetector + one DragTarget wraps the whole Stack.
// Hit-test position is converted to (resource, date, time) math-side,
// no per-cell widgets needed.

import 'package:flutter/material.dart';
import '../models/calendar_appointment.dart';
import '../models/calendar_resource.dart';
import '../models/calendar_config.dart';
import '../models/interaction_data.dart';
import '../builders/builder_delegates.dart';
import '../controllers/calendar_controller.dart';

class GridGestureDetector extends StatefulWidget {
  const GridGestureDetector({
    Key? key,
    required this.child,
    required this.config,
    required this.controller,
    required this.columnWidth,
    required this.resources,
    required this.dates, // single-item list for day view
    required this.verticalScrollOffset,
    required this.horizontalScrollOffset,
    this.onCellTap,
    this.onCellLongPress,
    this.onAppointmentDragEnd,
  }) : super(key: key);

  final Widget child;
  final CalendarConfig config;
  final CalendarController controller;
  final double columnWidth;

  /// Ordered list of resources as laid out left→right in the grid.
  /// Day view: filtered resources only (one date).
  /// Week view: depends on weekViewLayout — pass resources in column order.
  final List<CalendarResource> resources;

  /// Ordered list of dates as laid out left→right.
  /// Day view: [currentDate]  (single entry)
  /// Week view: visibleDates
  final List<DateTime> dates;

  /// Current vertical scroll offset of the grid (pixels).
  final double verticalScrollOffset;

  /// Current horizontal scroll offset of the grid (pixels).
  final double horizontalScrollOffset;

  final OnCellTap? onCellTap;
  final OnCellLongPress? onCellLongPress;
  final OnAppointmentDragEnd? onAppointmentDragEnd;

  @override
  State<GridGestureDetector> createState() => _GridGestureDetectorState();
}

class _GridGestureDetectorState extends State<GridGestureDetector> {
  bool _longPressTriggered = false;
  bool _isDragOver = false;

  // ── Coordinate math ────────────────────────────────────────────────────
  //
  // localPosition  = position within the visible viewport of this widget
  // gridX / gridY  = position within the full (scrolled) grid canvas
  //
  // Column order matches the order of widget.resources × widget.dates
  // as passed by the parent. Both day view and week view pre-flatten the
  // column list into a single ordered sequence before passing it here,
  // so this widget needs no layout-mode knowledge.

  _GridHitResult? _hitTest(Offset localPosition) {
    final gridX = localPosition.dx + widget.horizontalScrollOffset;
    final gridY = localPosition.dy + widget.verticalScrollOffset;

    final totalColumns = widget.resources.length * widget.dates.length;
    final colIndex = (gridX / widget.columnWidth).floor();

    if (colIndex < 0 || colIndex >= totalColumns) return null;

    // In day view: resources.length columns, dates.length == 1
    // In week view (resourcesFirst): resources[i] × dates[j]  → col = i*nDates + j
    // In week view (daysFirst):      dates[j] × resources[i]  → col = j*nRes + i
    // The parent passes resources & dates already in column order so we just:
    //   resource = resources[colIndex % resources.length]  ... NO — parent flattens.
    //
    // Parent passes a flat `resources` list where resources[colIndex] is correct
    // for day view, and for week view the parent interleaves them.
    // See the note in the factory constructors below.
    final resource = widget.resources[colIndex];
    final date = widget.dates[colIndex];

    // Time from Y
    final hourFloat = gridY / widget.config.hourHeight;
    final rawHour = widget.config.dayStartHour + hourFloat.floor();
    final rawMinutes = ((hourFloat - hourFloat.floor()) * 60).round();

    final snappedMinutes = widget.config.enableSnapping
        ? (rawMinutes ~/ widget.config.snapToMinutes) *
              widget.config.snapToMinutes
        : rawMinutes;

    final clampedHour = rawHour.clamp(
      widget.config.dayStartHour,
      widget.config.dayEndHour - 1,
    );

    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      clampedHour,
      snappedMinutes.clamp(0, 59),
    );

    final cellAppointments = widget.controller
        .getAppointmentsForResourceDate(resource.id, date)
        .where(
          (a) =>
              a.startTime.isBefore(dateTime.add(const Duration(hours: 1))) &&
              a.endTime.isAfter(dateTime),
        )
        .toList();

    return _GridHitResult(
      resource: resource,
      date: date,
      dateTime: dateTime,
      cellAppointments: cellAppointments,
    );
  }

  // ── Drop ───────────────────────────────────────────────────────────────
  void _onDrop(DragTargetDetails<CalendarAppointment> details) {
    if (widget.onAppointmentDragEnd == null) return;

    final appointment = details.data;
    final duration = appointment.endTime.difference(appointment.startTime);

    // details.offset = global top-left of the feedback widget.
    // Convert to local (viewport) position, then apply scroll offsets.
    final box = context.findRenderObject() as RenderBox;
    final localTopLeft = box.globalToLocal(details.offset);

    // Use center of the feedback as the logical pointer
    final feedbackHeight = (duration.inMinutes / 60) * widget.config.hourHeight;
    final center = Offset(
      localTopLeft.dx + widget.columnWidth / 2,
      localTopLeft.dy + feedbackHeight / 2,
    );

    final hit = _hitTest(center);
    if (hit == null) return;

    var newStart = hit.dateTime;
    var newEnd = newStart.add(duration);

    // Clamp to day end
    final dayEnd = DateTime(
      hit.date.year,
      hit.date.month,
      hit.date.day,
      widget.config.dayEndHour,
    );
    if (newEnd.isAfter(dayEnd)) {
      newEnd = dayEnd;
      newStart = dayEnd.subtract(duration);
    }

    final oldResource = widget.controller.resources.firstWhere(
      (r) => r.id == appointment.resourceId,
      orElse: () => hit.resource,
    );

    widget.onAppointmentDragEnd!.call(
      AppointmentDragData(
        appointment: appointment,
        oldResource: oldResource,
        newResource: hit.resource,
        oldStartTime: appointment.startTime,
        oldEndTime: appointment.endTime,
        newStartTime: newStart,
        newEndTime: newEnd,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<CalendarAppointment>(
      onWillAcceptWithDetails: (_) {
        setState(() => _isDragOver = true);
        return true;
      },
      onLeave: (_) => setState(() => _isDragOver = false),
      onAcceptWithDetails: (details) {
        setState(() => _isDragOver = false);
        _onDrop(details);
      },
      builder: (context, candidateData, _) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _longPressTriggered = false,
          onTapUp: (details) {
            if (_longPressTriggered) {
              _longPressTriggered = false;
              return;
            }
            if (widget.onCellTap == null) return;
            final hit = _hitTest(details.localPosition);
            if (hit == null) return;
            widget.onCellTap!.call(
              CellTapData(
                resource: hit.resource,
                dateTime: hit.dateTime,
                globalPosition: details.globalPosition,
                appointments: hit.cellAppointments,
              ),
            );
          },
          onTapCancel: () => _longPressTriggered = false,
          onLongPressStart: (details) {
            _longPressTriggered = true;
            if (widget.onCellLongPress == null) return;
            final hit = _hitTest(details.localPosition);
            if (hit == null) return;
            widget.onCellLongPress!.call(
              CellTapData(
                resource: hit.resource,
                dateTime: hit.dateTime,
                globalPosition: details.globalPosition,
                appointments: hit.cellAppointments,
              ),
            );
          },
          child: Stack(
            children: [
              widget.child,
              if (_isDragOver)
                Positioned.fill(
                  child: IgnorePointer(
                    child: ColoredBox(color: Colors.blue.withOpacity(0.06)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _GridHitResult {
  const _GridHitResult({
    required this.resource,
    required this.date,
    required this.dateTime,
    required this.cellAppointments,
  });
  final CalendarResource resource;
  final DateTime date;
  final DateTime dateTime;
  final List<CalendarAppointment> cellAppointments;
}
