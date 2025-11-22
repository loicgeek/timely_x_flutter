// lib/src/utils/slot_availability_calculator.dart

import '../models/available_slots.dart';

/// Utilities for working with slot-based availability
class SlotAvailabilityCalculator {
  /// Check if a time range fits within an available slot
  static bool isTimeRangeAvailable({
    required SlotAvailability? slotAvailability,
    required DateTime startTime,
    required DateTime endTime,
  }) {
    if (slotAvailability == null) return true;

    final slots = slotAvailability.findSlotsForTimeRange(startTime, endTime);
    return slots.isNotEmpty;
  }

  /// Find the best slot for a given time preference
  static AvailableSlot? findBestSlot({
    required SlotAvailability slotAvailability,
    required DateTime preferredTime,
    required Duration duration,
    int maxMinutesDeviation = 60,
  }) {
    final preferredEnd = preferredTime.add(duration);

    // First, try exact match
    final exactSlots = slotAvailability.findSlotsForTimeRange(
      preferredTime,
      preferredEnd,
    );

    if (exactSlots.isNotEmpty) {
      return exactSlots.first;
    }

    // If no exact match, find closest available slot
    final searchStart = preferredTime.subtract(
      Duration(minutes: maxMinutesDeviation),
    );
    final searchEnd = preferredTime.add(Duration(minutes: maxMinutesDeviation));

    final candidateSlots = slotAvailability.slots.where((slot) {
      return slot.startTime.isAfter(searchStart) &&
          slot.startTime.isBefore(searchEnd) &&
          slot.hasAvailability &&
          slot.duration >= duration;
    }).toList();

    if (candidateSlots.isEmpty) return null;

    // Sort by proximity to preferred time
    candidateSlots.sort((a, b) {
      final aDiff = a.startTime.difference(preferredTime).abs();
      final bDiff = b.startTime.difference(preferredTime).abs();
      return aDiff.compareTo(bDiff);
    });

    return candidateSlots.first;
  }

  /// Get all available slots for a date range
  /// Get all available slots for a date range
  ///
  /// FIXED: End date comparison now uses extended end date to include
  /// all slots that occur on the end date
  static List<AvailableSlot> getAvailableSlotsInRange({
    required SlotAvailability slotAvailability,
    required DateTime startDate,
    required DateTime endDate,
    Duration? minDuration,
  }) {
    // CRITICAL FIX: Extend end date to end of day
    // This ensures slots later in the day are included in the range
    final extendedEndDate = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      23,
      59,
      59,
      999,
    );

    final slots = slotAvailability.slots.where((slot) {
      final isInRange =
          (slot.startTime.isAtSameMomentAs(startDate) ||
              slot.startTime.isAfter(startDate)) &&
          (slot.endTime.isAtSameMomentAs(extendedEndDate) ||
              slot.endTime.isBefore(extendedEndDate));

      final meetsMinDuration =
          minDuration == null ||
          slot.duration.inMinutes >= minDuration.inMinutes;

      return isInRange && slot.hasAvailability && meetsMinDuration;
    }).toList();

