import 'package:flutter/material.dart';
import 'package:timely_x_flutter/src/models/tyx_event.dart';
import 'package:timely_x_flutter/src/models/tyx_event_enhanced.dart';
import 'package:timely_x_flutter/src/models/tyx_view.dart';

import 'tyx_resource.dart';
import 'tyx_resource_enhanced.dart';

class TyxCalendarOption {
  final double? timeslotHeight;
  final Duration? timelotSlotDuration;
  final DateTime? initialDate;
  final TimeOfDay? timeslotStartTime;
  final TimeOfDay? timeslotEndTime;
  final double? cellWidth;
  final double? timesCellWidth;
  final double? resourceHeaderHeight;

  final List<TyxResource>? resources;
  final List<TyxEvent>? events;
  final TyxView initialView;

  // Whether to show trailing days
  final bool showTrailingDays;
  final int? startWeekDay;

  Widget Function(BuildContext context, TyxEventEnhanced item)? eventBuilder;
  Widget Function(BuildContext context, TyxResourceEnhanced item)?
      resourceBuilder;
  TyxCalendarOption({
    this.timeslotHeight,
    this.timelotSlotDuration,
    this.initialDate,
    this.timeslotStartTime,
    this.timeslotEndTime,
    this.cellWidth,
    this.timesCellWidth,
    this.resourceHeaderHeight,
    this.resources,
    this.events,
    this.eventBuilder,
    this.resourceBuilder,
    this.showTrailingDays = false,
    this.startWeekDay = 7,
    this.initialView = TyxView.month,
  });
}
