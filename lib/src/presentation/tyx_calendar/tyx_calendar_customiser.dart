import 'package:flutter/material.dart';
import 'package:timely_x/timely_x.dart';

/// A class that provides extensive customization options for the TyxCalendar.
/// This allows developers to modify the appearance and behavior of various
/// calendar elements.
class TyxCalendarCustomizer {
  /// Customizes the appearance of the calendar header.
  final TyxHeaderStyle headerStyle;

  /// Customizes the appearance of day cells.
  final TyxDayCellStyle dayCellStyle;

  /// Customizes the appearance of event indicators.
  final TyxEventStyle eventStyle;

  /// Customizes weekday header appearance.
  final TyxWeekdayStyle weekdayStyle;

  /// Determines if the calendar should animate between view changes.
  final bool animateViewChanges;

  /// Animation duration for view transitions if [animateViewChanges] is true.
  final Duration viewChangeAnimationDuration;

  /// Custom builder for day cells.
  final Widget Function(BuildContext context, DateTime date, bool isToday,
      bool isCurrentMonth, List<TyxEvent> events)? dayBuilder;

  /// Custom builder for event indicators.
  final Widget Function(BuildContext context, TyxEvent event)? eventBuilder;

  /// Custom builder for the month header.
  final Widget Function(BuildContext context, DateTime currentMonth,
      Function() nextMonth, Function() previousMonth)? monthHeaderBuilder;

  /// Custom builder for the weekday headers.
  final Widget Function(BuildContext context, List<String> weekdays)?
      weekdayHeaderBuilder;

  /// Called when a day cell is tapped.
  final Function(DateTime date)? onDayTap;

  /// Called when an event is tapped.
  final Function(TyxEvent event)? onEventTap;

  /// Called when the view is changed (e.g., from month to week).
  final Function(TyxView oldView, TyxView newView)? onViewChanged;

  /// Allows custom date formatting for the header.
  final String Function(DateTime date)? dateHeaderFormatter;

  /// Allows custom date formatting for day cells.
  final String Function(DateTime date)? dayFormatter;

  /// Determines how many events to show per day before showing a "+X more" indicator.
  final int maxEventsPerDay;

  /// Whether to show the "Today" button in the header.
  final bool showTodayButton;

  /// Whether to show the view selector in the header.
  final bool showViewSelector;

  /// Custom views to show in the view selector.
  final List<TyxView>? availableViews;

  const TyxCalendarCustomizer({
    this.headerStyle = const TyxHeaderStyle(),
    this.dayCellStyle = const TyxDayCellStyle(),
    this.eventStyle = const TyxEventStyle(),
    this.weekdayStyle = const TyxWeekdayStyle(),
    this.animateViewChanges = true,
    this.viewChangeAnimationDuration = const Duration(milliseconds: 300),
    this.dayBuilder,
    this.eventBuilder,
    this.monthHeaderBuilder,
    this.weekdayHeaderBuilder,
    this.onDayTap,
    this.onEventTap,
    this.onViewChanged,
    this.dateHeaderFormatter,
    this.dayFormatter,
    this.maxEventsPerDay = 3,
    this.showTodayButton = true,
    this.showViewSelector = true,
    this.availableViews,
  });

