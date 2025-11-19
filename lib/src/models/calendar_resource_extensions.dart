// lib/src/models/calendar_resource_extensions.dart

import 'dart:ui';

import './calendar_resource.dart';
import './business_hours.dart';
import './available_slots.dart';

/// Extension to add business hours capability to resources
/// Resources can optionally implement this to provide business hours
abstract class CalendarResourceWithBusinessHours extends CalendarResource {
  /// Business hours configuration for this resource
  BusinessHours? get businessHours => null;

  /// Whether this resource respects business hours
  bool get respectsBusinessHours => businessHours != null;
}

/// Extension to add slot-based availability to resources
/// Resources can implement this to provide explicit available time slots
abstract class CalendarResourceWithSlots extends CalendarResource {
  /// Slot availability configuration for this resource
  SlotAvailability? get slotAvailability => null;

  /// Whether this resource uses slot-based availability
  bool get usesSlotAvailability => slotAvailability != null;
}

/// Combined interface for resources supporting both availability modes
abstract class CalendarResourceWithAvailability extends CalendarResource
    implements CalendarResourceWithBusinessHours, CalendarResourceWithSlots {
  @override
  BusinessHours? get businessHours => null;

  @override
  SlotAvailability? get slotAvailability => null;

  /// Availability mode for this resource
  AvailabilityMode get availabilityMode {
    if (slotAvailability != null) return AvailabilityMode.slots;
    if (businessHours != null) return AvailabilityMode.businessHours;
    return AvailabilityMode.unrestricted;
  }
}

/// Availability mode enumeration
enum AvailabilityMode {
  /// No restrictions - always available
  unrestricted,

  /// Business hours based (unavailability-based)
  businessHours,

  /// Slot-based (availability-based)
  slots,
}

/// Default implementation with business hours support
class DefaultResourceWithBusinessHours extends DefaultResource
    implements CalendarResourceWithBusinessHours {
  DefaultResourceWithBusinessHours({
    required super.id,
    required super.name,
    super.avatarUrl,
    super.color,
    super.isActive,
    super.category,
    super.customData,
    this.businessHours,
  });

  @override
  final BusinessHours? businessHours;

  @override
  bool get respectsBusinessHours => businessHours != null;

  @override
  DefaultResourceWithBusinessHours copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    Color? color,
    bool? isActive,
    String? category,
    Map<String, dynamic>? customData,
    BusinessHours? businessHours,
  }) {
    return DefaultResourceWithBusinessHours(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      category: category ?? this.category,
      customData: customData ?? this.customData,
      businessHours: businessHours ?? this.businessHours,
    );
  }
}

/// Default implementation with slot-based availability
class DefaultResourceWithSlots extends DefaultResource
    implements CalendarResourceWithSlots {
  DefaultResourceWithSlots({
    required super.id,
    required super.name,
    super.avatarUrl,
    super.color,
    super.isActive,
    super.category,
    super.customData,
    this.slotAvailability,
  });

  @override
  final SlotAvailability? slotAvailability;

  @override
  bool get usesSlotAvailability => slotAvailability != null;

  @override
  DefaultResourceWithSlots copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    Color? color,
    bool? isActive,
    String? category,
    Map<String, dynamic>? customData,
    SlotAvailability? slotAvailability,
  }) {
    return DefaultResourceWithSlots(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      category: category ?? this.category,
      customData: customData ?? this.customData,
      slotAvailability: slotAvailability ?? this.slotAvailability,
    );
  }
}

/// Default implementation supporting both availability modes
class DefaultResourceWithAvailability extends DefaultResource
    implements CalendarResourceWithAvailability {
  DefaultResourceWithAvailability({
    required super.id,
    required super.name,
    super.avatarUrl,
    super.color,
    super.isActive,
    super.category,
    super.customData,
    this.businessHours,
    this.slotAvailability,
  });

  @override
  final BusinessHours? businessHours;

  @override
  final SlotAvailability? slotAvailability;

  @override
  bool get respectsBusinessHours => businessHours != null;

  @override
  bool get usesSlotAvailability => slotAvailability != null;

  @override
  AvailabilityMode get availabilityMode {
    if (slotAvailability != null) return AvailabilityMode.slots;
    if (businessHours != null) return AvailabilityMode.businessHours;
    return AvailabilityMode.unrestricted;
  }

  @override
  DefaultResourceWithAvailability copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    Color? color,
    bool? isActive,
    String? category,
    Map<String, dynamic>? customData,
    BusinessHours? businessHours,
    SlotAvailability? slotAvailability,
  }) {
    return DefaultResourceWithAvailability(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      category: category ?? this.category,
      customData: customData ?? this.customData,
      businessHours: businessHours ?? this.businessHours,
      slotAvailability: slotAvailability ?? this.slotAvailability,
    );
  }
}

/// Helper to get business hours from any resource
extension CalendarResourceBusinessHoursHelper on CalendarResource {
  /// Try to get business hours if resource implements the interface
  BusinessHours? tryGetBusinessHours() {
    if (this is CalendarResourceWithBusinessHours) {
      return (this as CalendarResourceWithBusinessHours).businessHours;
    }
    if (this is CalendarResourceWithAvailability) {
      return (this as CalendarResourceWithAvailability).businessHours;
    }
    return null;
  }

  /// Check if resource has business hours defined
  bool hasBusinessHours() {
    return tryGetBusinessHours() != null;
  }
}

/// Helper to get slot availability from any resource
extension CalendarResourceSlotAvailabilityHelper on CalendarResource {
  /// Try to get slot availability if resource implements the interface
  SlotAvailability? tryGetSlotAvailability() {
    if (this is CalendarResourceWithSlots) {
      return (this as CalendarResourceWithSlots).slotAvailability;
    }
    if (this is CalendarResourceWithAvailability) {
      return (this as CalendarResourceWithAvailability).slotAvailability;
    }
    return null;
  }

  /// Check if resource has slot availability defined
  bool hasSlotAvailability() {
    return tryGetSlotAvailability() != null;
  }

  /// Get the availability mode for this resource
  AvailabilityMode getAvailabilityMode() {
    if (hasSlotAvailability()) return AvailabilityMode.slots;
    if (hasBusinessHours()) return AvailabilityMode.businessHours;
    return AvailabilityMode.unrestricted;
  }
}
