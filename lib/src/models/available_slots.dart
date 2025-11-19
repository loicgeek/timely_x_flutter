// lib/src/models/available_slots.dart

import 'package:flutter/material.dart';

/// Represents a specific available time slot
class AvailableSlot {
  AvailableSlot({
    required this.startTime,
    required this.endTime,
    this.id,
    this.capacity = 1,
    this.bookedCount = 0,
    this.price,
    this.metadata,
    this.status = SlotStatus.available,
  }) : assert(
         startTime.isBefore(endTime),
         'Start time must be before end time',
       );

  /// Unique identifier for this slot (optional)
  final String? id;

  /// Start time of the slot
  final DateTime startTime;

  /// End time of the slot
  final DateTime endTime;

  /// Maximum number of bookings this slot can accommodate
  final int capacity;

  /// Number of current bookings
  final int bookedCount;

  /// Optional price for this slot
  final double? price;

  /// Additional metadata
  final Map<String, dynamic>? metadata;

  /// Status of the slot
  final SlotStatus status;

  /// Duration of the slot
  Duration get duration => endTime.difference(startTime);

  /// Whether the slot is fully booked
  bool get isFullyBooked => bookedCount >= capacity;

  /// Whether the slot has any availability
  bool get hasAvailability =>
      bookedCount < capacity && status == SlotStatus.available;

  /// Remaining capacity
  int get remainingCapacity => capacity - bookedCount;

  /// Check if this slot contains a specific time
  bool contains(DateTime time) {
    return time.isAtSameMomentAs(startTime) ||
        (time.isAfter(startTime) && time.isBefore(endTime));
  }

  /// Check if this slot overlaps with another
  bool overlapsWith(AvailableSlot other) {
    return startTime.isBefore(other.endTime) &&
        other.startTime.isBefore(endTime);
  }

  /// Check if a time range fits within this slot
  bool canAccommodate(DateTime start, DateTime end) {
    return (start.isAtSameMomentAs(startTime) || start.isAfter(startTime)) &&
        (end.isAtSameMomentAs(endTime) || end.isBefore(endTime)) &&
        hasAvailability;
  }

  AvailableSlot copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    int? capacity,
    int? bookedCount,
    double? price,
    Map<String, dynamic>? metadata,
    SlotStatus? status,
  }) {
    return AvailableSlot(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      capacity: capacity ?? this.capacity,
      bookedCount: bookedCount ?? this.bookedCount,
      price: price ?? this.price,
      metadata: metadata ?? this.metadata,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AvailableSlot &&
        other.id == id &&
        other.startTime == startTime &&
        other.endTime == endTime;
  }

  @override
  int get hashCode => Object.hash(id, startTime, endTime);
}

/// Status of an available slot
enum SlotStatus {
  /// Slot is available for booking
  available,

  /// Slot is tentatively held (e.g., in cart)
  tentative,

  /// Slot is blocked/unavailable
  blocked,

  /// Slot is in the past
  past,
}

/// Visual style for rendering available slots
enum SlotHighlightStyle {
  /// No highlighting (default calendar appearance)
  none,

  /// Light background highlight
  subtle,

  /// Border around slot
  border,

  /// Stronger background highlight
  emphasized,

  /// Gradient effect
  gradient,

  /// Custom style (use builder)
  custom,
}

/// Configuration for slot highlighting
class SlotHighlightConfig {
  const SlotHighlightConfig({
    this.style = SlotHighlightStyle.subtle,
    this.availableColor = const Color(0xFFE8F5E9),
    this.tentativeColor = const Color(0xFFFFF9C4),
    this.blockedColor = const Color(0xFFFFEBEE),
    this.borderColor = const Color(0xFF4CAF50),
    this.borderWidth = 2.0,
    this.opacity = 0.3,
    this.showCapacity = true,
    this.showPrice = false,
  });

  final SlotHighlightStyle style;
  final Color availableColor;
  final Color tentativeColor;
  final Color blockedColor;
  final Color borderColor;
  final double borderWidth;
  final double opacity;
  final bool showCapacity;
  final bool showPrice;

  SlotHighlightConfig copyWith({
    SlotHighlightStyle? style,
    Color? availableColor,
    Color? tentativeColor,
    Color? blockedColor,
    Color? borderColor,
    double? borderWidth,
    double? opacity,
    bool? showCapacity,
    bool? showPrice,
  }) {
    return SlotHighlightConfig(
      style: style ?? this.style,
      availableColor: availableColor ?? this.availableColor,
      tentativeColor: tentativeColor ?? this.tentativeColor,
      blockedColor: blockedColor ?? this.blockedColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      opacity: opacity ?? this.opacity,
      showCapacity: showCapacity ?? this.showCapacity,
      showPrice: showPrice ?? this.showPrice,
    );
  }
}

