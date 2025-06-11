import 'package:flutter/material.dart';
import 'package:timely_x/src/models/tyx_calendar_border.dart';

import 'package:timely_x/src/presentation/tyx_calendar/tyx_calendar_month/tyx_calendar_month_view_large.dart';
import 'package:timely_x/src/presentation/tyx_calendar/tyx_calendar_month/tyx_calendar_month_view_small.dart';
import 'package:timely_x/timely_x.dart';

class TyxCalendarMonthView extends StatefulWidget {
  final TyxCalendarOption option;
  final DateTime? initialDate;
  final Function(DateTime date, List<TyxEvent> events)? onDateChanged;
  final Function(TyxView view)? onViewChanged;
  final Function(TyxCalendarBorder border)? onBorderChanged;
  final TyxView view;
  final Function(TyxEvent)? onEventTapped;
  const TyxCalendarMonthView({
    super.key,
    required this.option,
    this.initialDate,
    this.onDateChanged,
    this.onViewChanged,
    this.onBorderChanged,
    required this.view,
    this.onEventTapped,
  });

  @override
  State<TyxCalendarMonthView> createState() => _TyxCalendarMonthViewState();
}

class _TyxCalendarMonthViewState extends State<TyxCalendarMonthView> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isLargeScreen = constraints.maxWidth > 600;
        return isLargeScreen
            ? TyxCalendarMonthViewLarge(
                option: widget.option,
                initialDate: widget.initialDate,
                onDateChanged: widget.onDateChanged,
                onViewChanged: widget.onViewChanged,
                onBorderChanged: widget.onBorderChanged,
                view: widget.view,
                onEventTapped: widget.onEventTapped,
              )
            : TyxCalendarMonthViewSmall(
                option: widget.option,
                initialDate: widget.initialDate,
                onDateChanged: widget.onDateChanged,
                onViewChanged: widget.onViewChanged,
                onBorderChanged: widget.onBorderChanged,
                view: widget.view,
                onEventTapped: widget.onEventTapped,
              );
      },
    );
  }
}
