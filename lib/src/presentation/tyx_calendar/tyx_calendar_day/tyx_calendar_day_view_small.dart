import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timely_x_flutter/src/models/tyx_calendar_option.dart';
import 'package:timely_x_flutter/src/models/tyx_event.dart';
import 'package:timely_x_flutter/src/models/tyx_event_enhanced.dart';
import 'package:timely_x_flutter/src/models/tyx_view.dart';

class TyxCalendarDayViewSmall extends StatefulWidget {
  final TyxCalendarOption option;
  final Function(DateTime)? onDateSelected;
  final Function(TyxEvent)? onEventTapped;
  final Function(DateTime date)? onDateChanged;
  final Function(TyxView view)? onViewChanged;
  final TyxView view;

  const TyxCalendarDayViewSmall({
    super.key,
    required this.option,
    this.onDateSelected,
    this.onEventTapped,
    this.onDateChanged,
    this.onViewChanged,
    required this.view,
  });

  @override
  State<TyxCalendarDayViewSmall> createState() =>
      _TyxCalendarDayViewSmallState();
}

class _TyxCalendarDayViewSmallState extends State<TyxCalendarDayViewSmall> {
  late DateTime _selectedDate;
  late ScrollController _scrollController;
  late double _hourHeight;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.option.initialDate ?? DateTime.now();
    _hourHeight = widget.option.timeslotHeight ?? 60.0;
    _scrollController = ScrollController();

    // Schedule scrolling to current time after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentTime();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentTime() {
    final now = DateTime.now();
    if (!isSameDay(now, _selectedDate)) return;

    final dayStartHour = widget.option.timeslotStartTime?.hour ?? 6;
    final currentHour = now.hour;
    final currentMinute = now.minute;