/// Configuration for slot-based availability
class SlotAvailability {
  const SlotAvailability({
    required this.slots,
    this.highlightConfig = const SlotHighlightConfig(),
    this.showOnlyAvailableSlots = false,
    this.allowPartialSlotBooking = false,
    this.autoGenerateSlots = false,
  });

  /// List of available slots
  final List<AvailableSlot> slots;

  /// Configuration for highlighting slots
  final SlotHighlightConfig highlightConfig;

  /// If true, only show/allow interaction with defined slots
  final bool showOnlyAvailableSlots;

  /// If true, allow booking portions of a slot
  final bool allowPartialSlotBooking;

  /// If true, auto-generate slots based on other settings
  final bool autoGenerateSlots;

  /// Get all slots for a specific date
  List<AvailableSlot> getSlotsForDate(DateTime date) {
    return slots.where((slot) {
      final slotDate = DateTime(
        slot.startTime.year,
        slot.startTime.month,
        slot.startTime.day,
      );
      final checkDate = DateTime(date.year, date.month, date.day);
      return slotDate.isAtSameMomentAs(checkDate);
    }).toList();
  }

  /// Get all available (not booked) slots for a date
  List<AvailableSlot> getAvailableSlotsForDate(DateTime date) {
    return getSlotsForDate(date).where((slot) => slot.hasAvailability).toList();
  }

  /// Get all fully booked slots for a date
  List<AvailableSlot> getBookedSlotsForDate(DateTime date) {
    return getSlotsForDate(date).where((slot) => slot.isFullyBooked).toList();
  }

  /// Find slot containing a specific time
  AvailableSlot? findSlotAtTime(DateTime time) {
    return slots.firstWhere(
      (slot) => slot.contains(time),
      orElse: () => null as AvailableSlot,
    );
  }

  /// Find slots that can accommodate a time range
  List<AvailableSlot> findSlotsForTimeRange(DateTime start, DateTime end) {
    return slots.where((slot) => slot.canAccommodate(start, end)).toList();
  }

  /// Get next available slot after a given time
  AvailableSlot? getNextAvailableSlot(DateTime after) {
    final availableSlots =
        slots
            .where(
              (slot) => slot.startTime.isAfter(after) && slot.hasAvailability,
            )
            .toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime));

    return availableSlots.isEmpty ? null : availableSlots.first;
  }

  SlotAvailability copyWith({
    List<AvailableSlot>? slots,
    SlotHighlightConfig? highlightConfig,
    bool? showOnlyAvailableSlots,
    bool? allowPartialSlotBooking,
    bool? autoGenerateSlots,
  }) {
    return SlotAvailability(
      slots: slots ?? this.slots,
      highlightConfig: highlightConfig ?? this.highlightConfig,
      showOnlyAvailableSlots:
          showOnlyAvailableSlots ?? this.showOnlyAvailableSlots,
      allowPartialSlotBooking:
          allowPartialSlotBooking ?? this.allowPartialSlotBooking,
      autoGenerateSlots: autoGenerateSlots ?? this.autoGenerateSlots,
    );
  }
}

