import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:timely_x/src/models/tyx_calendar_option.dart';
import 'package:timely_x/src/models/tyx_view.dart';
import 'package:timely_x/src/presentation/tyx_calendar/tyx_calendar_day/tyx_calendar_day_view.dart';
import 'package:timely_x/src/presentation/tyx_calendar/tyx_calendar_month/tyx_calendar_month_view.dart';
import 'package:timely_x/src/presentation/tyx_calendar/tyx_calendar_week/tyx_calendar_week_view.dart';

class TyxCalendarView extends StatefulWidget {
  const TyxCalendarView({
    super.key,
    this.onDateChanged,
    this.onShowDatePicker,
    required this.option,
    this.currentDateFormatter,
    this.onViewChanged,
  });
  final Function(DateTime date)? onDateChanged;
  final Function(TyxView view)? onViewChanged;
  final String Function(DateTime date)? currentDateFormatter;
  final Future<DateTime?> Function({required BuildContext context})?
      onShowDatePicker;
  final TyxCalendarOption option;

  @override
  State<TyxCalendarView> createState() => _TyxCalendarViewState();
}

class _TyxCalendarViewState extends State<TyxCalendarView> {
  TyxView _view = TyxView.month;

  late DateTime _currentDate;
  @override
  void initState() {
    super.initState();
    _currentDate = widget.option.initialDate ?? DateTime.now();
    _view = widget.option.initialView;
  }

  _onDateChanged(DateTime date) {
    _currentDate = date;
    widget.onDateChanged?.call(_currentDate);
  }

  _onViewChanged(TyxView view) {
    setState(() {
      _view = view;
      widget.onViewChanged?.call(_view);
    });
  }

  _gotoNextDate() {
    var nextDate = switch (_view) {
      TyxView.day =>
        Jiffy.parseFromDateTime(_currentDate).startOf(Unit.day).add(days: 1),
      TyxView.week =>
        Jiffy.parseFromDateTime(_currentDate).startOf(Unit.week).add(weeks: 1),
      TyxView.month => Jiffy.parseFromDateTime(_currentDate)
          .startOf(Unit.month)
          .add(months: 1),
    };

    _onDateChanged(nextDate.dateTime);
  }

  _gotoPreviousDate() {
    var nextDate = switch (_view) {
      TyxView.day => Jiffy.parseFromDateTime(_currentDate)
          .startOf(Unit.day)
          .subtract(days: 1),
      TyxView.week => Jiffy.parseFromDateTime(_currentDate)
          .startOf(Unit.week)
          .subtract(weeks: 1),
      TyxView.month => Jiffy.parseFromDateTime(_currentDate)
          .startOf(Unit.month)
          .subtract(months: 1),
    };

    _onDateChanged(nextDate.dateTime);
  }

  _onShowDatePicker({required BuildContext ctx}) async {
    if (!mounted) return;
    var pickedDate = widget.onShowDatePicker != null
        ? await widget.onShowDatePicker?.call(context: ctx)
        : await showDatePicker(
            context: ctx,
            initialDate: _currentDate,
            firstDate: _currentDate.subtract(const Duration(days: 365 * 20)),
            lastDate: _currentDate.add(const Duration(days: 365 * 5)),
          );
    if (pickedDate != null) {
      _onDateChanged(pickedDate);
    }
  }

