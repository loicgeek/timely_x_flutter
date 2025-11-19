// lib/src/widgets/resource_header.dart

import 'package:flutter/material.dart';
import '../models/calendar_resource.dart';
import '../models/calendar_theme.dart';
import '../builders/builder_delegates.dart';
import '../builders/default_builders.dart';
import '../models/interaction_data.dart';

class ResourceHeader extends StatefulWidget {
  const ResourceHeader({
    Key? key,
    required this.resource,
    required this.width,
    required this.theme,
    this.builder,
    this.onTap,
    this.onLongPress,
    this.onSecondaryTap,
  }) : super(key: key);

  final CalendarResource resource;
  final double width;
  final CalendarTheme theme;
  final ResourceHeaderBuilder? builder;
  final OnResourceHeaderTap? onTap;
  final OnResourceHeaderTap? onLongPress;
  final OnResourceHeaderTap? onSecondaryTap;

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
              context,
              widget.resource,
              widget.width,
              _isHovered,
            ) ??
            DefaultBuilders.resourceHeader(
              context,
              widget.resource,
              widget.width,
              _isHovered,
              widget.theme,
            ),
      ),
    );
  }
}
