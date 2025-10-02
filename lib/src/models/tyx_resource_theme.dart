import 'package:flutter/material.dart';
import 'package:timely_x/timely_x.dart';

/// Theme configuration for the calendar resource view
class TyxResourceTheme {
  // Colors
  final Color backgroundColor;
  final Color borderColor;
  final Color gridLineColor;
  final Color timeColumnBackground;
  final Color headerBackground;
  final Color todayHighlightColor;

  // Typography
  final TextStyle timeTextStyle;
  final TextStyle resourceNameStyle;
  final TextStyle dayHeaderStyle;
  final TextStyle eventTimeStyle;
  final TextStyle eventTitleStyle;

  // Dimensions
  final double timeslotHeight;
  final double cellWidth;
  final double timesCellWidth;
  final double resourceHeaderHeight;
  final double borderRadius;
  final double gridLineWidth;

  // Resource header styling
  final BoxDecoration? resourceHeaderDecoration;
  final EdgeInsets resourceHeaderPadding;

  const TyxResourceTheme({
    // Colors
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFFE5E7EB),
    this.gridLineColor = const Color(0xFFF3F4F6),
    this.timeColumnBackground = const Color(0xFFFAFAFA),
    this.headerBackground = Colors.white,
    this.todayHighlightColor = const Color(0xFFEEF2FF),

    // Typography
    this.timeTextStyle = const TextStyle(
      fontSize: 11,
      color: Color(0xFF6B7280),
      fontWeight: FontWeight.w400,
    ),
    this.resourceNameStyle = const TextStyle(
      fontSize: 13,
      color: Color(0xFF111827),
      fontWeight: FontWeight.w600,
    ),
    this.dayHeaderStyle = const TextStyle(
      fontSize: 11,
      color: Color(0xFF6B7280),
      fontWeight: FontWeight.w500,
    ),
    this.eventTimeStyle = const TextStyle(
      fontSize: 10,
      color: Color(0xFF374151),
      fontWeight: FontWeight.w500,
    ),
    this.eventTitleStyle = const TextStyle(
      fontSize: 11,
      color: Color(0xFF111827),
      fontWeight: FontWeight.w500,
    ),

    // Dimensions
    this.timeslotHeight = 60.0,
    this.cellWidth = 140.0,
    this.timesCellWidth = 70.0,
    this.resourceHeaderHeight = 80.0,
    this.borderRadius = 8.0,
    this.gridLineWidth = 1.0,

    // Resource header
    this.resourceHeaderDecoration,
    this.resourceHeaderPadding = const EdgeInsets.all(12.0),
  });

  /// Modern light theme matching the screenshot
  static TyxResourceTheme light() {
    return const TyxResourceTheme(
      backgroundColor: Colors.white,
      borderColor: Color(0xFFE5E7EB),
      gridLineColor: Color(0xFFF3F4F6),
      timeColumnBackground: Color(0xFFFAFAFA),
      headerBackground: Colors.white,
      todayHighlightColor: Color(0xFFEEF2FF),
      timeslotHeight: 60.0,
      cellWidth: 140.0,
      resourceHeaderHeight: 80.0,
    );
  }

  /// Dark theme variant
  static TyxResourceTheme dark() {
    return const TyxResourceTheme(
      backgroundColor: Color(0xFF1F2937),
      borderColor: Color(0xFF374151),
      gridLineColor: Color(0xFF4B5563),
      timeColumnBackground: Color(0xFF111827),
      headerBackground: Color(0xFF1F2937),
      todayHighlightColor: Color(0xFF1E3A8A),
      timeTextStyle: TextStyle(
        fontSize: 11,
        color: Color(0xFF9CA3AF),
        fontWeight: FontWeight.w400,
      ),
      resourceNameStyle: TextStyle(
        fontSize: 13,
        color: Color(0xFFF9FAFB),
        fontWeight: FontWeight.w600,
      ),
      dayHeaderStyle: TextStyle(
        fontSize: 11,
        color: Color(0xFF9CA3AF),
        fontWeight: FontWeight.w500,
      ),
      timeslotHeight: 60.0,
      cellWidth: 140.0,
      resourceHeaderHeight: 80.0,
    );
  }

  TyxResourceTheme copyWith({
    Color? backgroundColor,
    Color? borderColor,
    Color? gridLineColor,
    Color? timeColumnBackground,
    Color? headerBackground,
    Color? todayHighlightColor,
    TextStyle? timeTextStyle,
    TextStyle? resourceNameStyle,
    TextStyle? dayHeaderStyle,
    TextStyle? eventTimeStyle,
    TextStyle? eventTitleStyle,
    double? timeslotHeight,
    double? cellWidth,
    double? timesCellWidth,
    double? resourceHeaderHeight,
    double? borderRadius,
    double? gridLineWidth,
    BoxDecoration? resourceHeaderDecoration,
    EdgeInsets? resourceHeaderPadding,
  }) {
    return TyxResourceTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      gridLineColor: gridLineColor ?? this.gridLineColor,
      timeColumnBackground: timeColumnBackground ?? this.timeColumnBackground,
      headerBackground: headerBackground ?? this.headerBackground,
      todayHighlightColor: todayHighlightColor ?? this.todayHighlightColor,
      timeTextStyle: timeTextStyle ?? this.timeTextStyle,
      resourceNameStyle: resourceNameStyle ?? this.resourceNameStyle,
      dayHeaderStyle: dayHeaderStyle ?? this.dayHeaderStyle,
      eventTimeStyle: eventTimeStyle ?? this.eventTimeStyle,
      eventTitleStyle: eventTitleStyle ?? this.eventTitleStyle,
      timeslotHeight: timeslotHeight ?? this.timeslotHeight,
      cellWidth: cellWidth ?? this.cellWidth,
      timesCellWidth: timesCellWidth ?? this.timesCellWidth,
      resourceHeaderHeight: resourceHeaderHeight ?? this.resourceHeaderHeight,
      borderRadius: borderRadius ?? this.borderRadius,
      gridLineWidth: gridLineWidth ?? this.gridLineWidth,
      resourceHeaderDecoration:
          resourceHeaderDecoration ?? this.resourceHeaderDecoration,
      resourceHeaderPadding:
          resourceHeaderPadding ?? this.resourceHeaderPadding,
    );
  }
}

/// Extension to apply theme to resource option
extension TyxResourceOptionTheming on TyxResourceOption {
  TyxResourceOption applyTheme(TyxResourceTheme theme) {
    return TyxResourceOption(
      initialDate: initialDate,
      timeslotHeight: theme.timeslotHeight,
      cellWidth: theme.cellWidth,
      timesCellWidth: theme.timesCellWidth,
      resourceHeaderHeight: theme.resourceHeaderHeight,
      timelotSlotDuration: timelotSlotDuration,
      timeslotStartTime: timeslotStartTime,
      resourceBuilder: resourceBuilder,
      eventBuilder: eventBuilder,
    );
  }
}