  _formatCurrent() {
    return switch (_view) {
      TyxView.day => DateFormat("dd MMM yyyy").format(_currentDate),
      TyxView.week => DateFormat("dd MMM yyyy").format(_currentDate),
      TyxView.month => DateFormat("MMM yyyy").format(_currentDate),
    };
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        children: [
          // const SizedBox(height: 12),
          // Row(
          //   children: [
          //     Expanded(
          //       child: Row(
          //         children: [
          //           InkWell(
          //             onTap: () {
          //               _onShowDatePicker(ctx: context);
          //             },
          //             child: Padding(
          //               padding: const EdgeInsets.all(4.0),
          //               child: Row(
          //                 mainAxisSize: MainAxisSize.min,
          //                 children: [
          //                   Text(widget.currentDateFormatter != null
          //                       ? widget.currentDateFormatter!(_currentDate)
          //                       : _formatCurrent()),
          //                   const SizedBox(width: 2),
          //                   Transform.rotate(
          //                     angle: -pi / 2,
          //                     child: const Icon(
          //                       Icons.chevron_left,
          //                       weight: .5,
          //                       size: 17,
          //                     ),
          //                   ),
          //                 ],
          //               ),
          //             ),
          //           ),
          //           const SizedBox(width: 5),
          //           Container(
          //             padding: const EdgeInsets.all(3),
          //             decoration: BoxDecoration(
          //               borderRadius: BorderRadius.circular(15),
          //               border: Border.all(
          //                 color: Theme.of(context).colorScheme.outline,
          //               ),
          //             ),
          //             child: Row(
          //               children: [
          //                 InkWell(
          //                   onTap: _gotoPreviousDate,
          //                   child: Icon(
          //                     Icons.chevron_left,
          //                     weight: .5,
          //                     size: 17,
          //                     color: Theme.of(context).iconTheme.color,
          //                   ),
          //                 ),
          //                 const SizedBox(width: 2),
          //                 InkWell(
          //                   onTap: _gotoNextDate,
          //                   child: Icon(
          //                     Icons.chevron_right,
          //                     weight: .5,
          //                     size: 17,
          //                     color: Theme.of(context).iconTheme.color,
          //                   ),
          //                 )
          //               ],
          //             ),
          //           )
          //         ],
          //       ),
          //     ),
          //     const SizedBox(width: 10),
          //     Row(
          //       children: [
          //         for (var view in TyxView.values) ...[
          //           GestureDetector(
          //             onTap: () {
          //               setState(() {
          //                 _view = view;
          //               });
          //             },
          //             child: Container(
          //               padding: const EdgeInsets.symmetric(
          //                   horizontal: 8, vertical: 4),
          //               decoration: BoxDecoration(
          //                 borderRadius: BorderRadius.circular(15),
          //                 color: _view == view
          //                     ? Theme.of(context).colorScheme.surfaceContainer
          //                     : Colors.transparent,
          //               ),
          //               child: Text(
          //                 view.name[0].toUpperCase() + view.name.substring(1),
          //                 style: Theme.of(context)
          //                     .textTheme
          //                     .labelMedium
          //                     ?.copyWith(
          //                       color: Theme.of(context).colorScheme.onSurface,
          //                     ),
          //               ),
          //             ),
          //           ),
          //           const SizedBox(width: 5),
          //         ],
          //       ],
          //     )
          //   ],
          // ),
          // const SizedBox(height: 8),
          Expanded(
            //  key: ValueKey(_view),
            child: switch (_view) {
              TyxView.day => TyxCalendarDayView(
                  key: ValueKey(
                      "${_currentDate.year}-${_currentDate.month}-${_currentDate.day}"),
                  option: widget.option,
                  initialDate: _currentDate,
                  onViewChanged: _onViewChanged,
                  view: _view,
                  onDateSelected: _onDateChanged,
                  // onEventTapped: widget.onEventTapped,
                ),
              TyxView.week => TyxCalendarWeekView(
                  key: ValueKey(
                      "${_currentDate.year}-${_currentDate.month}-${_currentDate.day}"),
                  option: widget.option,
                  view: _view,
                  initialDate: _currentDate,
                  onViewChanged: _onViewChanged,
                  onDateChanged: (date) {
                    setState(() {
                      _currentDate = date;
                      widget.onDateChanged?.call(_currentDate);
                    });
                  },
                ),
              TyxView.month => TyxCalendarMonthView(
                  key: ValueKey("${_currentDate.year}-${_currentDate.month}"),
                  option: widget.option,
                  view: _view,
                  initialDate: _currentDate,
                  onViewChanged: _onViewChanged,
                  onDateChanged: (date) {
                    setState(() {
                      _currentDate = date;
                      widget.onDateChanged?.call(_currentDate);
                    });
                  },
                ),
            },
          ),
        ],
      ),
    );
  }
}