  /// Creates a copy of this customizer with specific properties replaced.
  TyxCalendarCustomizer copyWith({
    TyxHeaderStyle? headerStyle,
    TyxDayCellStyle? dayCellStyle,
    TyxEventStyle? eventStyle,
    TyxWeekdayStyle? weekdayStyle,
    bool? animateViewChanges,
    Duration? viewChangeAnimationDuration,
    Widget Function(BuildContext context, DateTime date, bool isToday,
            bool isCurrentMonth, List<TyxEvent> events)?
        dayBuilder,
    Widget Function(BuildContext context, TyxEvent event)? eventBuilder,
    Widget Function(BuildContext context, DateTime currentMonth,
            Function() nextMonth, Function() previousMonth)?
        monthHeaderBuilder,
    Widget Function(BuildContext context, List<String> weekdays)?
        weekdayHeaderBuilder,
    Function(DateTime date)? onDayTap,
    Function(TyxEvent event)? onEventTap,
    Function(TyxView oldView, TyxView newView)? onViewChanged,
    String Function(DateTime date)? dateHeaderFormatter,
    String Function(DateTime date)? dayFormatter,
    int? maxEventsPerDay,
    bool? showTodayButton,
    bool? showViewSelector,
    List<TyxView>? availableViews,
  }) {
    return TyxCalendarCustomizer(
      headerStyle: headerStyle ?? this.headerStyle,
      dayCellStyle: dayCellStyle ?? this.dayCellStyle,
      eventStyle: eventStyle ?? this.eventStyle,
      weekdayStyle: weekdayStyle ?? this.weekdayStyle,
      animateViewChanges: animateViewChanges ?? this.animateViewChanges,
      viewChangeAnimationDuration:
          viewChangeAnimationDuration ?? this.viewChangeAnimationDuration,
      dayBuilder: dayBuilder ?? this.dayBuilder,
      eventBuilder: eventBuilder ?? this.eventBuilder,
      monthHeaderBuilder: monthHeaderBuilder ?? this.monthHeaderBuilder,
      weekdayHeaderBuilder: weekdayHeaderBuilder ?? this.weekdayHeaderBuilder,
      onDayTap: onDayTap ?? this.onDayTap,
      onEventTap: onEventTap ?? this.onEventTap,
      onViewChanged: onViewChanged ?? this.onViewChanged,
      dateHeaderFormatter: dateHeaderFormatter ?? this.dateHeaderFormatter,
      dayFormatter: dayFormatter ?? this.dayFormatter,
      maxEventsPerDay: maxEventsPerDay ?? this.maxEventsPerDay,
      showTodayButton: showTodayButton ?? this.showTodayButton,
      showViewSelector: showViewSelector ?? this.showViewSelector,
      availableViews: availableViews ?? this.availableViews,
    );
  }
}

/// Style customization for the calendar header.
class TyxHeaderStyle {
  /// Background color of the header.
  final Color? backgroundColor;

  /// Text style for the header title.
  final TextStyle? titleStyle;

  /// Icon theme for header buttons.
  final IconThemeData? iconTheme;

  /// Decoration for the entire header container.
  final BoxDecoration? decoration;

  /// Padding for the header.
  final EdgeInsetsGeometry padding;

  /// Height of the header.
  final double? height;

  /// Style for the Today button.
  final ButtonStyle? todayButtonStyle;

  /// Text style for the Today button.
  final TextStyle? todayButtonTextStyle;

  /// Style for the view selector buttons.
  final ButtonStyle? viewSelectorStyle;

  const TyxHeaderStyle({
    this.backgroundColor,
    this.titleStyle,
    this.iconTheme,
    this.decoration,
    this.padding = const EdgeInsets.all(16),
    this.height,
    this.todayButtonStyle,
    this.todayButtonTextStyle,
    this.viewSelectorStyle,
  });

  /// Creates a copy of this style with specific properties replaced.
  TyxHeaderStyle copyWith({
    Color? backgroundColor,
    TextStyle? titleStyle,
    IconThemeData? iconTheme,
    BoxDecoration? decoration,
    EdgeInsetsGeometry? padding,
    double? height,
    ButtonStyle? todayButtonStyle,
    TextStyle? todayButtonTextStyle,
    ButtonStyle? viewSelectorStyle,
  }) {
    return TyxHeaderStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      titleStyle: titleStyle ?? this.titleStyle,
      iconTheme: iconTheme ?? this.iconTheme,
      decoration: decoration ?? this.decoration,
      padding: padding ?? this.padding,
      height: height ?? this.height,
      todayButtonStyle: todayButtonStyle ?? this.todayButtonStyle,
      todayButtonTextStyle: todayButtonTextStyle ?? this.todayButtonTextStyle,
      viewSelectorStyle: viewSelectorStyle ?? this.viewSelectorStyle,
    );
  }
}

/// Style customization for the day cells in the calendar.
class TyxDayCellStyle {
  /// Default cell background color.
  final Color? backgroundColor;

  /// Background color for the current day.
  final Color? todayBackgroundColor;

  /// Text style for day numbers.
  final TextStyle? textStyle;

