// lib/src/widgets/resource_header.dart

import 'package:calendar2/calendar2.dart';
import 'package:flutter/material.dart';

class ResourceHeader extends StatefulWidget {
  const ResourceHeader({
    super.key,
    required this.resource,
    required this.width,
    required this.theme,
    this.builder,
    this.onTap,
    this.onLongPress,
    this.onSecondaryTap,
    this.date,
    this.dates,
    required this.controller,
    required this.config,
  });

  final CalendarResource resource;
  final double width;
  final CalendarTheme theme;
  final ResourceHeaderBuilder? builder;
  final OnResourceHeaderTap? onTap;
  final OnResourceHeaderTap? onLongPress;
  final OnResourceHeaderTap? onSecondaryTap;

  final CalendarController controller;

  /// Single date for counting (day view, week days-first)
  final DateTime? date;

  /// Multiple dates for counting (week resources-first)
  final List<DateTime>? dates;

  final CalendarConfig config;

  @override
  State<ResourceHeader> createState() => _ResourceHeaderState();
}

class _ResourceHeaderState extends State<ResourceHeader> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          widget.onTap?.call(
            ResourceHeaderTapData(
              resource: widget.resource,
              globalPosition: Offset.zero,
            ),
          );
        },
        onLongPress: () {
          widget.onLongPress?.call(
            ResourceHeaderTapData(
              resource: widget.resource,
              globalPosition: Offset.zero,
            ),
          );
        },
        onSecondaryTap: () {
          widget.onSecondaryTap?.call(
            ResourceHeaderTapData(
              resource: widget.resource,
              globalPosition: Offset.zero,
            ),
          );
        },
        child:
            widget.builder?.call(
              context: context,
              resource: widget.resource,
              width: widget.width,
              isHovered: _isHovered,
              appointmentsCount:
                  widget.dates != null && widget.dates!.isNotEmpty
                  ? widget.controller.getAppointmentCountForResourceDates(
                      widget.resource.id,
                      widget.dates!,
                    )
                  : widget.date != null
                  ? widget.controller
                        .getAppointmentsForResourceDate(
                          widget.resource.id,
                          widget.date!,
                        )
                        .length
                  : 0,
            ) ??
            DefaultBuilders.resourceHeader(
              context: context,
              resource: widget.resource,
              width: widget.width,
              isHovered: _isHovered,
              theme: widget.theme,
              config: widget.config,
              controller: widget.controller,
              date: widget.date,
              dates: widget.dates,
            ),
      ),
    );
  }
}