/// Builder for generating available slots
class SlotBuilder {
  /// Generate slots for a date range with fixed intervals
  static List<AvailableSlot> generateFixedSlots({
    required DateTime startDate,
    required DateTime endDate,
    required Duration slotDuration,
    required TimeOfDay dayStartTime,
    required TimeOfDay dayEndTime,
    List<int> daysOfWeek = const [1, 2, 3, 4, 5], // Mon-Fri by default
    Duration? breakDuration,
    TimeOfDay? breakStartTime,
    int capacity = 1,
    double? price,
  }) {
    final slots = <AvailableSlot>[];
    var currentDate = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    while (currentDate.isBefore(end) || currentDate.isAtSameMomentAs(end)) {
      if (daysOfWeek.contains(currentDate.weekday)) {
        final daySlots = _generateSlotsForDay(
          date: currentDate,
          dayStartTime: dayStartTime,
          dayEndTime: dayEndTime,
          slotDuration: slotDuration,
          breakDuration: breakDuration,
          breakStartTime: breakStartTime,
          capacity: capacity,
          price: price,
        );
        slots.addAll(daySlots);
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return slots;
  }

  static List<AvailableSlot> _generateSlotsForDay({
    required DateTime date,
    required TimeOfDay dayStartTime,
    required TimeOfDay dayEndTime,
    required Duration slotDuration,
    Duration? breakDuration,
    TimeOfDay? breakStartTime,
    int capacity = 1,
    double? price,
  }) {
    final slots = <AvailableSlot>[];

    var currentTime = DateTime(
      date.year,
      date.month,
      date.day,
      dayStartTime.hour,
      dayStartTime.minute,
    );

    final dayEnd = DateTime(
      date.year,
      date.month,
      date.day,
      dayEndTime.hour,
      dayEndTime.minute,
    );

    DateTime? breakStart;
    DateTime? breakEnd;
    if (breakDuration != null && breakStartTime != null) {
      breakStart = DateTime(
        date.year,
        date.month,
        date.day,
        breakStartTime.hour,
        breakStartTime.minute,
      );
      breakEnd = breakStart.add(breakDuration);
    }

    while (currentTime.add(slotDuration).isBefore(dayEnd) ||
        currentTime.add(slotDuration).isAtSameMomentAs(dayEnd)) {
      final slotEnd = currentTime.add(slotDuration);

      // Skip if slot overlaps with break
      if (breakStart != null && breakEnd != null) {
        if (currentTime.isBefore(breakEnd) && slotEnd.isAfter(breakStart)) {
          currentTime = slotEnd;
          continue;
        }
      }

      slots.add(
        AvailableSlot(
          id: '${date.toIso8601String()}_${currentTime.hour}_${currentTime.minute}',
          startTime: currentTime,
          endTime: slotEnd,
          capacity: capacity,
          price: price,
        ),
      );

      currentTime = slotEnd;
    }

    return slots;
  }

  /// Generate slots at specific times
  static List<AvailableSlot> generateSpecificSlots({
    required DateTime startDate,
    required DateTime endDate,
    required List<({TimeOfDay start, TimeOfDay end})> slotTimes,
    List<int> daysOfWeek = const [1, 2, 3, 4, 5],
    int capacity = 1,
    double? price,
  }) {
    final slots = <AvailableSlot>[];
    var currentDate = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    while (currentDate.isBefore(end) || currentDate.isAtSameMomentAs(end)) {
      if (daysOfWeek.contains(currentDate.weekday)) {
        for (final slotTime in slotTimes) {
          final startTime = DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
            slotTime.start.hour,
            slotTime.start.minute,
          );
          final endTime = DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
            slotTime.end.hour,
            slotTime.end.minute,
          );

          slots.add(
            AvailableSlot(
              id: '${currentDate.toIso8601String()}_${slotTime.start.hour}_${slotTime.start.minute}',
              startTime: startTime,
              endTime: endTime,
              capacity: capacity,
              price: price,
            ),
          );
        }
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return slots;
  }
}

/// Preset slot configurations
class SlotAvailabilityPresets {
  /// 30-minute slots, 9 AM - 5 PM, Mon-Fri
  static SlotAvailability standard({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return SlotAvailability(
      slots: SlotBuilder.generateFixedSlots(
        startDate: startDate,
        endDate: endDate,
        slotDuration: const Duration(minutes: 30),
        dayStartTime: const TimeOfDay(hour: 9, minute: 0),
        dayEndTime: const TimeOfDay(hour: 17, minute: 0),
        breakDuration: const Duration(hours: 1),
        breakStartTime: const TimeOfDay(hour: 12, minute: 0),
      ),
    );
  }

  /// 1-hour slots, 8 AM - 6 PM, Mon-Fri
  static SlotAvailability extended({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return SlotAvailability(
      slots: SlotBuilder.generateFixedSlots(
        startDate: startDate,
        endDate: endDate,
        slotDuration: const Duration(hours: 1),
        dayStartTime: const TimeOfDay(hour: 8, minute: 0),
        dayEndTime: const TimeOfDay(hour: 18, minute: 0),
      ),
    );
  }

  /// 15-minute slots for quick appointments
  static SlotAvailability quickSlots({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return SlotAvailability(
      slots: SlotBuilder.generateFixedSlots(
        startDate: startDate,
        endDate: endDate,
        slotDuration: const Duration(minutes: 15),
        dayStartTime: const TimeOfDay(hour: 9, minute: 0),
        dayEndTime: const TimeOfDay(hour: 17, minute: 0),
      ),
    );
  }
}

/// Preset highlight configurations
class SlotHighlightPresets {
  static const subtle = SlotHighlightConfig(
    style: SlotHighlightStyle.subtle,
    availableColor: Color(0xFFE8F5E9),
    opacity: 0.2,
  );

  static const border = SlotHighlightConfig(
    style: SlotHighlightStyle.border,
    borderColor: Color(0xFF4CAF50),
    borderWidth: 2.0,
  );

  static const emphasized = SlotHighlightConfig(
    style: SlotHighlightStyle.emphasized,
    availableColor: Color(0xFFC8E6C9),
    opacity: 0.5,
  );

  static const withPrice = SlotHighlightConfig(
    style: SlotHighlightStyle.subtle,
    showPrice: true,
    showCapacity: true,
  );
}