  /// Text style for day numbers of the current day.
  final TextStyle? todayTextStyle;

  /// Text style for day numbers outside the current month.
  final TextStyle? outsideTextStyle;

  /// Border for day cells.
  final Border? border;

  /// Border for the current day cell.
  final Border? todayBorder;

  /// Border radius for day cells.
  final BorderRadius? borderRadius;

  /// Cell decoration.
  final BoxDecoration? decoration;

  /// Cell decoration for the current day.
  final BoxDecoration? todayDecoration;

  /// Cell decoration for selected days.
  final BoxDecoration? selectedDecoration;

  /// Text style for selected days.
  final TextStyle? selectedTextStyle;

  /// Color for the selected day indicator.
  final Color? selectionColor;

  /// Size of the day indicator.
  final double? dayIndicatorSize;

  /// Whether to show a circular indicator for the current day.
  final bool useCircularIndicator;

  /// Cell padding.
  final EdgeInsetsGeometry padding;

  /// Width of the cell border.
  final double borderWidth;

  /// Color of the cell border.
  final Color? borderColor;

  const TyxDayCellStyle({
    this.backgroundColor,
    this.todayBackgroundColor,
    this.textStyle,
    this.todayTextStyle,
    this.outsideTextStyle,
    this.border,
    this.todayBorder,
    this.borderRadius,
    this.decoration,
    this.todayDecoration,
    this.selectedDecoration,
    this.selectedTextStyle,
    this.selectionColor,
    this.dayIndicatorSize,
    this.useCircularIndicator = false,
    this.padding = const EdgeInsets.all(2),
    this.borderWidth = 0.5,
    this.borderColor,
  });

  /// Creates a copy of this style with specific properties replaced.
  TyxDayCellStyle copyWith({
    Color? backgroundColor,
    Color? todayBackgroundColor,
    TextStyle? textStyle,
    TextStyle? todayTextStyle,
    TextStyle? outsideTextStyle,
    Border? border,
    Border? todayBorder,
    BorderRadius? borderRadius,
    BoxDecoration? decoration,
    BoxDecoration? todayDecoration,
    BoxDecoration? selectedDecoration,
    TextStyle? selectedTextStyle,
    Color? selectionColor,
    double? dayIndicatorSize,
    bool? useCircularIndicator,
    EdgeInsetsGeometry? padding,
    double? borderWidth,
    Color? borderColor,
  }) {
    return TyxDayCellStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      todayBackgroundColor: todayBackgroundColor ?? this.todayBackgroundColor,
      textStyle: textStyle ?? this.textStyle,
      todayTextStyle: todayTextStyle ?? this.todayTextStyle,
      outsideTextStyle: outsideTextStyle ?? this.outsideTextStyle,
      border: border ?? this.border,
      todayBorder: todayBorder ?? this.todayBorder,
      borderRadius: borderRadius ?? this.borderRadius,
      decoration: decoration ?? this.decoration,
      todayDecoration: todayDecoration ?? this.todayDecoration,
      selectedDecoration: selectedDecoration ?? this.selectedDecoration,
      selectedTextStyle: selectedTextStyle ?? this.selectedTextStyle,
      selectionColor: selectionColor ?? this.selectionColor,
      dayIndicatorSize: dayIndicatorSize ?? this.dayIndicatorSize,
      useCircularIndicator: useCircularIndicator ?? this.useCircularIndicator,
      padding: padding ?? this.padding,
      borderWidth: borderWidth ?? this.borderWidth,
      borderColor: borderColor ?? this.borderColor,
    );
  }
}

/// Style customization for event indicators in the calendar.
class TyxEventStyle {
  /// Background color for event indicators.
  final Color? backgroundColor;

  /// Text style for event text.
  final TextStyle? textStyle;

  /// Margin around event indicators.
  final EdgeInsetsGeometry margin;

  /// Padding inside event indicators.
  final EdgeInsetsGeometry padding;

  /// Border radius for event indicators.
  final BorderRadius borderRadius;

  /// Whether to show a left border on events.
  final bool showLeftBorder;

  /// Width of the left border if [showLeftBorder] is true.
  final double leftBorderWidth;

  /// Whether to display the event time.
  final bool showEventTime;

