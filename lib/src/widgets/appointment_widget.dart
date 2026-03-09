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
  bool _isHovered = false;

  void _onDragStarted() {
    // Synchronously reset ALL interaction state before the pointer is claimed
    // by LongPressDraggable. This ensures:
    //  - MouseRegion.onExit will never fire on a stale "hovered" child
    //  - The custom builder sees isDragging=true on its very next frame
    //  - Any overlay the app layer manages gets the signal to close
    setState(() {
      _isDragging = true;
      _isHovered = false;
    });

    // Fire onLongPress here — LongPressDraggable consumes the long-press
    // gesture itself so we cannot attach a separate GestureDetector.onLongPress
    // on the same node without them competing.
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

  void _onTap() {
    if (_isDragging) return;
    widget.onTap?.call(
      AppointmentTapData(
        appointment: widget.position.appointment,
        resource: widget.resource,
        globalPosition: Offset.zero,
      ),
    );
  }

  void _onSecondaryTap() {
    widget.onSecondaryTap?.call(
      AppointmentSecondaryTapData(
        appointment: widget.position.appointment,
        resource: widget.resource,
        globalPosition: Offset.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rect = widget.position.adjustedRect;
    final width = rect.width - widget.theme.appointmentMargin.right;
    final height = rect.height - widget.theme.appointmentMargin.bottom;

    return Positioned(
      left: rect.left,
      top: rect.top,
      width: width,
      height: height,
      child: _buildGestureLayer(rect, width, height),
    );
  }

  // ---------------------------------------------------------------------------
  // Gesture / interaction layer — fully owned by the library.
  //
  // Stack from outermost to innermost:
  //   MouseRegion      — hover tracking, cursor, resets on drag
  //   LongPressDraggable — drag initiation; fires onLongPress on start
  //   GestureDetector  — tap, secondary tap
  //   _buildVisual     — pure display, no gesture logic
  //
  // The custom builder is a pure visual. It receives the appointment,
  // resource, rect, and isSelected — same as before. It must NOT attach
  // its own MouseRegion or GestureDetector because the library layer above
  // already handles all of that.
  // ---------------------------------------------------------------------------
  Widget _buildGestureLayer(Rect rect, double width, double height) {
    // 1. Pure visual (innermost)
    Widget child = _buildVisual(rect);

    // 2. Tap + secondary tap
    child = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      onSecondaryTap: _onSecondaryTap,
      child: child,
    );

    // 3. Drag
    if (widget.enableDrag) {
      child = LongPressDraggable<CalendarAppointment>(
        data: widget.position.appointment,
        feedback: _buildDragFeedback(width, height),
        childWhenDragging: _buildDragPlaceholder(),
        onDragStarted: _onDragStarted,
        onDragEnd: _onDragEnd,
        onDraggableCanceled: _onDraggableCanceled,
        child: child,
      );
    }

    // 4. Hover (outermost — sees enter/exit before drag claims the pointer)
    child = MouseRegion(
      cursor: _isDragging
          ? SystemMouseCursors.grabbing
          : SystemMouseCursors.click,
      onEnter: (_) {
        if (!_isDragging) setState(() => _isHovered = true);
      },
      onExit: (_) => setState(() => _isHovered = false),
      child: child,
    );

    return child;
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
