// lib/src/widgets/date_header.dart

import 'package:flutter/material.dart';
import '../models/calendar_theme.dart';
import '../builders/builder_delegates.dart';
import '../builders/default_builders.dart';
import '../utils/date_time_utils.dart';
import '../models/interaction_data.dart';

class DateHeader extends StatelessWidget {
  const DateHeader({
    Key? key,
    required this.date,
    required this.width,
    required this.theme,
    this.builder,
    this.onTap,
  }) : super(key: key);

  final DateTime date;
  final double width;
  final CalendarTheme theme;
  final DateHeaderBuilder? builder;
  final OnDateHeaderTap? onTap;

  @override
  Widget build(BuildContext context) {
    final isToday = DateTimeUtils.isToday(date);

    return GestureDetector(
      onTap: () {
        onTap?.call(DateHeaderTapData(date: date, globalPosition: Offset.zero));
      },
      child:
          builder?.call(context, date, width, isToday) ??
          DefaultBuilders.dateHeader(context, date, width, isToday, theme),
    );
  }
}
