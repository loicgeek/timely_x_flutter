// lib/src/builders/builder_delegates.dart

import 'package:flutter/material.dart';
import '../models/calendar_appointment.dart';
import '../models/calendar_resource.dart';
import '../models/interaction_data.dart';

/// Builder for resource header
typedef ResourceHeaderBuilder =
    Widget Function({
      required BuildContext context,
      required CalendarResource resource,
      required double width,
      required bool isHovered,
      required int appointmentsCount,
    });

/// Builder for date header
typedef DateHeaderBuilder =
    Widget Function(
      BuildContext context,
      DateTime date,
      double width,
      bool isToday,
    );

/// Builder for time label
typedef TimeColumnBuilder =
    Widget Function(
      BuildContext context,
      DateTime time,
      double height,
      bool isHourMark,
    );

/// Builder for appointment
typedef AppointmentBuilder =
    Widget Function(
      BuildContext context,
      CalendarAppointment appointment,
      CalendarResource resource,
      Rect rect,
      bool isSelected,
    );

/// Builder for empty cell
typedef EmptyCellBuilder =
    Widget? Function(
      BuildContext context,
      CalendarResource resource,
      DateTime dateTime,
      Rect rect,
    );

/// Builder for current time indicator
typedef CurrentTimeIndicatorBuilder =
    Widget Function(BuildContext context, double width);

/// Callbacks for interactions
typedef OnAppointmentTap = void Function(AppointmentTapData data);
typedef OnAppointmentLongPress = void Function(AppointmentLongPressData data);
typedef OnAppointmentSecondaryTap =
    void Function(AppointmentSecondaryTapData data);
typedef OnCellTap = void Function(CellTapData data);
typedef OnCellLongPress = void Function(CellTapData data);
typedef OnAppointmentDragEnd = void Function(AppointmentDragData data);
typedef OnAppointmentResizeEnd = void Function(AppointmentResizeData data);
typedef OnResourceHeaderTap = void Function(ResourceHeaderTapData data);
typedef OnDateHeaderTap = void Function(DateHeaderTapData data);

/// Callbacks for date selection (month view)
typedef OnDateSelectionChanged = void Function(Set<DateTime> selectedDates);
typedef OnDateRangeChanged =
    void Function(DateTime? start, DateTime? end, Set<DateTime> selectedDates);
