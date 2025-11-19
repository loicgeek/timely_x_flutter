// lib/src/widgets/appointment_widget.dart (PROPERLY FIXED)

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
  Offset? _dragOffset;

  @override
  Widget build(BuildContext context) {
    final rect = widget.position.adjustedRect;

    if (widget.enableDrag) {
      // When draggable, use LongPressDraggable which doesn't interfere with Positioned
      return Positioned(
        left: rect.left,
        top: rect.top,
        width: rect.width - widget.theme.appointmentMargin.right,
        height: rect.height - widget.theme.appointmentMargin.bottom,
        child: LongPressDraggable<CalendarAppointment>(
          data: widget.position.appointment,
          feedback: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(
              widget.theme.appointmentBorderRadius,
            ),
            child: Container(
              width: rect.width - widget.theme.appointmentMargin.right,
              height: rect.height - widget.theme.appointmentMargin.bottom,
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
          ),
          childWhenDragging: Container(
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
                style: BorderStyle.solid,
              ),
            ),
          ),
          onDragStarted: () {
            setState(() => _isDragging = true);
          },
          onDragEnd: (_) {
            setState(() => _isDragging = false);
          },
          onDraggableCanceled: (_, __) {
            setState(() => _isDragging = false);
          },
          child: _buildAppointmentContent(rect),
        ),
      );
    }

    // When not draggable, simple positioned widget
    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width - widget.theme.appointmentMargin.right,
      height: rect.height - widget.theme.appointmentMargin.bottom,
      child: _buildAppointmentContent(rect),
    );
  }

  Widget _buildAppointmentContent(Rect rect) {
    return GestureDetector(
      onTap: () {
        widget.onTap?.call(
          AppointmentTapData(
            appointment: widget.position.appointment,
            resource: widget.resource,
            globalPosition: Offset.zero,
          ),
        );
      },
      onLongPress: () {
        widget.onLongPress?.call(
          AppointmentLongPressData(
            appointment: widget.position.appointment,
            resource: widget.resource,
            globalPosition: Offset.zero,
          ),
        );
      },
      onSecondaryTap: () {
        widget.onSecondaryTap?.call(
          AppointmentSecondaryTapData(
            appointment: widget.position.appointment,
            resource: widget.resource,
            globalPosition: Offset.zero,
          ),
        );
      },
      child:
          widget.builder?.call(
            context,
            widget.position.appointment,
            widget.resource,
            rect,
            widget.isSelected,
          ) ??
          DefaultBuilders.appointment(
            context,
            widget.position.appointment,
            widget.resource,
            rect,
            widget.isSelected,
            widget.theme,
          ),
    );
  }
}
