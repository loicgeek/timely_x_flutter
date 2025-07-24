import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timely_x/src/models/tyx_calendar_border.dart';
import 'package:timely_x/timely_x.dart';

class TyxCalendarWeekViewSmall<T extends TyxEvent> extends StatefulWidget {
  final TyxCalendarOption<T> option;
  final DateTime? initialDate;
  final Function(DateTime date)? onDateChanged;
  final Function(TyxView view)? onViewChanged;
  final Function(T)? onEventTapped;
  final Function(TyxCalendarBorder border)? onBorderChanged;
  final TyxView view;
  final List<T>? events;

  const TyxCalendarWeekViewSmall({
    super.key,
    required this.option,
    this.initialDate,
    this.onDateChanged,
    this.onViewChanged,
    this.onEventTapped,
    this.onBorderChanged,
    required this.view,
    this.events,
  });

  @override
  State<TyxCalendarWeekViewSmall<T>> createState() =>
      _TyxCalendarWeekViewSmallState<T>();
}

class _TyxCalendarWeekViewSmallState<T extends TyxEvent>
    extends State<TyxCalendarWeekViewSmall<T>> {
  late DateTime _selectedDate;
  late List<DateTime> _weekDays;
  final ScrollController _eventsScrollController = ScrollController();
  final ScrollController _timeScrollController = ScrollController();
  final double _hourHeight = 60.0;
  final int _startHour = 6; // 6 AM
  final int _endHour = 22; // 10 PM

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _weekDays = _getWeekDays(_selectedDate);

    // Scroll to current time after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentTime();
    });
  }

  @override
  void dispose() {
    _eventsScrollController.dispose();
    _timeScrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentTime() {
    final now = DateTime.now();
    if (now.hour >= _startHour && now.hour <= _endHour) {
      final scrollPosition = (now.hour - _startHour) * _hourHeight +
          (now.minute / 60) * _hourHeight;
      _timeScrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  List<DateTime> _getWeekDays(DateTime date) {
    // Get the start day of week from options, default to Monday if not specified
    final startWeekDay =
        widget.option.startWeekDay ?? 1; // 1 = Monday, 7 = Sunday

    // Find the first day of the week containing the given date
    final firstDayOfWeek = date.subtract(
      Duration(days: (date.weekday - startWeekDay) % 7),
    );

    // Generate 7 days starting from the first day of the week
    return List.generate(
      7,
      (index) => firstDayOfWeek.add(Duration(days: index)),
    );
  }

  DateTime _getStartOfWeek(DateTime date) {
    // Get the start day of week from options, default to Monday if not specified
    final startWeekDay =
        widget.option.startWeekDay ?? 1; // 1 = Monday, 7 = Sunday
    return date.subtract(Duration(days: (date.weekday - startWeekDay) % 7));
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
        _buildDaySelector(),
        Expanded(
          child: _buildDayView(),
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _previousWeek,
              ),
              Column(
                children: [
                  Text(
                    headerText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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

  Widget _buildDaySelector() {
    var theme = Theme.of(context);
    var colorScheme = theme.colorScheme;

    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _weekDays.length,
        itemBuilder: (context, index) {
          DateTime day = _weekDays[index];
          bool isToday = _isToday(day);
          bool isSelected = _isSameDay(day, _selectedDate);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = day;
              });
              widget.onDateChanged?.call(day);
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.secondaryContainer
                    : isToday
                        ? colorScheme.primaryContainer.withOpacity(0.3)
                        : null,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isToday
                      ? colorScheme.primary
                      : isSelected
                          ? colorScheme.secondary
                          : colorScheme.outlineVariant,
                  width: isToday || isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(day),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color:
                          isSelected ? colorScheme.onSecondaryContainer : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isToday
                          ? colorScheme.primaryContainer
                          : isSelected
                              ? colorScheme.secondary
                              : null,
                    ),
                    child: Center(
                      child: Text(
                        day.day.toString(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: isToday || isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? colorScheme.onSecondary
                              : isToday
                                  ? colorScheme.primary
                                  : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayView() {
    return Stack(
      children: [
        SingleChildScrollView(
          controller: _timeScrollController,
          child: Column(
            children: [
              // Time slots
              ...List.generate(_endHour - _startHour + 1, (index) {
                final hour = _startHour + index;
                return _buildTimeSlot(hour);
              }),
              const SizedBox(height: 60), // Bottom padding
            ],
          ),
        ),
        _buildCurrentTimeIndicator(),
        _buildEventsOverlay(),
      ],
    );
  }

  Widget _buildTimeSlot(int hour) {
    var theme = Theme.of(context);
    var colorScheme = theme.colorScheme;

    String timeText = DateFormat('h a').format(
      DateTime(2022, 1, 1, hour),
    );

    return Container(
      height: _hourHeight,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
        ),
      ),
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
        ],
      ),
    );
  }

  Widget _buildCurrentTimeIndicator() {
    final now = DateTime.now();

    // Only show if today is selected and the current time is within our displayed range
    if (!_isToday(_selectedDate) ||
        now.hour < _startHour ||
        now.hour > _endHour) {
      return const SizedBox.shrink();
    }

    // Calculate the top position based on the current time
    double top =
        (now.hour - _startHour) * _hourHeight + (now.minute / 60) * _hourHeight;

    return Positioned(
      top: top,
      left: 60, // After the time column
      right: 0,
      child: Container(
        height: 2,
        color: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Widget _buildEventsOverlay() {
    // Only show events for the selected date
    List<T> selectedDayEvents = [];

    for (var event in widget.events ?? []) {
      if (_isSameDay(event.start, _selectedDate)) {
        selectedDayEvents.add(event);
      }
    }

    // Calculate the total height of the grid
    final totalHeight = (_endHour - _startHour + 1) * _hourHeight;

    return Positioned(
      top: 0,
      left: 60, // After the time column
      right: 0,
      height: totalHeight,
      child: SingleChildScrollView(
        controller: _eventsScrollController,
        physics:
            const NeverScrollableScrollPhysics(), // Prevent independent scrolling
        child: Stack(
          children: selectedDayEvents.map((event) {
            // Calculate position and height for the event
            final startHour = event.start.hour + event.start.minute / 60;
            final endHour = event.end.hour + event.end.minute / 60;

            // Skip events outside our time range
            if (endHour < _startHour || startHour > _endHour) {
              return const SizedBox.shrink();
            }

            final clampedStartHour =
                startHour.clamp(_startHour.toDouble(), _endHour.toDouble());
            final clampedEndHour =
                endHour.clamp(_startHour.toDouble(), _endHour + 1.0);

            final top = (clampedStartHour - _startHour) * _hourHeight;
            final height = (clampedEndHour - clampedStartHour) * _hourHeight;

            var colorScheme = ColorScheme.fromSeed(seedColor: event.color);

            return Positioned(
              top: top,
              left: 8,
              right: 8,
              height: height,
              child: GestureDetector(
                onTap: () => widget.onEventTapped?.call(event),
                child: Card(
                  margin: EdgeInsets.zero,
                  color: colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title ?? 'Untitled Event',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (height > 40)
                          Text(
                            '${TimeOfDay.fromDateTime(event.start).format(context)} - ${TimeOfDay.fromDateTime(event.end).format(context)}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (height > 60 &&
                            event.locationAddress != null &&
                            event.locationAddress!.isNotEmpty)
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 12,
                                color: colorScheme.onPrimaryContainer
                                    .withOpacity(0.7),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  event.locationAddress!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: colorScheme.onPrimaryContainer
                                            .withOpacity(0.7),
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
