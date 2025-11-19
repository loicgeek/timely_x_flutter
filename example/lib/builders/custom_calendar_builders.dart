// example/lib/builders/custom_calendar_builders.dart

import 'package:flutter/material.dart';
import 'package:calendar2/calendar2.dart';
import 'package:intl/intl.dart';

class CustomCalendarBuilders {
  CustomCalendarBuilders({
    this.onAppointmentTap,
    this.onAppointmentLongPress,
    this.onResourceHeaderTap,
  });

  final Function(AppointmentTapData)? onAppointmentTap;
  final Function(AppointmentLongPressData)? onAppointmentLongPress;
  final Function(ResourceHeaderTapData)? onResourceHeaderTap;

  // Resource Header Builder - Matches spec exactly
  Widget buildResourceHeader(
    BuildContext context,
    CalendarResource resource,
    double width,
    bool isHovered,
  ) {
    return Container(
      width: width,
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isHovered ? const Color(0xFFF5F5F5) : Colors.white,
        border: const Border(
          right: BorderSide(color: Color(0xFFE5E5E5), width: 1),
          bottom: BorderSide(color: Color(0xFFCCCCCC), width: 1),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatar: 40-48px circular
          CircleAvatar(
            radius: 22,
            backgroundColor: resource.color ?? Colors.blue,
            backgroundImage: resource.avatarUrl != null
                ? NetworkImage(resource.avatarUrl!)
                : null,
            child: resource.avatarUrl == null
                ? Text(
                    resource.name.isNotEmpty
                        ? resource.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 8),
          // Resource name
          Flexible(
            child: Text(
              resource.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121),
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Date Header Builder - Single letter weekday
  Widget buildDateHeader(
    BuildContext context,
    DateTime date,
    double width,
    bool isToday,
  ) {
    final weekdayMap = {1: 'M', 2: 'T', 3: 'W', 4: 'T', 5: 'F', 6: 'S', 7: 'S'};
    final isWeekend = date.weekday == 6 || date.weekday == 7;

    return Container(
      width: width,
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isToday ? const Color(0xFFE3F2FD) : Colors.white,
        border: const Border(
          right: BorderSide(color: Color(0xFFE5E5E5), width: 1),
          bottom: BorderSide(color: Color(0xFFCCCCCC), width: 2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            weekdayMap[date.weekday] ?? '',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: isWeekend ? Colors.red.shade300 : const Color(0xFF757575),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isToday ? Colors.blue : const Color(0xFF212121),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Time Column Builder
  Widget buildTimeColumn(
    BuildContext context,
    DateTime time,
    double height,
    bool isHourMark,
  ) {
    if (!isHourMark) return const SizedBox.shrink();

    return Container(
      height: height,
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.only(top: 4, right: 8),
      child: Text(
        DateFormat('HH:mm').format(time),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: Color(0xFF666666),
        ),
      ),
    );
  }

  // Appointment Builder - Clean design
  Widget buildAppointment(
    BuildContext context,
    CalendarAppointment appointment,
    CalendarResource resource,
    Rect rect,
    bool isSelected,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: appointment.color,
        borderRadius: BorderRadius.circular(4),
        border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            appointment.title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (appointment.subtitle != null && rect.height > 40) ...[
            const SizedBox(height: 2),
            Text(
              appointment.subtitle!,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (rect.height > 60) ...[
            const SizedBox(height: 4),
            Text(
              '${DateFormat('HH:mm').format(appointment.startTime)} - '
              '${DateFormat('HH:mm').format(appointment.endTime)}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Colors.white60,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Current Time Indicator Builder
  Widget buildCurrentTimeIndicator(BuildContext context, double width) {
    return Container(
      width: width,
      height: 2,
      color: const Color(0xFFFF5252),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFFF5252),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(child: Container(height: 2, color: const Color(0xFFFF5252))),
        ],
      ),
    );
  }
}
