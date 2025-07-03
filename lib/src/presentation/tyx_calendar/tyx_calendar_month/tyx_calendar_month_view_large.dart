import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timely_x/src/models/tyx_calendar_border.dart';

import 'package:timely_x/timely_x.dart';

class TyxCalendarMonthViewLarge<T extends TyxEvent> extends StatefulWidget {
  final TyxCalendarOption<T> option;

  final Function(DateTime date, List<T> events)? onDateChanged;
  final Function(TyxView view)? onViewChanged;
  final TyxView view;
  final Function(TyxCalendarBorder border)? onBorderChanged;
  final Function(T)? onEventTapped;
  const TyxCalendarMonthViewLarge({
    super.key,
    required this.option,
    this.onDateChanged,
    this.onViewChanged,
    this.onBorderChanged,
    required this.view,
    this.onEventTapped,
  });

  @override
  State<TyxCalendarMonthViewLarge<T>> createState() =>
      _TyxCalendarMonthViewLargeState<T>();
}

class _TyxCalendarMonthViewLargeState<T extends TyxEvent>
    extends State<TyxCalendarMonthViewLarge<T>> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.option.initialDate ?? DateTime.now();
    _currentMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMonthHeader(),
        _buildWeekdayHeaders(),
        Expanded(
          child: _buildCalendarGrid(),
        ),
      ],
    );
  }

  Widget _buildMonthHeader() {
    var theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    final newDate = DateTime(
                        _currentMonth.year, _currentMonth.month - 1, 1);
                    _currentMonth = newDate;
                    widget.onBorderChanged?.call(TyxCalendarBorder(
                      start: DateTime(newDate.year, newDate.month,
                          1), // First day of the month
                      end: DateTime(newDate.year, newDate.month + 1, 0, 23, 59,
                          59), // Last day of the month
                    ));
                  });
                },
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MMM yyyy').format(_currentMonth),
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    final newDate = DateTime(
                        _currentMonth.year, _currentMonth.month + 1, 1);
                    _currentMonth = newDate;

                    widget.onBorderChanged?.call(TyxCalendarBorder(
                      start: DateTime(newDate.year, newDate.month,
                          1), // First day of the month
                      end: DateTime(newDate.year, newDate.month + 1, 0, 23, 59,
                          59), // Last day of the month
                    ));
                  });
                },
              ),
            ],
          ),
          Row(
            children: [
              // Today button
              OutlinedButton(
                onPressed: () {
                  final now = DateTime.now();
                  setState(() {
                    _selectedDate = now;
                  });
                  widget.onDateChanged?.call(now, _getEventsForDay(now));
                },
                child: const Text('Today'),
              ),
              const SizedBox(width: 16),
              // View type selector
              SegmentedButton<TyxView>(
                segments: TyxView.values
                    .map((view) =>
                        ButtonSegment(value: view, label: Text(view.name)))
                    .toList(),
                selected: {widget.view},
                onSelectionChanged: (Set<TyxView> newSelection) {
                  widget.onViewChanged?.call(newSelection.first);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    // Get weekday names from DateFormat
    final fullWeekdays = DateFormat().dateSymbols.WEEKDAYS;

    // Get the start day of week from options, default to Monday if not specified
    final startWeekDay =
        widget.option.startWeekDay ?? 1; // 1 = Monday, 7 = Sunday

    // In DateFormat's array:
    // Sunday is at index 0, Monday is at index 1, etc.
    // In DateTime's weekday property:
    // Monday is 1, Tuesday is 2, ..., Sunday is 7

    // Convert from DateTime's weekday (1-7) to DateFormat array index (0-6)
    int startIndex = startWeekDay == 7 ? 0 : startWeekDay;

    // Reorder array to start from desired day
    final weekdays = [
      ...fullWeekdays.sublist(startIndex),
      ...fullWeekdays.sublist(0, startIndex)
    ];

    var theme = Theme.of(context);
    var colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekdays
            .map((day) => Expanded(
                  child: Text(
                    day,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = _getDaysInMonth();

    return GridView.builder(
      // physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 16 / 10,
      ),
      itemCount: daysInMonth.length,
      itemBuilder: (context, index) {
        final day = daysInMonth[index];
        return _buildDayCell(day);
      },
    );
  }

  Widget _buildDayCell(DateTime day) {
    final isToday = _isToday(day);

    final isCurrentMonth = day.month == _currentMonth.month;
    final dayEvents = _getEventsForDay(day);
    if (widget.option.showTrailingDays == false && !isCurrentMonth) {
      return const SizedBox.shrink();
    }

    var theme = Theme.of(context);
    var colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isToday ? colorScheme.secondary : colorScheme.outlineVariant,
          width: isToday ? 1 : .5,
        ),
      ),
      child: Column(
        children: [
          // Day number
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              borderRadius: isToday
                  ? const BorderRadius.vertical(top: Radius.circular(0))
                  : null,
            ),
            child: Text(
              day.day.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: !isCurrentMonth ? theme.disabledColor : null,
              ),
            ),
          ),

          // Events for the day
          Expanded(
            child: dayEvents.isEmpty
                ? const SizedBox() // Empty placeholder
                : ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                    itemCount: dayEvents.length,
                    itemBuilder: (context, index) {
                      final event = dayEvents[index];
                      return _buildEventIndicator(event);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventIndicator(T event) {
    var colorScheme = ColorScheme.fromSeed(seedColor: event.color);
    return GestureDetector(
      onTap: () {
        widget.onEventTapped?.call(event);
      },
      child: widget.option.monthOption?.eventIndicatorBuilder != null
          ? widget.option.monthOption!.eventIndicatorBuilder!(context, event)
          : Container(
              margin: const EdgeInsets.only(bottom: 2),
              padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
              decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                  border: Border(
                      left: BorderSide(
                    color: colorScheme.primary,
                    width: 5,
                  ))),
              child: Text(
                "${TimeOfDay.fromDateTime(event.start).format(context)} ${event.title ?? ''}",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
    );
  }

  List<DateTime> _getDaysInMonth() {
    // First day of the month
    final firstDay = _currentMonth;

    // Get the start day of week from options, default to Monday if not specified
    final startWeekDay =
        widget.option.startWeekDay ?? 1; // 1 = Monday, 7 = Sunday

    // Calculate the correct offset
    // If firstDay weekday is same as startWeekDay, offset is 0
    // Otherwise we need to go back to the previous occurrence of startWeekDay
    int diff = firstDay.weekday - startWeekDay;
    int daysToSubtract = diff < 0 ? diff + 7 : diff;

    final startDate = firstDay.subtract(Duration(days: daysToSubtract));

    // Generate 42 days (6 weeks) to ensure we have enough days to cover all layouts
    return List.generate(42, (index) {
      return startDate.add(Duration(days: index));
    });
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  List<T> _getEventsForDay(DateTime day) {
    return (widget.option.events ?? [])
        .where((event) => isSameDay(event.start, day))
        .toList();
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
