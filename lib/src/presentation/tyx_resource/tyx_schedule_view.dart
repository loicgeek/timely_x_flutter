import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:timely_x/src/models/tyx_resource_theme.dart';
import 'package:timely_x/timely_x.dart';

/// Schedule View - Resources displayed as ROWS
/// - Day view: Time slots run horizontally (columns)
/// - Week view: Days run horizontally (columns)
class TyxScheduleView<E extends TyxEvent, R extends TyxResource>
    extends StatefulWidget {
  final TyxResourceOption<E, R>? option;
  final TyxResourceViewMode viewMode;
  final TyxResourceTheme? theme;
  final void Function(DateTime date, dynamic resource)? onTimeSlotTap;
  final void Function(TyxEventEnhanced event, dynamic resource)? onEventTap;
  final List<R> resources;
  final List<E> events;

  const TyxScheduleView({
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
  State<TyxScheduleView<E, R>> createState() => _TyxScheduleViewState<E, R>();
}

class _TyxScheduleViewState<E extends TyxEvent, R extends TyxResource>
    extends State<TyxScheduleView<E, R>> {
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
  void didUpdateWidget(covariant TyxScheduleView<E, R> oldWidget) {
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
                    bottom: BorderSide(color: theme.borderColor)),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _headerScrollController,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: _buildTimeHeadersRow(config, theme),
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
                _buildResourceNamesColumn(config, resources, theme),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      children: resources.map((resource) {
                        final events = filteredEvents
                            .where((e) => e.resourceId == resource.id)
                            .toList();
                        return _buildResourceRowWithTimeSlots(
                            config, resource, events, currentDate, theme);
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
                    bottom: BorderSide(color: theme.borderColor)),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _headerScrollController,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: Row(
                  children: weekDays.map((date) {
                    final jiffy = Jiffy.parseFromDateTime(date);
                    final isToday = date.year == DateTime.now().year &&
                        date.month == DateTime.now().month &&
                        date.day == DateTime.now().day;
                    return Container(
                      width: config.cellW,
                      height: config.resourceHeaderH,
                      decoration: BoxDecoration(
                        color: isToday
                            ? theme.headerBackground.withOpacity(0.8)
                            : theme.headerBackground,
                        border: Border(
                            left: BorderSide(color: theme.borderColor),
                            bottom: BorderSide(color: theme.borderColor)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                          '${jiffy.format(pattern: 'EEE')}\n${jiffy.date}',
                          style: theme.dayHeaderStyle.copyWith(
                              fontWeight: isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal),
                          textAlign: TextAlign.center),
                    );
                  }).toList(),
                ),
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
                _buildResourceNamesColumn(config, resources, theme),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      children: resources.map((resource) {
                        return Row(
                          children: weekDays.map((date) {
                            final events = filteredEvents.where((e) {
                              return e.resourceId == resource.id &&
                                  e.start.year == date.year &&
                                  e.start.month == date.month &&
                                  e.start.day == date.day;
                            }).toList();
                            return _buildDayCell(
                                config, resource, events, date, theme);
                          }).toList(),
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

  Widget _buildTimeHeadersRow(_ViewConfig config, TyxResourceTheme theme) {
    return SizedBox(
      height: config.resourceHeaderH,
      width: config.timeslotCount * config.timeslotHeight,
      child: Row(
        children: List.generate(config.timeslotCount, (i) {
          final time = TimeOfDay.fromDateTime(config.initialDate.add(
              Duration(minutes: i * config.timelotSlotDuration.inMinutes)));
          return Container(
            width: config.timeslotHeight,
            height: config.resourceHeaderH,
            decoration: BoxDecoration(
                color: theme.headerBackground,
                border: Border(
                    left: BorderSide(color: theme.borderColor),
                    bottom: BorderSide(color: theme.borderColor))),
            alignment: Alignment.center,
            child: RotatedBox(
                quarterTurns: -1,
                child: Text(time.format(config.context),
                    style: theme.timeTextStyle)),
          );
        }),
      ),
    );
  }

  Widget _buildResourceNamesColumn(
      _ViewConfig config, List<R> resources, TyxResourceTheme theme) {
    return Container(
      width: config.timesCellW,
      decoration: BoxDecoration(
          color: theme.timeColumnBackground,
          border: Border(right: BorderSide(color: theme.borderColor))),
      child: Column(
        children: resources.map((resource) {
          return Container(
            width: config.timesCellW,
            height: config.cellW,
            decoration: BoxDecoration(
                color: theme.headerBackground,
                border: Border(top: BorderSide(color: theme.borderColor))),
            child: widget.option?.resourceBuilder != null
                ? widget.option!.resourceBuilder!(
                    context,
                    TyxResourceEnhanced(
                        width: config.timesCellW,
                        height: config.cellW,
                        resource: resource))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade300),
                        child: Center(
                            child: Text(
                                resource.name.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white))),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(resource.name,
                              style: theme.resourceNameStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis)),
                    ],
                  ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildResourceRowWithTimeSlots(_ViewConfig config, R resource,
      List<E> events, DateTime date, TyxResourceTheme theme) {
    final eventPositions = _calculateEventPositionsHorizontal(config, events);
    return Container(
      width: config.timeslotCount * config.timeslotHeight,
      height: config.cellW,
      decoration: BoxDecoration(
          color: theme.backgroundColor,
          border: Border(top: BorderSide(color: theme.borderColor))),
      child: Stack(
        children: [
          ...List.generate(config.timeslotCount, (i) {
            final slotDateTime = date.add(Duration(
                hours: config.initialDate.hour,
                minutes: config.initialDate.minute +
                    (i * config.timelotSlotDuration.inMinutes)));
            return Positioned(
              left: i * config.timeslotHeight,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: widget.onTimeSlotTap != null
                    ? () => widget.onTimeSlotTap!(slotDateTime, resource)
                    : null,
                behavior: HitTestBehavior.opaque,
                child: Container(
                    width: config.timeslotHeight,
                    decoration: BoxDecoration(
                        border: Border(
                            left: BorderSide(
                                color: theme.gridLineColor,
                                width: theme.gridLineWidth)))),
              ),
            );
          }),
          ...eventPositions.map((item) {
            return Positioned(
              left: item.position,
              top: item.offsetX,
              width: item.height,
              height: item.width,
              child: GestureDetector(
                  onTap: widget.onEventTap != null
                      ? () => widget.onEventTap!(item, resource)
                      : null,
                  child: _buildEventHorizontal(config, item, theme)),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDayCell(_ViewConfig config, dynamic resource, List<E> events,
      DateTime date, TyxResourceTheme theme) {
    return Container(
      width: config.cellW,
      height: config.cellW,
      decoration: BoxDecoration(
          color: theme.backgroundColor,
          border: Border(
              left: BorderSide(color: theme.borderColor),
              top: BorderSide(color: theme.borderColor))),
      child: GestureDetector(
        onTap: widget.onTimeSlotTap != null
            ? () => widget.onTimeSlotTap!(date, resource)
            : null,
        child: Stack(
          children: [
            if (events.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < events.length && i < 3; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: GestureDetector(
                          onTap: widget.onEventTap != null
                              ? () => widget.onEventTap!(
                                  TyxEventEnhanced(
                                      e: events[i],
                                      position: 0,
                                      height: 0,
                                      width: 0,
                                      offsetX: 0,
                                      groupSize: 1),
                                  resource)
                              : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                                color:
                                    events[i].color ?? const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color: events[i].color?.withOpacity(0.3) ??
                                        const Color(0xFF86EFAC),
                                    width: 1)),
                            child: Text(events[i].title ?? '',
                                style: theme.eventTitleStyle
                                    .copyWith(fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1),
                          ),
                        ),
                      ),
                    if (events.length > 3)
                      Text('+${events.length - 3} more',
                          style: theme.eventTimeStyle.copyWith(fontSize: 10)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventHorizontal(
      _ViewConfig config, TyxEventEnhanced item, TyxResourceTheme theme) {
    if (widget.option?.eventBuilder != null) {
      return Padding(
          padding: const EdgeInsets.all(2),
          child: widget.option!.eventBuilder!(context, item));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
            color: item.e.color ?? const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                color:
                    item.e.color?.withOpacity(0.3) ?? const Color(0xFF86EFAC),
                width: 1)),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (item.width > 30)
              Text(item.e.title ?? '',
                  style: theme.eventTitleStyle.copyWith(fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1),
            if (item.width > 50)
              Text("${TimeOfDay.fromDateTime(item.e.start).format(context)}",
                  style: theme.eventTimeStyle.copyWith(fontSize: 9),
                  overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  List<TyxEventEnhanced> _calculateEventPositionsHorizontal(
      _ViewConfig config, List<E> events) {
    final collisionGroups = _getCollisionGroups(events);
    return events.map((e) {
      final startMinutes = e.start.difference(config.initialDate).inMinutes;
      final position = (startMinutes / config.timelotSlotDuration.inMinutes) *
          config.timeslotHeight;
      final eventDurationInMinutes = e.end.difference(e.start).inMinutes;
      final width =
          (eventDurationInMinutes / config.timelotSlotDuration.inMinutes) *
              config.timeslotHeight;
      final group = collisionGroups.firstWhere((g) => g.contains(e));
      final groupSize = group.length;
      final eventIndex = group.indexOf(e);
      final height = config.cellW / groupSize;
      final offsetX = height * eventIndex;
      return TyxEventEnhanced(
          e: e,
          position: position,
          height: width,
          width: height,
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
