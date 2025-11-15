import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timely_x/src/models/tyx_calendar_border.dart';
import 'package:timely_x/timely_x.dart';

class TyxCalendarWeekViewLarge<T extends TyxEvent> extends StatefulWidget {
  final TyxCalendarOption<T> option;
  final DateTime? initialDate;
  final Function(DateTime date)? onDateChanged;
  final Function(TyxView view)? onViewChanged;
  final Function(T)? onEventTapped;
  final Function(TyxCalendarBorder border)? onBorderChanged;
  final TyxView view;
  final OnRightClick? onRightClick;
  final List<T>? events;

  const TyxCalendarWeekViewLarge({
    super.key,
    required this.option,
    this.initialDate,
    this.onDateChanged,
    this.onViewChanged,
    this.onEventTapped,
    this.onBorderChanged,
    required this.view,
    this.onRightClick,
    this.events,
  });

  @override
  State<TyxCalendarWeekViewLarge<T>> createState() =>
      _TyxCalendarWeekViewLargeState<T>();
}

class _TyxCalendarWeekViewLargeState<T extends TyxEvent>
    extends State<TyxCalendarWeekViewLarge<T>> {
  late DateTime _selectedDate;
  late List<DateTime> _weekDays;
  final ScrollController _scrollController = ScrollController();
  double _hourHeight = 60.0;
  int _startHour = 6; // 6 AM
  int _endHour = 22; // 10 PM

  @override
  void initState() {
    super.initState();
    _startHour = widget.option.timeslotStartTime?.hour ?? 0;
    _endHour = widget.option.timeslotEndTime?.hour ?? 24;
    _hourHeight = widget.option.timeslotHeight ?? 60.0;
    _selectedDate = widget.option.initialDate ?? DateTime.now();
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

  _callRightClick({
    required Offset position,
    DateTime? date,
    required List<T>? events,
  }) {
    print("ddd");
    widget.onRightClick?.call(
      position,
      date,
      events,
    );
  }

// Add these helper methods to _TyxCalendarWeekViewLargeState class

  /// Check if two events overlap in time
  bool _eventsOverlap(T a, T b) {
    final aEnd = a.end;
    final bEnd = b.end;

    // Two events overlap if:
    // 1. a starts before b ends AND
    // 2. a ends after b starts
    return a.start.isBefore(bEnd) && aEnd.isAfter(b.start);
  }

  /// Group overlapping events for better visual layout
  List<List<T>> _groupOverlappingEvents(List<T> events) {
    if (events.isEmpty) return [];

    // Sort events by start time
    final sortedEvents = List<T>.from(events);
    sortedEvents.sort((a, b) => a.start.compareTo(b.start));

    // Create columns for events that overlap
    List<List<T>> groups = [];

    for (var event in sortedEvents) {
      bool addedToGroup = false;
      for (var group in groups) {
        if (group.any((e) => _eventsOverlap(e, event))) {
          group.add(event);
          addedToGroup = true;
          break;
        }
      }
      if (!addedToGroup) {
        groups.add([event]);
      }
    }

    return groups;
  }

  /// Build a single day column with properly positioned events
  Widget _buildDayColumnWithEvents(
      DateTime day, int dayIndex, double totalHeight, double columnWidth) {
    // Get events for this day
    List<T> dayEvents = (widget.events ?? [])
        .where((event) => _isSameDay(event.start, day))
        .toList();

    // Group overlapping events
    final groupedEvents = _groupOverlappingEvents(dayEvents);

    return GestureDetector(
      onLongPressStart: (eventGesture) {
        final localDy = (eventGesture.localPosition.dy).clamp(0, totalHeight);
        final hourDecimal = localDy / _hourHeight + _startHour;

        final int hour = hourDecimal.floor();
        final int minute = ((hourDecimal - hour) * 60).round();

        final dateTimeWithTime = DateTime(
          day.year,
          day.month,
          day.day,
          hour,
          minute,
        );

        _callRightClick(
          position: eventGesture.globalPosition,
          date: dateTimeWithTime,
          events: [],
        );
      },
      child: Listener(
        onPointerDown: (eventGesture) {
          if (eventGesture.kind == PointerDeviceKind.mouse &&
              eventGesture.buttons == kSecondaryMouseButton) {
            final localDy =
                (eventGesture.localPosition.dy).clamp(0, totalHeight);
            final hourDecimal = localDy / _hourHeight + _startHour;

            final int hour = hourDecimal.floor();
            final int minute = ((hourDecimal - hour) * 60).round();

            final dateTimeWithTime = DateTime(
              day.year,
              day.month,
              day.day,
              hour,
              minute,
            );

            _callRightClick(
              position: eventGesture.position,
              date: dateTimeWithTime,
              events: [],
            );
          }
        },
        child: Container(
          height: totalHeight,
          width: double.infinity,
          color: Colors.transparent,
          child: Stack(
            children: [
              // Render grouped events with proper positioning
              for (var i = 0; i < groupedEvents.length; i++)
                for (var j = 0; j < groupedEvents[i].length; j++)
                  _buildPositionedEvent(
                    event: groupedEvents[i][j],
                    position: j,
                    totalOverlapping: groupedEvents[i].length,
                    columnWidth: columnWidth,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build a single event with proper positioning
  Widget _buildPositionedEvent({
    required T event,
    required int position,
    required int totalOverlapping,
    required double columnWidth,
  }) {
    // Calculate position and height for the event
    final startHour = event.start.hour + event.start.minute / 60;
    final endHour = event.end.hour + event.end.minute / 60;

    // Skip events outside our time range
    if (endHour < _startHour || startHour > _endHour) {
      return const SizedBox.shrink();
    }

    final clampedStartHour =
        startHour.clamp(_startHour.toDouble(), _endHour.toDouble());
    final clampedEndHour = endHour.clamp(_startHour.toDouble(), _endHour + 1.0);

    final top = (clampedStartHour - _startHour) * _hourHeight;
    final height = (clampedEndHour - clampedStartHour) * _hourHeight;

    // Calculate horizontal position based on overlapping events
    final eventWidth = (columnWidth - 4) / totalOverlapping; // -4 for margins
    final left = 2 + (position * eventWidth);

    // Create an enhanced event
    final enhancedEvent = TyxEventEnhanced(
      e: event,
      position: top,
      height: height,
      width: eventWidth,
      offsetX: left,
      groupSize: totalOverlapping,
    );

    var colorScheme = ColorScheme.fromSeed(seedColor: event.color);
    var theme = Theme.of(context);

    // Use custom builder if provided, otherwise use default
    Widget eventWidget = widget.option.weekOption?.eventIndicatorBuilder != null
        ? widget.option.weekOption!.eventIndicatorBuilder!(
            context, enhancedEvent)
        : _buildDefaultWeekEventTile(event, enhancedEvent, theme, colorScheme);

    return Positioned(
      top: top,
      left: left,
      height: height,
      width: eventWidth,
      child: GestureDetector(
        onTap: () => widget.onEventTapped?.call(event),
        child: eventWidget,
      ),
    );
  }

  /// Build default event tile for week view
  Widget _buildDefaultWeekEventTile(
    T event,
    TyxEventEnhanced enhancedEvent,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final height = enhancedEvent.height;
    final totalOverlapping = enhancedEvent.groupSize;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 0.5),
      elevation: 2,
      color: colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(
          color: colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time
            if (height > 20)
              Text(
                '${TimeOfDay.fromDateTime(event.start).format(context)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  color: colorScheme.onPrimaryContainer,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            // Title
            if (height > 35)
              Flexible(
                child: Text(
                  event.title ?? 'Untitled',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  maxLines: totalOverlapping > 2 ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            // End time (only if there's space)
            if (height > 55 && totalOverlapping <= 2)
              Text(
                '- ${TimeOfDay.fromDateTime(event.end).format(context)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            // Location (only if there's plenty of space)
            if (height > 75 &&
                totalOverlapping <= 2 &&
                event.locationAddress != null &&
                event.locationAddress!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 10,
                      color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        event.locationAddress!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 9,
                          color:
                              colorScheme.onPrimaryContainer.withOpacity(0.7),
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
    );
  }

// Replace the entire _buildEventsOverlay method with this:
  Widget _buildEventsOverlay() {
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
            DateTime day = _weekDays[dayIndex];

            return Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return _buildDayColumnWithEvents(
                    day,
                    dayIndex,
                    totalHeight,
                    constraints.maxWidth,
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
