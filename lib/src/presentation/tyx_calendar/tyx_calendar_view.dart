import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:timely_x/src/models/tyx_calendar_border.dart';
import 'package:timely_x/src/presentation/tyx_calendar/tyx_calendar_day/tyx_calendar_day_view.dart';
import 'package:timely_x/src/presentation/tyx_calendar/tyx_calendar_month/tyx_calendar_month_view.dart';
import 'package:timely_x/src/presentation/tyx_calendar/tyx_calendar_week/tyx_calendar_week_view.dart';
import 'package:timely_x/src/presentation/tyx_calendar/tyx_calendar_customiser.dart';
import 'package:timely_x/timely_x.dart';

class TyxCalendarView<T extends TyxEvent> extends StatefulWidget {
  const TyxCalendarView({
    super.key,
    this.onDateChanged,
    this.onShowDatePicker,
    required this.option,
    this.currentDateFormatter,
    this.onViewChanged,
    this.customizer,
    this.onBorderChanged,
    this.onEventTapped,
    this.onRightClick,
    this.events,
  });
  final Function(DateTime date, List<T> events)? onDateChanged;
  final Function(TyxView view)? onViewChanged;
  final String Function(DateTime date)? currentDateFormatter;
  final Future<DateTime?> Function({required BuildContext context})?
      onShowDatePicker;
  final TyxCalendarOption<T> option;
  final TyxCalendarCustomizer? customizer;
  final Function(TyxCalendarBorder border)? onBorderChanged;
  final Function(T)? onEventTapped;
  final OnRightClick? onRightClick;
  final List<T>? events;

  @override
  State<TyxCalendarView<T>> createState() => _TyxCalendarViewState<T>();
}

class _TyxCalendarViewState<T extends TyxEvent>
    extends State<TyxCalendarView<T>> {
  TyxView _view = TyxView.month;

  late DateTime _currentDate;
  List<T>? _events;
  @override
  void initState() {
    super.initState();
    _currentDate = widget.option.initialDate ?? DateTime.now();
    _view = widget.option.initialView;
    _events = widget.events;
  }

  @override
  void didUpdateWidget(covariant TyxCalendarView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool hasChanged = widget.events != oldWidget.events ||
        widget.option.initialDate != oldWidget.option.initialDate ||
        widget.option.initialView != oldWidget.option.initialView;

    // Compare the references or perform a deeper equality check
    if (widget.events != oldWidget.events) {
      _events = widget.events;
    }

    if (widget.option.initialDate != oldWidget.option.initialDate) {
      _currentDate = widget.option.initialDate ?? DateTime.now();
      if (widget.option.initialDate?.month !=
              oldWidget.option.initialDate?.month &&
          widget.option.initialView == TyxView.month) {
        _onViewChanged(TyxView.month);
      }
    }

    if (widget.option.initialView != oldWidget.option.initialView) {
      _view = widget.option.initialView;
    }
    if (hasChanged) {
      setState(() {});
    }
  }

  _onDateChanged(DateTime date) {
    _currentDate = date;
    widget.onDateChanged?.call(_currentDate, []);
  }

  _onViewChanged(TyxView view) {
    setState(() {
      _view = view;
      widget.onViewChanged?.call(_view);
      if (view == TyxView.day) {
        _currentDate =
            DateTime(_currentDate.year, _currentDate.month, _currentDate.day);
        widget.onBorderChanged?.call(TyxCalendarBorder(
          start: _currentDate,
          end: DateTime(_currentDate.year, _currentDate.month, _currentDate.day,
              23, 59, 59), // Last day of the day
        ));
      }
      if (view == TyxView.week) {
        DateTime firstDayOfTheWeek =
            Jiffy.parseFromDateTime(_currentDate).startOf(Unit.week).dateTime;
        _currentDate = firstDayOfTheWeek;
        widget.onBorderChanged?.call(TyxCalendarBorder(
          start: firstDayOfTheWeek,
          end: DateTime(firstDayOfTheWeek.year, firstDayOfTheWeek.month,
              firstDayOfTheWeek.day + 6, 23, 59, 59), // Last day of the month
        ));
      } else if (view == TyxView.month) {
        DateTime firstDayOfTheMonth =
            Jiffy.parseFromDateTime(_currentDate).startOf(Unit.month).dateTime;
        _currentDate = firstDayOfTheMonth;
        widget.onBorderChanged?.call(TyxCalendarBorder(
          start: firstDayOfTheMonth,
          end: DateTime(firstDayOfTheMonth.year, firstDayOfTheMonth.month + 1,
              0, 23, 59, 59), // Last day of the month
        ));
      }
    });
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
          Expanded(
            child: switch (_view) {
              TyxView.day => TyxCalendarDayView<T>(
                  onEventTapped: widget.onEventTapped,
                  key: ValueKey(
                      "${_currentDate.year}-${_currentDate.month}-${_currentDate.day}"),
                  option: widget.option,
                  events: _events,
                  onViewChanged: _onViewChanged,
                  view: _view,
                  onDateChanged: _onDateChanged,
                  onBorderChanged: widget.onBorderChanged,
                  onRightClick: widget.onRightClick,

                  // onEventTapped: widget.onEventTapped,
                ),
              TyxView.week => TyxCalendarWeekView<T>(
                  onEventTapped: widget.onEventTapped,
                  key: ValueKey(
                      "${_currentDate.year}-${_currentDate.month}-${_currentDate.day}"),
                  option: widget.option,
                  view: _view,
                  onViewChanged: _onViewChanged,
                  onDateChanged: (date, events) {
                    setState(() {
                      _currentDate = date;
                      widget.onDateChanged?.call(_currentDate, events);
                    });
                  },
                  events: _events,
                  onBorderChanged: widget.onBorderChanged,
                  onRightClick: widget.onRightClick,
                ),
              TyxView.month => TyxCalendarMonthView<T>(
                  onEventTapped: widget.onEventTapped,
                  key: ValueKey("${_currentDate.year}-${_currentDate.month}"),
                  option: widget.option,
                  view: _view,
                  events: _events,
                  onViewChanged: _onViewChanged,
                  onDateChanged: (date, events) {
                    setState(() {
                      _currentDate = date;
                      widget.onDateChanged?.call(_currentDate, events);
                    });
                  },
                  onBorderChanged: widget.onBorderChanged,
                  onRightClick: widget.onRightClick,
                ),
            },
          ),
        ],
      ),
    );
  }
}
