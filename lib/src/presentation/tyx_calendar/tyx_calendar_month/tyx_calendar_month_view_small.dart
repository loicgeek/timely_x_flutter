import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timely_x/src/models/tyx_calendar_border.dart';
import 'package:timely_x/src/models/tyx_view.dart';
import 'package:timely_x/timely_x.dart';

class TyxCalendarMonthViewSmall<T extends TyxEvent> extends StatefulWidget {
  final TyxCalendarOption<T> option;
  final DateTime? initialDate;

  final Function(T)? onEventTapped;
  final void Function(DateTime date, List<T> events)? onDateChanged;
  final Function(TyxView view)? onViewChanged;
  final Function(TyxCalendarBorder border)? onBorderChanged;
  final TyxView view;

  const TyxCalendarMonthViewSmall({
    super.key,
    required this.option,
    this.initialDate,
    this.onEventTapped,
    this.onDateChanged,
    this.onViewChanged,
    this.onBorderChanged,
    required this.view,
  });

  @override
  State<TyxCalendarMonthViewSmall<T>> createState() =>
      _TyxCalendarMonthViewSmallState<T>();
}

class _TyxCalendarMonthViewSmallState<T extends TyxEvent>
    extends State<TyxCalendarMonthViewSmall<T>> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;
  final ScrollController _eventsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _currentMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
  }

  @override
  void dispose() {
    _eventsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDayHeader(),
        const SizedBox(height: 10),
        _buildWeekdayHeaders(),
        Expanded(
          child: ListView(
            children: [
              _buildCalendarGrid(),
              _buildSelectedDayEvents(),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildDayHeader() {
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Today button
              // OutlinedButton(
              //   onPressed: () {
              //     final now = DateTime.now();
              //     setState(() {
              //       _selectedDate = now;
              //     });
              //     widget.onDateChanged?.call(now);
              //   },
              //   child: const Text('Today'),
              // ),
              // const SizedBox(width: 16),
              // View type selector
              Expanded(
                child: SegmentedButton<TyxView>(
                  segments: TyxView.values
                      .map((view) =>
                          ButtonSegment(value: view, label: Text(view.name)))
                      .toList(),
                  selected: {widget.view},
                  onSelectionChanged: (Set<TyxView> newSelection) {
                    widget.onViewChanged?.call(newSelection.first);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                children: [
                  Text(
                    DateFormat('MMMM, yyyy').format(_currentMonth),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    // Get weekday names from DateFormat
    final fullWeekdays = DateFormat()
        .dateSymbols
        .SHORTWEEKDAYS; // Use short day names for mobile

    // Get the start day of week from options, default to Monday if not specified
    final startWeekDay =
        widget.option.startWeekDay ?? 1; // 1 = Monday, 7 = Sunday

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
                    style: theme.textTheme.bodySmall?.copyWith(
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

    // Calculate the number of rows needed for the grid
    final int rowCount = (daysInMonth.length / 7).ceil();

    // Calculate height based on device size, but ensure it's not too large
    final double cellWidth = MediaQuery.of(context).size.width / 7;
    final double cellHeight =
        cellWidth * 0.9; // Make cells slightly shorter than wide

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: cellWidth / cellHeight,
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
    final isSelected = isSameDay(day, _selectedDate);
    final isCurrentMonth = day.month == _currentMonth.month;
    final events = _getEventsForDay(day);

    if (widget.option.showTrailingDays == false && !isCurrentMonth) {
      return const SizedBox.shrink();
    }

    var theme = Theme.of(context);
    var colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedDate = day;
        });
        widget.onDateChanged?.call(day, events);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isToday
                ? colorScheme.primary
                : isSelected
                    ? colorScheme.secondary
                    : colorScheme.outlineVariant,
            width: (isToday || isSelected) ? 1.5 : 0.5,
          ),
          borderRadius: BorderRadius.circular(4),
          color: isSelected
              ? colorScheme.secondaryContainer.withOpacity(0.3)
              : null,
        ),
        margin: const EdgeInsets.all(1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Day number
            Text(
              day.day.toString(),
              style: TextStyle(
                fontWeight:
                    isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                color: !isCurrentMonth
                    ? theme.disabledColor
                    : isSelected
                        ? colorScheme.onSecondaryContainer
                        : null,
                fontSize: 14,
              ),
            ),

            // Event indicator
            if (events.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final event in events) ...[
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: ColorScheme.fromSeed(seedColor: event.color)
                            .primary,
                        shape: BoxShape.circle,
                      ),
                    )
                  ],
                ],
              )
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDayEvents() {
    final selectedDayEvents = _getEventsForDay(_selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            DateFormat('EEEE, MMMM d').format(_selectedDate),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        selectedDayEvents.isEmpty
            ? Center(
                child: Text(
                  'No events for this day',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).disabledColor,
                      ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                controller: _eventsScrollController,
                padding: EdgeInsets.zero,
                itemCount: selectedDayEvents.length,
                itemBuilder: (context, index) {
                  final event = selectedDayEvents[index];
                  return _buildEventCard(event);
                },
              ),
      ],
    );
  }

  Widget _buildEventCard(T event) {
    var colorScheme = ColorScheme.fromSeed(seedColor: event.color);

    return InkWell(
      onTap: () => widget.onEventTapped?.call(event),
      borderRadius: BorderRadius.circular(8),
      child: widget.option.monthOption?.eventListTileBuilder != null
          ? widget.option.monthOption!.eventListTileBuilder!(context, event)
          : Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 1,
              surfaceTintColor: colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 4,
                      height: 50,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title ?? 'Untitled Event',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${TimeOfDay.fromDateTime(event.start).format(context)} - ${TimeOfDay.fromDateTime(event.end).format(context)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (event.location != null &&
                              event.location!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 14,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      event.location!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color:
                                                Theme.of(context).disabledColor,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
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
    return (widget.option.events ?? List<T>.from([]))
        .where((event) => isSameDay(event.start, day))
        .toList();
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
