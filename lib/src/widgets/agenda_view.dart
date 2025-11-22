// lib/src/views/agenda_view.dart

import 'package:calendar2/src/builders/agenda_default_builders.dart';
import 'package:flutter/material.dart';
import '../models/agenda_view_config.dart';
import '../models/calendar_config.dart';
import '../models/calendar_theme.dart';
import '../controllers/calendar_controller.dart';
import '../utils/agenda_grouping.dart';
import '../builders/agenda_builder_delegates.dart';

import '../models/interaction_data.dart';

/// Agenda/list view for calendar appointments
class AgendaView extends StatefulWidget {
  const AgendaView({
    super.key,
    required this.controller,
    this.theme,
    this.config,
    this.agendaDateHeaderBuilder,
    this.agendaResourceHeaderBuilder,
    this.agendaItemBuilder,
    this.agendaEmptyStateBuilder,
    this.agendaTimeBuilder,
    this.agendaDurationBuilder,
    this.agendaResourceAvatarBuilder,
    this.agendaStatusIndicatorBuilder,
    this.onAppointmentTap,
    this.onAppointmentLongPress,
    this.onAppointmentSecondaryTap,
  });

  /// Calendar controller
  final CalendarController controller;

  /// Theme customization
  final CalendarTheme? theme;

  /// Agenda view configuration
  final CalendarConfig? config;

  /// Custom date header builder
  final AgendaDateHeaderBuilder? agendaDateHeaderBuilder;

  /// Custom resource header builder
  final AgendaResourceHeaderBuilder? agendaResourceHeaderBuilder;

  /// Custom agenda item builder
  final AgendaItemBuilder? agendaItemBuilder;

  /// Custom empty state builder
  final AgendaEmptyStateBuilder? agendaEmptyStateBuilder;

  /// Custom time builder
  final AgendaTimeBuilder? agendaTimeBuilder;

  /// Custom duration builder
  final AgendaDurationBuilder? agendaDurationBuilder;

  /// Custom resource avatar builder
  final AgendaResourceAvatarBuilder? agendaResourceAvatarBuilder;

  /// Custom status indicator builder
  final AgendaStatusIndicatorBuilder? agendaStatusIndicatorBuilder;

  /// Callback when appointment is tapped
  final Function(AppointmentTapData)? onAppointmentTap;

  /// Callback when appointment is long pressed
  final Function(AppointmentLongPressData)? onAppointmentLongPress;

  /// Callback when appointment is secondary tapped (right-click)
  final Function(AppointmentSecondaryTapData)? onAppointmentSecondaryTap;

