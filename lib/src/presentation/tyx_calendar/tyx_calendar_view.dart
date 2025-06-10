import 'package:flutter/material.dart';
import 'package:timely_x/src/models/tyx_calendar_border.dart';
import 'package:timely_x/src/models/tyx_calendar_option.dart';
import 'package:timely_x/src/models/tyx_view.dart';
import 'package:timely_x/src/presentation/tyx_calendar/tyx_calendar_day/tyx_calendar_day_view.dart';
import 'package:timely_x/src/presentation/tyx_calendar/tyx_calendar_month/tyx_calendar_month_view.dart';
import 'package:timely_x/src/presentation/tyx_calendar/tyx_calendar_week/tyx_calendar_week_view.dart';
import 'package:timely_x/src/presentation/tyx_calendar/tyx_calendar_customiser.dart';

class TyxCalendarView extends StatefulWidget {
  const TyxCalendarView({
    super.key,
    this.onDateChanged,
    this.onShowDatePicker,
    required this.option,
    this.currentDateFormatter,
    this.onViewChanged,
    this.customizer,
    this.onBorderChanged,
  });
  final Function(DateTime date)? onDateChanged;
  final Function(TyxView view)? onViewChanged;
  final String Function(DateTime date)? currentDateFormatter;
  final Future<DateTime?> Function({required BuildContext context})?
      onShowDatePicker;
  final TyxCalendarOption option;
  final TyxCalendarCustomizer? customizer;
  final Function(TyxCalendarBorder border)? onBorderChanged;

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
                  onBorderChanged: widget.onBorderChanged,
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
                  onBorderChanged: widget.onBorderChanged,
                ),
            },
          ),
        ],
      ),
    );
  }
}
