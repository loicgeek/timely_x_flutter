import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timely_x_flutter/src/models/tyx_calendar_option.dart';
import 'package:timely_x_flutter/src/models/tyx_event.dart';
import 'package:timely_x_flutter/src/models/tyx_event_enhanced.dart';
import 'package:timely_x_flutter/src/models/tyx_view.dart';

class TyxCalendarDayViewLarge extends StatefulWidget {
  final TyxCalendarOption option;
  final Function(DateTime)? onDateSelected;
  final Function(TyxEvent)? onEventTapped;
  final Function(DateTime date)? onDateChanged;
  final Function(TyxView view)? onViewChanged;
  final TyxView view;
  final DateTime? initialDate;

  const TyxCalendarDayViewLarge({
    super.key,
    required this.option,
    this.onDateSelected,
    this.onEventTapped,
    this.onDateChanged,
    this.onViewChanged,
    required this.view,
    this.initialDate,
  });

  @override
  State<TyxCalendarDayViewLarge> createState() =>
      _TyxCalendarDayViewLargeState();
}

class _TyxCalendarDayViewLargeState extends State<TyxCalendarDayViewLarge> {
  late DateTime _selectedDate;
  late ScrollController _scrollController;
  late double _timeslotHeight;
  late Duration _slotDuration;

  // Constants for layout
  final double _sidebarWidth = 280;

  // Track scroll position to keep events and time grid in sync
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _timeslotHeight = widget.option.timeslotHeight ?? 60.0;
    _slotDuration =
        widget.option.timelotSlotDuration ?? const Duration(minutes: 15);
    _scrollController = ScrollController();

