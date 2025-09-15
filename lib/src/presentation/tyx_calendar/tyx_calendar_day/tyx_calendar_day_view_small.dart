import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:timely_x/src/models/tyx_calendar_border.dart';
import 'package:timely_x/src/models/tyx_calendar_option.dart';
import 'package:timely_x/src/models/tyx_event.dart';
import 'package:timely_x/src/models/tyx_event_enhanced.dart';
import 'package:timely_x/src/models/tyx_view.dart';

class TyxCalendarDayViewSmall<T extends TyxEvent> extends StatefulWidget {
  final TyxCalendarOption<T> option;

  final Function(T)? onEventTapped;
  final Function(DateTime date)? onDateChanged;
  final Function(TyxView view)? onViewChanged;
  final Function(TyxCalendarBorder border)? onBorderChanged;
  final TyxView view;
  final OnRightClick? onRightClick;
  final List<T>? events;

  const TyxCalendarDayViewSmall({
    super.key,
    required this.option,
    this.onEventTapped,
    this.onDateChanged,
    this.onViewChanged,
    this.onBorderChanged,
    required this.view,
    this.onRightClick,
    this.events,
  });

  @override
  State<TyxCalendarDayViewSmall<T>> createState() =>
      _TyxCalendarDayViewSmallState<T>();
}

