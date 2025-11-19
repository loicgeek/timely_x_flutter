// lib/src/models/calendar_theme.dart

import 'package:flutter/material.dart';

/// Theme configuration for the calendar
class CalendarTheme {
  const CalendarTheme({
    // Grid colors
    this.gridLineColor = const Color(0xFFE5E5E5),
    this.hourLineColor = const Color(0xFFCCCCCC),
    this.zebraStripeOdd = const Color(0xFFFAFAFA),
    this.zebraStripeEven = Colors.white,
    this.currentDayHighlight = const Color(0xFFE3F2FD),
    this.currentTimeIndicatorColor = const Color(0xFFFF5252),
    this.selectedSlotColor = const Color(0xFFBBDEFB),
    this.hoverColor = const Color(0xFFF5F5F5),
    this.weekendColor = const Color(0xFFFAFAFA),
    this.weekendTextColor = const Color(0xFFD32F2F),
    this.todayHighlightColor = const Color(0xFF2196F3),
    this.otherMonthDayColor = const Color(0xFFBDBDBD),

    // Date selection colors (for month view)
    this.selectedDateBackgroundColor = const Color(0xFF2196F3),
    this.selectedDateTextColor = Colors.white,
    this.selectedDateBorderColor = const Color(0xFF1976D2),
    this.rangeSelectionColor = const Color(0xFFBBDEFB),
    this.rangeSelectionBorderColor = const Color(0xFF90CAF9),

    // Background colors
    this.headerBackgroundColor = Colors.white,
    this.gridBackgroundColor = Colors.white,
    this.timeColumnBackgroundColor = Colors.white,
    this.otherMonthGridBackgroundColor = Colors.white,

    // Text styles
    this.timeTextStyle = const TextStyle(
      fontSize: 13,
      color: Color(0xFF666666),
    ),
    this.resourceNameStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Color(0xFF212121),
    ),
    this.dateTextStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Color(0xFF212121),
    ),
    this.weekdayTextStyle = const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Color(0xFF757575),
    ),
    this.appointmentTextStyle = const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),
    this.appointmentSubtitleStyle = const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: Colors.white70,
    ),
    this.appointmentTimeStyle = const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w400,
      color: Colors.white70,
    ),
    this.monthViewDayTextStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Color(0xFF212121),
    ),
    this.monthViewAppointmentTextStyle = const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w400,
      color: Colors.white,
    ),

    // Date format patterns
    this.timeFormat = 'HH:mm',
    this.dateFormat = 'd',
    this.weekdayFormat = 'E',
    this.monthFormat = 'MMMM yyyy',
    this.dateHeaderFormat = 'MMMM d, yyyy',
    this.weekPeriodFormat = 'MMM d',

    // Spacing and sizing
    this.resourceHeaderPadding = const EdgeInsets.symmetric(
      vertical: 12,
      horizontal: 8,
    ),
    this.dateHeaderPadding = const EdgeInsets.symmetric(vertical: 8),
    this.appointmentPadding = const EdgeInsets.all(4),
    this.appointmentMargin = const EdgeInsets.only(right: 4, bottom: 2),
    this.timeLabelPadding = const EdgeInsets.only(top: 4, right: 8),
    this.resourceAvatarRadius = 20.0,
    this.appointmentSpacing = 2.0,

    // Month view specific
    this.monthViewHeaderHeight = 40.0,
    this.monthViewHeaderBackgroundColor = const Color(0xFFF5F5F5),
    this.monthViewCellPadding = const EdgeInsets.all(4),
    this.monthViewCellAspectRatio = 1.2,
    this.monthViewAppointmentMargin = const EdgeInsets.only(bottom: 2),
    this.monthViewAppointmentPadding = const EdgeInsets.symmetric(
      horizontal: 4,
      vertical: 2,
    ),
    this.monthViewAppointmentBorderRadius = 2.0,
    this.monthViewMaxVisibleAppointments = 3,
    this.monthViewMoreTextStyle = const TextStyle(
      fontSize: 10,
      color: Color(0xFF757575),
    ),

    // Decorations
    this.appointmentBorderRadius = 4.0,
    this.appointmentShadow = const [
      BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 2)),
    ],
    this.headerShadow = const [
      BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1)),
    ],

    // Drag and drop
    this.dragFeedbackOpacity = 0.8,
    this.dragPlaceholderOpacity = 0.3,
    this.dragPlaceholderBorderColor = const Color(0x80000000),
    this.dragPlaceholderBorderWidth = 2.0,
  });

  // Grid colors
  final Color gridLineColor;
  final Color hourLineColor;
  final Color zebraStripeOdd;
  final Color zebraStripeEven;
  final Color currentDayHighlight;
  final Color currentTimeIndicatorColor;
  final Color selectedSlotColor;
  final Color hoverColor;
  final Color weekendColor;
  final Color weekendTextColor;
  final Color todayHighlightColor;
  final Color otherMonthDayColor;

  // Date selection colors (for month view)
  final Color selectedDateBackgroundColor;
  final Color selectedDateTextColor;
  final Color selectedDateBorderColor;
  final Color rangeSelectionColor;
  final Color rangeSelectionBorderColor;

  // Background colors
  final Color headerBackgroundColor;
  final Color gridBackgroundColor;
  final Color otherMonthGridBackgroundColor;
  final Color timeColumnBackgroundColor;

  // Text styles
  final TextStyle timeTextStyle;
  final TextStyle resourceNameStyle;
  final TextStyle dateTextStyle;
  final TextStyle weekdayTextStyle;
  final TextStyle appointmentTextStyle;
  final TextStyle appointmentSubtitleStyle;
  final TextStyle appointmentTimeStyle;
  final TextStyle monthViewDayTextStyle;
  final TextStyle monthViewAppointmentTextStyle;
  final TextStyle monthViewMoreTextStyle;

  // Date format patterns
  final String timeFormat;
  final String dateFormat;
  final String weekdayFormat;
  final String monthFormat;
  final String dateHeaderFormat;
  final String weekPeriodFormat;

  // Spacing and sizing
  final EdgeInsets resourceHeaderPadding;
  final EdgeInsets dateHeaderPadding;
  final EdgeInsets appointmentPadding;
  final EdgeInsets appointmentMargin;
  final EdgeInsets timeLabelPadding;
  final double resourceAvatarRadius;
  final double appointmentSpacing;

  // Month view specific
  final double monthViewHeaderHeight;
  final Color monthViewHeaderBackgroundColor;
  final EdgeInsets monthViewCellPadding;
  final double monthViewCellAspectRatio;
  final EdgeInsets monthViewAppointmentMargin;
  final EdgeInsets monthViewAppointmentPadding;
  final double monthViewAppointmentBorderRadius;
  final int monthViewMaxVisibleAppointments;

  // Decorations
  final double appointmentBorderRadius;
  final List<BoxShadow> appointmentShadow;
  final List<BoxShadow> headerShadow;

  // Drag and drop
  final double dragFeedbackOpacity;
  final double dragPlaceholderOpacity;
  final Color dragPlaceholderBorderColor;
  final double dragPlaceholderBorderWidth;

  CalendarTheme copyWith({
    Color? gridLineColor,
    Color? hourLineColor,
    Color? zebraStripeOdd,
    Color? zebraStripeEven,
    Color? currentDayHighlight,
    Color? currentTimeIndicatorColor,
    Color? selectedSlotColor,
    Color? hoverColor,
    Color? weekendColor,
    Color? weekendTextColor,
    Color? todayHighlightColor,
    Color? otherMonthDayColor,
    Color? selectedDateBackgroundColor,
    Color? selectedDateTextColor,
    Color? selectedDateBorderColor,
    Color? rangeSelectionColor,
    Color? rangeSelectionBorderColor,
    Color? headerBackgroundColor,
    Color? gridBackgroundColor,
    Color? timeColumnBackgroundColor,
    TextStyle? timeTextStyle,
    TextStyle? resourceNameStyle,
    TextStyle? dateTextStyle,
    TextStyle? weekdayTextStyle,
    TextStyle? appointmentTextStyle,
    TextStyle? appointmentSubtitleStyle,
    TextStyle? appointmentTimeStyle,
    TextStyle? monthViewDayTextStyle,
    TextStyle? monthViewAppointmentTextStyle,
    TextStyle? monthViewMoreTextStyle,
    String? timeFormat,
    String? dateFormat,
    String? weekdayFormat,
    String? monthFormat,
    String? dateHeaderFormat,
    String? weekPeriodFormat,
    EdgeInsets? resourceHeaderPadding,
    EdgeInsets? dateHeaderPadding,
    EdgeInsets? appointmentPadding,
    EdgeInsets? appointmentMargin,
    EdgeInsets? timeLabelPadding,
    double? resourceAvatarRadius,
    double? appointmentSpacing,
    double? monthViewHeaderHeight,
    Color? monthViewHeaderBackgroundColor,
    EdgeInsets? monthViewCellPadding,
    double? monthViewCellAspectRatio,
    EdgeInsets? monthViewAppointmentMargin,
    EdgeInsets? monthViewAppointmentPadding,
    double? monthViewAppointmentBorderRadius,
    int? monthViewMaxVisibleAppointments,
    double? appointmentBorderRadius,
    List<BoxShadow>? appointmentShadow,
    List<BoxShadow>? headerShadow,
    double? dragFeedbackOpacity,
    double? dragPlaceholderOpacity,
    Color? dragPlaceholderBorderColor,
    double? dragPlaceholderBorderWidth,
  }) {
    return CalendarTheme(
      gridLineColor: gridLineColor ?? this.gridLineColor,
      hourLineColor: hourLineColor ?? this.hourLineColor,
      zebraStripeOdd: zebraStripeOdd ?? this.zebraStripeOdd,
      zebraStripeEven: zebraStripeEven ?? this.zebraStripeEven,
      currentDayHighlight: currentDayHighlight ?? this.currentDayHighlight,
      currentTimeIndicatorColor:
          currentTimeIndicatorColor ?? this.currentTimeIndicatorColor,
      selectedSlotColor: selectedSlotColor ?? this.selectedSlotColor,
      hoverColor: hoverColor ?? this.hoverColor,
      weekendColor: weekendColor ?? this.weekendColor,
      weekendTextColor: weekendTextColor ?? this.weekendTextColor,
      todayHighlightColor: todayHighlightColor ?? this.todayHighlightColor,
      otherMonthDayColor: otherMonthDayColor ?? this.otherMonthDayColor,
      selectedDateBackgroundColor:
          selectedDateBackgroundColor ?? this.selectedDateBackgroundColor,
      selectedDateTextColor:
          selectedDateTextColor ?? this.selectedDateTextColor,
      selectedDateBorderColor:
          selectedDateBorderColor ?? this.selectedDateBorderColor,
      rangeSelectionColor: rangeSelectionColor ?? this.rangeSelectionColor,
      rangeSelectionBorderColor:
          rangeSelectionBorderColor ?? this.rangeSelectionBorderColor,
      headerBackgroundColor:
          headerBackgroundColor ?? this.headerBackgroundColor,
      gridBackgroundColor: gridBackgroundColor ?? this.gridBackgroundColor,
      timeColumnBackgroundColor:
          timeColumnBackgroundColor ?? this.timeColumnBackgroundColor,
      timeTextStyle: timeTextStyle ?? this.timeTextStyle,
      resourceNameStyle: resourceNameStyle ?? this.resourceNameStyle,
      dateTextStyle: dateTextStyle ?? this.dateTextStyle,
      weekdayTextStyle: weekdayTextStyle ?? this.weekdayTextStyle,
      appointmentTextStyle: appointmentTextStyle ?? this.appointmentTextStyle,
      appointmentSubtitleStyle:
          appointmentSubtitleStyle ?? this.appointmentSubtitleStyle,
      appointmentTimeStyle: appointmentTimeStyle ?? this.appointmentTimeStyle,
      monthViewDayTextStyle:
          monthViewDayTextStyle ?? this.monthViewDayTextStyle,
      monthViewAppointmentTextStyle:
          monthViewAppointmentTextStyle ?? this.monthViewAppointmentTextStyle,
      monthViewMoreTextStyle:
          monthViewMoreTextStyle ?? this.monthViewMoreTextStyle,
      timeFormat: timeFormat ?? this.timeFormat,
      dateFormat: dateFormat ?? this.dateFormat,
      weekdayFormat: weekdayFormat ?? this.weekdayFormat,
      monthFormat: monthFormat ?? this.monthFormat,
      dateHeaderFormat: dateHeaderFormat ?? this.dateHeaderFormat,
      weekPeriodFormat: weekPeriodFormat ?? this.weekPeriodFormat,
      resourceHeaderPadding:
          resourceHeaderPadding ?? this.resourceHeaderPadding,
      dateHeaderPadding: dateHeaderPadding ?? this.dateHeaderPadding,
      appointmentPadding: appointmentPadding ?? this.appointmentPadding,
      appointmentMargin: appointmentMargin ?? this.appointmentMargin,
      timeLabelPadding: timeLabelPadding ?? this.timeLabelPadding,
      resourceAvatarRadius: resourceAvatarRadius ?? this.resourceAvatarRadius,
      appointmentSpacing: appointmentSpacing ?? this.appointmentSpacing,
      monthViewHeaderHeight:
          monthViewHeaderHeight ?? this.monthViewHeaderHeight,
      monthViewHeaderBackgroundColor:
          monthViewHeaderBackgroundColor ?? this.monthViewHeaderBackgroundColor,
      monthViewCellPadding: monthViewCellPadding ?? this.monthViewCellPadding,
      monthViewCellAspectRatio:
          monthViewCellAspectRatio ?? this.monthViewCellAspectRatio,
      monthViewAppointmentMargin:
          monthViewAppointmentMargin ?? this.monthViewAppointmentMargin,
      monthViewAppointmentPadding:
          monthViewAppointmentPadding ?? this.monthViewAppointmentPadding,
      monthViewAppointmentBorderRadius:
          monthViewAppointmentBorderRadius ??
          this.monthViewAppointmentBorderRadius,
      monthViewMaxVisibleAppointments:
          monthViewMaxVisibleAppointments ??
          this.monthViewMaxVisibleAppointments,
      appointmentBorderRadius:
          appointmentBorderRadius ?? this.appointmentBorderRadius,
      appointmentShadow: appointmentShadow ?? this.appointmentShadow,
      headerShadow: headerShadow ?? this.headerShadow,
      dragFeedbackOpacity: dragFeedbackOpacity ?? this.dragFeedbackOpacity,
      dragPlaceholderOpacity:
          dragPlaceholderOpacity ?? this.dragPlaceholderOpacity,
      dragPlaceholderBorderColor:
          dragPlaceholderBorderColor ?? this.dragPlaceholderBorderColor,
      dragPlaceholderBorderWidth:
          dragPlaceholderBorderWidth ?? this.dragPlaceholderBorderWidth,
    );
  }
}
