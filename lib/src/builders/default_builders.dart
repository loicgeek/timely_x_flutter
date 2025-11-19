// lib/src/builders/default_builders.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/calendar_appointment.dart';
import '../models/calendar_resource.dart';
import '../models/calendar_theme.dart';
import '../utils/date_time_utils.dart';

/// Default builders for calendar components
class DefaultBuilders {
  /// Default resource header builder
  static Widget resourceHeader(
    BuildContext context,
    CalendarResource resource,
    double width,
    bool isHovered,
    CalendarTheme theme,
  ) {
    return Container(
      width: width,
      padding: theme.resourceHeaderPadding,
      decoration: BoxDecoration(
        color: isHovered ? theme.hoverColor : theme.headerBackgroundColor,
        border: Border(
          right: BorderSide(color: theme.gridLineColor, width: 1),
          bottom: BorderSide(color: theme.hourLineColor, width: 1),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: theme.resourceAvatarRadius,
            backgroundColor: resource.color ?? theme.todayHighlightColor,
            backgroundImage: resource.avatarUrl != null
                ? NetworkImage(resource.avatarUrl!)
                : null,
            child: resource.avatarUrl == null
                ? Text(
                    resource.name.isNotEmpty
                        ? resource.name[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: theme.appointmentTextStyle.color,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          SizedBox(height: theme.appointmentSpacing * 4),
          Text(
            resource.name,
            style: theme.resourceNameStyle,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Default date header builder
  static Widget dateHeader(
    BuildContext context,
    DateTime date,
    double width,
    bool isToday,
    CalendarTheme theme,
  ) {
    final isWeekend = DateTimeUtils.isWeekend(date);

    return Container(
      width: width,
      padding: theme.dateHeaderPadding,
      decoration: BoxDecoration(
        color: isToday
            ? theme.currentDayHighlight
            : (isWeekend ? theme.weekendColor : theme.headerBackgroundColor),
        border: Border(
          right: BorderSide(color: theme.gridLineColor, width: 1),
          bottom: BorderSide(color: theme.hourLineColor, width: 2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat(theme.weekdayFormat).format(date).toUpperCase(),
            style: theme.weekdayTextStyle.copyWith(
              color: isWeekend
                  ? theme.weekendTextColor
                  : theme.weekdayTextStyle.color,
            ),
          ),
          SizedBox(height: theme.appointmentSpacing * 2),
          Flexible(
            child: Text(
              DateFormat(theme.dateFormat).format(date),
              style: theme.dateTextStyle.copyWith(
                color: isToday
                    ? theme.todayHighlightColor
                    : theme.dateTextStyle.color,
                fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Default time column builder
  static Widget timeLabel(
    BuildContext context,
    DateTime time,
    double height,
    bool isHourMark,
    CalendarTheme theme,
  ) {
    if (!isHourMark) return const SizedBox.shrink();

    return Container(
      height: height,
      alignment: Alignment.topCenter,
      padding: theme.timeLabelPadding,
      child: Text(
        DateFormat(theme.timeFormat).format(time),
        style: theme.timeTextStyle,
      ),
    );
  }

  /// Default appointment builder
  static Widget appointment(
    BuildContext context,
    CalendarAppointment appointment,
    CalendarResource resource,
    Rect rect,
    bool isSelected,
    CalendarTheme theme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: appointment.color,
        borderRadius: BorderRadius.circular(theme.appointmentBorderRadius),
        border: isSelected
            ? Border.all(
                color: theme.appointmentTextStyle.color ?? Colors.white,
                width: 2,
              )
            : null,
        boxShadow: theme.appointmentShadow,
      ),
      padding: theme.appointmentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            appointment.title,
            style: theme.appointmentTextStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (appointment.subtitle != null && rect.height > 40) ...[
            SizedBox(height: theme.appointmentSpacing),
            Text(
              appointment.subtitle!,
              style: theme.appointmentSubtitleStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (rect.height > 60) ...[
            SizedBox(height: theme.appointmentSpacing * 2),
            Text(
              '${DateFormat(theme.timeFormat).format(appointment.startTime)} - '
              '${DateFormat(theme.timeFormat).format(appointment.endTime)}',
              style: theme.appointmentTimeStyle,
            ),
          ],
        ],
      ),
    );
  }

  /// Default current time indicator
  static Widget currentTimeIndicator(
    BuildContext context,
    double width,
    CalendarTheme theme,
  ) {
    return Container(
      width: width,
      height: 2,
      color: theme.currentTimeIndicatorColor,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: theme.currentTimeIndicatorColor,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Container(height: 2, color: theme.currentTimeIndicatorColor),
          ),
        ],
      ),
    );
  }
}