    if (currentHour >= dayStartHour) {
      final hourDiff = currentHour - dayStartHour;
      final minuteFraction = currentMinute / 60.0;
      final scrollOffset = (hourDiff + minuteFraction) * _hourHeight;

      _scrollController.animateTo(
        scrollOffset - 100, // Scroll to a bit before current time
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
              });
              widget.onDateSelected?.call(_selectedDate);
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
              });
              widget.onDateSelected?.call(_selectedDate);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDayView() {
    final dayStartHour = widget.option.timeslotStartTime?.hour ?? 6;
    final dayEndHour = 22; // Default end hour at 10:00 PM
    final hoursToShow =
        dayEndHour - dayStartHour + 1; // +1 to include the end hour
    final events = _getEventsForDay(_selectedDate);

    return Stack(
      children: [
        // Time grid with lines
        CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final hour = dayStartHour + index;
                  return _buildHourRow(hour);
                },
                childCount: hoursToShow.toInt(),
              ),
            ),
            // Add extra space at the bottom
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),

        // Events overlay
        Positioned.fill(
          child: _buildEventsOverlay(events, dayStartHour, dayEndHour),
        ),

        // Now indicator line
        if (isSameDay(_selectedDate, DateTime.now()))
          _buildNowIndicator(dayStartHour),
      ],
    );
  }

  Widget _buildHourRow(int hour) {
    var theme = Theme.of(context);
    var colorScheme = theme.colorScheme;

    final timeString = DateFormat('h a').format(DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day, hour));

    // Use the timesCellWidth from options if available
    final timeColumnWidth = widget.option.timesCellWidth ?? 60.0;

    return Container(
      height: _hourHeight,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time indicator
          Container(
            width: timeColumnWidth,
            padding: const EdgeInsets.only(right: 8, top: 8),
            child: Text(
              timeString,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          // Main hour area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: colorScheme.outlineVariant,
                    width: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsOverlay(
      List<TyxEvent> events, int dayStartHour, int dayEndHour) {
    // Group overlapping events
    final groupedEvents = _groupOverlappingEvents(events);

    return Stack(
      children: [
        for (var i = 0; i < groupedEvents.length; i++)
          _buildEventGroup(groupedEvents[i], dayStartHour),
      ],
    );
  }

  Widget _buildEventGroup(List<TyxEvent> eventGroup, int dayStartHour) {
    // Calculate the max number of overlapping events to determine width
    int maxOverlaps = eventGroup.length;

    return Stack(
      children: [
        for (var i = 0; i < eventGroup.length; i++)
          _buildEventTile(eventGroup[i], i, maxOverlaps, dayStartHour),
      ],
    );
  }

  Widget _buildEventTile(
      TyxEvent event, int position, int totalOverlapping, int dayStartHour) {
    var theme = Theme.of(context);
    var colorScheme = ColorScheme.fromSeed(seedColor: event.color);

    // Calculate position and size
    final eventStart = event.start;
    final eventEnd = event.end ?? eventStart.add(const Duration(hours: 1));

    // Convert to minutes since day start
    final dayStart = DateTime(_selectedDate.year, _selectedDate.month,
        _selectedDate.day, dayStartHour);
    final startMinutes = max(0, eventStart.difference(dayStart).inMinutes);
    final endMinutes = max(0, eventEnd.difference(dayStart).inMinutes);
    final duration =
        max(30, endMinutes - startMinutes); // Minimum 30 min height

    // Convert to pixels
    final top = startMinutes * _hourHeight / 60;
    final height = duration * _hourHeight / 60;

    // Calculate horizontal position (width and left)
    final timeColumnWidth = widget.option.timesCellWidth ?? 60.0;
    final width = (MediaQuery.of(context).size.width - timeColumnWidth) /
        totalOverlapping;
    final left = timeColumnWidth + (position * width);

    // Check if we have a custom event builder
    if (widget.option.eventBuilder != null) {
      // Create an enhanced event for the builder using the existing class structure
      final enhancedEvent = TyxEventEnhanced(
        e: event,
        position: top,
        height: height,
        width: width,
        offsetX: left,
        groupSize: totalOverlapping,
      );

      return Positioned(
        top: top,
        left: left,
        height: height,
        width: width,
        child: GestureDetector(
          onTap: () => widget.onEventTapped?.call(event),
          child: widget.option.eventBuilder!(context, enhancedEvent),
        ),
      );
    }

    // Default event rendering
    return Positioned(
      top: top,
      left: left,
      height: height,
      width: width,
      child: GestureDetector(
        onTap: () => widget.onEventTapped?.call(event),
        child: Container(
          margin: const EdgeInsets.fromLTRB(2, 1, 2, 1),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(4),
            border: Border(
              left: BorderSide(
                color: colorScheme.primary,
                width: 4,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${TimeOfDay.fromDateTime(eventStart).format(context)} - ${TimeOfDay.fromDateTime(eventEnd).format(context)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                event.title ?? 'Untitled Event',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (event.location != null &&
                  event.location!.isNotEmpty &&
                  height > 80)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                      ),
                      const SizedBox(width: 2),
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
    final top = minutesSinceDayStart * _hourHeight / 60;

    // Use the timesCellWidth from options if available
    final timeColumnWidth = widget.option.timesCellWidth ?? 60.0;

    return Positioned(
      top: top,
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

  // Helper method to group overlapping events
  List<List<TyxEvent>> _groupOverlappingEvents(List<TyxEvent> events) {
    if (events.isEmpty) return [];

    // Sort events by start time
    final sortedEvents = List<TyxEvent>.from(events);
    sortedEvents.sort((a, b) => a.start.compareTo(b.start));

    List<List<TyxEvent>> result = [];

    for (var event in sortedEvents) {
      bool placed = false;

      // Try to place the event in an existing group where it doesn't overlap
      for (var group in result) {
        bool hasOverlap = false;
        for (var groupEvent in group) {
          if (_eventsOverlap(event, groupEvent)) {
            hasOverlap = true;
            break;
          }
        }

        if (!hasOverlap) {
          group.add(event);
          placed = true;
          break;
        }
      }

      // If it couldn't be placed in any existing group, create a new group
      if (!placed) {
        result.add([event]);
      }
    }

    return result;
  }

  // Check if two events overlap in time
  bool _eventsOverlap(TyxEvent a, TyxEvent b) {
    final aEnd = a.end ?? a.start.add(const Duration(hours: 1));
    final bEnd = b.end ?? b.start.add(const Duration(hours: 1));

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

  // Helper function to get maximum of two values
  int max(int a, int b) {
    return a > b ? a : b;
  }
}