    // Listen to scroll changes to update the event positions
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
    return Row(
      children: [
        // Left sidebar with mini month calendar and event details
        _buildSidebar(),

        // Main day view
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildDayHeader(),
              Expanded(
                child: _buildDayView(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar() {
    final theme = Theme.of(context);

    return Container(
      width: _sidebarWidth,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: theme.dividerColor,
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mini month calendar
          _buildMiniCalendar(),

          // Selected date events summary
          Expanded(
            child: _buildEventsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCalendar() {
    final currentMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final daysInMonth =
        DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    final firstDayOfMonth = currentMonth.weekday;

    // Get the start day of week from options, default to Monday if not specified
    final startWeekDay =
        widget.option.startWeekDay ?? 1; // 1 = Monday, 7 = Sunday

    // Convert from DateTime's weekday (1-7) to index (0-6)
    int startIndex = startWeekDay == 7 ? 0 : startWeekDay;

    // Calculate the offset to start displaying dates
    int offset = (firstDayOfMonth - startWeekDay) % 7;
    if (offset < 0) offset += 7;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month and year header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(_selectedDate),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      setState(() {
                        _selectedDate = DateTime(
                          _selectedDate.year,
                          _selectedDate.month - 1,
                          _selectedDate.day,
                        );
                        widget.onDateChanged?.call(_selectedDate);
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      setState(() {
                        _selectedDate = DateTime(
                          _selectedDate.year,
                          _selectedDate.month + 1,
                          _selectedDate.day,
                        );
                        widget.onDateChanged?.call(_selectedDate);
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Weekday headers
          Row(
            children: List.generate(7, (index) {
              final weekdayIndex = (startIndex + index) % 7;
              final weekdayName =
                  DateFormat().dateSymbols.SHORTWEEKDAYS[weekdayIndex];
              return Expanded(
                child: Text(
                  weekdayName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }),
          ),
          const SizedBox(height: 8),

          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: 42, // 6 rows of 7 days
            itemBuilder: (context, index) {
              // Calculate the day
              final adjustedIndex = index - offset;
              final day = adjustedIndex + 1;

              // Determine if this day is in the current month
              final isInCurrentMonth =
                  adjustedIndex >= 0 && adjustedIndex < daysInMonth;

              // Skip rendering days outside current month if not showing trailing days
              if (!widget.option.showTrailingDays && !isInCurrentMonth) {
                return const SizedBox.shrink();
              }

              // Create the date object for this grid cell
              final date = isInCurrentMonth
                  ? DateTime(_selectedDate.year, _selectedDate.month, day)
                  : (adjustedIndex < 0
                      ? DateTime(
                          _selectedDate.year,
                          _selectedDate.month - 1,
                          DateTime(_selectedDate.year, _selectedDate.month, 0)
                                  .day +
                              adjustedIndex +
                              1)
                      : DateTime(_selectedDate.year, _selectedDate.month + 1,
                          adjustedIndex - daysInMonth + 1));

              // Check if this is today or the selected date
              final isToday = _isToday(date);
              final isSelected = isSameDay(date, _selectedDate);

              // Check if there are events on this day
              final hasEvents = _getEventsForDay(date).isNotEmpty;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                    widget.onDateSelected?.call(date);
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.secondaryContainer
                        : isToday
                            ? colorScheme.primaryContainer.withOpacity(0.3)
                            : null,
                    borderRadius: BorderRadius.circular(4),
                    border: isToday
                        ? Border.all(color: colorScheme.primary, width: 1)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day.toString(),
                        style: TextStyle(
                          fontWeight: isSelected || isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: !isInCurrentMonth ? theme.disabledColor : null,
                        ),
                      ),
                      if (hasEvents)
                        Container(
                          width: 4,
                          height: 4,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    final events = _getEventsForDay(_selectedDate);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE, MMMM d').format(_selectedDate),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: events.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 48,
                          color: theme.disabledColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No events for this day',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.disabledColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return _buildEventListItem(event);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventListItem(TyxEvent event) {
    final theme = Theme.of(context);
    final colorScheme = ColorScheme.fromSeed(seedColor: event.color);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => widget.onEventTapped?.call(event),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${TimeOfDay.fromDateTime(event.start).format(context)} - ${TimeOfDay.fromDateTime(event.end ?? event.start.add(const Duration(hours: 1))).format(context)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                event.title ?? 'Untitled Event',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              if (event.description != null && event.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    event.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (event.location != null && event.location!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location!,
                          style: theme.textTheme.bodySmall?.copyWith(
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
      ),
    );
  }

  Widget _buildDayHeader() {
    var theme = Theme.of(context);
    var colorScheme = theme.colorScheme;

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
                    _selectedDate =
                        _selectedDate.subtract(const Duration(days: 1));
                  });
                  widget.onDateSelected?.call(_selectedDate);
                },
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE').format(_selectedDate),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('MMMM d, yyyy').format(_selectedDate),
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _selectedDate = _selectedDate.add(const Duration(days: 1));
                  });
                  widget.onDateSelected?.call(_selectedDate);
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
                  widget.onDateSelected?.call(now);
                  _scrollToCurrentTime();
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

  // Calculate total height of one hour row including all time slots
  double _getHourRowHeight() {
    final minutesPerSlot = _slotDuration.inMinutes;
    final slotsPerHour = 60 ~/ minutesPerSlot;
    return _timeslotHeight * slotsPerHour;
  }

  Widget _buildDayView() {
    final dayStartHour = widget.option.timeslotStartTime?.hour ?? 0;
    const dayEndHour = 24; // Full day (24 hours)
    final hoursToShow = dayEndHour - dayStartHour;
    final events = _getEventsForDay(_selectedDate);

    // Calculate total content height
    final totalHeight = hoursToShow * _getHourRowHeight();

    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          // Time grid with lines and events
          SingleChildScrollView(
            controller: _scrollController,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                minWidth: constraints.maxWidth,
              ),
              child: SizedBox(
                height: max(totalHeight, constraints.maxHeight).toDouble(),
                width: constraints.maxWidth,
                child: Stack(
                  children: [
                    // Time grid background
                    _buildTimeGrid(dayStartHour, hoursToShow.toInt()),

                    // Events overlay - now with parent constraints
                    _buildEventsOverlay(
                        events, dayStartHour, constraints.maxWidth),
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

    // Use the timesCellWidth from options if available
    final timeColumnWidth = widget.option.timesCellWidth ?? 80.0;

    // Use the timeslot slot duration if available
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
                  width: timeColumnWidth,
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

  Widget _buildEventsOverlay(
      List<TyxEvent> events, int dayStartHour, double containerWidth) {
    // Group overlapping events
    final groupedEvents = _groupOverlappingEvents(events);

    // Calculate dimensions for positioning
    final timeColumnWidth = widget.option.timesCellWidth ?? 80.0;

    // Calculate available width based on parent container width
    final availableWidth = containerWidth - timeColumnWidth;
    var theme = Theme.of(context);

    return SizedBox(
      width: containerWidth,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          for (var i = 0; i < groupedEvents.length; i++)
            for (var j = 0; j < groupedEvents[i].length; j++) ...[
              Builder(builder: (context) {
                final event = groupedEvents[i][j];
                final position = j;
                final totalOverlapping = groupedEvents[i].length;

                // Convert to minutes since day start
                final dayStart = DateTime(_selectedDate.year,
                    _selectedDate.month, _selectedDate.day, dayStartHour);

                int startMinutes = event.start.difference(dayStart).inMinutes;
                double top =
                    (startMinutes / _slotDuration.inMinutes) * _timeslotHeight;

                int eventDurationInMinutes =
                    event.end.difference(event.start).inMinutes;
                double height =
                    (eventDurationInMinutes / _slotDuration.inMinutes) *
                        _timeslotHeight;

                // Calculate horizontal position using parent width
                final width = availableWidth / totalOverlapping;
                final left = timeColumnWidth + (position * width);

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
                Widget eventWidget = widget.option.eventBuilder != null
                    ? widget.option.eventBuilder!(context, enhancedEvent)
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
    );
  }

  Widget _buildDefaultEventTile(
      TyxEvent event, TyxEventEnhanced enhancedEvent, ThemeData theme) {
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
              '${TimeOfDay.fromDateTime(event.start).format(context)} - ${TimeOfDay.fromDateTime(event.end).format(context)}',
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
            if (event.location != null &&
                event.location!.isNotEmpty &&
                enhancedEvent.height > 80)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
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

    // Use the timesCellWidth from options if available
    final timeColumnWidth = widget.option.timesCellWidth ?? 80.0;

    return Positioned(
      top: visiblePosition,
      left: 0,
      right: 0,
      child: Row(
        children: [
          // The circle at the start of the line
          Container(
            margin: EdgeInsets.only(left: timeColumnWidth - 6),
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

// Helper method to group overlapping events - improved algorithm
  List<List<TyxEvent>> _groupOverlappingEvents(List<TyxEvent> events) {
    if (events.isEmpty) return [];

    // Sort events by start time
    final sortedEvents = List<TyxEvent>.from(events);
    sortedEvents.sort((a, b) => a.start.compareTo(b.start));

    // Create columns for events that overlap

    List<List<TyxEvent>> groups = [];

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

// Check if two events overlap in time - more robust implementation
  bool _eventsOverlap(TyxEvent a, TyxEvent b) {
    // Handle null end times by assuming default duration of 1 hour
    final aEnd = a.end;
    final bEnd = b.end;

    // Two events overlap if:
    // 1. a starts before b ends AND
    // 2. a ends after b starts
    return a.start.isBefore(bEnd) && aEnd.isAfter(b.start);
  }

  List<TyxEvent> _getEventsForDay(DateTime day) {
    return (widget.option.events ?? [])
        .where((event) => isSameDay(event.start, day))
        .toList();
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return isSameDay(date, now);
  }

  // Helper function to get maximum of two values
  num max(num a, num b) {
    return a > b ? a : b;
  }
}