class _TyxCalendarDayViewSmallState<T extends TyxEvent>
    extends State<TyxCalendarDayViewSmall<T>> {
  late DateTime _selectedDate;
  late ScrollController _scrollController;

  late double _timeslotHeight;
  late Duration _slotDuration;
  late double _timeColumnWidth;

  // Track scroll position for now indicator
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.option.initialDate ?? DateTime.now();
    _timeslotHeight = widget.option.timeslotHeight ?? 60.0;
    _slotDuration =
        widget.option.timelotSlotDuration ?? const Duration(minutes: 15);
    _timeColumnWidth = widget.option.timesCellWidth ?? 80.0;

    _scrollController = ScrollController();

    // Add scroll listener
    _scrollController.addListener(_onScroll);

    // Schedule scrolling to current time after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentTime();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Update scroll offset when scrolling
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  void _scrollToCurrentTime() {
    final now = DateTime.now();
    if (!isSameDay(now, _selectedDate)) return;

    final dayStartHour = widget.option.timeslotStartTime?.hour ?? 0;
    final currentHour = now.hour;

    if (currentHour >= dayStartHour) {
      // Calculate position
      final dayStart = DateTime(_selectedDate.year, _selectedDate.month,
          _selectedDate.day, dayStartHour);
      final minutesSinceDayStart = now.difference(dayStart).inMinutes;
      double top =
          (minutesSinceDayStart / _slotDuration.inMinutes) * _timeslotHeight;

      _scrollController.animateTo(
        top - 100, // Scroll to a bit before current time
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDayHeader(),
        Expanded(
          child: _buildDayView(),
        ),
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
                    _selectedDate =
                        _selectedDate.subtract(const Duration(days: 1));
                    widget.onBorderChanged?.call(TyxCalendarBorder(
                      start: _selectedDate,
                      end: DateTime(_selectedDate.year, _selectedDate.month,
                          _selectedDate.day, 23, 59, 59),
                    ));
                  });
                  widget.onDateChanged?.call(_selectedDate);
                },
              ),
              Column(
                children: [
                  Text(
                    DateFormat('EEEE').format(_selectedDate),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('MMMM d, yyyy').format(_selectedDate),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _selectedDate = _selectedDate.add(const Duration(days: 1));
                    widget.onBorderChanged?.call(TyxCalendarBorder(
                      start: _selectedDate,
                      end: DateTime(_selectedDate.year, _selectedDate.month,
                          _selectedDate.day, 23, 59, 59),
                    ));
                  });
                  widget.onDateChanged?.call(_selectedDate);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Calculate total height of one hour row including all time slots
  double _getHourRowHeight() {
    final minutesPerSlot = _slotDuration.inMinutes;
    final slotsPerHour = 60 ~/ minutesPerSlot;
    return _timeslotHeight * slotsPerHour;
  }

  Widget _buildTimeGrid(int dayStartHour, int hoursToShow) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(hoursToShow, (index) {
        final hour = dayStartHour + index;
        return _buildHourRow(hour);
      }),
    );
  }

  Widget _buildHourRow(int hour) {
    var theme = Theme.of(context);
    var colorScheme = theme.colorScheme;

    final timeString = DateFormat('h a').format(DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day, hour));

    final minutesPerSlot = _slotDuration.inMinutes;
    final slotsPerHour = 60 ~/ minutesPerSlot;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int slot = 0; slot < slotsPerHour; slot++)
          Container(
            height: _timeslotHeight,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: slot == slotsPerHour - 1 ? 1 : 0.5,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time indicator (only show on first slot of the hour)
                Container(
                  width: _timeColumnWidth,
                  padding: const EdgeInsets.only(right: 16, top: 8),
                  child: slot == 0
                      ? Text(
                          timeString,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                          textAlign: TextAlign.right,
                        )
                      : null,
                ),
                // Main hour area
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: colorScheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  _callRightClick({
    required Offset position,
    DateTime? date,
    required List<T>? events,
  }) {
    widget.onRightClick?.call(
      position,
      date,
      events,
    );
  }

  Widget _buildEventsOverlay(
      List<T> events, int dayStartHour, double containerWidth) {
    // Group overlapping events
    final groupedEvents = _groupOverlappingEvents(events);

    // Calculate available width using the parent container width
    final availableWidth = containerWidth - _timeColumnWidth;
    var theme = Theme.of(context);

    return SizedBox(
      width: containerWidth,
      child: GestureDetector(
        onLongPressStart: (details) {
          final localDy = details.localPosition.dy.clamp(0.0, double.infinity);
          final hourDecimal =
              localDy / _timeslotHeight * _slotDuration.inMinutes / 60 +
                  dayStartHour;

          final hour = hourDecimal.floor();
          final minute = ((hourDecimal - hour) * 60).round();

          final tappedDate = DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            hour,
            minute,
          );

          _callRightClick(
            position: details.globalPosition,
            date: tappedDate,
            events: [],
          );
        },
        child: Listener(
          onPointerDown: (eventGesture) {
            if (eventGesture.kind == PointerDeviceKind.mouse &&
                eventGesture.buttons == kSecondaryMouseButton) {
              final localDy =
                  eventGesture.localPosition.dy.clamp(0.0, double.infinity);
              final hourDecimal =
                  localDy / _timeslotHeight * _slotDuration.inMinutes / 60 +
                      dayStartHour;

              final hour = hourDecimal.floor();
              final minute = ((hourDecimal - hour) * 60).round();

              final clickedDate = DateTime(
                _selectedDate.year,
                _selectedDate.month,
                _selectedDate.day,
                hour,
                minute,
              );

              _callRightClick(
                position: eventGesture.position,
                date: clickedDate,
                events: [],
              );
            }
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  color: Colors.transparent,
                ),
              ),
              for (var i = 0; i < groupedEvents.length; i++)
                for (var j = 0; j < groupedEvents[i].length; j++) ...[
                  Builder(builder: (context) {
                    final event = groupedEvents[i][j];
                    final position = j;
                    final totalOverlapping = groupedEvents[i].length;

                    // Convert to minutes since day start
                    final dayStart = DateTime(_selectedDate.year,
                        _selectedDate.month, _selectedDate.day, dayStartHour);

                    int startMinutes =
                        event.start.difference(dayStart).inMinutes;
                    double top = (startMinutes / _slotDuration.inMinutes) *
                        _timeslotHeight;

                    int eventDurationInMinutes =
                        event.end.difference(event.start).inMinutes;
                    double height =
                        (eventDurationInMinutes / _slotDuration.inMinutes) *
                            _timeslotHeight;

                    // Calculate horizontal position based on parent width
                    final width = availableWidth / totalOverlapping;
                    final left = _timeColumnWidth + (position * width);

                    // Create an enhanced event
                    final enhancedEvent = TyxEventEnhanced(
                      e: event,
                      position: top,
                      height: height,
                      width: width,
                      offsetX: left,
                      groupSize: totalOverlapping,
                    );

                    // Use custom builder or default rendering
                    Widget eventWidget = widget
                                .option.dayOption?.eventIndicatorBuilder !=
                            null
                        ? widget.option.dayOption!.eventIndicatorBuilder!(
                            context, enhancedEvent)
                        : _buildDefaultEventTile(event, enhancedEvent, theme);

                    // Position the event widget
                    return Positioned(
                      top: top,
                      left: left,
                      height: height,
                      width: width,
                      child: GestureDetector(
                        onTap: () => widget.onEventTapped?.call(event),
                        child: eventWidget,
                      ),
                    );
                  }),
                ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultEventTile(
      T event, TyxEventEnhanced<T> enhancedEvent, ThemeData theme) {
    final colorScheme = ColorScheme.fromSeed(seedColor: event.color);

    return Card(
      margin: const EdgeInsets.fromLTRB(2, 1, 2, 1),
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
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${TimeOfDay.fromDateTime(event.start).format(context)} - ${TimeOfDay.fromDateTime(event.end ?? event.start.add(const Duration(hours: 1))).format(context)}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              event.title ?? 'Untitled Event',
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (event.description != null &&
                event.description!.isNotEmpty &&
                enhancedEvent.height > 100)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  event.description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (event.locationAddress != null &&
                event.locationAddress!.isNotEmpty &&
                enhancedEvent.height > 80)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color:
                          colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.locationAddress!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.7),
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

  Widget _buildNowIndicator(int dayStartHour) {
    final now = DateTime.now();
    if (!isSameDay(now, _selectedDate)) return const SizedBox.shrink();

    var theme = Theme.of(context);
    var colorScheme = theme.colorScheme;

    // Calculate position
    final dayStart = DateTime(_selectedDate.year, _selectedDate.month,
        _selectedDate.day, dayStartHour);
    final minutesSinceDayStart = now.difference(dayStart).inMinutes;
    double top =
        (minutesSinceDayStart / _slotDuration.inMinutes) * _timeslotHeight;

    // Calculate indicator position relative to visible viewport
    final visiblePosition = top - _scrollOffset;

    // Only show indicator if it's in the visible viewport
    if (visiblePosition < 0 ||
        visiblePosition > MediaQuery.of(context).size.height) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: visiblePosition,
      left: 0,
      right: 0,
      child: Row(
        children: [
          // The circle at the start of the line
          Container(
            margin: EdgeInsets.only(left: _timeColumnWidth - 6),
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: colorScheme.error,
              shape: BoxShape.circle,
            ),
          ),
          // The line itself
          Expanded(
            child: Container(
              height: 2,
              color: colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayView() {
    final dayStartHour = widget.option.timeslotStartTime?.hour ?? 0;
    const dayEndHour = 24; // Full day (24 hours)
    final hoursToShow = dayEndHour - dayStartHour;
    final events = _getEventsForDay(_selectedDate);

    // Calculate total content height for proper layout
    final totalHeight = hoursToShow * _getHourRowHeight();

    return LayoutBuilder(builder: (context, constraints) {
      final availableWidth = constraints.maxWidth;

      return Stack(
        children: [
          // Time grid with lines
          SingleChildScrollView(
            controller: _scrollController,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                minWidth: constraints.maxWidth,
              ),
              child: SizedBox(
                // Ensure adequate height for scrolling
                height: max(totalHeight, constraints.maxHeight).toDouble(),
                width: availableWidth,
                child: Stack(
                  children: [
                    // Time grid background
                    _buildTimeGrid(dayStartHour, hoursToShow.toInt()),

                    // Events overlay - now inside the ScrollView and using parent width
                    _buildEventsOverlay(events, dayStartHour, availableWidth),
                  ],
                ),
              ),
            ),
          ),

          // Now indicator line - positioned in the viewport
          if (isSameDay(_selectedDate, DateTime.now()))
            _buildNowIndicator(dayStartHour),
        ],
      );
    });
  }

// Helper method to group overlapping events - improved algorithm
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

  // Check if two events overlap in time
  bool _eventsOverlap(T a, T b) {
    final aEnd = a.end;
    final bEnd = b.end;

    return a.start.isBefore(bEnd) && aEnd.isAfter(b.start);
  }

  List<T> _getEventsForDay(DateTime day) {
    return (widget.events ?? [])
        .where((event) => isSameDay(event.start, day))
        .toList();
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Helper function to get maximum of two values
  num max(num a, num b) {
    return a > b ? a : b;
  }
}
