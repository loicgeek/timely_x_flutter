// example/lib/theme/calendar_app_theme.dart

import 'package:flutter/material.dart';
import 'package:calendar2/calendar2.dart';

class CalendarAppTheme {
  // Calendar configuration matching spec
  static const config = CalendarConfig(
    viewType: CalendarViewType.week,
    hourHeight: 100.0, // 100px per hour as per spec
    minColumnWidth: 120.0, // 120-150px per resource
    maxColumnWidth: double.infinity,
    preferredColumnWidth: 130.0,
    timeColumnWidth: 70.0, // 60-80px
    resourceHeaderHeight: 100.0, // ~80-100px
    dateHeaderHeight: 60.0,
    timeSlotDuration: Duration(minutes: 30), // 30-minute intervals
    dayStartHour: 0,
    dayEndHour: 24,
    showWeekends: true,
    enableSnapping: true,
    snapToMinutes: 15,
    enableDragAndDrop: true,
    weekViewLayout: WeekViewLayout.daysFirst,
    firstDayOfWeek: DateTime.sunday,
  );

  // Calendar theme matching spec colors
  static const theme = CalendarTheme(
    // Grid colors from spec
    gridLineColor: Color(0xFFE5E5E5),
    hourLineColor: Color(0xFFCCCCCC),
    zebraStripeOdd: Color(0xFFFAFAFA),
    zebraStripeEven: Color(0xFFFFFFFF),
    currentDayHighlight: Color(0xFFE3F2FD),
    currentTimeIndicatorColor: Color(0xFFFF5252),
    selectedSlotColor: Color(0xFFBBDEFB),
    hoverColor: Color(0xFFF5F5F5),

    // Typography from spec
    timeTextStyle: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: Color(0xFF666666),
    ),
    resourceNameStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Color(0xFF212121),
    ),
    dateTextStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Color(0xFF212121),
    ),
    weekdayTextStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Color(0xFF757575),
    ),
    appointmentTextStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),
    appointmentSubtitleStyle: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: Colors.white70,
    ),

    // Decorations
    appointmentBorderRadius: 4.0,
    appointmentShadow: [
      BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 2)),
    ],
    headerShadow: [
      BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1)),
    ],
    unavailabilityStyle: UnavailabilityStyle(
      pattern: UnavailabilityPattern.diagonalLines,
      backgroundColor: Color(0xFFFAFAFA),
      patternColor: Color(0xFFE0E0E0),
      lineWidth: 1.0,
      lineSpacing: 8.0,
    ),
  );
}
