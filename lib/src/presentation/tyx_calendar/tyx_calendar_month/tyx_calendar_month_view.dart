import 'package:flutter/material.dart';
import 'package:timely_x/src/models/tyx_calendar_border.dart';

import 'package:timely_x/src/presentation/tyx_calendar/tyx_calendar_month/tyx_calendar_month_view_large.dart';
import 'package:timely_x/src/presentation/tyx_calendar/tyx_calendar_month/tyx_calendar_month_view_small.dart';
import 'package:timely_x/timely_x.dart';

class TyxCalendarMonthView<T extends TyxEvent> extends StatefulWidget {
  final TyxCalendarOption<T> option;

  final Function(DateTime date, List<T> events)? onDateChanged;
  final Function(TyxView view)? onViewChanged;
  final Function(TyxCalendarBorder border)? onBorderChanged;
  final TyxView view;
  final Function(T)? onEventTapped;
  const TyxCalendarMonthView({
    super.key,
    required this.option,
    this.onDateChanged,
    this.onViewChanged,
    this.onBorderChanged,
    required this.view,
    this.onEventTapped,
  });

  @override
  State<TyxCalendarMonthView<T>> createState() =>
      _TyxCalendarMonthViewState<T>();
}

class _TyxCalendarMonthViewState<T extends TyxEvent>
    extends State<TyxCalendarMonthView<T>> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isLargeScreen = constraints.maxWidth > 600;
        return isLargeScreen
            ? TyxCalendarMonthViewLarge<T>(
                option: widget.option,
                onDateChanged: widget.onDateChanged,
                onViewChanged: widget.onViewChanged,
                onBorderChanged: widget.onBorderChanged,
                view: widget.view,
                onEventTapped: widget.onEventTapped,
              )
            : TyxCalendarMonthViewSmall<T>(
                option: widget.option,
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
