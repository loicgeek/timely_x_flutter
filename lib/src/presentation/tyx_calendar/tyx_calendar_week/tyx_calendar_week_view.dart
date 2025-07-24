import 'package:flutter/material.dart';
import 'package:timely_x/src/models/tyx_calendar_border.dart';

import 'package:timely_x/timely_x.dart';

import 'tyx_calendar_week_view_large.dart';

class TyxCalendarWeekView<T extends TyxEvent> extends StatefulWidget {
  final TyxCalendarOption<T> option;
  final DateTime? initialDate;
  final Function(DateTime date, List<T> events)? onDateChanged;
  final Function(TyxView view)? onViewChanged;
  final Function(T)? onEventTapped;
  final TyxView view;
  final Function(TyxCalendarBorder border)? onBorderChanged;
  final OnRightClick? onRightClick;
  final List<T>? events;

  const TyxCalendarWeekView({
    super.key,
    required this.option,
    this.initialDate,
    this.onDateChanged,
    this.onViewChanged,
    this.onEventTapped,
    required this.view,
    this.onBorderChanged,
    this.onRightClick,
    this.events,
  });

  @override
  State<TyxCalendarWeekView<T>> createState() => _TyxCalendarWeekViewState<T>();
}

class _TyxCalendarWeekViewState<T extends TyxEvent>
    extends State<TyxCalendarWeekView<T>> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // bool isLargeScreen = constraints.maxWidth > 600;
        return TyxCalendarWeekViewLarge<T>(
          option: widget.option,
          initialDate: widget.initialDate,
          onDateChanged: widget.onDateChanged,
          onViewChanged: widget.onViewChanged,
          onEventTapped: widget.onEventTapped,
          view: widget.view,
          onBorderChanged: widget.onBorderChanged,
          onRightClick: widget.onRightClick,
          events: widget.events,
        );
      },
    );
  }
}