  /// Whether to use the event's color as the background.
  final bool useEventColorAsBackground;

  /// Whether to use the event's color as the border.
  final bool useEventColorAsBorder;

  /// Opacity of the background when using event color.
  final double backgroundOpacity;

  /// Height of each event indicator.
  final double? height;

  /// Maximum number of lines for event text.
  final int maxLines;

  /// Text overflow behavior for event text.
  final TextOverflow textOverflow;

  const TyxEventStyle({
    this.backgroundColor,
    this.textStyle,
    this.margin = const EdgeInsets.only(bottom: 2),
    this.padding = const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
    this.showLeftBorder = true,
    this.leftBorderWidth = 5,
    this.showEventTime = true,
    this.useEventColorAsBackground = true,
    this.useEventColorAsBorder = true,
    this.backgroundOpacity = 0.3,
    this.height,
    this.maxLines = 1,
    this.textOverflow = TextOverflow.ellipsis,
  });

  /// Creates a copy of this style with specific properties replaced.
  TyxEventStyle copyWith({
    Color? backgroundColor,
    TextStyle? textStyle,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
    bool? showLeftBorder,
    double? leftBorderWidth,
    bool? showEventTime,
    bool? useEventColorAsBackground,
    bool? useEventColorAsBorder,
    double? backgroundOpacity,
    double? height,
    int? maxLines,
    TextOverflow? textOverflow,
  }) {
    return TyxEventStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textStyle: textStyle ?? this.textStyle,
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      borderRadius: borderRadius ?? this.borderRadius,
      showLeftBorder: showLeftBorder ?? this.showLeftBorder,
      leftBorderWidth: leftBorderWidth ?? this.leftBorderWidth,
      showEventTime: showEventTime ?? this.showEventTime,
      useEventColorAsBackground:
          useEventColorAsBackground ?? this.useEventColorAsBackground,
      useEventColorAsBorder:
          useEventColorAsBorder ?? this.useEventColorAsBorder,
      backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
      height: height ?? this.height,
      maxLines: maxLines ?? this.maxLines,
      textOverflow: textOverflow ?? this.textOverflow,
    );
  }
}

/// Style customization for weekday headers in the calendar.
class TyxWeekdayStyle {
  /// Background color for weekday headers.
  final Color? backgroundColor;

  /// Text style for weekday text.
  final TextStyle? textStyle;

  /// Padding for weekday headers.
  final EdgeInsetsGeometry padding;

  /// Height of the weekday header row.
  final double? height;

  /// Decoration for the weekday header row.
  final BoxDecoration? decoration;

  /// Whether to use abbreviated weekday names.
  final bool useAbbreviatedNames;

  /// Whether to show the weekday header row.
  final bool showWeekdayHeader;

  /// Border for the weekday header row.
  final Border? border;

  /// Alignment of weekday text.
  final TextAlign textAlign;

  /// Whether to use uppercase for weekday names.
  final bool uppercase;

  const TyxWeekdayStyle({
    this.backgroundColor,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
    this.height,
    this.decoration,
    this.useAbbreviatedNames = false,
    this.showWeekdayHeader = true,
    this.border,
    this.textAlign = TextAlign.center,
    this.uppercase = false,
  });

  /// Creates a copy of this style with specific properties replaced.
  TyxWeekdayStyle copyWith({
    Color? backgroundColor,
    TextStyle? textStyle,
    EdgeInsetsGeometry? padding,
    double? height,
    BoxDecoration? decoration,
    bool? useAbbreviatedNames,
    bool? showWeekdayHeader,
    Border? border,
    TextAlign? textAlign,
    bool? uppercase,
  }) {
    return TyxWeekdayStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textStyle: textStyle ?? this.textStyle,
      padding: padding ?? this.padding,
      height: height ?? this.height,
      decoration: decoration ?? this.decoration,
      useAbbreviatedNames: useAbbreviatedNames ?? this.useAbbreviatedNames,
      showWeekdayHeader: showWeekdayHeader ?? this.showWeekdayHeader,
      border: border ?? this.border,
      textAlign: textAlign ?? this.textAlign,
      uppercase: uppercase ?? this.uppercase,
    );
  }
}
