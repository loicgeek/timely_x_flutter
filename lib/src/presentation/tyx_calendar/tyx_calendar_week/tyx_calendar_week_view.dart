import 'package:flutter/material.dart';

import 'package:timely_x_flutter/timely_x_flutter.dart';

import 'tyx_calendar_week_view_large.dart';
import 'tyx_calendar_week_view_small.dart';

class TyxCalendarWeekView extends StatefulWidget {
  final TyxCalendarOption option;
  final DateTime? initialDate;
  final Function(DateTime date)? onDateChanged;
  final Function(TyxView view)? onViewChanged;
  final Function(TyxEvent)? onEventTapped;
  final TyxView view;

  const TyxCalendarWeekView({
    super.key,
    required this.option,
    this.initialDate,
    this.onDateChanged,
    this.onViewChanged,
    this.onEventTapped,
    required this.view,
  });

  @override
  State<TyxCalendarWeekView> createState() => _TyxCalendarWeekViewState();
}

class _TyxCalendarWeekViewState extends State<TyxCalendarWeekView> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // bool isLargeScreen = constraints.maxWidth > 600;
        return TyxCalendarWeekViewLarge(
          option: widget.option,
          initialDate: widget.initialDate,
          onDateChanged: widget.onDateChanged,
          onViewChanged: widget.onViewChanged,
          onEventTapped: widget.onEventTapped,
          view: widget.view,
        );
        // return isLargeScreen
        //     ? TyxCalendarWeekViewLarge(
        //         option: widget.option,
        //         initialDate: widget.initialDate,
        //         onDateChanged: widget.onDateChanged,
        //         onViewChanged: widget.onViewChanged,
        //         onEventTapped: widget.onEventTapped,
        //         view: widget.view,
        //       )
        //     : TyxCalendarWeekViewSmall(
        //         option: widget.option,
        //         initialDate: widget.initialDate,
        //         onDateChanged: widget.onDateChanged,
        //         onViewChanged: widget.onViewChanged,
        //         onEventTapped: widget.onEventTapped,
        //         view: widget.view,
        //       );
      },
    );
  }
}
