import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timely_x/src/models/tyx_calendar_border.dart';
import 'package:timely_x/timely_x.dart';

class TyxCalendarWeekViewLarge extends StatefulWidget {
  final TyxCalendarOption option;
  final DateTime? initialDate;
  final Function(DateTime date)? onDateChanged;
  final Function(TyxView view)? onViewChanged;
  final Function(TyxEvent)? onEventTapped;
  final Function(TyxCalendarBorder border)? onBorderChanged;
  final TyxView view;

  const TyxCalendarWeekViewLarge({
    super.key,
    required this.option,
    this.initialDate,
    this.onDateChanged,
    this.onViewChanged,
    this.onEventTapped,
    this.onBorderChanged,
    required this.view,
  });

  @override
  State<TyxCalendarWeekViewLarge> createState() =>
      _TyxCalendarWeekViewLargeState();
}

class _TyxCalendarWeekViewLargeState extends State<TyxCalendarWeekViewLarge> {
  late DateTime _selectedDate;
  late List<DateTime> _weekDays;
  final ScrollController _scrollController = ScrollController();
  final double _hourHeight = 60.0;
  int _startHour = 6; // 6 AM
  int _endHour = 22; // 10 PM

  @override
  void initState() {
    super.initState();
    _startHour = widget.option.timeslotStartTime?.hour ?? 0;
    _endHour = widget.option.timeslotEndTime?.hour ?? 24;
    _selectedDate = widget.initialDate ?? DateTime.now();
    _weekDays = _getWeekDays(_selectedDate);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  DateTime _getStartOfWeek(DateTime date) {
    // Get the start day of week from options, default to Monday if not specified
    final startWeekDay =
        widget.option.startWeekDay ?? 1; // 1 = Monday, 7 = Sunday
    return date.subtract(Duration(days: (date.weekday - startWeekDay) % 7));
  }

  List<DateTime> _getWeekDays(DateTime date) {
    // Get the start day of week from options, default to Monday if not specified

    // Find the first day of the week containing the given date
    final firstDayOfWeek = _getStartOfWeek(date);

    // Generate 7 days starting from the first day of the week
    return List.generate(
      7,
      (index) => firstDayOfWeek.add(Duration(days: index)),
    );
  }

  void _previousWeek() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 7));
      final startOfWeek = _getStartOfWeek(_selectedDate);

      // End of week (Sunday at 23:59:59)
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      final endOfWeekWithTime =
          DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59);

      widget.onBorderChanged?.call(TyxCalendarBorder(
        start: startOfWeek,
        end: endOfWeekWithTime,
      ));

      _weekDays = _getWeekDays(_selectedDate);
      widget.onDateChanged?.call(_selectedDate);
    });
  }

  void _nextWeek() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 7));
      final startOfWeek = _getStartOfWeek(_selectedDate);

      // End of week (Sunday at 23:59:59)
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      final endOfWeekWithTime =
          DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59);

      widget.onBorderChanged?.call(TyxCalendarBorder(
        start: startOfWeek,
        end: endOfWeekWithTime,
      ));
      _weekDays = _getWeekDays(_selectedDate);
      widget.onDateChanged?.call(_selectedDate);
    });
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildWeekHeader(),
        _buildDayHeaders(),
        Expanded(
          child: _buildTimeGrid(),
        ),
      ],
    );
  }

  Widget _buildWeekHeader() {
    var theme = Theme.of(context);
    final firstDayOfWeek = _weekDays.first;
    final lastDayOfWeek = _weekDays.last;

    String headerText;
    if (firstDayOfWeek.month == lastDayOfWeek.month) {
      // Same month
      headerText = DateFormat('MMMM yyyy').format(firstDayOfWeek);
    } else if (firstDayOfWeek.year == lastDayOfWeek.year) {
      // Different months, same year
      headerText =
          '${DateFormat('MMM').format(firstDayOfWeek)} - ${DateFormat('MMM yyyy').format(lastDayOfWeek)}';
    } else {
      // Different years
      headerText =
          '${DateFormat('MMM yyyy').format(firstDayOfWeek)} - ${DateFormat('MMM yyyy').format(lastDayOfWeek)}';
    }

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
      child: LayoutBuilder(builder: (context, constraints) {
        bool isLargeScreen = constraints.maxWidth > 600;
        if (isLargeScreen) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _previousWeek,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        headerText,
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _nextWeek,
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
                        _weekDays = _getWeekDays(_selectedDate);
                      });
                      widget.onDateChanged?.call(now);
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
          );
        } else {
          return SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<TyxView>(
                        segments: TyxView.values
                            .map((view) => ButtonSegment(
                                value: view, label: Text(view.name)))
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
                      onPressed: _previousWeek,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          headerText,
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          "${DateFormat('MMMM d').format(_weekDays.first)} - ${DateFormat('MMMM d').format(_weekDays.last)}",
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _nextWeek,
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      }),
    );
  }

  Widget _buildDayHeaders() {
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
        children: [
          // Time column header
          SizedBox(
            width: 60,
            child: Text(
              '',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          // Day headers
          ...List.generate(7, (index) {
            DateTime day = _weekDays[index];
            bool isToday = _isToday(day);

            return Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isToday
                      ? colorScheme.primaryContainer.withOpacity(0.3)
                      : null,
                  border: Border(
                    left: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('E').format(day),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      day.day.toString(),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight:
                            isToday ? FontWeight.bold : FontWeight.normal,
                        color: isToday ? colorScheme.primary : null,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimeGrid() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Stack(
        children: [
          // Time grid with hours
          Column(
            children: List.generate(_endHour - _startHour + 1, (index) {
              final hour = _startHour + index;
              return _buildHourRow(hour);
            }),
          ),

          // Current time indicator
          _buildCurrentTimeIndicator(),

          // Events overlay
          _buildEventsOverlay(),
        ],
      ),
    );
  }

  Widget _buildHourRow(int hour) {
    var theme = Theme.of(context);
    var colorScheme = theme.colorScheme;

    String timeText = DateFormat('h a').format(
      DateTime(2022, 1, 1, hour),
    );

    return SizedBox(
      height: _hourHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time label
          SizedBox(
            width: 60,
            child: Padding(
              padding: const EdgeInsets.only(right: 8, top: 4),
              child: Text(
                timeText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.disabledColor,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
          // Day columns
          ...List.generate(7, (index) {
            return Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        color: colorScheme.outlineVariant.withOpacity(0.5)),
                    left: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCurrentTimeIndicator() {
    final now = DateTime.now();

    // Only show if the current time is within our displayed range
    if (now.hour < _startHour || now.hour > _endHour) {
      return const SizedBox.shrink();
    }

    // Check if today is in the current week view
    bool isTodayInView = _weekDays.any((day) => _isToday(day));
    if (!isTodayInView) {
      return const SizedBox.shrink();
    }

    // Find the index of today in the week days
    int todayIndex = _weekDays.indexWhere((day) => _isToday(day));

    // Calculate the top position based on the current time
    double top =
        (now.hour - _startHour) * _hourHeight + (now.minute / 60) * _hourHeight;

    return Positioned(
      top: top,
      left: 60, // After the time column
      right: 0,
      child: Row(
        children: [
          ...List.generate(7, (index) {
            // Only highlight today's column
            if (index != todayIndex) {
              return Expanded(child: Container());
            }

            return Expanded(
              child: Container(
                height: 2,
                color: Theme.of(context).colorScheme.error,
                margin: const EdgeInsets.only(left: 1),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEventsOverlay() {
    // Group events by day
    Map<int, List<TyxEvent>> eventsByDay = {};

    for (var event in widget.option.events ?? []) {
      for (int i = 0; i < _weekDays.length; i++) {
        if (_isSameDay(event.start, _weekDays[i])) {
          if (!eventsByDay.containsKey(i)) {
            eventsByDay[i] = [];
          }
          eventsByDay[i]!.add(event);
        }
      }
    }

    // Calculate the total height of the grid
    final totalHeight = (_endHour - _startHour + 1) * _hourHeight;

    return SizedBox(
      height: totalHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time column space
          const SizedBox(width: 60),
          // Day columns with events
          ...List.generate(7, (dayIndex) {
            List<TyxEvent> dayEvents = eventsByDay[dayIndex] ?? [];

            return Expanded(
              child: Stack(
                children: dayEvents.map((event) {
                  // Calculate position and height for the event
                  final startHour = event.start.hour + event.start.minute / 60;
                  final endHour = event.end.hour + event.end.minute / 60;

                  // Skip events outside our time range
                  if (endHour < _startHour || startHour > _endHour) {
                    return const SizedBox.shrink();
                  }

                  final clampedStartHour = startHour.clamp(
                      _startHour.toDouble(), _endHour.toDouble());
                  final clampedEndHour =
                      endHour.clamp(_startHour.toDouble(), _endHour + 1.0);

                  final top = (clampedStartHour - _startHour) * _hourHeight;
                  final height =
                      (clampedEndHour - clampedStartHour) * _hourHeight;

                  var colorScheme =
                      ColorScheme.fromSeed(seedColor: event.color);

                  return Positioned(
                    top: top,
                    left: 2,
                    right: 2,
                    height: height,
                    child: GestureDetector(
                      onTap: () => widget.onEventTapped?.call(event),
                      child: Card(
                        margin: EdgeInsets.zero,
                        color: colorScheme.primaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title ?? 'Untitled Event',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (height > 40)
                                Text(
                                  '${TimeOfDay.fromDateTime(event.start).format(context)} - ${TimeOfDay.fromDateTime(event.end).format(context)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: colorScheme.onPrimaryContainer,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (height > 60 &&
                                  event.location != null &&
                                  event.location!.isNotEmpty)
                                Text(
                                  event.location!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: colorScheme.onPrimaryContainer,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }
}
