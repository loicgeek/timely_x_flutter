// lib/src/widgets/calendar_view.dart

import 'package:flutter/material.dart';
import '../models/calendar_config.dart';
import '../models/calendar_theme.dart';
import '../models/calendar_view_type.dart';
import '../controllers/calendar_controller.dart';
import '../builders/builder_delegates.dart';
import 'day_view.dart';
import 'week_view.dart';
import 'month_view.dart';

/// Main calendar widget that switches between different view types
class CalendarView extends StatelessWidget {
  const CalendarView({
    super.key,
    required this.controller,
    this.config = const CalendarConfig(),
    this.theme = const CalendarTheme(),
    this.resourceHeaderBuilder,
    this.dateHeaderBuilder,
    this.timeColumnBuilder,
    this.appointmentBuilder,
    this.emptyCellBuilder,
    this.currentTimeIndicatorBuilder,
    this.onAppointmentTap,
    this.onAppointmentLongPress,
    this.onAppointmentSecondaryTap,
    this.onCellTap,
    this.onCellLongPress,
    this.onAppointmentDragEnd,
    this.onResourceHeaderTap,
    this.onDateHeaderTap,
    this.onDateSelectionChanged,
    this.onDateRangeChanged,
  });

  final CalendarController controller;
  final CalendarConfig config;
  final CalendarTheme theme;

  // Builders
  final ResourceHeaderBuilder? resourceHeaderBuilder;
  final DateHeaderBuilder? dateHeaderBuilder;
  final TimeColumnBuilder? timeColumnBuilder;
  final AppointmentBuilder? appointmentBuilder;
  final EmptyCellBuilder? emptyCellBuilder;
  final CurrentTimeIndicatorBuilder? currentTimeIndicatorBuilder;

  // Callbacks
  final OnAppointmentTap? onAppointmentTap;
  final OnAppointmentLongPress? onAppointmentLongPress;
  final OnAppointmentSecondaryTap? onAppointmentSecondaryTap;
  final OnCellTap? onCellTap;
  final OnCellLongPress? onCellLongPress;
  final OnAppointmentDragEnd? onAppointmentDragEnd;
  final OnResourceHeaderTap? onResourceHeaderTap;
  final OnDateHeaderTap? onDateHeaderTap;

  // Date selection callbacks (month view)
  final OnDateSelectionChanged? onDateSelectionChanged;
  final OnDateRangeChanged? onDateRangeChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        switch (controller.viewType) {
          case CalendarViewType.day:
            return CalendarDayView(
              controller: controller,
              config: config,
              theme: theme,
              resourceHeaderBuilder: resourceHeaderBuilder,
              timeColumnBuilder: timeColumnBuilder,
              appointmentBuilder: appointmentBuilder,
              emptyCellBuilder: emptyCellBuilder,
              currentTimeIndicatorBuilder: currentTimeIndicatorBuilder,
              onAppointmentTap: onAppointmentTap,
              onAppointmentLongPress: onAppointmentLongPress,
              onAppointmentSecondaryTap: onAppointmentSecondaryTap,
              onCellTap: onCellTap,
              onCellLongPress: onCellLongPress,
              onAppointmentDragEnd: onAppointmentDragEnd,
              onResourceHeaderTap: onResourceHeaderTap,
            );

          case CalendarViewType.week:
            return CalendarWeekView(
              controller: controller,
              config: config,
              theme: theme,
              resourceHeaderBuilder: resourceHeaderBuilder,
              dateHeaderBuilder: dateHeaderBuilder,
              timeColumnBuilder: timeColumnBuilder,
              appointmentBuilder: appointmentBuilder,
              emptyCellBuilder: emptyCellBuilder,
              currentTimeIndicatorBuilder: currentTimeIndicatorBuilder,
              onAppointmentTap: onAppointmentTap,
              onAppointmentLongPress: onAppointmentLongPress,
              onAppointmentSecondaryTap: onAppointmentSecondaryTap,
              onCellTap: onCellTap,
              onCellLongPress: onCellLongPress,
              onAppointmentDragEnd: onAppointmentDragEnd,
              onResourceHeaderTap: onResourceHeaderTap,
              onDateHeaderTap: onDateHeaderTap,
            );

          case CalendarViewType.month:
            return CalendarMonthView(
              controller: controller,
              config: config,
              theme: theme,
              onAppointmentTap: onAppointmentTap,
              onAppointmentLongPress: onAppointmentLongPress,
              onAppointmentSecondaryTap: onAppointmentSecondaryTap,
              onCellTap: onCellTap,
              onCellLongPress: onCellLongPress,
              onDateHeaderTap: onDateHeaderTap,
              onDateSelectionChanged: onDateSelectionChanged,
              onDateRangeChanged: onDateRangeChanged,
            );
        }
      },
    );
  }
}
