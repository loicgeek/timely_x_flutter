// lib/src/widgets/week_view.dart (UPDATED with layout options and cell interactions)

import 'dart:async';

import 'package:timely_x/timely_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import '../models/appointment_position.dart';
import '../utils/overlap_calculator.dart';
import '../utils/date_time_utils.dart';
import 'resource_header.dart';
import 'date_header.dart';
import 'grid_painter.dart';
import 'appointment_widget.dart';
import 'slot_highlight_painter.dart';
import 'scroll_navigation_wrapper.dart';

/// Calendar week view - shows multiple days for multiple resources
class CalendarWeekView extends StatefulWidget {
  const CalendarWeekView({
    Key? key,
    required this.controller,
    required this.config,
    required this.theme,
    this.resourceHeaderBuilder,
    this.dateHeaderBuilder,
    this.timeColumnBuilder,
    this.appointmentBuilder,
    this.emptyCellBuilder,
    this.currentTimeIndicatorBuilder,
    this.onAppointmentTap,
    this.onAppointmentLongPress,
    this.onAppointmentSecondaryTap,
    this.onCellTap,
    this.onCellLongPress,
    this.onAppointmentDragEnd,
    this.onResourceHeaderTap,
    this.onDateHeaderTap,
  }) : super(key: key);

  final CalendarController controller;
  final CalendarConfig config;
  final CalendarTheme theme;

  // Builders
  final ResourceHeaderBuilder? resourceHeaderBuilder;
  final DateHeaderBuilder? dateHeaderBuilder;
  final TimeColumnBuilder? timeColumnBuilder;
  final AppointmentBuilder? appointmentBuilder;
  final EmptyCellBuilder? emptyCellBuilder;
  final CurrentTimeIndicatorBuilder? currentTimeIndicatorBuilder;

  // Callbacks
  final OnAppointmentTap? onAppointmentTap;
  final OnAppointmentLongPress? onAppointmentLongPress;
  final OnAppointmentSecondaryTap? onAppointmentSecondaryTap;
  final OnCellTap? onCellTap;
  final OnCellLongPress? onCellLongPress;
  final OnAppointmentDragEnd? onAppointmentDragEnd;
  final OnResourceHeaderTap? onResourceHeaderTap;
  final OnDateHeaderTap? onDateHeaderTap;

  @override
  State<CalendarWeekView> createState() => _CalendarWeekViewState();
}

class _CalendarWeekViewState extends State<CalendarWeekView> {
  late ScrollController _gridVerticalController;
  late ScrollController _gridHorizontalController;
  late ScrollController _timeColumnVerticalController;
  late ScrollController _resourceHeaderHorizontalController;
  late ScrollController _dateHeaderHorizontalController;

  double _columnWidth = 0;
  bool _needsHorizontalScroll = false;
  bool _isUpdatingScroll = false;

  int? _verticalSyncCallbackId;

  ScrollController?
  _horizontalScrollSource; // Track which controller is scrolling

  final Map<String, List<AppointmentPosition>> _positionCache = {};

  Timer? _scrollDebounceTimer;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();

    // Initialize scroll controllers
    _gridVerticalController = ScrollController();
    _gridHorizontalController = ScrollController();
    _timeColumnVerticalController = ScrollController();
    _resourceHeaderHorizontalController = ScrollController();
    _dateHeaderHorizontalController = ScrollController();

    // Add listeners for scroll synchronization
    _gridVerticalController.addListener(_onGridVerticalScroll);
    _gridHorizontalController.addListener(_onGridHorizontalScroll);
    _resourceHeaderHorizontalController.addListener(
      _onResourceHeaderHorizontalScroll,
    );
    _dateHeaderHorizontalController.addListener(_onDateHeaderHorizontalScroll);

    _gridVerticalController.addListener(_onScrollChanged);

