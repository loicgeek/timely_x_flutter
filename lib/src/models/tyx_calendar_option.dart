import 'package:flutter/material.dart';

import 'package:timely_x/src/models/tyx_event.dart';
import 'package:timely_x/src/models/tyx_event_enhanced.dart';
import 'package:timely_x/src/models/tyx_view.dart';

import 'tyx_resource.dart';
import 'tyx_resource_enhanced.dart';

typedef OnRightClick = void Function(
  Offset offset,
  DateTime? date,
  List<TyxEvent>? events,
);

class TyxCalendarOption<T extends TyxEvent> {
  final double? timeslotHeight;
  final Duration? timelotSlotDuration;
  final DateTime? initialDate;
  final TimeOfDay? timeslotStartTime;
  final TimeOfDay? timeslotEndTime;
  final double? cellWidth;
  final double? timesCellWidth;
  final double? resourceHeaderHeight;

  final List<TyxResource>? resources;
  final List<T>? events;
  final TyxView initialView;

  // Whether to show trailing days
  final bool showTrailingDays;
  final int? startWeekDay;

  final TyxCalendarMonthOption<T>? monthOption;
  final TyxCalendarWeekOption<T>? weekOption;
  final TyxCalendarDayOption<T>? dayOption;

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
    this.resourceBuilder,
    this.showTrailingDays = false,
    this.startWeekDay = 7,
    this.initialView = TyxView.month,
    this.monthOption,
    this.weekOption,
    this.dayOption,
  });
}

class TyxCalendarMonthOption<T> {
  Widget Function(BuildContext context, T item)? eventListTileBuilder;
  Widget Function(BuildContext context, T item)? eventIndicatorBuilder;
  final int maxIndicatorsPerDay;

  TyxCalendarMonthOption({
    this.eventListTileBuilder,
    this.eventIndicatorBuilder,
    this.maxIndicatorsPerDay = 4,
  });
}

class TyxCalendarWeekOption<T extends TyxEvent> {
  Widget Function(BuildContext context, T item)? eventIndicatorBuilder;
  TyxCalendarWeekOption({
    this.eventIndicatorBuilder,
  });
}

class TyxCalendarDayOption<T extends TyxEvent> {
  Widget Function(BuildContext context, TyxEventEnhanced<T> item)?
      eventIndicatorBuilder;
  Widget Function(BuildContext context, T item)? eventListTileBuilder;
  TyxCalendarDayOption({
    this.eventIndicatorBuilder,
    this.eventListTileBuilder,
  });
}
