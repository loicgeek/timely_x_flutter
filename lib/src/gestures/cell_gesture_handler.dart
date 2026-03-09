// ============================================================
// PATCH: Replace _CellGestureHandler in both
//   lib/src/widgets/week_view.dart
//   lib/src/widgets/day_view.dart
//
// The existing _CellGestureHandler is a plain GestureDetector.
// It never receives dropped CalendarAppointments because there
// is no DragTarget anywhere in the grid. Replace it with this
// version, which wraps the tap handling in a DragTarget so drops
// are detected on the correct cell.
// ============================================================

import 'package:flutter/material.dart';
import 'package:timely_x/timely_x.dart';

class CellGestureHandler extends StatefulWidget {
  const CellGestureHandler({
    Key? key,
    required this.cellDateTime,
    required this.cellHeight,
    required this.resource,
    required this.cellAppointments,
    required this.onCellTap,
    required this.onCellLongPress,
    required this.calculateTimeFromOffset,
    // ── NEW: drag-drop wiring ──
    required this.config,
    required this.controller,
    required this.onAppointmentDragEnd,
  }) : super(key: key);

  final DateTime cellDateTime;
  final double cellHeight;
  final CalendarResource resource;
  final List<CalendarAppointment> cellAppointments;
  final OnCellTap? onCellTap;
  final OnCellLongPress? onCellLongPress;
  final DateTime Function(DateTime, double, double) calculateTimeFromOffset;
  // NEW
  final CalendarConfig config;
  final CalendarController controller;
  final OnAppointmentDragEnd? onAppointmentDragEnd;

  @override
  State<CellGestureHandler> createState() => _CellGestureHandlerState();
}

class _CellGestureHandlerState extends State<CellGestureHandler> {
  bool _longPressTriggered = false;
  bool _isDragOver = false;

  // ── Drop logic ──────────────────────────────────────────────────────────
  //
  // details.offset is the global position of the pointer at drop time.
  // We convert it to a local offset within this cell to calculate the
  // exact drop time, then snap and fire onAppointmentDragEnd.
  void _handleDrop(DragTargetDetails<CalendarAppointment> details) {
    final appointment = details.data;

    // Convert global drop position → local offset within this cell widget
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localOffset = box.globalToLocal(details.offset);

    // Calculate the drop time from the y-position within this cell
    DateTime dropTime = widget.calculateTimeFromOffset(
      widget.cellDateTime,
      localOffset.dy.clamp(0.0, widget.cellHeight),
      widget.cellHeight,
    );

    // Preserve the original appointment duration
    final duration = appointment.endTime.difference(appointment.startTime);
    final newEndTime = dropTime.add(duration);

    // Find the old resource (needed for AppointmentDragData)
    final oldResource = widget.controller.resources.firstWhere(
      (r) => r.id == appointment.resourceId,
      orElse: () => widget.resource,
    );

    widget.onAppointmentDragEnd?.call(
      AppointmentDragData(
        appointment: appointment,
        oldResource: oldResource,
        newResource: widget.resource,
        oldStartTime: appointment.startTime,
        oldEndTime: appointment.endTime,
        newStartTime: dropTime,
        newEndTime: newEndTime,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<CalendarAppointment>(
      onWillAcceptWithDetails: (details) {
        // Accept any CalendarAppointment dragged over this cell
        setState(() => _isDragOver = true);
        return true;
      },
      onLeave: (_) => setState(() => _isDragOver = false),
      onAcceptWithDetails: (details) {
        setState(() => _isDragOver = false);
        _handleDrop(details);
      },
      builder: (context, candidateData, rejectedData) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _longPressTriggered = false,
          onTapUp: (details) {
            if (_longPressTriggered) {
              _longPressTriggered = false;
              return;
            }
            if (widget.onCellTap == null) return;
            final exactDateTime = widget.calculateTimeFromOffset(
              widget.cellDateTime,
              details.localPosition.dy,
              widget.cellHeight,
            );
            widget.onCellTap!.call(
              CellTapData(
                resource: widget.resource,
                dateTime: exactDateTime,
                globalPosition: details.globalPosition,
                appointments: widget.cellAppointments,
              ),
            );
          },
          onTapCancel: () => _longPressTriggered = false,
          onLongPressStart: (details) {
            _longPressTriggered = true;
            if (widget.onCellLongPress == null) return;
            final exactDateTime = widget.calculateTimeFromOffset(
              widget.cellDateTime,
              details.localPosition.dy,
              widget.cellHeight,
            );
            widget.onCellLongPress!.call(
              CellTapData(
                resource: widget.resource,
                dateTime: exactDateTime,
                globalPosition: details.globalPosition,
                appointments: widget.cellAppointments,
              ),
            );
          },
          child: Container(
            // Subtle drag-over highlight so users see where they'll drop
            color: _isDragOver
                ? Colors.blue.withOpacity(0.08)
                : Colors.transparent,
          ),
        );
      },
    );
  }
}
