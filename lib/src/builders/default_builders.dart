// lib/src/builders/default_builders.dart

import 'package:calendar2/calendar2.dart';
import 'package:calendar2/src/widgets/appointment_count_badge.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/date_time_utils.dart';

/// Default builders for calendar components
class DefaultBuilders {
  /// Default resource header builder with appointment count support
  ///
  /// Parameters:
  /// - date: For single-day display (day view, week days-first)
  /// - dates: For multi-day display (week resources-first)
  static Widget resourceHeader({
    required BuildContext context,
    required CalendarResource resource,
    required double width,
    required bool isHovered,
    required CalendarTheme theme,
    required CalendarConfig config,
    required CalendarController controller,
    DateTime? date, // For single-day counting
    List<DateTime>? dates, // For multi-day counting
  }) {
    // Determine appointment count based on what's provided
    int appointmentCount = 0;
    if (config.showResourceAppointmentCount) {
      if (dates != null && dates.isNotEmpty) {
        // Multi-day mode (week resources-first)
        appointmentCount = controller.getAppointmentCountForResourceDates(
          resource.id,
          dates,
        );
      } else if (date != null) {
        // Single-day mode (day view, week days-first)
        appointmentCount = controller
            .getAppointmentsForResourceDate(resource.id, date)
            .length;
      }
    }

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
          // Avatar
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

          // Resource name
          Text(
            resource.name,
            style: theme.resourceNameStyle,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),

          // Appointment count
          if (config.showResourceAppointmentCount && appointmentCount > 0) ...[
            SizedBox(height: theme.appointmentSpacing * 2),
            if (theme.appointmentCountBadgeTheme?.appointmentCountBuilder !=
                null)
              theme.appointmentCountBadgeTheme!.appointmentCountBuilder!(
                context,
                appointmentCount,
              )
            else
              AppointmentCountBadge(count: appointmentCount, theme: theme),
          ],
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
  static Widget appointment({
    required BuildContext context,
    required CalendarAppointment appointment,
    required CalendarResource resource,
    required Rect rect,
    required bool isSelected,
    required CalendarTheme theme,
  }) {
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
  static Widget currentTimeIndicator({
    required BuildContext context,
    required double width,
    required CalendarTheme theme,
  }) {
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
