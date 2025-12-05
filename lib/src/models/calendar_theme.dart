// lib/src/models/calendar_theme.dart

import 'package:calendar2/src/models/business_hours.dart';
import 'package:flutter/material.dart';

class CalendarScrollbarTheme {
  final double scrollbarThickness;
  final double scrollbarMinThumbLength;
  final Radius scrollbarRadius;
  final Color scrollbarThumbColor;
  final Color scrollbarTrackColor;
  final Color scrollbarTrackBorderColor;
  final bool scrollbarAlwaysVisible;
  final EdgeInsets scrollbarPadding;

  const CalendarScrollbarTheme({
    this.scrollbarThickness = 8.0,
    this.scrollbarMinThumbLength = 48.0,
    this.scrollbarRadius = const Radius.circular(4.0),
    this.scrollbarThumbColor = const Color(0xFF9E9E9E),
    this.scrollbarTrackColor = const Color(0xFFE0E0E0),
    this.scrollbarTrackBorderColor = const Color(0xFFBDBDBD),
    this.scrollbarAlwaysVisible = true,
    this.scrollbarPadding = const EdgeInsets.only(right: 2.0),
  });
}

class CalendarAppointmentCountBadgeTheme {
  final TextStyle? appointmentCountTextStyle;
  final Color? appointmentCountBackgroundColor;
  final Color? appointmentCountBorderColor;
  final EdgeInsets? appointmentCountPadding;
  final double? appointmentCountBorderRadius;
  final bool? appointmentCountShowBadge;

  final Function(BuildContext context, int count)? appointmentCountBuilder;

