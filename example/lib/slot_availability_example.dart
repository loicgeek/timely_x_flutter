// example/slot_availability_example.dart

import 'package:flutter/material.dart';
import 'package:timely_x/timely_x.dart';

void main() {
  runApp(const SlotAvailabilityExampleApp());
}

class SlotAvailabilityExampleApp extends StatelessWidget {
  const SlotAvailabilityExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Slot Availability Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const SlotAvailabilityExample(),
    );
  }
}

class SlotAvailabilityExample extends StatefulWidget {
  const SlotAvailabilityExample({super.key});

  @override
  State<SlotAvailabilityExample> createState() =>
      _SlotAvailabilityExampleState();
}

class _SlotAvailabilityExampleState extends State<SlotAvailabilityExample> {
  late CalendarController _controller;

  @override
  void initState() {
    super.initState();

    _controller = CalendarController(
      config: const CalendarConfig(
        viewType: CalendarViewType.week,
        dayStartHour: 8,
        dayEndHour: 20,
        hourHeight: 80.0,
      ),
    );

    _setupResources();
    _setupAppointments();
  }

  void _setupResources() {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 7));
    final endDate = now.add(const Duration(days: 14));

    // Resource 1: Standard 30-minute slots
    final resource1 = DefaultResourceWithSlots(
      id: '1',
      name: 'Dr. Smith',
      color: Colors.blue,
      slotAvailability: SlotAvailability(
        slots: SlotBuilder.generateFixedSlots(
          startDate: startDate,
          endDate: endDate,
          slotDuration: const Duration(minutes: 30),
          dayStartTime: const TimeOfDay(hour: 9, minute: 0),
          dayEndTime: const TimeOfDay(hour: 17, minute: 0),
          breakDuration: const Duration(hours: 1),
          breakStartTime: const TimeOfDay(hour: 12, minute: 0),
          daysOfWeek: const [1, 2, 3, 4, 5], // Mon-Fri
        ),
        highlightConfig: SlotHighlightPresets.subtle,
      ),
    );

    // Resource 2: Specific time slots with pricing
    final resource2 = DefaultResourceWithSlots(
      id: '2',
      name: 'Dr. Johnson',
      color: Colors.green,
      slotAvailability: SlotAvailability(
        slots: SlotBuilder.generateSpecificSlots(
          startDate: startDate,
          endDate: endDate,
          slotTimes: [
            (
              start: const TimeOfDay(hour: 9, minute: 0),
              end: const TimeOfDay(hour: 10, minute: 0),
            ),
            (
              start: const TimeOfDay(hour: 10, minute: 0),
              end: const TimeOfDay(hour: 11, minute: 0),
            ),
            (
              start: const TimeOfDay(hour: 11, minute: 0),
              end: const TimeOfDay(hour: 12, minute: 0),
            ),
            (
              start: const TimeOfDay(hour: 14, minute: 0),
              end: const TimeOfDay(hour: 15, minute: 0),
            ),
            (
              start: const TimeOfDay(hour: 15, minute: 0),
              end: const TimeOfDay(hour: 16, minute: 0),
            ),
            (
              start: const TimeOfDay(hour: 16, minute: 0),
              end: const TimeOfDay(hour: 17, minute: 0),
            ),
          ],
          daysOfWeek: const [1, 2, 3, 4, 5],
          price: 150.0,
        ),
        highlightConfig: SlotHighlightPresets.withPrice,
      ),
    );

    // Resource 3: Multi-capacity slots (group classes)
    final groupSlots = SlotBuilder.generateFixedSlots(
      startDate: startDate,
      endDate: endDate,
      slotDuration: const Duration(hours: 1),
      dayStartTime: const TimeOfDay(hour: 10, minute: 0),
      dayEndTime: const TimeOfDay(hour: 18, minute: 0),
      daysOfWeek: const [6, 7], // Weekend only
      capacity: 10, // 10 people per slot
    );

    final resource3 = DefaultResourceWithSlots(
      id: '3',
      name: 'Yoga Studio',
      color: Colors.purple,
      slotAvailability: SlotAvailability(
        slots: groupSlots,
        highlightConfig: const SlotHighlightConfig(
          style: SlotHighlightStyle.emphasized,
          availableColor: Color(0xFFE1BEE7),
          showCapacity: true,
        ),
      ),
    );

    // Resource 4: 15-minute quick slots
    final resource4 = DefaultResourceWithSlots(
      id: '4',
      name: 'Quick Care',
      color: Colors.orange,
      slotAvailability: SlotAvailability(
        slots: SlotBuilder.generateFixedSlots(
          startDate: startDate,
          endDate: endDate,
          slotDuration: const Duration(minutes: 15),
          dayStartTime: const TimeOfDay(hour: 8, minute: 0),
          dayEndTime: const TimeOfDay(hour: 12, minute: 0),
          daysOfWeek: const [1, 2, 3, 4, 5],
        ),
        highlightConfig: SlotHighlightPresets.border,
      ),
    );

    _controller.updateResources([resource1, resource2, resource3, resource4]);
  }

  void _setupAppointments() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final appointments = [
      DefaultAppointment(
        id: '1',
        resourceId: '1',
        startTime: today.add(const Duration(hours: 10)),
        endTime: today.add(const Duration(hours: 10, minutes: 30)),
        title: 'Patient Consultation',
        color: Colors.blue.shade700,
      ),
      DefaultAppointment(
        id: '2',
        resourceId: '2',
        startTime: today.add(const Duration(hours: 14)),
        endTime: today.add(const Duration(hours: 15)),
        title: 'Appointment',
        color: Colors.green.shade700,
      ),
      DefaultAppointment(
        id: '3',
        resourceId: '3',
        startTime: today.add(const Duration(hours: 10)),
        endTime: today.add(const Duration(hours: 11)),
        title: 'Yoga Class (5/10)',
        color: Colors.purple.shade700,
      ),
    ];

    _controller.updateAppointments(appointments);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Slot Availability Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _controller.previous(),
          ),
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () => _controller.goToToday(),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _controller.next(),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Period description
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _controller.getViewPeriodDescription(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          // Calendar
          Expanded(
            child: CalendarView(
              controller: _controller,
              config: const CalendarConfig(
                viewType: CalendarViewType.week,
                dayStartHour: 8,
                dayEndHour: 20,
                hourHeight: 80.0,
              ),
              onCellTap: (data) {
                _handleCellTap(data);
              },
              onAppointmentTap: (data) {
                _showAppointmentDetails(data);
              },
            ),
          ),
          // Legend and stats
          _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Legend
          const Text(
            'Highlighted areas indicate available time slots',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          // Resource info
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: _controller.filteredResources.map((resource) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: resource.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(resource.name, style: const TextStyle(fontSize: 11)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _handleCellTap(CellTapData data) {
    SlotAvailability? slotAvailability;
    if (data.resource is CalendarResourceWithSlots) {
      slotAvailability =
          (data.resource as CalendarResourceWithSlots).slotAvailability;
    }

    if (slotAvailability == null) {
      _showMessage('This resource does not use slot-based availability');
      return;
    }

    // Find slot at tapped time
    final slot = slotAvailability.findSlotAtTime(data.dateTime);

    if (slot == null) {
      // No slot at this time - show next available
      final nextSlot = slotAvailability.getNextAvailableSlot(data.dateTime);

      if (nextSlot != null) {
        _showSlotDialog(
          context: context,
          resource: data.resource,
          slot: nextSlot,
          isNextAvailable: true,
        );
      } else {
        _showMessage('No available slots found');
      }
    } else {
      _showSlotDialog(context: context, resource: data.resource, slot: slot);
    }
  }

  void _showSlotDialog({
    required BuildContext context,
    required CalendarResource resource,
    required AvailableSlot slot,
    bool isNextAvailable = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isNextAvailable ? 'Next Available Slot' : 'Available Slot'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resource: ${resource.name}'),
            const SizedBox(height: 8),
            Text(
              'Time: ${_formatTime(slot.startTime)} - ${_formatTime(slot.endTime)}',
            ),
            Text('Duration: ${slot.duration.inMinutes} minutes'),
            if (slot.capacity > 1) ...[
              const SizedBox(height: 8),
              Text('Capacity: ${slot.remainingCapacity}/${slot.capacity}'),
            ],
            if (slot.price != null) ...[
              const SizedBox(height: 8),
              Text('Price: \$${slot.price!.toStringAsFixed(2)}'),
            ],
            const SizedBox(height: 16),
            // Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: slot.hasAvailability
                    ? Colors.green.shade100
                    : Colors.red.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                slot.hasAvailability ? '✓ Available' : '✗ Fully Booked',
                style: TextStyle(
                  color: slot.hasAvailability
                      ? Colors.green.shade900
                      : Colors.red.shade900,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (slot.hasAvailability)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _bookSlot(resource, slot);
              },
              child: const Text('Book'),
            ),
        ],
      ),
    );
  }

  void _bookSlot(CalendarResource resource, AvailableSlot slot) {
    // Create appointment
    final appointment = DefaultAppointment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      resourceId: resource.id,
      startTime: slot.startTime,
      endTime: slot.endTime,
      title: 'New Booking',
      color: resource.color ?? Colors.blue,
    );

    _controller.addAppointment(appointment);

    _showMessage('Slot booked successfully!');
  }

  void _showAppointmentDetails(AppointmentTapData data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data.appointment.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resource: ${data.resource.name}'),
            Text('Start: ${_formatTime(data.appointment.startTime)}'),
            Text('End: ${_formatTime(data.appointment.endTime)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _controller.removeAppointment(data.appointment.id);
              _showMessage('Appointment cancelled');
            },
            child: const Text('Cancel Appointment'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Slot Availability'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This example demonstrates slot-based availability:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('• Dr. Smith: 30-minute slots'),
              Text('• Dr. Johnson: 1-hour slots with pricing'),
              Text('• Yoga Studio: Multi-capacity group classes'),
              Text('• Quick Care: 15-minute express slots'),
              SizedBox(height: 12),
              Text('Highlighted areas show available slots.'),
              Text('Tap on a slot to book an appointment.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
