// example/business_hours_example.dart

import 'package:flutter/material.dart';
import 'package:calendar2/calendar2.dart';

void main() {
  runApp(const BusinessHoursExampleApp());
}

class BusinessHoursExampleApp extends StatelessWidget {
  const BusinessHoursExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Business Hours Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const BusinessHoursExample(),
    );
  }
}

class BusinessHoursExample extends StatefulWidget {
  const BusinessHoursExample({super.key});

  @override
  State<BusinessHoursExample> createState() => _BusinessHoursExampleState();
}

class _BusinessHoursExampleState extends State<BusinessHoursExample> {
  late CalendarController _controller;

  @override
  void initState() {
    super.initState();

    _controller = CalendarController(
      config: const CalendarConfig(
        viewType: CalendarViewType.week,
        dayStartHour: 7,
        dayEndHour: 20,
        hourHeight: 80.0,
      ),
    );

    _setupResources();
    _setupAppointments();
  }

  void _setupResources() {
    // Resource 1: Standard office hours with lunch break
    final resource1 = DefaultResourceWithBusinessHours(
      id: '1',
      name: 'Dr. Smith',
      color: Colors.blue,
      businessHours: BusinessHours(
        workingHours: const {
          DateTime.monday: [TimePeriod(startTime: 10.0, endTime: 15.5)],
          DateTime.tuesday: [TimePeriod(startTime: 9.0, endTime: 16.0)],
          DateTime.wednesday: [TimePeriod(startTime: 10.0, endTime: 15.0)],
          DateTime.thursday: [TimePeriod(startTime: 10.0, endTime: 15.0)],
          DateTime.friday: [TimePeriod(startTime: 10.0, endTime: 15.0)],
        },

        showNonWorkingHours: true,
        showBreaks: true,
      ),
    );

    // Resource 2: Split shift (morning and evening)
    final resource2 = DefaultResourceWithBusinessHours(
      id: '2',
      name: 'Dr. Johnson',
      color: Colors.green,
      businessHours: const BusinessHours(
        workingHours: {
          DateTime.monday: [
            TimePeriod(startTime: 8.0, endTime: 12.0),
            TimePeriod(startTime: 16.0, endTime: 20.0),
          ],
          DateTime.tuesday: [
            TimePeriod(startTime: 8.0, endTime: 12.0),
            TimePeriod(startTime: 16.0, endTime: 20.0),
          ],
          DateTime.wednesday: [
            TimePeriod(startTime: 8.0, endTime: 12.0),
            TimePeriod(startTime: 16.0, endTime: 20.0),
          ],
          DateTime.thursday: [
            TimePeriod(startTime: 8.0, endTime: 12.0),
            TimePeriod(startTime: 16.0, endTime: 20.0),
          ],
          DateTime.friday: [
            TimePeriod(startTime: 8.0, endTime: 12.0),
            TimePeriod(startTime: 16.0, endTime: 20.0),
          ],
        },
        showNonWorkingHours: true,
      ),
    );

    // Resource 3: Weekend availability
    final resource3 = DefaultResourceWithBusinessHours(
      id: '3',
      name: 'Dr. Williams',
      color: Colors.purple,
      businessHours: const BusinessHours(
        workingHours: {
          DateTime.saturday: [TimePeriod(startTime: 9.0, endTime: 17.0)],
          DateTime.sunday: [TimePeriod(startTime: 10.0, endTime: 16.0)],
        },
        showNonWorkingHours: true,
      ),
    );

    // Resource 4: With vacation/leave
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));

    final resource4 = DefaultResourceWithBusinessHours(
      id: '4',
      name: 'Dr. Davis',
      color: Colors.orange,
      businessHours: BusinessHours(
        workingHours: const {
          DateTime.monday: [TimePeriod(startTime: 9.0, endTime: 17.0)],
          DateTime.tuesday: [TimePeriod(startTime: 9.0, endTime: 17.0)],
          DateTime.wednesday: [TimePeriod(startTime: 9.0, endTime: 17.0)],
          DateTime.thursday: [TimePeriod(startTime: 9.0, endTime: 17.0)],
          DateTime.friday: [TimePeriod(startTime: 9.0, endTime: 17.0)],
        },
        unavailabilities: [
          UnavailabilityPeriod(
            startTime: nextWeek,
            endTime: nextWeek.add(const Duration(days: 3)),
            type: UnavailabilityType.leave,
            label: 'Vacation',
            style: UnavailabilityStylePresets.holiday,
          ),
        ],
        showNonWorkingHours: true,
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
        endTime: today.add(const Duration(hours: 11)),
        title: 'Morning Consultation',
        color: Colors.blue.shade700,
      ),
      DefaultAppointment(
        id: '2',
        resourceId: '1',
        startTime: today.add(const Duration(hours: 14)),
        endTime: today.add(const Duration(hours: 15, minutes: 30)),
        title: 'Afternoon Session',
        color: Colors.blue.shade700,
      ),
      DefaultAppointment(
        id: '3',
        resourceId: '2',
        startTime: today.add(const Duration(hours: 9)),
        endTime: today.add(const Duration(hours: 11)),
        title: 'Morning Shift',
        color: Colors.green.shade700,
      ),
      DefaultAppointment(
        id: '4',
        resourceId: '2',
        startTime: today.add(const Duration(hours: 17)),
        endTime: today.add(const Duration(hours: 19)),
        title: 'Evening Shift',
        color: Colors.green.shade700,
      ),
    ];

    _controller.updateAppointments(appointments);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Hours Example'),
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
                dayStartHour: 5,
                dayEndHour: 24,
                hourHeight: 80.0,
              ),
              onCellTap: (data) {
                _showNewAppointmentDialog(data);
              },
              onAppointmentTap: (data) {
                _showAppointmentDetails(data);
              },
            ),
          ),
          // Legend
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
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
      child: Wrap(
        spacing: 24,
        runSpacing: 8,
        children: [
          _legendItem('Non-Working Hours', UnavailabilityStylePresets.standard),
          _legendItem('Break Time', UnavailabilityStylePresets.break_),
          _legendItem('Vacation/Leave', UnavailabilityStylePresets.holiday),
        ],
      ),
    );
  }

  Widget _legendItem(String label, UnavailabilityStyle style) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: style.backgroundColor,
            border: Border.all(color: style.borderColor),
          ),
          child: CustomPaint(painter: _LegendPatternPainter(style)),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  void _showNewAppointmentDialog(CellTapData data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resource: ${data.resource.name}'),
            Text('Time: ${data.dateTime}'),
            const SizedBox(height: 16),
            // Check if time slot is available
            Builder(
              builder: (context) {
                BusinessHours? businessHours;
                if (data.resource is CalendarResourceWithBusinessHours) {
                  businessHours =
                      (data.resource as CalendarResourceWithBusinessHours)
                          .businessHours;
                }

                if (businessHours != null) {
                  final isAvailable =
                      BusinessHoursCalculator.isTimeSlotAvailable(
                        businessHours: businessHours,
                        startTime: data.dateTime,
                        endTime: data.dateTime.add(const Duration(hours: 1)),
                      );

                  if (!isAvailable) {
                    return const Text(
                      '⚠ This time slot is outside business hours',
                      style: TextStyle(color: Colors.orange),
                    );
                  }
                }

                return const Text('✓ Time slot is available');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Add appointment logic here
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
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
            Text('Start: ${data.appointment.startTime}'),
            Text('End: ${data.appointment.endTime}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// Simple painter for legend items
class _LegendPatternPainter extends CustomPainter {
  final UnavailabilityStyle style;

  _LegendPatternPainter(this.style);

  @override
  void paint(Canvas canvas, Size size) {
    if (style.pattern == UnavailabilityPattern.diagonalLines) {
      final paint = Paint()
        ..color = style.patternColor
        ..strokeWidth = 1;

      for (double i = -size.height; i < size.width; i += 4) {
        canvas.drawLine(
          Offset(i, 0),
          Offset(i + size.height, size.height),
          paint,
        );
      }
    } else if (style.pattern == UnavailabilityPattern.horizontalLines) {
      final paint = Paint()
        ..color = style.patternColor
        ..strokeWidth = 1;

      for (double i = 0; i < size.height; i += 4) {
        canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_LegendPatternPainter oldDelegate) => false;
}
