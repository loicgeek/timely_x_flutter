// lib/src/widgets/appointment_count_badge.dart

import 'package:flutter/material.dart';
import '../models/calendar_theme.dart';

class AppointmentCountBadge extends StatelessWidget {
  const AppointmentCountBadge({
    super.key,
    required this.count,
    required this.theme,
  });

  final int count;
  final CalendarTheme theme;

  @override
  Widget build(BuildContext context) {
    if (count == 0) {
      return const SizedBox.shrink();
    }

    final text = _formatCount();
    final showBadge =
        theme.appointmentCountBadgeTheme?.appointmentCountShowBadge ?? true;

    if (showBadge) {
      return _buildBadge(text);
    } else {
      return _buildPlainText(text);
    }
  }

  Widget _buildBadge(String text) {
    return Container(
      padding:
          theme.appointmentCountBadgeTheme?.appointmentCountPadding ??
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            theme.appointmentCountBadgeTheme?.appointmentCountBackgroundColor ??
            Colors.grey[200],
        borderRadius: BorderRadius.circular(
          theme.appointmentCountBadgeTheme?.appointmentCountBorderRadius ??
              12.0,
        ),
        border:
            theme.appointmentCountBadgeTheme?.appointmentCountBorderColor !=
                null
            ? Border.all(
                color: theme
                    .appointmentCountBadgeTheme!
                    .appointmentCountBorderColor!,
                width: 1,
              )
            : null,
      ),
      child: Text(
        text,
        style:
            theme.appointmentCountBadgeTheme?.appointmentCountTextStyle ??
            TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  Widget _buildPlainText(String text) {
    return Text(
      text,
      style:
          theme.appointmentCountBadgeTheme?.appointmentCountTextStyle ??
          TextStyle(fontSize: 12, color: Colors.grey[600]),
    );
  }

  String _formatCount() {
    return count == 1 ? '$count appt' : '$count appts';
  }
}
