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
    this.getEvents,
  });
  final Function(DateTime date, List<T> events)? onDateChanged;
  final Function(TyxView view)? onViewChanged;
  final String Function(DateTime date)? currentDateFormatter;
  final Future<DateTime?> Function({required BuildContext context})?
      onShowDatePicker;
  final TyxCalendarOption<T> option;
  final TyxCalendarCustomizer? customizer;
  final Function(TyxCalendarBorder border)? onBorderChanged;
  final Future<List<T>> Function(TyxCalendarBorder border)? getEvents;
  final Function(T)? onEventTapped;
  final OnRightClick? onRightClick;
  final List<T>? events;

  @override
  State<TyxCalendarView<T>> createState() => TyxCalendarViewState<T>();
}

class TyxCalendarViewState<T extends TyxEvent>
    extends State<TyxCalendarView<T>> {
  TyxView _view = TyxView.month;

  late DateTime _currentDate;
  List<T>? _events;
  late TyxCalendarBorder _border;
  late TyxCalendarOption<T> _option;
  @override
  void initState() {
    super.initState();
    _option = widget.option;
    _currentDate = widget.option.initialDate ?? DateTime.now();
    _view = widget.option.initialView;
    _events = widget.events;
    _border = _getBorder(_currentDate, _view);
  }

  @override
  void didUpdateWidget(covariant TyxCalendarView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint("widget updated");
    bool hasChanged = widget.events != oldWidget.events ||
        widget.option.initialDate != oldWidget.option.initialDate ||
        widget.option.initialView != oldWidget.option.initialView;

    // Compare the references or perform a deeper equality check
    if (widget.events != oldWidget.events) {
      debugPrint("events changed");
      _events = widget.events;
    }

    if (widget.option.initialDate != oldWidget.option.initialDate) {
      debugPrint("initial date changed");
      _currentDate = widget.option.initialDate ?? DateTime.now();
    }

    if (widget.option.initialView != oldWidget.option.initialView) {
      debugPrint("initial view changed");
      _view = widget.option.initialView;
    }
    if (hasChanged) {
      setState(() {});
    }
  }

  _onDateChanged(DateTime date) {
    _currentDate = date;
    _option.initialDate = date;
    widget.onDateChanged?.call(_currentDate, []);
  }

  navigateToDate(DateTime date) {
    var newBorder = _getBorder(date, _view);
    bool borderHasChanged = newBorder != _border;
    _onDateChanged(date);
    if (borderHasChanged) {
      _onBorderChanged(newBorder, initialDate: date);
    }
  }

  TyxCalendarBorder _getBorder(DateTime date, TyxView view) {
    switch (view) {
      case TyxView.day:
        return TyxCalendarBorder(
          start: date,
          end: DateTime(date.year, date.month, date.day, 23, 59,
              59), // Last day of the day
        );
      case TyxView.week:
        DateTime firstDayOfTheWeek =
            Jiffy.parseFromDateTime(date).startOf(Unit.week).dateTime;
        return TyxCalendarBorder(
          start: firstDayOfTheWeek,
          end: DateTime(firstDayOfTheWeek.year, firstDayOfTheWeek.month,
              firstDayOfTheWeek.day + 6, 23, 59, 59), // Last day of the month
        );
      case TyxView.month:
        DateTime firstDayOfTheMonth =
            Jiffy.parseFromDateTime(date).startOf(Unit.month).dateTime;
        return TyxCalendarBorder(
          start: firstDayOfTheMonth,
          end: DateTime(firstDayOfTheMonth.year, firstDayOfTheMonth.month + 1,
              0, 23, 59, 59), // Last day of the month
        );
    }
  }

  _onBorderChanged(TyxCalendarBorder border, {DateTime? initialDate}) async {
    //_border = border;

    debugPrint("border changed: ${border.start}-${border.end}");
    _option.initialDate = initialDate ?? border.start;
    widget.onBorderChanged?.call(border);
  }

  _onViewChanged(TyxView view) {
    setState(() {
      _view = view;
      widget.onViewChanged?.call(_view);
      if (view == TyxView.day) {
        _currentDate =
            DateTime(_currentDate.year, _currentDate.month, _currentDate.day);

        _onBorderChanged(_getBorder(_currentDate, view));
      }
      if (view == TyxView.week) {
        DateTime firstDayOfTheWeek =
            Jiffy.parseFromDateTime(_currentDate).startOf(Unit.week).dateTime;
        _currentDate = firstDayOfTheWeek;

        _onBorderChanged(_getBorder(_currentDate, view));
      } else if (view == TyxView.month) {
        DateTime firstDayOfTheMonth =
            Jiffy.parseFromDateTime(_currentDate).startOf(Unit.month).dateTime;
        _currentDate = firstDayOfTheMonth;
        _onBorderChanged(_getBorder(_currentDate, view));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    debugPrint("built calendar");
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        children: [
          Expanded(
            key: ValueKey("${_events}"),
            child: switch (_view) {
              TyxView.day => TyxCalendarDayView<T>(
                  onEventTapped: widget.onEventTapped,
                  key: ValueKey(
                      "${_currentDate.year}-${_currentDate.month}-${_currentDate.day}"),
                  option: _option,
                  events: _events,
                  onViewChanged: _onViewChanged,
                  view: _view,
                  onDateChanged: _onDateChanged,
                  onBorderChanged: _onBorderChanged,
                  onRightClick: widget.onRightClick,

                  // onEventTapped: widget.onEventTapped,
                ),
              TyxView.week => TyxCalendarWeekView<T>(
                  onEventTapped: widget.onEventTapped,
                  key: ValueKey(
                      "${_currentDate.year}-${_currentDate.month}-${_currentDate.day}"),
                  option: _option,
                  view: _view,
                  onViewChanged: _onViewChanged,
                  onDateChanged: (date, events) {
                    setState(() {
                      _currentDate = date;
                      widget.onDateChanged?.call(_currentDate, events);
                    });
                  },
                  events: _events,
                  onBorderChanged: _onBorderChanged,
                  onRightClick: widget.onRightClick,
                ),
              TyxView.month => TyxCalendarMonthView<T>(
                  onEventTapped: widget.onEventTapped,
                  key: ValueKey("${_currentDate.year}-${_currentDate.month}"),
                  option: _option,
                  view: _view,
                  events: _events,
                  onViewChanged: _onViewChanged,
                  onDateChanged: (date, events) {
                    setState(() {
                      _currentDate = date;
                      widget.onDateChanged?.call(_currentDate, events);
                    });
                  },
                  onBorderChanged: _onBorderChanged,
                  onRightClick: widget.onRightClick,
                ),
            },
          ),
        ],
      ),
    );
  }
}
