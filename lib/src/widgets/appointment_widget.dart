// lib/src/widgets/appointment_widget.dart

import 'package:flutter/material.dart';
import '../models/calendar_appointment.dart';
import '../models/calendar_resource.dart';
import '../models/appointment_position.dart';
import '../models/calendar_theme.dart';
import '../models/interaction_data.dart';
import '../builders/builder_delegates.dart';
import '../builders/default_builders.dart';

class AppointmentWidget extends StatefulWidget {
  const AppointmentWidget({
    Key? key,
    required this.position,
    required this.resource,
    required this.theme,
    required this.isSelected,
    this.builder,
    this.onTap,
    this.onLongPress,
    this.onSecondaryTap,
    this.enableDrag = true,
  }) : super(key: key);

  final AppointmentPosition position;
  final CalendarResource resource;
  final CalendarTheme theme;
  final bool isSelected;
  final AppointmentBuilder? builder;
  final OnAppointmentTap? onTap;
  final OnAppointmentLongPress? onLongPress;
  final OnAppointmentSecondaryTap? onSecondaryTap;
  final bool enableDrag;

  @override
  State<AppointmentWidget> createState() => _AppointmentWidgetState();
}

class _AppointmentWidgetState extends State<AppointmentWidget> {
  bool _isDragging = false;

  void _onDragStarted() {
    setState(() => _isDragging = true);
    // onLongPress fires here because LongPressDraggable owns the long-press
    // gesture — a separate GestureDetector.onLongPress on the same node
    // would compete and cause double-fires.
    widget.onLongPress?.call(
      AppointmentLongPressData(
        appointment: widget.position.appointment,
        resource: widget.resource,
        globalPosition: Offset.zero,
      ),
    );
  }

  void _onDragEnd(DraggableDetails _) => setState(() => _isDragging = false);
  void _onDraggableCanceled(Velocity _, Offset __) =>
      setState(() => _isDragging = false);

  @override
  Widget build(BuildContext context) {
    final rect = widget.position.adjustedRect;
    final width = rect.width - widget.theme.appointmentMargin.right;
    final height = rect.height - widget.theme.appointmentMargin.bottom;

    Widget content = _buildVisual(rect);

    // ── Tap + secondary tap ──────────────────────────────────────────────
    content = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (details) {
        if (_isDragging) return;
        widget.onTap?.call(
          AppointmentTapData(
            appointment: widget.position.appointment,
            resource: widget.resource,
            // Use the real global position so overlays anchor correctly
            globalPosition: details.globalPosition,
          ),
        );
      },
      onSecondaryTapUp: (details) {
        widget.onSecondaryTap?.call(
          AppointmentSecondaryTapData(
            appointment: widget.position.appointment,
            resource: widget.resource,
            globalPosition: details.globalPosition,
          ),
        );
      },
      child: content,
    );

    // ── Drag ─────────────────────────────────────────────────────────────
    if (widget.enableDrag) {
      content = LongPressDraggable<CalendarAppointment>(
        data: widget.position.appointment,
        feedback: _buildDragFeedback(width, height),
        childWhenDragging: _buildDragPlaceholder(),
        onDragStarted: _onDragStarted,
        onDragEnd: _onDragEnd,
        onDraggableCanceled: _onDraggableCanceled,
        child: content,
      );
    }

    // ── Hover cursor (desktop/web) ────────────────────────────────────────
    content = MouseRegion(
      cursor: _isDragging
          ? SystemMouseCursors.grabbing
          : SystemMouseCursors.click,
      child: content,
    );

    return Positioned(
      left: rect.left,
      top: rect.top,
      width: width,
      height: height,
      child: content,
    );
  }

  Widget _buildVisual(Rect rect) {
    if (widget.builder != null) {
      return widget.builder!.call(
        context,
        widget.position.appointment,
        widget.resource,
        rect,
        widget.isSelected,
      );
    }
    return DefaultBuilders.appointment(
      context: context,
      appointment: widget.position.appointment,
      resource: widget.resource,
      rect: rect,
      isSelected: widget.isSelected,
      theme: widget.theme,
    );
  }

  Widget _buildDragFeedback(double width, double height) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(widget.theme.appointmentBorderRadius),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: widget.position.appointment.color.withOpacity(
            widget.theme.dragFeedbackOpacity,
          ),
          borderRadius: BorderRadius.circular(
            widget.theme.appointmentBorderRadius,
          ),
        ),
        padding: widget.theme.appointmentPadding,
        child: Text(
          widget.position.appointment.title,
          style: widget.theme.appointmentTextStyle,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildDragPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: widget.theme.gridBackgroundColor.withOpacity(
          widget.theme.dragPlaceholderOpacity,
        ),
        borderRadius: BorderRadius.circular(
          widget.theme.appointmentBorderRadius,
        ),
        border: Border.all(
          color: widget.theme.dragPlaceholderBorderColor,
          width: widget.theme.dragPlaceholderBorderWidth,
        ),
      ),
    );
  }
}