    widget.controller.addListener(_onControllerUpdate);
  }

  void _onScrollChanged() {
    if (!_isScrolling) {
      setState(() => _isScrolling = true);
    }

    _scrollDebounceTimer?.cancel();
    _scrollDebounceTimer = Timer(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => _isScrolling = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollDebounceTimer?.cancel();
    _positionCache.clear();
    // Cancel any pending frame callbacks
    if (_verticalSyncCallbackId != null) {
      SchedulerBinding.instance.cancelFrameCallbackWithId(
        _verticalSyncCallbackId!,
      );
    }

    // Remove all listeners
    _gridVerticalController.removeListener(_onScrollChanged);
    _gridVerticalController.removeListener(_onGridVerticalScroll);
    _gridHorizontalController.removeListener(_onGridHorizontalScroll);
    _resourceHeaderHorizontalController.removeListener(
      _onResourceHeaderHorizontalScroll,
    );
    _dateHeaderHorizontalController.removeListener(
      // ← THIS WAS MISSING!
      _onDateHeaderHorizontalScroll,
    );

    // Dispose all controllers
    _gridVerticalController.dispose();
    _gridHorizontalController.dispose();
    _timeColumnVerticalController.dispose();
    _resourceHeaderHorizontalController.dispose();
    _dateHeaderHorizontalController.dispose(); // ← THIS WAS MISSING!

    widget.controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  /// Improved vertical scroll synchronization
  void _onGridVerticalScroll() {
    if (_isUpdatingScroll) return;
    _syncVerticalScrollImmediate(); // ← Change to immediate
  }

  void _syncVerticalScrollImmediate() {
    if (_isUpdatingScroll) return;

    _isUpdatingScroll = true;

    if (!_gridVerticalController.hasClients ||
        !_timeColumnVerticalController.hasClients) {
      _isUpdatingScroll = false;
      return;
    }

    final offset = _gridVerticalController.position.pixels;
    _timeColumnVerticalController.jumpTo(offset);

    _isUpdatingScroll = false;
  }

  /// Improved horizontal scroll synchronization for grid
  void _onGridHorizontalScroll() {
    if (_isUpdatingScroll) return;
    _horizontalScrollSource = _gridHorizontalController;
    _syncHorizontalScrollImmediate();
  }

  /// Improved horizontal scroll synchronization for resource header
  void _onResourceHeaderHorizontalScroll() {
    if (_isUpdatingScroll) return;
    _horizontalScrollSource = _resourceHeaderHorizontalController;
    _syncHorizontalScrollImmediate();
  }

  void _onDateHeaderHorizontalScroll() {
    if (_isUpdatingScroll) return;
    _horizontalScrollSource = _dateHeaderHorizontalController;
    _syncHorizontalScrollImmediate();
  }

  void _syncHorizontalScrollImmediate() {
    if (_isUpdatingScroll) return;

    _isUpdatingScroll = true;

    // Use the tracked source controller
    final source = _horizontalScrollSource;

    // Safety check
    if (source == null || !source.hasClients) {
      _isUpdatingScroll = false;
      return;
    }

    // Get source position
    final sourcePosition = source.position;
    final targetOffset = sourcePosition.pixels;

    // Get all target controllers (everything EXCEPT the source)
    final targets = <ScrollController>[
      if (_gridHorizontalController.hasClients &&
          _gridHorizontalController != source)
        _gridHorizontalController,
      if (_resourceHeaderHorizontalController.hasClients &&
          _resourceHeaderHorizontalController != source)
        _resourceHeaderHorizontalController,
      if (_dateHeaderHorizontalController.hasClients &&
          _dateHeaderHorizontalController != source)
        _dateHeaderHorizontalController,
    ];

    // Sync all targets immediately using jumpTo (no physics check needed)
    for (final target in targets) {
      if (target.hasClients) {
        final currentOffset = target.position.pixels;

        // Only update if different (prevents unnecessary rebuilds)
        if ((currentOffset - targetOffset).abs() > 0.1) {
          target.jumpTo(targetOffset);
        }
      }
    }

    _isUpdatingScroll = false;
  }

  void _onControllerUpdate() {
    _positionCache.clear(); // Clear cache when appointments change
    setState(() {});
  }

  void _calculateColumnWidth(double viewportWidth) {
    final dimensions = widget.config.calculateColumnDimensions(
      viewportWidth: viewportWidth,
      numberOfResources: widget.controller.resources.length,
      effectiveNumberOfDays: widget.controller.effectiveNumberOfDays,
    );

    _columnWidth = dimensions.columnWidth;
    _needsHorizontalScroll = dimensions.requiresHorizontalScroll;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _calculateColumnWidth(constraints.maxWidth);

        return Column(
          children: [
            _buildHeaders(),
            Expanded(child: _buildBody()),
          ],
        );
      },
    );
  }

  Widget _buildHeaders() {
    switch (widget.config.weekViewLayout) {
      case WeekViewLayout.resourcesFirst:
        return _buildResourcesFirstHeaders();
      case WeekViewLayout.daysFirst:
        return _buildDaysFirstHeaders();
    }
  }

  Widget _buildResourcesFirstHeaders() {
    final resources = widget.controller.resources;
    final dates = widget.controller.visibleDates;
    final visibleDates = widget.controller.visibleDates;

    return Column(
      children: [
        // Resource Headers
        SizedBox(
          height: widget.config.resourceHeaderHeight,
          child: Row(
            children: [
              // Time column placeholder
              Container(
                width: widget.config.timeColumnWidth,
                decoration: BoxDecoration(
                  color: widget.theme.headerBackgroundColor,
                  border: Border(
                    right: BorderSide(
                      color: widget.theme.gridLineColor,
                      width: 1,
                    ),
                    bottom: BorderSide(
                      color: widget.theme.hourLineColor,
                      width: 1,
                    ),
                  ),
                  boxShadow: widget.theme.headerShadow,
                ),
              ),
              // Scrollable resource headers
              Expanded(
                child: ScrollNavigationWrapper(
                  child: SingleChildScrollView(
                    controller: _resourceHeaderHorizontalController,
                    scrollDirection: Axis.horizontal,
                    physics: _needsHorizontalScroll
                        ? const AlwaysScrollableScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    child: Row(
                      children: resources.map((resource) {
                        return ResourceHeader(
                          resource: resource,
                          width: _columnWidth * dates.length,
                          theme: widget.theme,
                          builder: widget.resourceHeaderBuilder,
                          onTap: widget.onResourceHeaderTap,
                          date: null,
                          dates: visibleDates,
                          controller: widget.controller,
                          config: widget.config,
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Date Headers
        SizedBox(
          height: widget.config.dateHeaderHeight,
          child: Row(
            children: [
              // Time column placeholder
              Container(
                width: widget.config.timeColumnWidth,
                decoration: BoxDecoration(
                  color: widget.theme.headerBackgroundColor,
                  border: Border(
                    right: BorderSide(
                      color: widget.theme.gridLineColor,
                      width: 1,
                    ),
                    bottom: BorderSide(
                      color: widget.theme.hourLineColor,
                      width: 2,
                    ),
                  ),
                  boxShadow: widget.theme.headerShadow,
                ),
              ),
              // Scrollable date headers
              Expanded(
                child: ScrollNavigationWrapper(
                  child: SingleChildScrollView(
                    controller: _dateHeaderHorizontalController,
                    scrollDirection: Axis.horizontal,
                    physics: _needsHorizontalScroll
                        ? const AlwaysScrollableScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    child: Row(
                      children: [
                        for (final resource in resources)
                          for (final date in dates)
                            DateHeader(
                              date: date,
                              width: _columnWidth,
                              theme: widget.theme,
                              builder: widget.dateHeaderBuilder,
                              onTap: widget.onDateHeaderTap,
                            ),
                      ],
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

  Widget _buildDaysFirstHeaders() {
    final resources = widget.controller.resources;
    final dates = widget.controller.visibleDates;

    return Column(
      children: [
        // Date Headers
        SizedBox(
          height: widget.config.dateHeaderHeight,
          child: Row(
            children: [
              // Time column placeholder
              Container(
                width: widget.config.timeColumnWidth,
                decoration: BoxDecoration(
                  color: widget.theme.headerBackgroundColor,
                  border: Border(
                    right: BorderSide(
                      color: widget.theme.gridLineColor,
                      width: 1,
                    ),
                    bottom: BorderSide(
                      color: widget.theme.hourLineColor,
                      width: 1,
                    ),
                  ),
                  boxShadow: widget.theme.headerShadow,
                ),
              ),
              // Scrollable date headers
              Expanded(
                child: ScrollNavigationWrapper(
                  child: SingleChildScrollView(
                    controller: _dateHeaderHorizontalController,
                    scrollDirection: Axis.horizontal,
                    physics: _needsHorizontalScroll
                        ? const AlwaysScrollableScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    child: Row(
                      children: dates.map((date) {
                        return DateHeader(
                          date: date,
                          width: _columnWidth * resources.length,
                          theme: widget.theme,
                          builder: widget.dateHeaderBuilder,
                          onTap: widget.onDateHeaderTap,
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Resource Headers
        SizedBox(
          height: widget.config.resourceHeaderHeight,
          child: Row(
            children: [
              // Time column placeholder
              Container(
                width: widget.config.timeColumnWidth,
                decoration: BoxDecoration(
                  color: widget.theme.headerBackgroundColor,
                  border: Border(
                    right: BorderSide(
                      color: widget.theme.gridLineColor,
                      width: 1,
                    ),
                    bottom: BorderSide(
                      color: widget.theme.hourLineColor,
                      width: 2,
                    ),
                  ),
                  boxShadow: widget.theme.headerShadow,
                ),
              ),
              // Scrollable resource headers
              Expanded(
                child: ScrollNavigationWrapper(
                  child: SingleChildScrollView(
                    controller: _resourceHeaderHorizontalController,
                    scrollDirection: Axis.horizontal,
                    physics: _needsHorizontalScroll
                        ? const AlwaysScrollableScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    child: Row(
                      children: [
                        for (final date in dates)
                          for (final resource in resources)
                            ResourceHeader(
                              resource: resource,
                              width: _columnWidth,
                              theme: widget.theme,
                              builder: widget.resourceHeaderBuilder,
                              onTap: widget.onResourceHeaderTap,
                              date: date,
                              controller: widget.controller,
                              config: widget.config,
                            ),
                      ],
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

  Widget _buildBody() {
    return Row(
      children: [
        // Time column - scrolls vertically with grid
        Container(
          width: widget.config.timeColumnWidth,
          decoration: BoxDecoration(
            color: widget.theme.timeColumnBackgroundColor,
            border: Border(
              right: BorderSide(color: widget.theme.gridLineColor, width: 1),
            ),
            boxShadow: widget.theme.headerShadow,
          ),
          child: SingleChildScrollView(
            controller: _timeColumnVerticalController,
            physics: const NeverScrollableScrollPhysics(),
            child: _buildTimeLabels(),
          ),
        ),
        // Grid
        Expanded(child: _buildGridWithScrollbar()),
      ],
    );
  }

  Widget _buildGridWithScrollbar() {
    return RawScrollbar(
      controller: _gridVerticalController,
      thumbVisibility: widget.theme.scrollbarTheme.scrollbarAlwaysVisible,
      trackVisibility: widget.theme.scrollbarTheme.scrollbarAlwaysVisible,
      thickness: widget.theme.scrollbarTheme.scrollbarThickness,
      radius: widget.theme.scrollbarTheme.scrollbarRadius,
      thumbColor: widget.theme.scrollbarTheme.scrollbarThumbColor,
      trackColor: widget.theme.scrollbarTheme.scrollbarTrackColor,
      trackBorderColor: widget.theme.scrollbarTheme.scrollbarTrackBorderColor,
      child: _buildGrid(),
    );
  }

  Widget _buildTimeLabels() {
    final slots = <Widget>[];
    final hours = widget.config.dayEndHour - widget.config.dayStartHour;
    final slotsPerHour = 60 ~/ widget.config.timeSlotDuration.inMinutes;

    for (int i = 0; i < hours * slotsPerHour; i++) {
      final hour = widget.config.dayStartHour + (i ~/ slotsPerHour);
      final minute =
          (i % slotsPerHour) * widget.config.timeSlotDuration.inMinutes;
      final time = DateTime(2000, 1, 1, hour, minute);
      final isHourMark = i % slotsPerHour == 0;
      final slotHeight = widget.config.hourHeight / slotsPerHour;

      if (isHourMark) {
        slots.add(
          Container(
            height: slotHeight,
            alignment: Alignment.topCenter,
            padding: widget.theme.timeLabelPadding,
            child: Text(
              DateFormat(widget.theme.timeFormat).format(time),
              style: widget.theme.timeTextStyle,
            ),
          ),
        );
      } else {
        slots.add(SizedBox(height: slotHeight));
      }
    }

    return Column(children: slots);
  }

  void _handleGridTap(
    Offset localPosition,
    List<CalendarResource> resources,
    List<DateTime> dates,
  ) {
    if (widget.onCellTap == null) return;

    final tapData = _calculateCellFromPosition(localPosition, resources, dates);
    if (tapData == null) return;

    widget.onCellTap!(tapData);
  }

  void _handleGridLongPress(
    Offset localPosition,
    List<CalendarResource> resources,
    List<DateTime> dates,
  ) {
    if (widget.onCellLongPress == null) return;

    final tapData = _calculateCellFromPosition(localPosition, resources, dates);
    if (tapData == null) return;

    widget.onCellLongPress!(tapData);
  }

  CellTapData? _calculateCellFromPosition(
    Offset localPosition,
    List<CalendarResource> resources,
    List<DateTime> dates,
  ) {
    // Account for scroll offsets to get actual position in grid
    final verticalOffset = _gridVerticalController.hasClients
        ? _gridVerticalController.position.pixels
        : 0.0;
    final horizontalOffset = _gridHorizontalController.hasClients
        ? _gridHorizontalController.position.pixels
        : 0.0;

    // Adjust tap position by scroll offsets
    final adjustedX = localPosition.dx + horizontalOffset;
    final adjustedY = localPosition.dy + verticalOffset;

    // Calculate column index from adjusted x position
    final columnIndex = (adjustedX / _columnWidth).floor();
    final totalColumns = resources.length * dates.length;

    if (columnIndex < 0 || columnIndex >= totalColumns) {
      return null;
    }

    // Determine resource and date based on layout
    CalendarResource resource;
    DateTime date;

    switch (widget.config.weekViewLayout) {
      case WeekViewLayout.resourcesFirst:
        // Column layout: Resource1[Day1, Day2...], Resource2[Day1, Day2...]
        final resourceIndex = columnIndex ~/ dates.length;
        final dateIndex = columnIndex % dates.length;

        if (resourceIndex >= resources.length || dateIndex >= dates.length) {
          return null;
        }

        resource = resources[resourceIndex];
        date = dates[dateIndex];
        break;

      case WeekViewLayout.daysFirst:
        // Column layout: Day1[Resource1, Resource2...], Day2[Resource1, Resource2...]
        final dateIndex = columnIndex ~/ resources.length;
        final resourceIndex = columnIndex % resources.length;

        if (dateIndex >= dates.length || resourceIndex >= resources.length) {
          return null;
        }

        resource = resources[resourceIndex];
        date = dates[dateIndex];
        break;
    }

    // Calculate time from adjusted y position
    final hourOffset = adjustedY / widget.config.hourHeight;
    final hour = widget.config.dayStartHour + hourOffset.floor();
    final minuteFraction = hourOffset - hourOffset.floor();
    final minutes = (minuteFraction * 60).round();

    // Validate hour is within day bounds
    if (hour < widget.config.dayStartHour || hour >= widget.config.dayEndHour) {
      return null;
    }

    // Snap to time slot if enabled
    final snappedMinutes = widget.config.enableSnapping
        ? (minutes ~/ widget.config.snapToMinutes) * widget.config.snapToMinutes
        : minutes;

    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      snappedMinutes.clamp(0, 59),
    );

    // Get appointments at this location
    final cellAppointments = widget.controller.appointments.where((apt) {
      return apt.resourceId == resource.id &&
          apt.startTime.year == date.year &&
          apt.startTime.month == date.month &&
          apt.startTime.day == date.day &&
          apt.startTime.isBefore(dateTime.add(const Duration(hours: 1))) &&
          apt.endTime.isAfter(dateTime);
    }).toList();

    return CellTapData(
      resource: resource,
      dateTime: dateTime,
      globalPosition: localPosition,
      appointments: cellAppointments,
    );
  }

  Widget _buildGrid() {
    final resources = widget.controller.resources;
    final dates = widget.controller.visibleDates;
    final totalWidth = _columnWidth * resources.length * dates.length;
    final totalHeight = widget.config.totalGridHeight;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (details) =>
          _handleGridTap(details.localPosition, resources, dates),
      onLongPressStart: (details) =>
          _handleGridLongPress(details.localPosition, resources, dates),
      child: SingleChildScrollView(
        controller: _gridVerticalController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: ScrollNavigationWrapper(
          child: SingleChildScrollView(
            controller: _gridHorizontalController,
            scrollDirection: Axis.horizontal,
            physics: _needsHorizontalScroll
                ? const AlwaysScrollableScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            child: SizedBox(
              width: totalWidth,
              height: totalHeight,
              child: Stack(
                children: [
                  // Grid background
                  RepaintBoundary(
                    child: CustomPaint(
                      size: Size(totalWidth, totalHeight),
                      painter: GridPainter(
                        config: widget.config,
                        theme: widget.theme,
                        numberOfColumns: resources.length * dates.length,
                        columnWidth: _columnWidth,
                      ),
                    ),
                  ),
                  // Unavailability layers
                  RepaintBoundary(
                    child: Stack(
                      children: _buildUnavailabilityLayers(resources, dates),
                    ),
                  ),
                  // Appointments
                  ..._buildAppointments(resources, dates),
                  // Current time indicator
                  if (_shouldShowCurrentTimeIndicator())
                    _buildCurrentTimeIndicator(totalWidth),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildUnavailabilityLayers(
    List<CalendarResource> resources,
    List<DateTime> dates,
  ) {
    final widgets = <Widget>[];
    int columnIndex = 0;

    // Determine column order based on layout
    switch (widget.config.weekViewLayout) {
      case WeekViewLayout.resourcesFirst:
        for (final resource in resources) {
          for (final date in dates) {
            _addUnavailabilityForCell(widgets, resource, date, columnIndex);
            columnIndex++;
          }
        }
        break;

      case WeekViewLayout.daysFirst:
        for (final date in dates) {
          for (final resource in resources) {
            _addUnavailabilityForCell(widgets, resource, date, columnIndex);
            columnIndex++;
          }
        }
        break;
    }

    return widgets;
  }

  void _addUnavailabilityForCell(
    List<Widget> widgets,
    CalendarResource resource,
    DateTime date,
    int columnIndex,
  ) {
    // Check availability mode
    final availabilityMode = resource.getAvailabilityMode();

    if (availabilityMode == AvailabilityMode.businessHours) {
      // Business hours mode - show unavailability
      BusinessHours? businessHours;
      if (resource is CalendarResourceWithBusinessHours) {
        businessHours = resource.businessHours;
      }

      if (businessHours == null) return;

      final unavailabilities = BusinessHoursCalculator.getUnavailabilityPeriods(
        businessHours: businessHours,
        date: date,
        config: widget.config,
        themeStyle: widget.theme.unavailabilityStyle,
      );

      if (unavailabilities.isEmpty) return;

      widgets.add(
        Positioned(
          left: columnIndex * _columnWidth,
          top: 0,
          width: _columnWidth,
          height: widget.config.totalGridHeight,
          child: CustomPaint(
            painter: UnavailabilityPainter(
              unavailabilityPeriods: unavailabilities,
              hourHeight: widget.config.hourHeight,
              dayStartHour: widget.config.dayStartHour,
              cellWidth: _columnWidth,
              cellLeft: 0,
            ),
          ),
        ),
      );
    } else if (availabilityMode == AvailabilityMode.slots) {
      // Slot mode - highlight available slots
      SlotAvailability? slotAvailability;
      if (resource is CalendarResourceWithSlots) {
        slotAvailability = resource.slotAvailability;
      }

      if (slotAvailability == null) return;

      final slots = slotAvailability.getSlotsForDate(date);
      if (slots.isEmpty) return;

      widgets.add(
        Positioned(
          left: columnIndex * _columnWidth,
          top: 0,
          width: _columnWidth,
          height: widget.config.totalGridHeight,
          child: CustomPaint(
            painter: SlotHighlightPainter(
              slots: slots,
              config: slotAvailability.highlightConfig,
              hourHeight: widget.config.hourHeight,
              dayStartHour: widget.config.dayStartHour,
              cellWidth: _columnWidth,
              cellLeft: 0,
            ),
          ),
        ),
      );
    }
  }

  List<Widget> _buildCellInteractionLayer(
    List<CalendarResource> resources,
    List<DateTime> dates,
  ) {
    return [];
    final widgets = <Widget>[];
    final cellHeight = widget.config.hourHeight;
    int columnIndex = 0;

    // Determine column order based on layout
    final List<({CalendarResource resource, DateTime date})> cellOrder;

    switch (widget.config.weekViewLayout) {
      case WeekViewLayout.resourcesFirst:
        // Resources first: Resource1[Day1, Day2...], Resource2[Day1, Day2...]
        cellOrder = [
          for (final resource in resources)
            for (final date in dates) (resource: resource, date: date),
        ];
        break;
      case WeekViewLayout.daysFirst:
        // Days first: Day1[Resource1, Resource2...], Day2[Resource1, Resource2...]
        cellOrder = [
          for (final date in dates)
            for (final resource in resources) (resource: resource, date: date),
        ];
        break;
    }

    for (final cell in cellOrder) {
      final hours = widget.config.dayEndHour - widget.config.dayStartHour;

      for (int hour = 0; hour < hours; hour++) {
        final cellDateTime = DateTime(
          cell.date.year,
          cell.date.month,
          cell.date.day,
          widget.config.dayStartHour + hour,
        );

        // Get appointments for this cell
        final cellAppointments = widget.controller.appointments.where((apt) {
          return apt.resourceId == cell.resource.id &&
              apt.startTime.year == cell.date.year &&
              apt.startTime.month == cell.date.month &&
              apt.startTime.day == cell.date.day &&
              apt.startTime.hour <= cellDateTime.hour &&
              apt.endTime.hour > cellDateTime.hour;
        }).toList();

        widgets.add(
          Positioned(
            left: columnIndex * _columnWidth,
            top: hour * cellHeight.toDouble(),
            width: _columnWidth,
            height: cellHeight,
            child: _CellGestureHandler(
              cellDateTime: cellDateTime,
              cellHeight: cellHeight,
              resource: cell.resource,
              cellAppointments: cellAppointments,
              onCellTap: widget.onCellTap,
              onCellLongPress: widget.onCellLongPress,
              calculateTimeFromOffset: _calculateTimeFromOffset,
            ),
          ),
        );
      }

      columnIndex++;
    }

    return widgets;
  }

  List<Widget> _buildAppointments(
    List<CalendarResource> resources,
    List<DateTime> dates,
  ) {
    final widgets = <Widget>[];

    // Handle initial render (before scroll controller is attached)
    if (!_gridVerticalController.hasClients) {
      // Render all appointments on first build
      int columnIndex = 0;
      switch (widget.config.weekViewLayout) {
        case WeekViewLayout.resourcesFirst:
          for (final resource in resources) {
            for (final date in dates) {
              _addAllAppointments(widgets, resource, date, columnIndex);
              columnIndex++;
            }
          }
          break;
        case WeekViewLayout.daysFirst:
          for (final date in dates) {
            for (final resource in resources) {
              _addAllAppointments(widgets, resource, date, columnIndex);
              columnIndex++;
            }
          }
          break;
      }
      return widgets;
    }

    // After initial render, use viewport culling for performance
    final scrollOffset = _gridVerticalController.position.pixels;
    final viewportHeight = _gridVerticalController.position.viewportDimension;

    // Buffer zone (render slightly above/below viewport)
    final buffer = _isScrolling
        ? widget.config.hourHeight *
              2 // 2 hours when scrolling
        : widget.config.hourHeight; // 1 hour when stopped
    final visibleStart = (scrollOffset - buffer).clamp(0.0, double.infinity);
    final visibleEnd = scrollOffset + viewportHeight + buffer;

    int columnIndex = 0;

    switch (widget.config.weekViewLayout) {
      case WeekViewLayout.resourcesFirst:
        for (final resource in resources) {
          for (final date in dates) {
            _addVisibleAppointments(
              widgets,
              resource,
              date,
              columnIndex,
              visibleStart,
              visibleEnd,
            );
            columnIndex++;
          }
        }
        break;

      case WeekViewLayout.daysFirst:
        for (final date in dates) {
          for (final resource in resources) {
            _addVisibleAppointments(
              widgets,
              resource,
              date,
              columnIndex,
              visibleStart,
              visibleEnd,
            );
            columnIndex++;
          }
        }
        break;
    }

    return widgets;
  }

  // Add this helper method for initial render (no culling)
  void _addAllAppointments(
    List<Widget> widgets,
    CalendarResource resource,
    DateTime date,
    int columnIndex,
  ) {
    final appointments = widget.controller.getAppointmentsForResourceDate(
      resource.id,
      date,
    );

    if (appointments.isEmpty) return;

    final dayStart = DateTime(
      date.year,
      date.month,
      date.day,
      widget.config.dayStartHour,
    );

    final positions = OverlapCalculator.calculatePositions(
      appointments: appointments,
      cellWidth: _columnWidth,
      cellLeft: columnIndex * _columnWidth,
      hourHeight: widget.config.hourHeight,
      dayStart: dayStart,
    );

    for (final position in positions) {
      widgets.add(
        AppointmentWidget(
          key: ValueKey(
            '${position.appointment.id}_${position.rect.top.toInt()}_${position.rect.left.toInt()}',
          ),
          position: position,
          resource: resource,
          theme: widget.theme,
          isSelected:
              widget.controller.selectedAppointment?.id ==
              position.appointment.id,
          builder: widget.appointmentBuilder,
          onTap: widget.onAppointmentTap,
          onLongPress: widget.onAppointmentLongPress,
          onSecondaryTap: widget.onAppointmentSecondaryTap,
          enableDrag: widget.config.enableDragAndDrop,
        ),
      );
    }
  }

  void _addVisibleAppointments(
    List<Widget> widgets,
    CalendarResource resource,
    DateTime date,
    int columnIndex,
    double visibleStart,
    double visibleEnd,
  ) {
    final appointments = widget.controller.getAppointmentsForResourceDate(
      resource.id,
      date,
    );

    if (appointments.isEmpty) return;

    // Create cache key
    final cacheKey =
        '${resource.id}_${date.year}_${date.month}_${date.day}_$columnIndex';

    // Check cache first
    List<AppointmentPosition> positions;
    if (_positionCache.containsKey(cacheKey)) {
      positions = _positionCache[cacheKey]!; // Use cached positions
    } else {
      // Calculate and cache
      final dayStart = DateTime(
        date.year,
        date.month,
        date.day,
        widget.config.dayStartHour,
      );

      positions = OverlapCalculator.calculatePositions(
        appointments: appointments,
        cellWidth: _columnWidth,
        cellLeft: columnIndex * _columnWidth,
        hourHeight: widget.config.hourHeight,
        dayStart: dayStart,
      );

      _positionCache[cacheKey] = positions; // Cache for next time
    }

    // Render visible appointments (same as before)
    for (final position in positions) {
      final top = position.rect.top;
      final bottom = top + position.rect.height;

      if (bottom < visibleStart || top > visibleEnd) {
        continue;
      }

      widgets.add(
        AppointmentWidget(
          key: ValueKey(
            '${position.appointment.id}_${position.rect.top.toInt()}_${position.rect.left.toInt()}',
          ),
          position: position,
          resource: resource,
          theme: widget.theme,
          isSelected:
              widget.controller.selectedAppointment?.id ==
              position.appointment.id,
          builder: widget.appointmentBuilder,
          onTap: widget.onAppointmentTap,
          onLongPress: widget.onAppointmentLongPress,
          onSecondaryTap: widget.onAppointmentSecondaryTap,
          enableDrag: widget.config.enableDragAndDrop,
        ),
      );
    }
  }

  bool _shouldShowCurrentTimeIndicator() {
    final now = DateTime.now();
    final weekStart = widget.controller.viewStartDate;
    final weekEnd = weekStart.add(
      Duration(days: widget.controller.effectiveNumberOfDays),
    );

    return now.isAfter(weekStart) && now.isBefore(weekEnd);
  }

  /// Calculate exact DateTime from tap offset within a cell
  DateTime _calculateTimeFromOffset(
    DateTime cellStartTime,
    double offsetY,
    double cellHeight,
  ) {
    // Calculate fraction of hour based on tap position
    final fractionOfHour = offsetY / cellHeight;

    // Calculate minutes from fraction (hour = 60 minutes)
    final additionalMinutes = (fractionOfHour * 60).round();

    // Optionally snap to time slot duration
    final snappedMinutes = widget.config.enableSnapping
        ? (additionalMinutes ~/ widget.config.snapToMinutes) *
              widget.config.snapToMinutes
        : additionalMinutes;

    return cellStartTime.add(Duration(minutes: snappedMinutes));
  }

  Widget _buildCurrentTimeIndicator(double width) {
    final now = DateTime.now();
    final dayStart = DateTime(
      now.year,
      now.month,
      now.day,
      widget.config.dayStartHour,
    );

    final offset = DateTimeUtils.calculateVerticalOffset(
      time: now,
      dayStart: dayStart,
      hourHeight: widget.config.hourHeight,
    );

    return Positioned(
      left: 0,
      top: offset,
      child: Container(
        width: width,
        height: 2,
        color: widget.theme.currentTimeIndicatorColor,
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: widget.theme.currentTimeIndicatorColor,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Container(
                height: 2,
                color: widget.theme.currentTimeIndicatorColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper widget to properly handle cell tap and long press gestures
/// Prevents both callbacks from firing on mobile devices
class _CellGestureHandler extends StatefulWidget {
  const _CellGestureHandler({
    Key? key,
    required this.cellDateTime,
    required this.cellHeight,
    required this.resource,
    required this.cellAppointments,
    required this.onCellTap,
    required this.onCellLongPress,
    required this.calculateTimeFromOffset,
  }) : super(key: key);

  final DateTime cellDateTime;
  final double cellHeight;
  final CalendarResource resource;
  final List<CalendarAppointment> cellAppointments;
  final OnCellTap? onCellTap;
  final OnCellLongPress? onCellLongPress;
  final DateTime Function(DateTime, double, double) calculateTimeFromOffset;

  @override
  State<_CellGestureHandler> createState() => _CellGestureHandlerState();
}

class _CellGestureHandlerState extends State<_CellGestureHandler> {
  bool _longPressTriggered = false;
  Offset? _tapDownPosition;
  Offset? _tapDownGlobalPosition;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) {
        // Track tap position for later use
        _longPressTriggered = false;
        _tapDownPosition = details.localPosition;
        _tapDownGlobalPosition = details.globalPosition;
      },
      onTapUp: (details) {
        // Only fire tap if long press wasn't triggered
        if (!_longPressTriggered && widget.onCellTap != null) {
          final exactDateTime = widget.calculateTimeFromOffset(
            widget.cellDateTime,
            details.localPosition.dy,
            widget.cellHeight,
          );

          widget.onCellTap!.call(
            CellTapData(
              resource: widget.resource,
              dateTime: exactDateTime,
              globalPosition: details.globalPosition,
              appointments: widget.cellAppointments,
            ),
          );
        }
        // Reset flag
        _longPressTriggered = false;
      },
      onTapCancel: () {
        // Reset flag on cancel
        _longPressTriggered = false;
      },
      onLongPressStart: (details) {
        // Mark that long press was triggered
        _longPressTriggered = true;

        if (widget.onCellLongPress != null) {
          final exactDateTime = widget.calculateTimeFromOffset(
            widget.cellDateTime,
            details.localPosition.dy,
            widget.cellHeight,
          );

          widget.onCellLongPress!.call(
            CellTapData(
              resource: widget.resource,
              dateTime: exactDateTime,
              globalPosition: details.globalPosition,
              appointments: widget.cellAppointments,
            ),
          );
        }
      },
      child: Container(color: Colors.transparent),
    );
  }
}