  @override
  State<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends State<AgendaView> {
  String? _hoveredItemKey;
  final ScrollController _scrollController = ScrollController();

  CalendarTheme get _theme => widget.theme ?? CalendarTheme();

  // and prioritize the local widget config if provided, falling back
  // to the controller's agendaConfig, and finally to default.
  AgendaViewConfig get _agendaConfig {
    // If agendaConfig is passed directly to AgendaView, use it.
    if (widget.config?.agendaConfig != null) {
      return widget.config!.agendaConfig!;
    }

    // If AgendaView is wrapped in CalendarView, the controller's config should be available.
    // Assuming controller exposes its main CalendarConfig via a getter.
    // The CalendarView widget should have passed config.agendaConfig, but for direct
    // usage, we'll check the controller's internal config.

    // ❗️ You need to ensure CalendarController exposes its config like this:
    if (widget.controller.config.agendaConfig != null) {
      return widget.controller.config.agendaConfig!;
    }

    // Since we don't have the controller's source, we'll maintain the current logic
    // but note that the caller (CalendarView) is responsible for passing the final config.
    // The CalendarView implementation you provided already handles this correctly:
    // agendaConfig: config.agendaConfig,

    // Since CalendarView already passes the correct config, and if AgendaView is used
    // directly, it can't know the parent CalendarConfig, we'll keep the existing simple fallback:
    return const AgendaViewConfig();
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointments = widget.controller.appointments;
    final resources = widget.controller.resources;

    // Use the controller's effective config
    final CalendarConfig primaryConfig = widget.controller.config;
    final AgendaViewConfig effectiveAgendaConfig =
        widget.config?.agendaConfig ??
        primaryConfig.agendaConfig ??
        const AgendaViewConfig();

    // ⭐️ CRITICAL FIX: Get the definitive date range directly from the controller.
    // The controller is the source of truth for navigation/config.

    DateTime startDate;
    DateTime endDate;

    if (effectiveAgendaConfig.dateRangeMode == AgendaDateRangeMode.relative) {
      // In relative mode, the start date is based on the controller's _currentDate
      // (which changes during next/previous navigation).
      startDate = widget.controller.viewStartDate;

      // Calculate the end date using the controller's viewStartDate and daysToShow
      final daysToShow = effectiveAgendaConfig.daysToShow;

      // If showPastAppointments is FALSE, startDate is guaranteed to be >= today.
      if (!effectiveAgendaConfig.showPastAppointments) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        // Ensure startDate is at least 'today' if showPastAppointments is false
        startDate = startDate.isBefore(today) ? today : startDate;
      }

      final lastDay = startDate.day + daysToShow - 1;
      endDate = DateTime(
        startDate.year,
        startDate.month,
        lastDay,
        23, // Extend to end of day
        59,
        59,
        999,
      );
    } else {
      // Custom date range mode
      startDate = widget.controller.viewStartDate; // = _agendaStartDate!

      // CRITICAL: Must use the definitive _agendaEndDate if set (which includes 23:59:59.999)
      endDate =
          widget.controller.agendaEndDate ??
          DateTime(
            // Fallback logic is complex, simplify if possible
            startDate.year,
            startDate.month,
            startDate.day +
                widget.controller.effectiveNumberOfDays -
                1, // Fallback end day
            23,
            59,
            59,
            999,
          );
    }

    // Group appointments
    final groups = AgendaGroupingUtils.groupAppointments(
      appointments: appointments,
      resources: resources,
      mode: effectiveAgendaConfig.groupingMode,
      showEmptyDays: effectiveAgendaConfig.showEmptyDays,
      showEmptyResources: effectiveAgendaConfig.showEmptyResources,
      startDate: startDate,
      endDate: endDate,
    );

    // Check if there are any appointments
    final hasAppointments = groups.any((group) => group.hasItems);

    if (!hasAppointments) {
      return _buildEmptyState();
    }

    return Container(
      color: _theme.gridBackgroundColor,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: groups.length,
        itemBuilder: (context, index) {
          return _buildGroup(groups[index]);
        },
      ),
    );
  }

  /// Build a group (with optional subgroups)
  Widget _buildGroup(AgendaGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Group header
        _buildGroupHeader(group),

        // Direct items (if not nested)
        if (group.items.isNotEmpty) ...group.items.map(_buildItem),

        // Sub-groups (if nested)
        if (group.subGroups != null)
          ...group.subGroups!.map(
            (subGroup) => Padding(
              padding: const EdgeInsets.only(left: 0),
              child: _buildSubGroup(subGroup),
            ),
          ),
      ],
    );
  }

  /// Build a sub-group
  Widget _buildSubGroup(AgendaGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sub-group header
        _buildSubGroupHeader(group),

        // Items
        ...group.items.map(_buildItem),
      ],
    );
  }

  /// Build group header (date or resource)
  Widget _buildGroupHeader(AgendaGroup group) {
    final isDateHeader = group.header.date != null;

    if (isDateHeader) {
      if (widget.agendaDateHeaderBuilder != null) {
        return widget.agendaDateHeaderBuilder!(context, group.header, true);
      }
      return AgendaDefaultBuilders.dateHeader(
        context,
        group.header,
        true,
        _theme,
      );
    } else {
      if (widget.agendaResourceHeaderBuilder != null) {
        return widget.agendaResourceHeaderBuilder!(context, group.header, true);
      }
      return AgendaDefaultBuilders.resourceHeader(
        context,
        group.header,
        true,
        _theme,
        _agendaConfig,
      );
    }
  }

  /// Build sub-group header
  Widget _buildSubGroupHeader(AgendaGroup group) {
    final isDateHeader = group.header.date != null;

    if (isDateHeader) {
      if (widget.agendaDateHeaderBuilder != null) {
        return widget.agendaDateHeaderBuilder!(context, group.header, true);
      }
      return Padding(
        padding: const EdgeInsets.only(left: 16),
        child: AgendaDefaultBuilders.dateHeader(
          context,
          group.header,
          true,
          _theme,
        ),
      );
    } else {
      if (widget.agendaResourceHeaderBuilder != null) {
        return widget.agendaResourceHeaderBuilder!(context, group.header, true);
      }
      return Padding(
        padding: const EdgeInsets.only(left: 16),
        child: AgendaDefaultBuilders.resourceHeader(
          context,
          group.header,
          true,
          _theme,
          _agendaConfig,
        ),
      );
    }
  }

  /// Build individual agenda item
  Widget _buildItem(AgendaItem item) {
    final appointment = item.appointment;
    final itemKey = '${appointment.id}_${appointment.startTime}';
    final isSelected =
        widget.controller.selectedAppointment?.id == appointment.id;
    final isHovered = _hoveredItemKey == itemKey;

    Widget itemWidget;

    if (widget.agendaItemBuilder != null) {
      itemWidget = widget.agendaItemBuilder!(
        context,
        item,
        isSelected,
        isHovered,
      );
    } else {
      itemWidget = AgendaDefaultBuilders.item(
        context,
        item,
        isSelected,
        isHovered,
        _theme,
        _agendaConfig,
      );
    }

    return MouseRegion(
      onEnter: (_) {
        if (mounted) {
          setState(() {
            _hoveredItemKey = itemKey;
          });
        }
      },
      onExit: (_) {
        if (mounted) {
          setState(() {
            _hoveredItemKey = null;
          });
        }
      },
      child: GestureDetector(
        onTap: _agendaConfig.enableAppointmentTap
            ? () => _handleTap(item)
            : null,
        onLongPress: _agendaConfig.enableAppointmentLongPress
            ? () => _handleLongPress(item)
            : null,
        onSecondaryTap: () => _handleSecondaryTap(item),
        child: Column(
          children: [
            itemWidget,
            // Divider
            if (_theme.agendaDividerThickness != null &&
                (_theme.agendaDividerThickness ?? 0) > 0)
              Divider(
                height: _theme.agendaDividerThickness,
                thickness: _theme.agendaDividerThickness,
                color: _theme.agendaDividerColor ?? const Color(0xFFE0E0E0),
                indent: _theme.agendaDividerIndent ?? 16,
                endIndent: _theme.agendaDividerEndIndent ?? 0,
              ),
          ],
        ),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    String message = 'No appointments scheduled';

    if (!_agendaConfig.showPastAppointments) {
      message = 'No upcoming appointments';
    }

    if (widget.agendaEmptyStateBuilder != null) {
      return widget.agendaEmptyStateBuilder!(context, message);
    }

    return AgendaDefaultBuilders.emptyState(context, message, _theme);
  }

  /// Handle appointment tap
  void _handleTap(AgendaItem item) {
    widget.controller.selectAppointment(item.appointment);

    if (widget.onAppointmentTap != null) {
      widget.onAppointmentTap!(
        AppointmentTapData(
          appointment: item.appointment,
          resource: item.resource,
          globalPosition: Offset.zero,
        ),
      );
    }
  }

  /// Handle appointment long press
  void _handleLongPress(AgendaItem item) {
    if (widget.onAppointmentLongPress != null) {
      widget.onAppointmentLongPress!(
        AppointmentLongPressData(
          appointment: item.appointment,
          resource: item.resource,
          globalPosition: Offset.zero,
        ),
      );
    }
  }

  /// Handle appointment secondary tap
  void _handleSecondaryTap(AgendaItem item) {
    if (widget.onAppointmentSecondaryTap != null) {
      widget.onAppointmentSecondaryTap!(
        AppointmentSecondaryTapData(
          appointment: item.appointment,
          resource: item.resource,
          globalPosition: Offset.zero,
        ),
      );
    }
  }
}