    slots.sort((a, b) => a.startTime.compareTo(b.startTime));
    return slots;
  }

  /// Snap appointment time to nearest available slot
  static DateTime? snapToAvailableSlot({
    required SlotAvailability slotAvailability,
    required DateTime proposedTime,
    required Duration duration,
  }) {
    // Find slot at or after proposed time
    final slot = slotAvailability.slots.firstWhere(
      (s) =>
          (s.startTime.isAtSameMomentAs(proposedTime) ||
              s.startTime.isAfter(proposedTime)) &&
          s.hasAvailability &&
          s.duration >= duration,
      orElse: () => null as AvailableSlot,
    );

    return slot?.startTime;
  }

  /// Get slot utilization statistics for a date
  static SlotUtilizationStats getUtilizationStats({
    required SlotAvailability slotAvailability,
    required DateTime date,
  }) {
    final dateSlots = slotAvailability.getSlotsForDate(date);

    if (dateSlots.isEmpty) {
      return SlotUtilizationStats(
        totalSlots: 0,
        availableSlots: 0,
        bookedSlots: 0,
        utilizationRate: 0.0,
      );
    }

    final availableSlots = dateSlots.where((s) => s.hasAvailability).length;
    final bookedSlots = dateSlots.where((s) => s.isFullyBooked).length;
    final utilizationRate = bookedSlots / dateSlots.length;

    return SlotUtilizationStats(
      totalSlots: dateSlots.length,
      availableSlots: availableSlots,
      bookedSlots: bookedSlots,
      utilizationRate: utilizationRate,
    );
  }

  /// Book a slot (returns updated slot with incremented booking count)
  static AvailableSlot bookSlot(AvailableSlot slot) {
    if (slot.isFullyBooked) {
      throw Exception('Slot is already fully booked');
    }

    return slot.copyWith(bookedCount: slot.bookedCount + 1);
  }

  /// Cancel a booking (returns updated slot with decremented booking count)
  static AvailableSlot cancelBooking(AvailableSlot slot) {
    if (slot.bookedCount == 0) {
      throw Exception('No bookings to cancel');
    }

    return slot.copyWith(bookedCount: slot.bookedCount - 1);
  }

  /// Merge overlapping slots
  static List<AvailableSlot> mergeOverlappingSlots(List<AvailableSlot> slots) {
    if (slots.isEmpty) return [];

    final sorted = List<AvailableSlot>.from(slots)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final merged = <AvailableSlot>[];
    var current = sorted.first;

    for (int i = 1; i < sorted.length; i++) {
      final next = sorted[i];

      if (current.endTime.isAfter(next.startTime) ||
          current.endTime.isAtSameMomentAs(next.startTime)) {
        // Merge slots
        current = AvailableSlot(
          startTime: current.startTime,
          endTime: next.endTime.isAfter(current.endTime)
              ? next.endTime
              : current.endTime,
          capacity: current.capacity + next.capacity,
          bookedCount: current.bookedCount + next.bookedCount,
        );
      } else {
        merged.add(current);
        current = next;
      }
    }

    merged.add(current);
    return merged;
  }

  /// Split a slot into smaller slots
  static List<AvailableSlot> splitSlot({
    required AvailableSlot slot,
    required Duration newSlotDuration,
  }) {
    final subSlots = <AvailableSlot>[];
    var currentStart = slot.startTime;

    while (currentStart.add(newSlotDuration).isBefore(slot.endTime) ||
        currentStart.add(newSlotDuration).isAtSameMomentAs(slot.endTime)) {
      subSlots.add(
        AvailableSlot(
          id: '${slot.id}_${currentStart.hour}_${currentStart.minute}',
          startTime: currentStart,
          endTime: currentStart.add(newSlotDuration),
          capacity: slot.capacity,
          price: slot.price,
          metadata: slot.metadata,
        ),
      );

      currentStart = currentStart.add(newSlotDuration);
    }

    return subSlots;
  }

  /// Get gaps between slots (unavailable periods)
  static List<({DateTime start, DateTime end})> getSlotGaps({
    required List<AvailableSlot> slots,
    required DateTime dayStart,
    required DateTime dayEnd,
  }) {
    if (slots.isEmpty) {
      return [(start: dayStart, end: dayEnd)];
    }

    final sorted = List<AvailableSlot>.from(slots)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final gaps = <({DateTime start, DateTime end})>[];

    // Gap before first slot
    if (sorted.first.startTime.isAfter(dayStart)) {
      gaps.add((start: dayStart, end: sorted.first.startTime));
    }

    // Gaps between slots
    for (int i = 0; i < sorted.length - 1; i++) {
      final currentEnd = sorted[i].endTime;
      final nextStart = sorted[i + 1].startTime;

      if (nextStart.isAfter(currentEnd)) {
        gaps.add((start: currentEnd, end: nextStart));
      }
    }

    // Gap after last slot
    if (sorted.last.endTime.isBefore(dayEnd)) {
      gaps.add((start: sorted.last.endTime, end: dayEnd));
    }

    return gaps;
  }

  /// Find consecutive available slots
  static List<List<AvailableSlot>> findConsecutiveSlots({
    required SlotAvailability slotAvailability,
    required DateTime date,
    int minConsecutiveSlots = 2,
  }) {
    final dateSlots = slotAvailability.getAvailableSlotsForDate(date)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final consecutiveGroups = <List<AvailableSlot>>[];
    var currentGroup = <AvailableSlot>[];

    for (int i = 0; i < dateSlots.length; i++) {
      if (currentGroup.isEmpty) {
        currentGroup.add(dateSlots[i]);
      } else {
        final lastSlot = currentGroup.last;
        final currentSlot = dateSlots[i];

        // Check if consecutive
        if (lastSlot.endTime.isAtSameMomentAs(currentSlot.startTime)) {
          currentGroup.add(currentSlot);
        } else {
          if (currentGroup.length >= minConsecutiveSlots) {
            consecutiveGroups.add(List.from(currentGroup));
          }
          currentGroup = [currentSlot];
        }
      }
    }

    // Add last group if it meets minimum
    if (currentGroup.length >= minConsecutiveSlots) {
      consecutiveGroups.add(currentGroup);
    }

    return consecutiveGroups;
  }

  /// Calculate revenue potential for a date
  static double calculateRevenuePotential({
    required SlotAvailability slotAvailability,
    required DateTime date,
  }) {
    final dateSlots = slotAvailability.getSlotsForDate(date);

    return dateSlots.fold(0.0, (sum, slot) {
      if (slot.price != null) {
        return sum + (slot.price! * slot.capacity);
      }
      return sum;
    });
  }
}

/// Statistics about slot utilization
class SlotUtilizationStats {
  const SlotUtilizationStats({
    required this.totalSlots,
    required this.availableSlots,
    required this.bookedSlots,
    required this.utilizationRate,
  });

  final int totalSlots;
  final int availableSlots;
  final int bookedSlots;
  final double utilizationRate;

  String get utilizationPercentage =>
      '${(utilizationRate * 100).toStringAsFixed(1)}%';
}
