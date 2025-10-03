import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:timely_x/src/models/tyx_resource_theme.dart';
import 'package:timely_x/timely_x.dart';

/// Resource View - Resources displayed as COLUMNS
/// Supports two grouping modes:
/// - Separate: Each resource gets its own column(s)
/// - Combined: Resources share day/week columns (divided into sub-columns)
class TyxResourceVerticalContent<E extends TyxEvent, R extends TyxResource>
    extends StatefulWidget {
  final TyxResourceOption<E, R>? option;
  final TyxResourceViewMode viewMode;
  final TyxResourceTheme? theme;
  final void Function(DateTime date, dynamic resource)? onTimeSlotTap;
  final void Function(TyxEventEnhanced event, dynamic resource)? onEventTap;
  final List<R> resources;
  final List<E> events;

  const TyxResourceVerticalContent({
    super.key,
    this.option,
    this.viewMode = TyxResourceViewMode.day,
    this.theme,
    this.onTimeSlotTap,
    this.onEventTap,
    required this.resources,
    required this.events,
  });

  @override
  State<TyxResourceVerticalContent<E, R>> createState() =>
      _TyxResourceVerticalContentState<E, R>();
}

class _TyxResourceVerticalContentState<E extends TyxEvent,
    R extends TyxResource> extends State<TyxResourceVerticalContent<E, R>> {
  late ScrollController _horizontalScrollController;
  late ScrollController _headerScrollController;
  late ScrollController _verticalScrollController;
  late List<R> _resources;
  late List<E> _events;

  @override
  void initState() {
    super.initState();
    _resources = widget.resources;
    _events = widget.events;
    _horizontalScrollController = ScrollController();
    _headerScrollController = ScrollController();
    _verticalScrollController = ScrollController();
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
  void didUpdateWidget(covariant TyxResourceVerticalContent<E, R> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.resources != oldWidget.resources) {
      _resources = widget.resources;
    }
    if (widget.events != oldWidget.events) {
      _events = widget.events;
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
    final resourceGrouping =
        widget.option?.resourceGrouping ?? TyxResourceGrouping.separate;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(theme.borderRadius),
        color: theme.backgroundColor,
        border: Border.all(color: theme.borderColor),
      ),
      child: resourceGrouping == TyxResourceGrouping.combined
          ? (widget.viewMode == TyxResourceViewMode.day
              ? _buildDayViewCombined(theme)
              : _buildWeekViewCombined(theme))
          : (widget.viewMode == TyxResourceViewMode.day
              ? _buildDayViewSeparate(theme)
              : _buildWeekViewSeparate(theme)),
    );
  }

  // ============================================================================
  // COMBINED MODE - Day/Week columns divided by resources
  // ============================================================================

  Widget _buildDayViewCombined(TyxResourceTheme theme) {
    final config = _ViewConfig.fromOption(widget.option, context, theme);
    final resources = _resources;
    final allEvents = _events;
    final currentDate = config.initialDate;
    final filteredEvents = allEvents.where((e) {
      return e.start.year == currentDate.year &&
          e.start.month == currentDate.month &&
          e.start.day == currentDate.day;
    }).toList();
    final subColumnWidth = config.cellW / resources.length;

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: config.timesCellW,
              height: config.resourceHeaderH,
              decoration: BoxDecoration(
                  color: theme.headerBackground,
                  border: Border(
                      right: BorderSide(color: theme.borderColor),
                      bottom: BorderSide(color: theme.borderColor))),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _headerScrollController,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: Row(
                    children: resources
                        .map((resource) => _buildResourceHeaderSmall(
                            config, resource, theme, subColumnWidth))
                        .toList()),
              ),
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _verticalScrollController,
            scrollDirection: Axis.vertical,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimeColumnContent(config, theme),
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
                        return _buildDayColumn(config, resource, events,
                            config.initialDate, subColumnWidth, theme);
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

  Widget _buildWeekViewCombined(TyxResourceTheme theme) {
    final config = _ViewConfig.fromOption(widget.option, context, theme);
    final resources = _resources;
    final allEvents = _events;
    final currentDate = config.initialDate;
    final startOfWeek = _getStartOfWeek(currentDate);
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    final filteredEvents = allEvents.where((e) {
      return e.start
              .isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
          e.start.isBefore(endOfWeek);
    }).toList();
    final weekDays =
        List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
    final subColumnWidth = config.cellW / resources.length;
    final dayWidth = config.cellW;

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: config.timesCellW,
              height: config.resourceHeaderH,
              decoration: BoxDecoration(
                  color: theme.headerBackground,
                  border: Border(
                      right: BorderSide(color: theme.borderColor),
                      bottom: BorderSide(color: theme.borderColor))),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _headerScrollController,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: Row(
                    children: weekDays
                        .map((date) => _buildDayHeaderWithResources(config,
                            date, resources, theme, dayWidth, subColumnWidth))
                        .toList()),
              ),
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _verticalScrollController,
            scrollDirection: Axis.vertical,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimeColumnContent(config, theme),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: Row(
                      children: weekDays.map((date) {
                        return SizedBox(
                          width: dayWidth,
                          child: Row(
                            children: resources.map((resource) {
                              final events = filteredEvents.where((e) {
                                return e.resourceId == resource.id &&
                                    e.start.year == date.year &&
                                    e.start.month == date.month &&
                                    e.start.day == date.day;
                              }).toList();
                              return _buildDayColumn(config, resource, events,
                                  date, subColumnWidth, theme);
                            }).toList(),
                          ),
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

  Widget _buildResourceHeaderSmall(
      _ViewConfig config, R resource, TyxResourceTheme theme, double width) {
    return Container(
      width: width,
      height: config.resourceHeaderH,
      decoration: BoxDecoration(
          color: theme.headerBackground,
          border: Border(left: BorderSide(color: theme.borderColor))),
      child: widget.option?.resourceBuilder != null
          ? widget.option!.resourceBuilder!(
              context,
              TyxResourceEnhanced(
                  width: width,
                  height: config.resourceHeaderH,
                  resource: resource))
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.grey.shade300),
                  child: Center(
                      child: Text(resource.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white))),
                ),
                const SizedBox(height: 4),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(resource.name,
                        style: theme.resourceNameStyle.copyWith(fontSize: 10),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis)),
              ],
            ),
    );
  }

  Widget _buildDayHeaderWithResources(
      _ViewConfig config,
      DateTime date,
      List<R> resources,
      TyxResourceTheme theme,
      double dayWidth,
      double subColumnWidth) {
    final jiffy = Jiffy.parseFromDateTime(date);
    final isToday = date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;
    return SizedBox(
      width: dayWidth,
      child: Column(
        children: [
          Container(
            width: dayWidth,
            height: config.resourceHeaderH * 0.4,
            decoration: BoxDecoration(
                color: isToday
                    ? theme.headerBackground.withOpacity(0.8)
                    : theme.headerBackground,
                border: Border(
                    left: BorderSide(color: theme.borderColor),
                    bottom: BorderSide(color: theme.borderColor))),
            alignment: Alignment.center,
            child: Text('${jiffy.format(pattern: 'EEE')} ${jiffy.date}',
                style: theme.dayHeaderStyle.copyWith(
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12)),
          ),
          SizedBox(
              height: config.resourceHeaderH * 0.6,
              child: Row(
                  children: resources
                      .map((resource) => _buildResourceHeaderSmall(
                          config, resource, theme, subColumnWidth))
                      .toList())),
        ],
      ),
    );
  }

  // ============================================================================
  // SEPARATE MODE - Each resource has its own column(s)
  // ============================================================================

  Widget _buildDayViewSeparate(TyxResourceTheme theme) {
    final config = _ViewConfig.fromOption(widget.option, context, theme);
    final resources = _resources;
    final allEvents = _events;
    final currentDate = config.initialDate;
    final filteredEvents = allEvents.where((e) {
      return e.start.year == currentDate.year &&
          e.start.month == currentDate.month &&
          e.start.day == currentDate.day;
    }).toList();

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: config.timesCellW,
              height: config.resourceHeaderH,
              decoration: BoxDecoration(
                  color: theme.headerBackground,
                  border: Border(
                      right: BorderSide(color: theme.borderColor),
                      bottom: BorderSide(color: theme.borderColor))),
            ),
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
        Expanded(
          child: SingleChildScrollView(
            controller: _verticalScrollController,
            scrollDirection: Axis.vertical,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimeColumnContent(config, theme),
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
                        return _buildResourceColumn(config, resource, events,
                            config.initialDate, theme);
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

  Widget _buildWeekViewSeparate(TyxResourceTheme theme) {
    final config = _ViewConfig.fromOption(widget.option, context, theme);
    final resources = _resources;
    final allEvents = _events;
    final currentDate = config.initialDate;
    final startOfWeek = _getStartOfWeek(currentDate);
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    final filteredEvents = allEvents.where((e) {
      return e.start
              .isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
          e.start.isBefore(endOfWeek);
    }).toList();

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: config.timesCellW,
              height: config.resourceHeaderH,
              decoration: BoxDecoration(
                  color: theme.headerBackground,
                  border: Border(
                      right: BorderSide(color: theme.borderColor),
                      bottom: BorderSide(color: theme.borderColor))),
            ),
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
        Expanded(
          child: SingleChildScrollView(
            controller: _verticalScrollController,
            scrollDirection: Axis.vertical,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimeColumnContent(config, theme),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: Row(
                      children: resources.map((resource) {
                        return _buildWeekResourceColumn(config, resource,
                            filteredEvents, theme, startOfWeek);
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

  Widget _buildResourceHeadersRow(
      _ViewConfig config, List<R> resources, TyxResourceTheme theme) {
    return SizedBox(
      height: config.resourceHeaderH,
      child: Row(
          children: resources
              .map((resource) => _buildResourceHeader(config, resource, theme))
              .toList()),
    );
  }

  Widget _buildWeekResourceHeadersRow(_ViewConfig config, List<R> resources,
      TyxResourceTheme theme, DateTime startOfWeek) {
    return SizedBox(
      height: config.resourceHeaderH,
      child: Row(
          children: resources
              .map((resource) => _buildWeekResourceHeader(
                  config, resource, theme, startOfWeek))
              .toList()),
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
              bottom: BorderSide(color: theme.borderColor))),
      child: widget.option?.resourceBuilder != null
          ? widget.option!.resourceBuilder!(
              context,
              TyxResourceEnhanced(
                  width: config.cellW,
                  height: config.resourceHeaderH,
                  resource: resource))
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.grey.shade300),
                  child: Center(
                      child: Text(resource.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white))),
                ),
                const SizedBox(height: 8),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(resource.name,
                        style: theme.resourceNameStyle,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis)),
              ],
            ),
    );
  }

  Widget _buildWeekResourceHeader(_ViewConfig config, R resource,
      TyxResourceTheme theme, DateTime startOfWeek) {
    final weekDays =
        List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
    final dayCellWidth = config.cellW / 1.5;
    return SizedBox(
      width: dayCellWidth * 7,
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: theme.headerBackground,
                  border: Border(
                      left: BorderSide(color: theme.borderColor),
                      bottom: BorderSide(color: theme.borderColor))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.grey.shade300),
                    child: Center(
                        child: Text(resource.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white))),
                  ),
                  const SizedBox(height: 4),
                  Text(resource.name,
                      style: theme.resourceNameStyle.copyWith(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
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
                              : BorderSide.none)),
                  child: Text('${jiffy.format(pattern: 'EEE')} ${jiffy.date}',
                      style: theme.dayHeaderStyle),
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
          border: Border(right: BorderSide(color: theme.borderColor))),
      child: SizedBox(
        height: config.timeslotCount * config.timeslotHeight,
        child: Stack(
          children: List.generate(config.timeslotCount, (i) {
            final time = TimeOfDay.fromDateTime(config.initialDate.add(
                Duration(minutes: i * config.timelotSlotDuration.inMinutes)));
            return Positioned(
              top: i * config.timeslotHeight,
              left: 0,
              right: 0,
              height: config.timeslotHeight,
              child: Container(
                decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(
                            color: theme.gridLineColor,
                            width: theme.gridLineWidth))),
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.only(top: 4),
                child: Text(time.format(config.context),
                    style: theme.timeTextStyle),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildResourceColumn(_ViewConfig config, R resource, List<E> events,
      DateTime date, TyxResourceTheme theme) {
    return _buildDayColumn(config, resource, events, date, config.cellW, theme);
  }

  Widget _buildWeekResourceColumn(_ViewConfig config, R resource,
      List<E> allEvents, TyxResourceTheme theme, DateTime startOfWeek) {
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

  Widget _buildDayColumn(_ViewConfig config, dynamic resource, List<E> events,
      DateTime date, double cellWidth, TyxResourceTheme theme) {
    final eventPositions = _calculateEventPositions(config, events, cellWidth);
    return Container(
      width: cellWidth,
      height: config.timeslotCount * config.timeslotHeight,
      decoration: BoxDecoration(
          color: theme.backgroundColor,
          border: Border(left: BorderSide(color: theme.borderColor))),
      child: Stack(
        children: [
          ...List.generate(config.timeslotCount, (i) {
            final slotDateTime = date.add(Duration(
                hours: config.initialDate.hour,
                minutes: config.initialDate.minute +
                    (i * config.timelotSlotDuration.inMinutes)));
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
                                width: theme.gridLineWidth)))),
              ),
            );
          }),
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
                  child: _buildEvent(config, item, theme)),
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
          child: widget.option!.eventBuilder!(context, item));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Container(
        decoration: BoxDecoration(
            color: item.e.color ?? const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                color:
                    item.e.color?.withOpacity(0.3) ?? const Color(0xFF86EFAC),
                width: 1)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "${TimeOfDay.fromDateTime(item.e.start).format(context)} - ${TimeOfDay.fromDateTime(item.e.end).format(context)}",
                style: theme.eventTimeStyle,
                overflow: TextOverflow.ellipsis),
            if (item.height > 40) ...[
              const SizedBox(height: 2),
              Text(item.e.title ?? '',
                  style: theme.eventTitleStyle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2),
            ],
          ],
        ),
      ),
    );
  }

  List<TyxEventEnhanced> _calculateEventPositions(
      _ViewConfig config, List<E> events, double cellWidth) {
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
          groupSize: groupSize);
    }).toList();
  }

  DateTime _getStartOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: daysFromMonday));
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
        option?.timeslotStartTime?.minute ?? 0);
    final endOfDate = Jiffy.parseFromDateTime(initialDate).endOf(Unit.day);
    final totalDayDurationInMinutes =
        endOfDate.diff(Jiffy.parseFromDateTime(initialDate), unit: Unit.minute);
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
