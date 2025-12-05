// lib/src/widgets/day_view.dart (FIXED)

import 'package:timely_x/timely_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import '../utils/overlap_calculator.dart';
import '../utils/date_time_utils.dart';
import 'resource_header.dart';
import 'grid_painter.dart';
import 'appointment_widget.dart';
import 'slot_highlight_painter.dart';
import 'scroll_navigation_wrapper.dart';

/// Calendar day view - shows all resources for a single day
class CalendarDayView extends StatefulWidget {
  const CalendarDayView({
    Key? key,
    required this.controller,
    required this.config,
    required this.theme,
    this.resourceHeaderBuilder,
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
  }) : super(key: key);

  final CalendarController controller;
  final CalendarConfig config;
  final CalendarTheme theme;

  // Builders
  final ResourceHeaderBuilder? resourceHeaderBuilder;
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

  @override
  State<CalendarDayView> createState() => _CalendarDayViewState();
}

class _CalendarDayViewState extends State<CalendarDayView> {
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

    widget.controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    // Cancel any pending frame callbacks
    if (_verticalSyncCallbackId != null) {
      SchedulerBinding.instance.cancelFrameCallbackWithId(
        _verticalSyncCallbackId!,
      );
    }

    // Remove all listeners
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
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    final resources = widget.controller.resources;
    final currentDate = widget.controller.currentDate; // The day being shown

    return SizedBox(
      height: widget.config.resourceHeaderHeight,
      child: Row(
        children: [
          // Time column placeholder with date
          Container(
            width: widget.config.timeColumnWidth,
            decoration: BoxDecoration(
              color: widget.theme.headerBackgroundColor,
              border: Border(
                right: BorderSide(color: widget.theme.gridLineColor, width: 1),
                bottom: BorderSide(color: widget.theme.hourLineColor, width: 2),
              ),
              boxShadow: widget.theme.headerShadow,
            ),
            child: Center(
              child: Text(
                DateTimeUtils.formatDate(
                  widget.controller.currentDate,
                  'EEE\nMMM d',
                ),
                textAlign: TextAlign.center,
                style: widget.theme.weekdayTextStyle,
              ),
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
                      width: _columnWidth,
                      theme: widget.theme,
                      builder: widget.resourceHeaderBuilder,
                      onTap: widget.onResourceHeaderTap,
                      date: currentDate,
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
            physics:
                const NeverScrollableScrollPhysics(), // Controlled by grid scroll
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

  Widget _buildGrid() {
    final resources = widget.controller.resources;
    final totalWidth = _columnWidth * resources.length;
    final totalHeight = widget.config.totalGridHeight;

    return SingleChildScrollView(
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
                CustomPaint(
                  size: Size(totalWidth, totalHeight),
                  painter: GridPainter(
                    config: widget.config,
                    theme: widget.theme,
                    numberOfColumns: resources.length,
                    columnWidth: _columnWidth,
                  ),
                ),
                // Unavailability layers (business hours)
                ..._buildUnavailabilityLayers(resources),
                // Cell interaction layer
                ..._buildCellInteractionLayer(resources),
                // Appointments
                ..._buildAppointments(resources),
                // Current time indicator
                if (_shouldShowCurrentTimeIndicator())
                  _buildCurrentTimeIndicator(totalWidth),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildUnavailabilityLayers(List<CalendarResource> resources) {
    final widgets = <Widget>[];
    final currentDate = widget.controller.currentDate;

    for (int i = 0; i < resources.length; i++) {
      final resource = resources[i];

      // Check availability mode
      final availabilityMode = resource.getAvailabilityMode();

      if (availabilityMode == AvailabilityMode.businessHours) {
        // Business hours mode - show unavailability
        BusinessHours? businessHours;
        if (resource is CalendarResourceWithBusinessHours) {
          businessHours = resource.businessHours;
        }

        if (businessHours == null) continue;

        final unavailabilities =
            BusinessHoursCalculator.getUnavailabilityPeriods(
              businessHours: businessHours,
              date: currentDate,
              config: widget.config,
              themeStyle: widget.theme.unavailabilityStyle,
            );

        if (unavailabilities.isEmpty) continue;

        widgets.add(
          Positioned(
            left: i * _columnWidth,
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

        if (slotAvailability == null) continue;

        final slots = slotAvailability.getSlotsForDate(currentDate);
        if (slots.isEmpty) continue;

        widgets.add(
          Positioned(
            left: i * _columnWidth,
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

    return widgets;
  }

  List<Widget> _buildCellInteractionLayer(List<CalendarResource> resources) {
    final widgets = <Widget>[];
    final currentDate = widget.controller.currentDate;
    final cellHeight = widget.config.hourHeight;
    final hours = widget.config.dayEndHour - widget.config.dayStartHour;

    for (int i = 0; i < resources.length; i++) {
      final resource = resources[i];

      for (int hour = 0; hour < hours; hour++) {
        final cellDateTime = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
          widget.config.dayStartHour + hour,
        );

        // Get appointments for this cell
        final cellAppointments = widget.controller.appointments.where((apt) {
          return apt.resourceId == resource.id &&
              apt.startTime.year == currentDate.year &&
              apt.startTime.month == currentDate.month &&
              apt.startTime.day == currentDate.day &&
              apt.startTime.hour <= cellDateTime.hour &&
              apt.endTime.hour > cellDateTime.hour;
        }).toList();

        widgets.add(
          Positioned(
            left: i * _columnWidth,
            top: hour * cellHeight,
            width: _columnWidth,
            height: cellHeight,
            child: _CellGestureHandler(
              cellDateTime: cellDateTime,
              cellHeight: cellHeight,
              resource: resource,
              cellAppointments: cellAppointments,
              onCellTap: widget.onCellTap,
              onCellLongPress: widget.onCellLongPress,
              calculateTimeFromOffset: _calculateTimeFromOffset,
            ),
          ),
        );
      }
    }

    return widgets;
  }

  List<Widget> _buildAppointments(List<CalendarResource> resources) {
    final widgets = <Widget>[];
    final currentDate = widget.controller.currentDate;

    for (int i = 0; i < resources.length; i++) {
      final resource = resources[i];
      final appointments = widget.controller.getAppointmentsForResourceDate(
        resource.id,
        currentDate,
      );

      if (appointments.isEmpty) continue;

      final dayStart = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        widget.config.dayStartHour,
      );

      final positions = OverlapCalculator.calculatePositions(
        appointments: appointments,
        cellWidth: _columnWidth,
        cellLeft: i * _columnWidth,
        hourHeight: widget.config.hourHeight,
        dayStart: dayStart,
      );

      for (final position in positions) {
        widgets.add(
          AppointmentWidget(
            key: ValueKey(position.appointment.id),
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

    return widgets;
  }

  bool _shouldShowCurrentTimeIndicator() {
    return DateTimeUtils.isToday(widget.controller.currentDate);
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