  const CalendarAppointmentCountBadgeTheme({
    this.appointmentCountTextStyle,
    this.appointmentCountBackgroundColor,
    this.appointmentCountBorderColor,
    this.appointmentCountPadding,
    this.appointmentCountBorderRadius,
    this.appointmentCountShowBadge,
    this.appointmentCountBuilder,
  });
}

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

    // Agenda view

    // Colors (7 properties)
    this.agendaItemBackgroundColor = Colors.white,
    this.agendaItemHoverColor = const Color(0xFFF5F5F5),
    this.agendaItemSelectedColor = const Color(0xFFE3F2FD),
    this.agendaDateHeaderBackgroundColor = const Color(0xFFF5F5F5),
    this.agendaResourceHeaderBackgroundColor = const Color(0xFFFAFAFA),
    this.agendaDividerColor = const Color(0xFFE0E0E0),
    this.agendaEmptyBackgroundColor = const Color(0xFFFAFAFA),

    // Text Styles (8 properties)
    this.agendaDateHeaderTextStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    ),
    this.agendaResourceHeaderTextStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    this.agendaTimeTextStyle = const TextStyle(
      fontSize: 12,
      color: Colors.black54,
    ),
    this.agendaTitleTextStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    this.agendaSubtitleTextStyle = const TextStyle(
      fontSize: 12,
      color: Colors.black54,
    ),
    this.agendaDurationTextStyle = const TextStyle(
      fontSize: 11,
      color: Colors.black45,
    ),
    this.agendaResourceNameTextStyle = const TextStyle(fontSize: 12),
    this.agendaEmptyTextStyle = const TextStyle(
      fontSize: 14,
      color: Colors.black45,
    ),

    // Date Formats (3 properties)
    this.agendaDateHeaderFormat = 'EEEE, MMMM d', // "Monday, November 18"
    this.agendaTimeFormat = 'h:mm a', // "2:30 PM"
    this.agendaDurationFormat = 'H:mm', // "1:30"
    // Spacing (8 properties)
    this.agendaDateHeaderPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
    this.agendaResourceHeaderPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 10,
    ),
    this.agendaItemPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
    this.agendaItemMargin = EdgeInsets.zero,
    this.agendaTimeToTitleSpacing = 12.0,
    this.agendaTitleToSubtitleSpacing = 4.0,
    this.agendaResourceAvatarRadius = 16.0,
    this.agendaAvatarSpacing = 12.0,

    // Decorations (5 properties)
    this.agendaItemBorderRadius = 0.0,
    this.agendaItemShadow = const [
      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
    ],
    this.agendaDividerThickness = 1.0,
    this.agendaDividerIndent = 16.0,
    this.agendaDividerEndIndent = 0.0,

    // Indicators (4 properties)
    this.agendaStatusIndicatorSize = 8.0,
    this.agendaShowColorBar = true,
    this.agendaColorBarWidth = 4.0,
    this.agendaShowStatusIndicator = false,

    // Unavailability style
    this.unavailabilityStyle,

    // Scrollbar theme
    this.scrollbarTheme = const CalendarScrollbarTheme(),

    // Appointment count badge theme
    this.appointmentCountBadgeTheme,
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

  // Agenda view specific theme properties (add to CalendarTheme)

  // ============================================================================
  // Agenda View Colors (7 properties)
  // ============================================================================

  /// Background color for agenda list items
  /// Default: Colors.white
  final Color? agendaItemBackgroundColor;

  /// Hover color for agenda list items
  /// Default: Color(0xFFF5F5F5)
  final Color? agendaItemHoverColor;

  /// Background color for selected agenda items
  /// Default: Color(0xFFE3F2FD)
  final Color? agendaItemSelectedColor;

  /// Background color for date group headers
  /// Default: Color(0xFFF5F5F5)
  final Color? agendaDateHeaderBackgroundColor;

  /// Background color for resource group headers
  /// Default: Color(0xFFFAFAFA)
  final Color? agendaResourceHeaderBackgroundColor;

  /// Divider color between agenda items
  /// Default: Color(0xFFE0E0E0)
  final Color? agendaDividerColor;

  /// Background color for empty state
  /// Default: Color(0xFFFAFAFA)
  final Color? agendaEmptyBackgroundColor;

  // ============================================================================
  // Agenda View Text Styles (6 properties)
  // ============================================================================

  /// Text style for date group headers (e.g., "Monday, Nov 21")
  /// Default: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)
  final TextStyle? agendaDateHeaderTextStyle;

  /// Text style for resource group headers
  /// Default: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)
  final TextStyle? agendaResourceHeaderTextStyle;

  /// Text style for appointment time in agenda items
  /// Default: TextStyle(fontSize: 12, color: Colors.black54)
  final TextStyle? agendaTimeTextStyle;

  /// Text style for appointment title in agenda items
  /// Default: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)
  final TextStyle? agendaTitleTextStyle;

  /// Text style for appointment subtitle/location
  /// Default: TextStyle(fontSize: 12, color: Colors.black54)
  final TextStyle? agendaSubtitleTextStyle;

  /// Text style for appointment duration
  /// Default: TextStyle(fontSize: 11, color: Colors.black45)
  final TextStyle? agendaDurationTextStyle;

  /// Text style for resource name when shown in items
  /// Default: TextStyle(fontSize: 12, color: Colors.black54)
  final TextStyle? agendaResourceNameTextStyle;

  /// Text style for empty state message
  /// Default: TextStyle(fontSize: 14, color: Colors.black45)
  final TextStyle? agendaEmptyTextStyle;

  // ============================================================================
  // Agenda View Date Formats (3 properties)
  // ============================================================================

  /// Format for date headers in agenda view
  /// Default: 'EEEE, MMMM d' (e.g., "Monday, November 21")
  final String? agendaDateHeaderFormat;

  /// Format for time display in agenda items
  /// Default: 'h:mm a' (e.g., "2:30 PM")
  final String? agendaTimeFormat;

  /// Format for duration display
  /// Default: 'H:mm' (e.g., "1:30" for 1 hour 30 minutes)
  final String? agendaDurationFormat;

  // ============================================================================
  // Agenda View Spacing (8 properties)
  // ============================================================================

  /// Padding for date group headers
  /// Default: EdgeInsets.symmetric(horizontal: 16, vertical: 12)
  final EdgeInsets? agendaDateHeaderPadding;

  /// Padding for resource group headers
  /// Default: EdgeInsets.symmetric(horizontal: 16, vertical: 10)
  final EdgeInsets? agendaResourceHeaderPadding;

  /// Padding for individual agenda items
  /// Default: EdgeInsets.symmetric(horizontal: 16, vertical: 12)
  final EdgeInsets? agendaItemPadding;

  /// Margin between agenda items
  /// Default: EdgeInsets.zero
  final EdgeInsets? agendaItemMargin;

  /// Spacing between appointment time and title
  /// Default: 12.0
  final double? agendaTimeToTitleSpacing;

  /// Spacing between title and subtitle
  /// Default: 4.0
  final double? agendaTitleToSubtitleSpacing;

  /// Radius for resource avatar in agenda items
  /// Default: 16.0
  final double? agendaResourceAvatarRadius;

  /// Spacing around resource avatar
  /// Default: 12.0
  final double? agendaAvatarSpacing;

  // ============================================================================
  // Agenda View Decorations (5 properties)
  // ============================================================================

  /// Border radius for agenda items
  /// Default: 0.0 (square corners)
  final double? agendaItemBorderRadius;

  /// Elevation/shadow for agenda items
  /// Default: null (no shadow)
  final List<BoxShadow>? agendaItemShadow;

  /// Thickness of divider between items
  /// Default: 1.0
  final double? agendaDividerThickness;

  /// Indent for divider
  /// Default: 16.0
  final double? agendaDividerIndent;

  /// End indent for divider
  /// Default: 0.0
  final double? agendaDividerEndIndent;

  // ============================================================================
  // Agenda View Indicators (4 properties)
  // ============================================================================

  /// Size of appointment status indicator dot
  /// Default: 8.0
  final double? agendaStatusIndicatorSize;

  /// Show colored bar on left side of item
  /// Default: true
  final bool? agendaShowColorBar;

  /// Width of colored bar
  /// Default: 4.0
  final double? agendaColorBarWidth;

  /// Show appointment status indicator
  /// Default: false
  final bool? agendaShowStatusIndicator;

  /// Default style for unavailability periods
  /// When an UnavailabilityPeriod doesn't specify a custom style,
  /// this theme style will be used instead
  /// Default: UnavailabilityStylePresets.standard
  final UnavailabilityStyle? unavailabilityStyle;

  final CalendarScrollbarTheme scrollbarTheme;

  final CalendarAppointmentCountBadgeTheme? appointmentCountBadgeTheme;

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

    // Agenda view colors
    Color? agendaItemBackgroundColor,
    Color? agendaItemHoverColor,
    Color? agendaItemSelectedColor,
    Color? agendaDateHeaderBackgroundColor,
    Color? agendaResourceHeaderBackgroundColor,
    Color? agendaDividerColor,
    Color? agendaEmptyBackgroundColor,

    // Agenda view text styles
    TextStyle? agendaDateHeaderTextStyle,
    TextStyle? agendaResourceHeaderTextStyle,
    TextStyle? agendaTimeTextStyle,
    TextStyle? agendaTitleTextStyle,
    TextStyle? agendaSubtitleTextStyle,
    TextStyle? agendaDurationTextStyle,
    TextStyle? agendaResourceNameTextStyle,
    TextStyle? agendaEmptyTextStyle,

    // Agenda view date formats
    String? agendaDateHeaderFormat,
    String? agendaTimeFormat,
    String? agendaDurationFormat,

    // Agenda view spacing
    EdgeInsets? agendaDateHeaderPadding,
    EdgeInsets? agendaResourceHeaderPadding,
    EdgeInsets? agendaItemPadding,
    EdgeInsets? agendaItemMargin,
    double? agendaTimeToTitleSpacing,
    double? agendaTitleToSubtitleSpacing,
    double? agendaResourceAvatarRadius,
    double? agendaAvatarSpacing,

    // Agenda view decorations
    double? agendaItemBorderRadius,
    List<BoxShadow>? agendaItemShadow,
    double? agendaDividerThickness,
    double? agendaDividerIndent,
    double? agendaDividerEndIndent,

    // Agenda view indicators
    double? agendaStatusIndicatorSize,
    bool? agendaShowColorBar,
    double? agendaColorBarWidth,
    bool? agendaShowStatusIndicator,

    // Unavailability style
    UnavailabilityStyle? unavailabilityStyle,

    // Scrollbar theme
    CalendarScrollbarTheme? scrollbarTheme,

    // Appointment count badge theme
    CalendarAppointmentCountBadgeTheme? appointmentCountBadgeTheme,
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

      // Agenda view colors
      agendaItemBackgroundColor:
          agendaItemBackgroundColor ?? this.agendaItemBackgroundColor,
      agendaItemHoverColor: agendaItemHoverColor ?? this.agendaItemHoverColor,
      agendaItemSelectedColor:
          agendaItemSelectedColor ?? this.agendaItemSelectedColor,
      agendaDateHeaderBackgroundColor:
          agendaDateHeaderBackgroundColor ??
          this.agendaDateHeaderBackgroundColor,
      agendaResourceHeaderBackgroundColor:
          agendaResourceHeaderBackgroundColor ??
          this.agendaResourceHeaderBackgroundColor,
      agendaDividerColor: agendaDividerColor ?? this.agendaDividerColor,
      agendaEmptyBackgroundColor:
          agendaEmptyBackgroundColor ?? this.agendaEmptyBackgroundColor,

      // Agenda view text styles
      agendaDateHeaderTextStyle:
          agendaDateHeaderTextStyle ?? this.agendaDateHeaderTextStyle,
      agendaResourceHeaderTextStyle:
          agendaResourceHeaderTextStyle ?? this.agendaResourceHeaderTextStyle,
      agendaTimeTextStyle: agendaTimeTextStyle ?? this.agendaTimeTextStyle,
      agendaTitleTextStyle: agendaTitleTextStyle ?? this.agendaTitleTextStyle,
      agendaSubtitleTextStyle:
          agendaSubtitleTextStyle ?? this.agendaSubtitleTextStyle,
      agendaDurationTextStyle:
          agendaDurationTextStyle ?? this.agendaDurationTextStyle,
      agendaResourceNameTextStyle:
          agendaResourceNameTextStyle ?? this.agendaResourceNameTextStyle,
      agendaEmptyTextStyle: agendaEmptyTextStyle ?? this.agendaEmptyTextStyle,

      // Agenda view date formats
      agendaDateHeaderFormat:
          agendaDateHeaderFormat ?? this.agendaDateHeaderFormat,
      agendaTimeFormat: agendaTimeFormat ?? this.agendaTimeFormat,
      agendaDurationFormat: agendaDurationFormat ?? this.agendaDurationFormat,

      // Agenda view spacing
      agendaDateHeaderPadding:
          agendaDateHeaderPadding ?? this.agendaDateHeaderPadding,
      agendaResourceHeaderPadding:
          agendaResourceHeaderPadding ?? this.agendaResourceHeaderPadding,
      agendaItemPadding: agendaItemPadding ?? this.agendaItemPadding,
      agendaItemMargin: agendaItemMargin ?? this.agendaItemMargin,
      agendaTimeToTitleSpacing:
          agendaTimeToTitleSpacing ?? this.agendaTimeToTitleSpacing,
      agendaTitleToSubtitleSpacing:
          agendaTitleToSubtitleSpacing ?? this.agendaTitleToSubtitleSpacing,
      agendaResourceAvatarRadius:
          agendaResourceAvatarRadius ?? this.agendaResourceAvatarRadius,
      agendaAvatarSpacing: agendaAvatarSpacing ?? this.agendaAvatarSpacing,

      // Agenda view decorations
      agendaItemBorderRadius:
          agendaItemBorderRadius ?? this.agendaItemBorderRadius,
      agendaItemShadow: agendaItemShadow ?? this.agendaItemShadow,
      agendaDividerThickness:
          agendaDividerThickness ?? this.agendaDividerThickness,
      agendaDividerIndent: agendaDividerIndent ?? this.agendaDividerIndent,
      agendaDividerEndIndent:
          agendaDividerEndIndent ?? this.agendaDividerEndIndent,

      // Agenda view indicators
      agendaStatusIndicatorSize:
          agendaStatusIndicatorSize ?? this.agendaStatusIndicatorSize,
      agendaShowColorBar: agendaShowColorBar ?? this.agendaShowColorBar,
      agendaColorBarWidth: agendaColorBarWidth ?? this.agendaColorBarWidth,
      agendaShowStatusIndicator:
          agendaShowStatusIndicator ?? this.agendaShowStatusIndicator,

      // Unavailability style
      unavailabilityStyle: unavailabilityStyle ?? this.unavailabilityStyle,

      // Scrollbar theme
      scrollbarTheme: scrollbarTheme ?? this.scrollbarTheme,

      // Appointment count badge theme
      appointmentCountBadgeTheme:
          appointmentCountBadgeTheme ?? this.appointmentCountBadgeTheme,
    );
  }
}
