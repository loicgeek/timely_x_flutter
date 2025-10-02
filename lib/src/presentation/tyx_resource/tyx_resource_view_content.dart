import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

import 'package:timely_x/src/models/tyx_resource_theme.dart';

import 'package:timely_x/timely_x.dart';

class TyxResourceViewContent<E extends TyxEvent, R extends TyxResource>
    extends StatefulWidget {
  final TyxResourceOption<E, R>? option;
  final TyxResourceViewMode viewMode;
  final TyxResourceTheme? theme;
  final void Function(DateTime date, dynamic resource)? onTimeSlotTap;
  final void Function(TyxEventEnhanced event, dynamic resource)? onEventTap;
  final List<R>? resources;
  final List<E>? events;

  const TyxResourceViewContent({
    super.key,
    this.option,
    this.viewMode = TyxResourceViewMode.day,
    this.theme,
    this.onTimeSlotTap,
    this.onEventTap,
    this.resources,
    this.events,
  });

  @override
  State<TyxResourceViewContent<E, R>> createState() =>
      _TyxResourceViewContentState<E, R>();
}

class _TyxResourceViewContentState<E extends TyxEvent, R extends TyxResource>
    extends State<TyxResourceViewContent<E, R>> {
  late ScrollController _horizontalScrollController;
  late ScrollController _headerScrollController;
  late ScrollController _verticalScrollController;

  late List<R> _resources;
  late List<E> _events;

  @override
  void initState() {
    super.initState();
    _resources = widget.resources!;
    _events = widget.events!;
    _horizontalScrollController = ScrollController();
    _headerScrollController = ScrollController();
    _verticalScrollController = ScrollController();

    // Sync horizontal scroll controllers
    _horizontalScrollController.addListener(_syncHeaderScroll);
    _headerScrollController.addListener(_syncContentScroll);
  }

  void _syncHeaderScroll() {
    if (_headerScrollController.hasClients &&
        _headerScrollController.offset != _horizontalScrollController.offset) {
      _headerScrollController.jumpTo(_horizontalScrollController.offset);
    }
  }

  void _syncContentScroll() {
    if (_horizontalScrollController.hasClients &&
        _horizontalScrollController.offset != _headerScrollController.offset) {
      _horizontalScrollController.jumpTo(_headerScrollController.offset);
    }
  }

  @override
  void didUpdateWidget(covariant TyxResourceViewContent<E, R> oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool hasChanged = false;
    if (widget.resources != oldWidget.resources) {
      _resources = widget.resources!;
      hasChanged = true;
    }
    if (widget.events != oldWidget.events) {
      _events = widget.events!;
      hasChanged = true;
    }
    if (hasChanged) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _horizontalScrollController.removeListener(_syncHeaderScroll);
    _headerScrollController.removeListener(_syncContentScroll);
    _horizontalScrollController.dispose();
    _headerScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme ?? TyxResourceTheme.light();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(theme.borderRadius),
        color: theme.backgroundColor,
        border: Border.all(color: theme.borderColor),
      ),
      child: widget.viewMode == TyxResourceViewMode.day
          ? _buildDayView(theme)
          : _buildWeekView(theme),
    );
  }

  Widget _buildDayView(TyxResourceTheme theme) {
    final config = _ViewConfig.fromOption(widget.option, context, theme);
    final resources = _resources;
    final allEvents = _events;

    // Filter events for current day only
    final currentDate = config.initialDate;
    final filteredEvents = allEvents.where((e) {
      return e.start.year == currentDate.year &&
          e.start.month == currentDate.month &&
          e.start.day == currentDate.day;
    }).toList();

    return Column(
      children: [
        // Fixed header row (doesn't scroll vertically)
        Row(
          children: [
            // Empty corner cell
            Container(
              width: config.timesCellW,
              height: config.resourceHeaderH,
              decoration: BoxDecoration(
                color: theme.headerBackground,
                border: Border(
                  right: BorderSide(color: theme.borderColor),
                  bottom: BorderSide(color: theme.borderColor),
                ),
              ),
            ),
            // Resource headers (scroll horizontally WITH columns)
            Expanded(
              child: SingleChildScrollView(
                controller: _headerScrollController,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: _buildResourceHeadersRow(config, resources, theme),
              ),
            ),
          ],
        ),
        // Scrollable content area
        Expanded(
          child: SingleChildScrollView(
            controller: _verticalScrollController,
            scrollDirection: Axis.vertical,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time column (scrolls vertically with content)
                _buildTimeColumnContent(config, theme),
                // Resource columns (scroll horizontally)
                Expanded(
                  child: SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: Row(
                      children: resources.map((resource) {
                        final events = filteredEvents
                            .where((e) => e.resourceId == resource.id)
                            .toList();
                        return _buildResourceColumn(
                          config,
                          resource,
                          events,
                          config.initialDate,
                          theme,
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekView(TyxResourceTheme theme) {
    final config = _ViewConfig.fromOption(widget.option, context, theme);
    final resources = _resources;
    final allEvents = _events;

    // Get the start of the week for the current date
    final currentDate = config.initialDate;
    final startOfWeek = _getStartOfWeek(currentDate);

    // Filter events for the current week (7 days from startOfWeek)
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    final filteredEvents = allEvents.where((e) {
      return e.start
              .isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
          e.start.isBefore(endOfWeek);
    }).toList();

    return Column(
      children: [
        // Fixed header row (doesn't scroll vertically)
        Row(
          children: [
            // Empty corner cell
            Container(
              width: config.timesCellW,
              height: config.resourceHeaderH,
              decoration: BoxDecoration(
                color: theme.headerBackground,
                border: Border(
                  right: BorderSide(color: theme.borderColor),
                  bottom: BorderSide(color: theme.borderColor),
                ),
              ),
            ),
            // Resource headers with day subdivisions (scroll horizontally WITH columns)
            Expanded(
              child: SingleChildScrollView(
                controller: _headerScrollController,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: _buildWeekResourceHeadersRow(
                    config, resources, theme, startOfWeek),
              ),
            ),
          ],
        ),
        // Scrollable content area
        Expanded(
          child: SingleChildScrollView(
            controller: _verticalScrollController,
            scrollDirection: Axis.vertical,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time column (scrolls vertically with content)
                _buildTimeColumnContent(config, theme),
                // Resource columns (scroll horizontally)
                Expanded(
                  child: SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: Row(
                      children: resources.map((resource) {
                        return _buildWeekResourceColumn(
                          config,
                          resource,
                          filteredEvents,
                          theme,
                          startOfWeek,
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  DateTime _getStartOfWeek(DateTime date) {
    // Get Monday as start of week (weekday 1 = Monday, 7 = Sunday)
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: daysFromMonday));
  }

  Widget _buildResourceHeadersRow(
      _ViewConfig config, List<R> resources, TyxResourceTheme theme) {
    return SizedBox(
      height: config.resourceHeaderH,
      child: Row(
        children: resources.map((resource) {
          return _buildResourceHeader(config, resource, theme);
        }).toList(),
      ),
    );
  }

  Widget _buildWeekResourceHeadersRow(_ViewConfig config, List<R> resources,
      TyxResourceTheme theme, DateTime startOfWeek) {
    return SizedBox(
      height: config.resourceHeaderH,
      child: Row(
        children: resources.map((resource) {
          return _buildWeekResourceHeader(config, resource, theme, startOfWeek);
        }).toList(),
      ),
    );
  }

  Widget _buildResourceHeader(
      _ViewConfig config, R resource, TyxResourceTheme theme) {
    return Container(
      width: config.cellW,
      height: config.resourceHeaderH,
      decoration: BoxDecoration(
        color: theme.headerBackground,
        border: Border(
          left: BorderSide(color: theme.borderColor),
          bottom: BorderSide(color: theme.borderColor),
        ),
      ),
      child: widget.option?.resourceBuilder != null
          ? widget.option!.resourceBuilder!(
              context,
              TyxResourceEnhanced(
                width: config.cellW,
                height: config.resourceHeaderH,
                resource: resource,
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Avatar circle
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade300,
                  ),
                  child: Center(
                    child: Text(
                      resource.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Resource name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    resource.name,
                    style: theme.resourceNameStyle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildWeekResourceHeader(_ViewConfig config, R resource,
      TyxResourceTheme theme, DateTime startOfWeek) {
    final weekDays = List.generate(7, (i) {
      return startOfWeek.add(Duration(days: i));
    });

    // Use smaller cell width for week view
    final dayCellWidth = config.cellW / 1.5;

    return SizedBox(
      width: dayCellWidth * 7,
      child: Column(
        children: [
          // Resource name with avatar
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.headerBackground,
                border: Border(
                  left: BorderSide(color: theme.borderColor),
                  bottom: BorderSide(color: theme.borderColor),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade300,
                    ),
                    child: Center(
                      child: Text(
                        resource.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    resource.name,
                    style: theme.resourceNameStyle.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          // Day headers
          Expanded(
            flex: 1,
            child: Row(
              children: weekDays.asMap().entries.map((entry) {
                final index = entry.key;
                final date = entry.value;
                final jiffy = Jiffy.parseFromDateTime(date);
                return Container(
                  width: dayCellWidth,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.headerBackground,
                    border: Border(
                      left: BorderSide(color: theme.borderColor),
                      bottom: BorderSide(color: theme.borderColor),
                      right: index == 6
                          ? BorderSide(color: theme.borderColor)
                          : BorderSide.none,
                    ),
                  ),
                  child: Text(
                    '${jiffy.format(pattern: 'EEE')} ${jiffy.date}',
                    style: theme.dayHeaderStyle,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeColumnContent(_ViewConfig config, TyxResourceTheme theme) {
    return Container(
      width: config.timesCellW,
      decoration: BoxDecoration(
        color: theme.timeColumnBackground,
        border: Border(
          right: BorderSide(color: theme.borderColor),
        ),
      ),
      child: SizedBox(
        height: config.timeslotCount * config.timeslotHeight,
        child: Stack(
          children: List.generate(config.timeslotCount, (i) {
            final time = TimeOfDay.fromDateTime(
              config.initialDate.add(
                Duration(minutes: i * config.timelotSlotDuration.inMinutes),
              ),
            );
            return Positioned(
              top: i * config.timeslotHeight,
              left: 0,
              right: 0,
              height: config.timeslotHeight,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        color: theme.gridLineColor, width: theme.gridLineWidth),
                  ),
                ),
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  time.format(config.context),
                  style: theme.timeTextStyle,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildResourceColumn(
    _ViewConfig config,
    R resource,
    List<E> events,
    DateTime date,
    TyxResourceTheme theme,
  ) {
    return _buildDayColumn(config, resource, events, date, config.cellW, theme);
  }

  Widget _buildWeekResourceColumn(
    _ViewConfig config,
    R resource,
    List<E> allEvents,
    TyxResourceTheme theme,
    DateTime startOfWeek,
  ) {
    // Use smaller cell width for week view
    final dayCellWidth = config.cellW / 1.5;

    return SizedBox(
      width: dayCellWidth * 7,
      child: Row(
        children: List.generate(7, (dayIndex) {
          final date = startOfWeek.add(Duration(days: dayIndex));
          final events = allEvents.where((e) {
            return e.resourceId == resource.id &&
                e.start.year == date.year &&
                e.start.month == date.month &&
                e.start.day == date.day;
          }).toList();

          return _buildDayColumn(
              config, resource, events, date, dayCellWidth, theme);
        }),
      ),
    );
  }

  Widget _buildDayColumn(
    _ViewConfig config,
    dynamic resource,
    List<E> events,
    DateTime date,
    double cellWidth,
    TyxResourceTheme theme,
  ) {
    final eventPositions = _calculateEventPositions(config, events, cellWidth);

    return Container(
      width: cellWidth,
      height: config.timeslotCount * config.timeslotHeight,
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        border: Border(
          left: BorderSide(color: theme.borderColor),
        ),
      ),
      child: Stack(
        children: [
          // Time grid lines and clickable areas
          ...List.generate(config.timeslotCount, (i) {
            final slotDateTime = date.add(
              Duration(
                hours: config.initialDate.hour,
                minutes: config.initialDate.minute +
                    (i * config.timelotSlotDuration.inMinutes),
              ),
            );

            return Positioned(
              top: i * config.timeslotHeight,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: widget.onTimeSlotTap != null
                    ? () => widget.onTimeSlotTap!(slotDateTime, resource)
                    : null,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: config.timeslotHeight,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: theme.gridLineColor,
                        width: theme.gridLineWidth,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          // Events
          ...eventPositions.map((item) {
            return Positioned(
              left: item.offsetX,
              top: item.position,
              width: item.width,
              height: item.height,
              child: GestureDetector(
                onTap: widget.onEventTap != null
                    ? () => widget.onEventTap!(item, resource)
                    : null,
                child: _buildEvent(config, item, theme),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEvent(
      _ViewConfig config, TyxEventEnhanced item, TyxResourceTheme theme) {
    if (widget.option?.eventBuilder != null) {
      return Padding(
        padding: const EdgeInsets.all(2),
        child: widget.option!.eventBuilder!(context, item),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Container(
        decoration: BoxDecoration(
          color: item.e.color ?? const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: item.e.color?.withOpacity(0.3) ?? const Color(0xFF86EFAC),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${TimeOfDay.fromDateTime(item.e.start).format(context)} - ${TimeOfDay.fromDateTime(item.e.end).format(context)}",
              style: theme.eventTimeStyle,
              overflow: TextOverflow.ellipsis,
            ),
            if (item.height > 40) ...[
              const SizedBox(height: 2),
              Text(
                item.e.title ?? '',
                style: theme.eventTitleStyle,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<TyxEventEnhanced> _calculateEventPositions(
    _ViewConfig config,
    List<E> events,
    double cellWidth,
  ) {
    final collisionGroups = _getCollisionGroups(events);

    return events.map((e) {
      final startMinutes = e.start.difference(config.initialDate).inMinutes;
      final position = (startMinutes / config.timelotSlotDuration.inMinutes) *
          config.timeslotHeight;

      final eventDurationInMinutes = e.end.difference(e.start).inMinutes;
      final height =
          (eventDurationInMinutes / config.timelotSlotDuration.inMinutes) *
              config.timeslotHeight;

      final group = collisionGroups.firstWhere((g) => g.contains(e));
      final groupSize = group.length;
      final eventIndex = group.indexOf(e);

      final width = cellWidth / groupSize;
      final offsetX = width * eventIndex;

      return TyxEventEnhanced(
        e: e,
        position: position,
        height: height,
        width: width,
        offsetX: offsetX,
        groupSize: groupSize,
      );
    }).toList();
  }

  List<List<E>> _getCollisionGroups(List<E> events) {
    List<List<E>> groups = [];

    for (var event in events) {
      bool addedToGroup = false;
      for (var group in groups) {
        if (group.any((e) => _checkOverlap(e, event))) {
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

  bool _checkOverlap(E e1, E e2) {
    return e1.start.isBefore(e2.end) && e2.start.isBefore(e1.end);
  }
}

class _ViewConfig {
  final double timeslotHeight;
  final Duration timelotSlotDuration;
  final DateTime initialDate;
  final int timeslotCount;
  final double cellW;
  final double timesCellW;
  final double resourceHeaderH;
  final BuildContext context;

  _ViewConfig({
    required this.timeslotHeight,
    required this.timelotSlotDuration,
    required this.initialDate,
    required this.timeslotCount,
    required this.cellW,
    required this.timesCellW,
    required this.resourceHeaderH,
    required this.context,
  });

  factory _ViewConfig.fromOption(
      TyxResourceOption? option, BuildContext context, TyxResourceTheme theme) {
    final timeslotHeight = option?.timeslotHeight ?? theme.timeslotHeight;
    final timelotSlotDuration =
        option?.timelotSlotDuration ?? const Duration(minutes: 15);
    final now = option?.initialDate ?? DateTime.now();

    final initialDate = DateTime(
      now.year,
      now.month,
      now.day,
      option?.timeslotStartTime?.hour ?? 0,
      option?.timeslotStartTime?.minute ?? 0,
    );

    final endOfDate = Jiffy.parseFromDateTime(initialDate).endOf(Unit.day);
    final totalDayDurationInMinutes = endOfDate.diff(
      Jiffy.parseFromDateTime(initialDate),
      unit: Unit.minute,
    );
    final timeslotCount =
        totalDayDurationInMinutes ~/ timelotSlotDuration.inMinutes + 1;

    return _ViewConfig(
      timeslotHeight: timeslotHeight,
      timelotSlotDuration: timelotSlotDuration,
      initialDate: initialDate,
      timeslotCount: timeslotCount,
      cellW: option?.cellWidth ?? theme.cellWidth,
      timesCellW: option?.timesCellWidth ?? theme.timesCellWidth,
      resourceHeaderH:
          option?.resourceHeaderHeight ?? theme.resourceHeaderHeight,
      context: context,
    );
  }
}
