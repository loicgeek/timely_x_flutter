import 'package:flutter/material.dart';
import 'package:timely_x_flutter/src/models/tyx_calendar_option.dart';
import 'package:timely_x_flutter/src/models/tyx_view.dart';
import 'package:timely_x_flutter/src/presentation/tyx_calendar/tyx_calendar_month/tyx_calendar_month_view_large.dart';
import 'package:timely_x_flutter/src/presentation/tyx_calendar/tyx_calendar_month/tyx_calendar_month_view_small.dart';

class TyxCalendarMonthView extends StatefulWidget {
  final TyxCalendarOption option;
  final DateTime? initialDate;
  final Function(DateTime date)? onDateChanged;
  final Function(TyxView view)? onViewChanged;
  final TyxView view;
  const TyxCalendarMonthView({
    super.key,
    required this.option,
    this.initialDate,
    this.onDateChanged,
    this.onViewChanged,
    required this.view,
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
                view: widget.view,
              )
            : TyxCalendarMonthViewSmall(
                option: widget.option,
                initialDate: widget.initialDate,
                onDateChanged: widget.onDateChanged,
                onViewChanged: widget.onViewChanged,
                view: widget.view,
              );
      },
    );
  }
}
