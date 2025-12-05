// lib/src/builders/agenda_default_builders.dart

import 'package:flutter/material.dart';
import '../models/agenda_view_config.dart';
import '../models/calendar_appointment.dart';
import '../models/calendar_resource.dart';
import '../models/calendar_theme.dart';
import '../utils/agenda_grouping.dart';
import '../utils/date_time_utils.dart';

/// Default builders for agenda view components
class AgendaDefaultBuilders {
  /// Build default date group header
  static Widget dateHeader(
    BuildContext context,
    AgendaGroupHeader header,
    bool isExpanded,
    CalendarTheme theme,
  ) {
    return Container(
      padding:
          theme.agendaDateHeaderPadding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: theme.agendaDateHeaderBackgroundColor ?? const Color(0xFFF5F5F5),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  header.title,
                  style:
                      theme.agendaDateHeaderTextStyle ??
                      const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                ),
                if (header.subtitle != null && header.subtitle!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      header.subtitle!,
                      style:
                          theme.agendaSubtitleTextStyle ??
                          const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),
              ],
            ),
          ),
          if (header.itemCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.todayHighlightColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${header.itemCount}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.todayHighlightColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Build default resource group header
  static Widget resourceHeader(
    BuildContext context,
    AgendaGroupHeader header,
    bool isExpanded,
    CalendarTheme theme,
    AgendaViewConfig config,
  ) {
    final resource = header.resource;

    return Container(
      padding:
          theme.agendaResourceHeaderPadding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color:
          theme.agendaResourceHeaderBackgroundColor ?? const Color(0xFFFAFAFA),
      child: Row(
        children: [
          if (resource?.avatarUrl != null && config.showResourceAvatar)
            Padding(
              padding: EdgeInsets.only(right: theme.agendaAvatarSpacing ?? 12),
              child: CircleAvatar(
                radius: theme.agendaResourceAvatarRadius ?? 16,
                backgroundImage: NetworkImage(resource!.avatarUrl!),
                backgroundColor: resource.color ?? Colors.grey,
              ),
            )
          else if (resource != null && config.showResourceAvatar)
            Padding(
              padding: EdgeInsets.only(right: theme.agendaAvatarSpacing ?? 12),
              child: CircleAvatar(
                radius: theme.agendaResourceAvatarRadius ?? 16,
                backgroundColor: resource.color ?? Colors.grey,
                child: Text(
                  resource.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  header.title,
                  style:
                      theme.agendaResourceHeaderTextStyle ??
                      const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                ),
                if (header.subtitle != null && header.subtitle!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      header.subtitle!,
                      style:
                          theme.agendaSubtitleTextStyle ??
                          const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),
              ],
            ),
          ),
          if (header.itemCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    resource?.color?.withOpacity(0.1) ?? Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${header.itemCount}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: resource?.color ?? Colors.black54,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Build default agenda item
  static Widget item(
    BuildContext context,
    AgendaItem agendaItem,
    bool isSelected,
    bool isHovered,
    CalendarTheme theme,
    AgendaViewConfig config,
  ) {
    final appointment = agendaItem.appointment;
    final resource = agendaItem.resource;
    final duration = appointment.endTime.difference(appointment.startTime);

    Color backgroundColor;
    if (isSelected) {
      backgroundColor =
          theme.agendaItemSelectedColor ?? const Color(0xFFE3F2FD);
    } else if (isHovered) {
      backgroundColor = theme.agendaItemHoverColor ?? const Color(0xFFF5F5F5);
    } else {
      backgroundColor = theme.agendaItemBackgroundColor ?? Colors.white;
    }

    return Container(
      margin: theme.agendaItemMargin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(theme.agendaItemBorderRadius ?? 0),
        boxShadow: theme.agendaItemShadow,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Color bar
            if (theme.agendaShowColorBar ?? true)
              Container(
                width: theme.agendaColorBarWidth ?? 4,
                decoration: BoxDecoration(
                  color: appointment.color,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(theme.agendaItemBorderRadius ?? 0),
                    bottomLeft: Radius.circular(
                      theme.agendaItemBorderRadius ?? 0,
                    ),
                  ),
                ),
              ),
            // Content
            Expanded(
              child: Padding(
                padding:
                    theme.agendaItemPadding ??
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time column
                    if (config.showAppointmentTime)
                      SizedBox(
                        width: 70,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateTimeUtils.formatDate(
                                appointment.startTime,
                                theme.agendaTimeFormat ?? 'h:mm a',
                              ),
                              style:
                                  theme.agendaTimeTextStyle ??
                                  const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                            ),
                            if (config.showAppointmentDuration)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  _formatDuration(duration),
                                  style:
                                      theme.agendaDurationTextStyle ??
                                      const TextStyle(
                                        fontSize: 11,
                                        color: Colors.black45,
                                      ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    if (config.showAppointmentTime)
                      SizedBox(width: theme.agendaTimeToTitleSpacing ?? 12),
                    // Main content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            appointment.title,
                            style:
                                theme.agendaTitleTextStyle ??
                                const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Subtitle
                          if (appointment.subtitle != null &&
                              appointment.subtitle!.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(
                                top: theme.agendaTitleToSubtitleSpacing ?? 4,
                              ),
                              child: Text(
                                appointment.subtitle!,
                                style:
                                    theme.agendaSubtitleTextStyle ??
                                    const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          // Resource name (if showing in chronological mode)
                          if (agendaItem.showResource &&
                              config.showResourceName)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  if (resource.avatarUrl != null &&
                                      config.showResourceAvatar)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: CircleAvatar(
                                        radius: 8,
                                        backgroundImage: NetworkImage(
                                          resource.avatarUrl!,
                                        ),
                                        backgroundColor:
                                            resource.color ?? Colors.grey,
                                      ),
                                    ),
                                  Flexible(
                                    child: Text(
                                      resource.name,
                                      style:
                                          theme.agendaResourceNameTextStyle ??
                                          const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Status indicator
                    if (theme.agendaShowStatusIndicator ?? false)
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Container(
                          width: theme.agendaStatusIndicatorSize ?? 8,
                          height: theme.agendaStatusIndicatorSize ?? 8,
                          decoration: BoxDecoration(
                            color: _getStatusColor(appointment),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build default empty state
  static Widget emptyState(
    BuildContext context,
    String message,
    CalendarTheme theme,
  ) {
    return Container(
      color: theme.agendaEmptyBackgroundColor ?? const Color(0xFFFAFAFA),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_busy,
                size: 64,
                color: theme.agendaEmptyTextStyle?.color ?? Colors.black45,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style:
                    theme.agendaEmptyTextStyle ??
                    const TextStyle(fontSize: 14, color: Colors.black45),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build default time display
  static Widget time(
    BuildContext context,
    CalendarAppointment appointment,
    CalendarTheme theme,
  ) {
    return Text(
      DateTimeUtils.formatDate(
        appointment.startTime,
        theme.agendaTimeFormat ?? 'h:mm a',
      ),
      style:
          theme.agendaTimeTextStyle ??
          const TextStyle(fontSize: 12, color: Colors.black54),
    );
  }

  /// Build default duration display
  static Widget duration(
    BuildContext context,
    Duration duration,
    CalendarTheme theme,
  ) {
    return Text(
      _formatDuration(duration),
      style:
          theme.agendaDurationTextStyle ??
          const TextStyle(fontSize: 11, color: Colors.black45),
    );
  }

  /// Build default resource avatar
  static Widget resourceAvatar(
    BuildContext context,
    CalendarResource resource,
    double size,
    CalendarTheme theme,
  ) {
    if (resource.avatarUrl != null) {
      return CircleAvatar(
        radius: size,
        backgroundImage: NetworkImage(resource.avatarUrl!),
        backgroundColor: resource.color ?? Colors.grey,
      );
    }

    return CircleAvatar(
      radius: size,
      backgroundColor: resource.color ?? Colors.grey,
      child: Text(
        resource.name[0].toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.8,
        ),
      ),
    );
  }

  /// Build default status indicator
  static Widget statusIndicator(
    BuildContext context,
    CalendarAppointment appointment,
    double size,
  ) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getStatusColor(appointment),
        shape: BoxShape.circle,
      ),
    );
  }

  /// Format duration for display
  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  /// Get status color based on appointment status
  static Color _getStatusColor(CalendarAppointment appointment) {
    final status = appointment.status?.toLowerCase() ?? '';

    if (status.contains('confirmed')) return Colors.green;
    if (status.contains('pending')) return Colors.orange;
    if (status.contains('cancelled')) return Colors.red;
    if (status.contains('completed')) return Colors.blue;

    return Colors.grey;
  }
}
