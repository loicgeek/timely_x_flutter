// lib/src/widgets/time_column.dart

import 'package:flutter/material.dart';
import '../models/calendar_config.dart';
import '../models/calendar_theme.dart';
import '../builders/builder_delegates.dart';
import '../builders/default_builders.dart';

class TimeColumn extends StatefulWidget {
  const TimeColumn({
    Key? key,
    required this.config,
    required this.theme,
    required this.scrollController,
    this.timeColumnBuilder,
  }) : super(key: key);

  final CalendarConfig config;
  final CalendarTheme theme;
  final ScrollController scrollController;
  final TimeColumnBuilder? timeColumnBuilder;

  @override
  State<TimeColumn> createState() => _TimeColumnState();
}

class _TimeColumnState extends State<TimeColumn> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.config.timeColumnWidth,
      decoration: BoxDecoration(
        color: widget.theme.timeColumnBackgroundColor,
        border: Border(
          right: BorderSide(color: widget.theme.gridLineColor, width: 1),
        ),
        boxShadow: widget.theme.headerShadow,
      ),
      child: SingleChildScrollView(
        controller: widget.scrollController,
        physics: const NeverScrollableScrollPhysics(),
        child: Column(children: _buildTimeSlots()),
      ),
    );
  }

  List<Widget> _buildTimeSlots() {
    final slots = <Widget>[];
    final hours = widget.config.dayEndHour - widget.config.dayStartHour;
    final slotsPerHour = 60 ~/ widget.config.timeSlotDuration.inMinutes;

    for (int i = 0; i < hours * slotsPerHour; i++) {
      final hour = widget.config.dayStartHour + (i ~/ slotsPerHour);
      final minute =
          (i % slotsPerHour) * widget.config.timeSlotDuration.inMinutes;
      final time = DateTime(2000, 1, 1, hour, minute);
      final isHourMark = i % slotsPerHour == 0;
      final slotHeight = widget.config.hourHeight / slotsPerHour;

      slots.add(
        SizedBox(
          height: slotHeight,
          child:
              widget.timeColumnBuilder?.call(
                context,
                time,
                slotHeight,
                isHourMark,
              ) ??
              DefaultBuilders.timeLabel(
                context,
                time,
                slotHeight,
                isHourMark,
                widget.theme,
              ),
        ),
      );
    }

    return slots;
  }
}
