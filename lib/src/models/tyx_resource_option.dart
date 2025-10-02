import 'package:flutter/material.dart';
import 'package:timely_x/src/models/tyx_event.dart';
import 'package:timely_x/src/models/tyx_event_enhanced.dart';

import 'tyx_resource.dart';
import 'tyx_resource_enhanced.dart';

class TyxResourceOption<B extends TyxEvent, R extends TyxResource> {
  final double? timeslotHeight;
  final Duration? timelotSlotDuration;
  final DateTime? initialDate;
  final TimeOfDay? timeslotStartTime;
  final double? cellWidth;
  final double? timesCellWidth;
  final double? resourceHeaderHeight;

  Widget Function(BuildContext context, TyxEventEnhanced item)? eventBuilder;
  Widget Function(BuildContext context, TyxResourceEnhanced item)?
      resourceBuilder;
  TyxResourceOption({
    this.timeslotHeight,
    this.timelotSlotDuration,
    this.initialDate,
    this.timeslotStartTime,
    this.cellWidth,
    this.timesCellWidth,
    this.resourceHeaderHeight,
    this.eventBuilder,
    this.resourceBuilder,
  });

  TyxResourceOption copyWith({
    double? timeslotHeight,
    Duration? timelotSlotDuration,
    DateTime? initialDate,
    TimeOfDay? timeslotStartTime,
    double? cellWidth,
    double? timesCellWidth,
    double? resourceHeaderHeight,
    Widget Function(BuildContext context, TyxEventEnhanced item)? eventBuilder,
    Widget Function(BuildContext context, TyxResourceEnhanced item)?
        resourceBuilder,
  }) {
    return TyxResourceOption(
      timeslotHeight: timeslotHeight ?? this.timeslotHeight,
      timelotSlotDuration: timelotSlotDuration ?? this.timelotSlotDuration,
      initialDate: initialDate ?? this.initialDate,
      timeslotStartTime: timeslotStartTime ?? this.timeslotStartTime,
      cellWidth: cellWidth ?? this.cellWidth,
      timesCellWidth: timesCellWidth ?? this.timesCellWidth,
      resourceHeaderHeight: resourceHeaderHeight ?? this.resourceHeaderHeight,
      eventBuilder: eventBuilder ?? this.eventBuilder,
      resourceBuilder: resourceBuilder ?? this.resourceBuilder,
    );
  }
}
