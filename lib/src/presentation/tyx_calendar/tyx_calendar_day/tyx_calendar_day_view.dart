import 'package:flutter/material.dart';
import 'package:timely_x_flutter/src/models/tyx_view.dart';
import 'package:timely_x_flutter/src/presentation/tyx_calendar/tyx_calendar_day/tyx_calendar_day_view_large.dart';
import 'package:timely_x_flutter/src/presentation/tyx_calendar/tyx_calendar_day/tyx_calendar_day_view_small.dart';
import 'package:timely_x_flutter/timely_x_flutter.dart';

class TyxCalendarDayView extends StatefulWidget {
  const TyxCalendarDayView({
    super.key,
    required this.option,
    this.initialDate,
    this.onDateSelected,
    this.onEventTapped,
    this.onDateChanged,
    this.onViewChanged,
    required this.view,
  });
  final TyxCalendarOption option;
  final DateTime? initialDate;
  final Function(DateTime)? onDateSelected;
  final Function(TyxEvent)? onEventTapped;
  final Function(DateTime date)? onDateChanged;
  final Function(TyxView view)? onViewChanged;
  final TyxView view;

  @override
  State<TyxCalendarDayView> createState() => _TyxCalendarDayViewState();
}

class _TyxCalendarDayViewState extends State<TyxCalendarDayView> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isLargeScreen = constraints.maxWidth > 600;
        return isLargeScreen
            ? TyxCalendarDayViewLarge(
                option: widget.option,
                onDateSelected: widget.onDateSelected,
                onEventTapped: widget.onEventTapped,
                onDateChanged: widget.onDateChanged,
                onViewChanged: widget.onViewChanged,
                view: widget.view,
              )
            : TyxCalendarDayViewSmall(
                option: widget.option,
                onDateSelected: widget.onDateSelected,
                onEventTapped: widget.onEventTapped,
                onDateChanged: widget.onDateChanged,
                onViewChanged: widget.onViewChanged,
                view: widget.view,
              );
      },
    );
  }
}
