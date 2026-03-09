// lib/src/reschedule/reschedule_handler.dart
//
// Drop-in reschedule confirmation system for TimelyX.
//
// USAGE — wire it up in your widget:
//
//   CalendarView(
//     controller: _controller,
//     config: CalendarConfig(enableDragAndDrop: true, enableSnapping: true),
//     onAppointmentDragEnd: RescheduleHandler.wrap(
//       controller: _controller,
//       onConfirmationRequired: (data) async {
//         // You decide how to show the UI:
//         return await showRescheduleDialog(context, data);
//         // Return true  → proceed to onConfirmed
//         // Return false → revert (no-op)
//       },
//       // copyWith is not on the abstract base — you own the update:
//       onConfirmed: (data) {
//         final updated = (data.appointment as MyAppointment).copyWith(
//           resourceId: data.newResource.id,
//           startTime:  data.newStartTime,
//           endTime:    data.newEndTime,
//         );
//         _controller.updateAppointment(updated);
//       },
//     ),
//   )

import 'package:flutter/material.dart';
import '../models/interaction_data.dart';
import '../models/calendar_appointment.dart';
import '../models/calendar_resource.dart';
import '../controllers/calendar_controller.dart';
import '../builders/builder_delegates.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 1.  Data model handed to your confirmation callback
// ─────────────────────────────────────────────────────────────────────────────

/// All information your UI needs to render a reschedule confirmation.
class RescheduleConfirmationData {
  const RescheduleConfirmationData({
    required this.appointment,
    required this.oldResource,
    required this.newResource,
    required this.oldStartTime,
    required this.oldEndTime,
    required this.newStartTime,
    required this.newEndTime,
    this.conflictingAppointments = const [],
  });

  /// The appointment being rescheduled.
  final CalendarAppointment appointment;

  /// Resource before the drag.
  final CalendarResource oldResource;

  /// Resource after the drag (may be the same).
  final CalendarResource newResource;

  // ── Old slot ───────────────────────────────────────────────────────────────
  final DateTime oldStartTime;
  final DateTime oldEndTime;

  // ── New slot ───────────────────────────────────────────────────────────────
  final DateTime newStartTime;
  final DateTime newEndTime;

  /// Appointments that overlap the proposed new slot (empty when slot is free).
  /// Non-empty means you are about to create a double-booking.
  final List<CalendarAppointment> conflictingAppointments;

  // ── Derived helpers ────────────────────────────────────────────────────────

  /// `true` when the appointment moves to a different resource.
  bool get resourceChanged => oldResource.id != newResource.id;

  /// Net time shift of the appointment's start (positive = moved later).
  Duration get timeDifference => newStartTime.difference(oldStartTime);

  /// `true` when the new slot overlaps at least one other appointment.
  bool get hasConflict => conflictingAppointments.isNotEmpty;

  /// Duration of the appointment (preserved across the drag).
  Duration get duration => oldEndTime.difference(oldStartTime);
}

// ─────────────────────────────────────────────────────────────────────────────
// 2.  Callback typedef
// ─────────────────────────────────────────────────────────────────────────────

/// Called after the user confirms a reschedule.
///
/// You own the appointment model — this is where you call `copyWith` (or
/// equivalent) on your concrete type and persist the change:
///
/// ```dart
/// onConfirmed: (data) {
///   final updated = (data.appointment as MyAppointment).copyWith(
///     resourceId: data.newResource.id,
///     startTime:  data.newStartTime,
///     endTime:    data.newEndTime,
///   );
///   controller.updateAppointment(updated);
/// }
/// ```
typedef OnRescheduleConfirmed = void Function(RescheduleConfirmationData data);

/// Return `true` to commit the reschedule, `false` to revert it.
///
/// The callback is `async` so you can await a dialog, a bottom-sheet,
/// a network call, or any other async decision flow before replying.
typedef OnRescheduleConfirmation =
    Future<bool> Function(RescheduleConfirmationData data);

// ─────────────────────────────────────────────────────────────────────────────
// 3.  Handler
// ─────────────────────────────────────────────────────────────────────────────

/// Intercepts drag-end events, validates the proposed slot, and gates the
/// calendar update behind your custom confirmation callback.
class RescheduleHandler {
  const RescheduleHandler._();

  // ── Configuration ──────────────────────────────────────────────────────────

  /// Minimum number of minutes an appointment must move before confirmation
  /// is required.  Moves smaller than this are silently reverted (accidental
  /// micro-drags).  Set to `0` to require confirmation for every drop.
  static const int _minMoveMinutes = 5;

  // ── Public factory ─────────────────────────────────────────────────────────

