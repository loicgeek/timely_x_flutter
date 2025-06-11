import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timely_x/timely_x.dart';

class TyxDatepicker extends StatefulWidget {
  final TyxCalendarOption option;
  final Function(DateTime)? onDateSelected;

  final TyxView view;
  final DateTime? initialDate;
  const TyxDatepicker({
    super.key,
    required this.option,
    this.onDateSelected,
    required this.view,
    this.initialDate,
  });

  @override
  State<TyxDatepicker> createState() => _TyxDatepickerState();
}

class _TyxDatepickerState extends State<TyxDatepicker> {
  late DateTime _selectedDate;

  // Track scroll position to keep events and time grid in sync

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  Widget _buildMiniCalendar() {
    final currentMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final daysInMonth =
        DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    final firstDayOfMonth = currentMonth.weekday;

    // Get the start day of week from options, default to Monday if not specified
    final startWeekDay =
        widget.option.startWeekDay ?? 1; // 1 = Monday, 7 = Sunday

    // Convert from DateTime's weekday (1-7) to index (0-6)
    int startIndex = startWeekDay == 7 ? 0 : startWeekDay;

    // Calculate the offset to start displaying dates
    int offset = (firstDayOfMonth - startWeekDay) % 7;
    if (offset < 0) offset += 7;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month and year header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(_selectedDate),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      setState(() {
                        _selectedDate = DateTime(
                          _selectedDate.year,
                          _selectedDate.month - 1,
                          _selectedDate.day,
                        );
                        widget.onDateSelected?.call(_selectedDate);
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      setState(() {
                        _selectedDate = DateTime(
                          _selectedDate.year,
                          _selectedDate.month + 1,
                          _selectedDate.day,
                        );
                        widget.onDateSelected?.call(_selectedDate);
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Weekday headers
          Row(
            children: List.generate(7, (index) {
              final weekdayIndex = (startIndex + index) % 7;
              final weekdayName =
                  DateFormat().dateSymbols.SHORTWEEKDAYS[weekdayIndex];
              return Expanded(
                child: Text(
                  weekdayName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }),
          ),
          const SizedBox(height: 8),

          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: 42, // 6 rows of 7 days
            itemBuilder: (context, index) {
              // Calculate the day
              final adjustedIndex = index - offset;
              final day = adjustedIndex + 1;

              // Determine if this day is in the current month
              final isInCurrentMonth =
                  adjustedIndex >= 0 && adjustedIndex < daysInMonth;

              // Skip rendering days outside current month if not showing trailing days
              if (!widget.option.showTrailingDays && !isInCurrentMonth) {
                return const SizedBox.shrink();
              }

              // Create the date object for this grid cell
              final date = isInCurrentMonth
                  ? DateTime(_selectedDate.year, _selectedDate.month, day)
                  : (adjustedIndex < 0
                      ? DateTime(
                          _selectedDate.year,
                          _selectedDate.month - 1,
                          DateTime(_selectedDate.year, _selectedDate.month, 0)
                                  .day +
                              adjustedIndex +
                              1)
                      : DateTime(_selectedDate.year, _selectedDate.month + 1,
                          adjustedIndex - daysInMonth + 1));

              // Check if this is today or the selected date
              final isToday = isTodayMethod(date);
              final isSelected = isSameDay(date, _selectedDate);

              // Check if there are events on this day

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                    widget.onDateSelected?.call(date);
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.secondaryContainer
                        : isToday
                            ? colorScheme.primaryContainer.withOpacity(0.3)
                            : null,
                    borderRadius: BorderRadius.circular(4),
                    border: isToday
                        ? Border.all(color: colorScheme.primary, width: 1)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day.toString(),
                        style: TextStyle(
                          fontWeight: isSelected || isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: !isInCurrentMonth ? theme.disabledColor : null,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildMiniCalendar();
  }
}
