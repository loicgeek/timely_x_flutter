// lib/src/builders/agenda_builder_delegates.dart

import 'package:flutter/material.dart';
import 'package:timely_x/timely_x.dart';
import '../models/calendar_appointment.dart';
import '../models/calendar_resource.dart';
import '../utils/agenda_grouping.dart';

/// Builder for date group header in agenda view
typedef AgendaDateHeaderBuilder =
    Widget Function(
      BuildContext context,
      AgendaGroupHeader header,
      bool isExpanded,
    );

/// Builder for resource group header in agenda view
typedef AgendaResourceHeaderBuilder =
    Widget Function(
      BuildContext context,
      AgendaGroupHeader header,
      bool isExpanded,
    );

/// Builder for individual agenda item
typedef AgendaItemBuilder =
    Widget Function(
      BuildContext context,
      AgendaItem item,
      bool isSelected,
      bool isHovered,
      CalendarTheme theme,
      AgendaViewConfig config,
    );

/// Builder for empty state when no appointments exist
typedef AgendaEmptyStateBuilder =
    Widget Function(BuildContext context, String message);

/// Builder for agenda item time display
typedef AgendaTimeBuilder =
    Widget Function(BuildContext context, CalendarAppointment appointment);

/// Builder for agenda item duration display
typedef AgendaDurationBuilder =
    Widget Function(BuildContext context, Duration duration);

/// Builder for resource avatar in agenda item
typedef AgendaResourceAvatarBuilder =
    Widget Function(
      BuildContext context,
      CalendarResource resource,
      double size,
    );

/// Builder for appointment status indicator
typedef AgendaStatusIndicatorBuilder =
    Widget Function(
      BuildContext context,
      CalendarAppointment appointment,
      double size,
    );

/// Add these to the main CalendarView widget parameters:
/// 
/// ```dart
/// class CalendarView extends StatefulWidget {
///   const CalendarView({
///     // ... existing parameters ...
///     
///     // Agenda view builders
///     this.agendaDateHeaderBuilder,
///     this.agendaResourceHeaderBuilder,
///     this.agendaItemBuilder,
///     this.agendaEmptyStateBuilder,
///     this.agendaTimeBuilder,
///     this.agendaDurationBuilder,
///     this.agendaResourceAvatarBuilder,
///     this.agendaStatusIndicatorBuilder,
///   });
///   
///   // ... existing fields ...
///   
///   /// Custom builder for date group headers in agenda view
///   final AgendaDateHeaderBuilder? agendaDateHeaderBuilder;
///   
///   /// Custom builder for resource group headers in agenda view
///   final AgendaResourceHeaderBuilder? agendaResourceHeaderBuilder;
///   
///   /// Custom builder for individual agenda items
///   final AgendaItemBuilder? agendaItemBuilder;
///   
///   /// Custom builder for empty state
///   final AgendaEmptyStateBuilder? agendaEmptyStateBuilder;
///   
///   /// Custom builder for time display in agenda items
///   final AgendaTimeBuilder? agendaTimeBuilder;
///   
///   /// Custom builder for duration display
///   final AgendaDurationBuilder? agendaDurationBuilder;
///   
///   /// Custom builder for resource avatar
///   final AgendaResourceAvatarBuilder? agendaResourceAvatarBuilder;
///   
///   /// Custom builder for status indicator
///   final AgendaStatusIndicatorBuilder? agendaStatusIndicatorBuilder;
/// }
/// ```