  /// Returns an [OnAppointmentDragEnd] you pass directly to [CalendarView].
  ///
  /// Parameters
  /// ----------
  /// [controller]
  ///   The same [CalendarController] powering your [CalendarView].  Used for
  ///   availability checking only — the library never mutates your appointment
  ///   directly because `copyWith` is not part of the [CalendarAppointment]
  ///   abstract contract (only [DefaultAppointment] has it).
  ///
  /// [onConfirmationRequired]
  ///   Your async callback.  Receives a [RescheduleConfirmationData] describing
  ///   the proposed move.  Return `true` to proceed, `false` to revert.
  ///
  /// [onConfirmed]
  ///   Called only after the user confirms.  **This is where you update the
  ///   appointment** using your concrete model's `copyWith` (or any other
  ///   mutation strategy) and call `controller.updateAppointment(...)`.
  ///   The library cannot do this for you because [CalendarAppointment] is an
  ///   abstract class with no `copyWith` method.
  ///
  ///   ```dart
  ///   onConfirmed: (data) {
  ///     final updated = (data.appointment as MyAppointment).copyWith(
  ///       resourceId: data.newResource.id,
  ///       startTime:  data.newStartTime,
  ///       endTime:    data.newEndTime,
  ///     );
  ///     controller.updateAppointment(updated);
  ///   }
  ///   ```
  ///
  /// [allowDoubleBooking]
  ///   When `false` (default) a drop onto a conflicting slot is automatically
  ///   rejected and [onConflictBlocked] is called instead of showing
  ///   confirmation.  Set to `true` to let the user decide even when there is a
  ///   conflict — [RescheduleConfirmationData.hasConflict] will be `true` so
  ///   your UI can warn the user.
  ///
  /// [onConflictBlocked]
  ///   Optional.  Called when [allowDoubleBooking] is `false` and the proposed
  ///   slot has a conflict.  Use it to show a snackbar / toast.
  ///
  /// [onReverted]
  ///   Optional.  Called whenever a drop is silently discarded (accidental
  ///   micro-drag or same-slot drop).
  static OnAppointmentDragEnd wrap({
    required CalendarController controller,
    required OnRescheduleConfirmation onConfirmationRequired,
    required OnRescheduleConfirmed onConfirmed,
    bool allowDoubleBooking = false,
    void Function(RescheduleConfirmationData data)? onConflictBlocked,
    void Function(AppointmentDragData data)? onReverted,
  }) {
    return (AppointmentDragData dragData) async {
      // ── 1. Guard: ignore trivial / same-slot drops ──────────────────────
      final moveDuration = dragData.newStartTime
          .difference(dragData.oldStartTime)
          .abs();
      final resourceUnchanged =
          dragData.oldResource.id == dragData.newResource.id;

      if (moveDuration.inMinutes < _minMoveMinutes && resourceUnchanged) {
        onReverted?.call(dragData);
        return; // nothing to confirm
      }

      // ── 2. Find conflicting appointments ────────────────────────────────
      final conflicts = _findConflicts(
        controller: controller,
        dragData: dragData,
      );

      // ── 3. Build confirmation data ───────────────────────────────────────
      final confirmationData = RescheduleConfirmationData(
        appointment: dragData.appointment,
        oldResource: dragData.oldResource,
        newResource: dragData.newResource,
        oldStartTime: dragData.oldStartTime,
        oldEndTime: dragData.oldEndTime,
        newStartTime: dragData.newStartTime,
        newEndTime: dragData.newEndTime,
        conflictingAppointments: conflicts,
      );

      // ── 4. Block double-bookings (unless caller opts in) ─────────────────
      if (conflicts.isNotEmpty && !allowDoubleBooking) {
        onConflictBlocked?.call(confirmationData);
        return;
      }

      // ── 5. Ask the caller ────────────────────────────────────────────────
      final confirmed = await onConfirmationRequired(confirmationData);

      if (!confirmed) return; // user cancelled — appointment stays put

      // ── 6. Delegate update to caller (they own the concrete model) ───────
      onConfirmed(confirmationData);
    };
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static List<CalendarAppointment> _findConflicts({
    required CalendarController controller,
    required AppointmentDragData dragData,
  }) {
    final resourceAppointments = controller.appointments.where(
      (a) =>
          a.resourceId == dragData.newResource.id &&
          a.id != dragData.appointment.id,
    );

    return resourceAppointments.where((a) {
      return dragData.newStartTime.isBefore(a.endTime) &&
          dragData.newEndTime.isAfter(a.startTime);
    }).toList();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4.  Optional built-in confirmation dialog
//     (use this or supply your own — both work the same way)
// ─────────────────────────────────────────────────────────────────────────────

/// A ready-to-use async helper that shows a Material confirmation dialog.
///
/// Pass it directly as [onConfirmationRequired], or call it from your own
/// callback after doing additional checks:
///
/// ```dart
/// onConfirmationRequired: (data) async {
///   if (data.hasConflict) return false; // extra guard
///   return showDefaultRescheduleDialog(context, data);
/// },
/// ```
Future<bool> showDefaultRescheduleDialog(
  BuildContext context,
  RescheduleConfirmationData data, {
  bool allowSendNotification = false,
}) async {
  bool sendNotification = false;

  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false, // explicit confirm/cancel required
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Row(
              children: [
                const Icon(Icons.schedule, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: const Text(
                    'Update Appointment',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Appointment title ──────────────────────────────────────
                Text(
                  data.appointment.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 16),

                // ── From ──────────────────────────────────────────────────
                _SlotRow(
                  label: 'From',
                  resource: data.oldResource,
                  start: data.oldStartTime,
                  end: data.oldEndTime,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(height: 4),

                // ── Arrow ─────────────────────────────────────────────────
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Icon(Icons.arrow_downward, size: 18),
                ),
                const SizedBox(height: 4),

                // ── To ────────────────────────────────────────────────────
                _SlotRow(
                  label: 'To',
                  resource: data.newResource,
                  start: data.newStartTime,
                  end: data.newEndTime,
                  color: Colors.blue.shade700,
                ),

                // ── Conflict warning ──────────────────────────────────────
                if (data.hasConflict) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 18,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Overlaps with '
                            '${data.conflictingAppointments.length} '
                            'existing appointment'
                            '${data.conflictingAppointments.length == 1 ? '' : 's'}.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ── Send notification toggle ──────────────────────────────
                if (allowSendNotification) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: sendNotification,
                        onChanged: (v) =>
                            setState(() => sendNotification = v ?? false),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Send reschedule notification to client',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      );
    },
  );

  // If caller wants to know about the notification choice, they can inspect
  // via a separate mechanism; for the dialog return value we only propagate
  // the confirmed bool.  See the extended example below for the notification
  // pattern with a separate notifier.
  return confirmed ?? false;
}

// ── Private helper widget ──────────────────────────────────────────────────

class _SlotRow extends StatelessWidget {
  const _SlotRow({
    required this.label,
    required this.resource,
    required this.start,
    required this.end,
    required this.color,
  });

  final String label;
  final CalendarResource resource;
  final DateTime start;
  final DateTime end;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 36,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatSlot(start, end),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
              Text(
                resource.name,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatSlot(DateTime s, DateTime e) {
    String pad(int n) => n.toString().padLeft(2, '0');
    final day = '${s.year}-${pad(s.month)}-${pad(s.day)}';
    final from = '${pad(s.hour)}:${pad(s.minute)}';
    final to = '${pad(e.hour)}:${pad(e.minute)}';
    return '$day  $from – $to';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5.  Extended example — notification + custom dialog
// ─────────────────────────────────────────────────────────────────────────────
//
// class _MyCalendarState extends State<MyCalendarPage> {
//   late final CalendarController _controller;
//
//   @override
//   Widget build(BuildContext context) {
//     return CalendarView(
//       controller: _controller,
//       config: CalendarConfig(
//         enableDragAndDrop: true,
//         enableSnapping: true,
//         snapToMinutes: 15,
//       ),
//       onAppointmentDragEnd: RescheduleHandler.wrap(
//         controller: _controller,
//
//         // ── Block double-bookings before asking the user ─────────────────
//         allowDoubleBooking: false,
//         onConflictBlocked: (data) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 'Cannot move "${data.appointment.title}": '
//                 'the slot is already taken.',
//               ),
//               backgroundColor: Colors.red,
//             ),
//           );
//         },
//
//         // ── Your confirmation UI ─────────────────────────────────────────
//         onConfirmationRequired: (data) async {
//           // Option A – use the built-in dialog:
//           return showDefaultRescheduleDialog(
//             context,
//             data,
//             allowSendNotification: true,
//           );
//
//           // Option B – roll your own dialog/bottom-sheet/etc.
//         },
//
//         // ── You own the update — copyWith lives on your concrete type ────
//         onConfirmed: (data) {
//           // DefaultAppointment:
//           final updated = (data.appointment as DefaultAppointment).copyWith(
//             resourceId: data.newResource.id,
//             startTime:  data.newStartTime,
//             endTime:    data.newEndTime,
//           );
//           _controller.updateAppointment(updated);
//
//           // Custom model example:
//           // final updated = (data.appointment as MyAppointment).copyWith(
//           //   resourceId: data.newResource.id,
//           //   startTime:  data.newStartTime,
//           //   endTime:    data.newEndTime,
//           // );
//           // _controller.updateAppointment(updated);
//         },
//       ),
//     );
//   }
// }
