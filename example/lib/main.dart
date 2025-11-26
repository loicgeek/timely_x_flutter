// example/lib/main.dart - UPDATED WITH PERFORMANCE TESTING

import 'package:flutter/material.dart';
import 'package:calendar2/calendar2.dart';
import 'package:performance/performance.dart';
import 'dart:math' as math;
import 'widgets/custom_navigation_bar.dart';
import 'builders/custom_calendar_builders.dart';
import 'theme/calendar_app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      showPerformanceOverlay: false, // Shows FPS overlay
      title: 'Calendar View Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: CustomPerformanceOverlay(child: const CalendarDemo()),
    );
  }
}

class CalendarDemo extends StatefulWidget {
  const CalendarDemo({Key? key}) : super(key: key);

  @override
  State<CalendarDemo> createState() => _CalendarDemoState();
}

class _CalendarDemoState extends State<CalendarDemo> {
  late CalendarController _controller;
  late CustomCalendarBuilders _builders;

  // PERFORMANCE TESTING CONFIGURATION
  static const int numberOfResources = 6;
  static const int numberOfDays = 21; // 2 weeks
  static const int appointmentsPerResourcePerDay = 10; // Adjust this!

  // Total appointments = 6 resources × 21 days × 10 = 1260 appointments

  @override
  void initState() {
    super.initState();

    _controller = CalendarController(config: CalendarAppTheme.config);

    _builders = CustomCalendarBuilders(
      onAppointmentTap: _handleAppointmentTap,
      onAppointmentLongPress: _handleAppointmentLongPress,
      onResourceHeaderTap: _handleResourceHeaderTap,
    );

    _loadSampleData();

    // Print performance info
    print('╔════════════════════════════════════════════════╗');
    print('║     PERFORMANCE TEST CONFIGURATION             ║');
    print('╠════════════════════════════════════════════════╣');
    print('║ Resources: $numberOfResources');
    print('║ Days: $numberOfDays');
    print('║ Appointments per resource/day: $appointmentsPerResourcePerDay');
    print(
      '║ Total appointments: ${numberOfResources * numberOfDays * appointmentsPerResourcePerDay}',
    );
    print('╚════════════════════════════════════════════════╝');
  }

  void _loadSampleData() {
    final random = math.Random(42); // Fixed seed for reproducible results

    // Create resources
    final resources = _generateResources(numberOfResources);

    // Generate appointments
    final appointments = _generateAppointments(
      resources: resources,
      numberOfDays: numberOfDays,
      appointmentsPerDay: appointmentsPerResourcePerDay,
      random: random,
    );

    _controller.updateResources(resources);
    _controller.updateAppointments(appointments);

    print('Loaded ${appointments.length} appointments successfully!');
  }

  List<CalendarResource> _generateResources(int count) {
    final resourceNames = [
      'Dr. Smith',
      'Dr. Johnson',
      'Dr. Williams',
      'Dr. Brown',
      'Dr. Jones',
      'Dr. Garcia',
      'Dr. Miller',
      'Dr. Davis',
      'Dr. Rodriguez',
      'Dr. Martinez',
    ];

    final colors = [
      Colors.blue,
      const Color(0xFF4CAF50),
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
      const Color(0xFFE91E63),
      const Color(0xFF00BCD4),
      const Color(0xFF8BC34A),
      const Color(0xFFFF5722),
      const Color(0xFF673AB7),
      const Color(0xFF009688),
    ];

    return List.generate(count, (i) {
      if (i == 0) {
        // First resource with business hours
        return DefaultResourceWithBusinessHours(
          id: '${i + 1}',
          name: resourceNames[i % resourceNames.length],
          color: colors[i % colors.length],
          businessHours: BusinessHours(
            workingHours: const {
              DateTime.monday: [TimePeriod(startTime: 9.0, endTime: 17.0)],
              DateTime.tuesday: [TimePeriod(startTime: 9.0, endTime: 17.0)],
              DateTime.wednesday: [TimePeriod(startTime: 9.0, endTime: 17.0)],
              DateTime.thursday: [TimePeriod(startTime: 9.0, endTime: 17.0)],
              DateTime.friday: [TimePeriod(startTime: 9.0, endTime: 17.0)],
            },
            showNonWorkingHours: true,
            showBreaks: true,
          ),
        );
      }

      return DefaultResource(
        id: '${i + 1}',
        name: resourceNames[i % resourceNames.length],
        color: colors[i % colors.length],
      );
    });
  }

  List<DefaultAppointment> _generateAppointments({
    required List<CalendarResource> resources,
    required int numberOfDays,
    required int appointmentsPerDay,
    required math.Random random,
  }) {
    final appointments = <DefaultAppointment>[];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final serviceTypes = [
      'Consultation',
      'Follow-up',
      'Check-up',
      'Treatment',
      'Surgery',
      'X-Ray',
      'Lab Work',
      'Physical',
      'Therapy',
      'Review',
    ];

    final clientNames = [
      'John Doe',
      'Jane Smith',
      'Bob Wilson',
      'Alice Johnson',
      'Charlie Brown',
      'Diana Prince',
      'Eva Green',
      'Frank Miller',
      'Grace Lee',
      'Henry Ford',
      'Iris West',
      'Jack Ryan',
    ];

    int appointmentId = 1;

    for (int day = 0; day < numberOfDays; day++) {
      final date = today.add(Duration(days: day));

      for (final resource in resources) {
        for (int apt = 0; apt < appointmentsPerDay; apt++) {
          // Generate random time between 8 AM and 5 PM
          final startHour = 8 + random.nextInt(9); // 8-16 (5 PM)
          final startMinute = random.nextInt(4) * 15; // 0, 15, 30, 45

          // Generate random duration (30 min to 2 hours)
          final durationMinutes = [30, 45, 60, 90, 120][random.nextInt(5)];

          final startTime = date.add(
            Duration(hours: startHour, minutes: startMinute),
          );

          final endTime = startTime.add(Duration(minutes: durationMinutes));

          // Don't create appointments that end after 6 PM
          if (endTime.hour >= 18) continue;

          appointments.add(
            DefaultAppointment(
              id: 'apt_${appointmentId++}',
              resourceId: resource.id,
              startTime: startTime,
              endTime: endTime,
              title: serviceTypes[random.nextInt(serviceTypes.length)],
              subtitle: clientNames[random.nextInt(clientNames.length)],
              color: resource.color ?? Colors.blue,
            ),
          );
        }
      }
    }

    return appointments;
  }

  void _handleCellLongPress(CellTapData data) {
    print("Cell long press: ${data.resource.name} ${data.dateTime}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          CustomNavigationBar(
            controller: _controller,
            onAddPressed: _handleAddPressed,
          ),
          // Performance info banner
          Container(
            color: Colors.amber.shade100,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.speed, size: 20, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Performance Test: ${numberOfResources * numberOfDays * appointmentsPerResourcePerDay} appointments',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  'Watch FPS overlay above',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          Expanded(
            child: CalendarView(
              controller: _controller,
              config: _controller.config,
              theme: CalendarAppTheme.theme,
              resourceHeaderBuilder: _builders.buildResourceHeader,
              dateHeaderBuilder: _builders.buildDateHeader,
              timeColumnBuilder: _builders.buildTimeColumn,
              appointmentBuilder: _builders.buildAppointment,
              currentTimeIndicatorBuilder: _builders.buildCurrentTimeIndicator,
              onAppointmentTap: _handleAppointmentTap,
              onAppointmentLongPress: _handleAppointmentLongPress,
              onAppointmentSecondaryTap: _handleAppointmentSecondaryTap,
              onCellTap: _handleCellTap,
              onCellLongPress: _handleCellLongPress,
              onResourceHeaderTap: _handleResourceHeaderTap,
              onDateHeaderTap: _handleDateHeaderTap,
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Add more appointments button
          FloatingActionButton.small(
            heroTag: 'add_more',
            onPressed: _addMoreAppointments,
            backgroundColor: Colors.green,
            child: const Icon(Icons.add, size: 20),
          ),
          const SizedBox(height: 8),
          // Reload button
          FloatingActionButton.small(
            heroTag: 'reload',
            onPressed: _loadSampleData,
            backgroundColor: Colors.blue,
            child: const Icon(Icons.refresh, size: 20),
          ),
          const SizedBox(height: 8),
          // Clear all button
          FloatingActionButton.small(
            heroTag: 'clear',
            onPressed: _clearAllAppointments,
            backgroundColor: Colors.red,
            child: const Icon(Icons.clear, size: 20),
          ),
        ],
      ),
    );
  }

  void _addMoreAppointments() {
    final random = math.Random();
    final newAppointments = _generateAppointments(
      resources: _controller.resources,
      numberOfDays: 7,
      appointmentsPerDay: 3,
      random: random,
    );

    for (final apt in newAppointments) {
      _controller.addAppointment(apt);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${newAppointments.length} appointments')),
    );
  }

  void _clearAllAppointments() {
    setState(() {
      _controller.updateAppointments([]);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Cleared all appointments')));
  }

  void _handleAddPressed() {
    if (_controller.resources.isNotEmpty) {
      _showCreateDialog(_controller.resources.first, DateTime.now());
    }
  }

  void _handleAppointmentTap(AppointmentTapData data) {
    _showAppointmentDialog(data.appointment);
  }

  void _handleAppointmentLongPress(AppointmentLongPressData data) {
    _showContextMenu(context, data.appointment, data.globalPosition);
  }

  void _handleAppointmentSecondaryTap(AppointmentSecondaryTapData data) {
    _showContextMenu(context, data.appointment, data.globalPosition);
  }

  void _handleCellTap(CellTapData data) {
    print("Cell tap: ${data.resource.name} ${data.dateTime}");
    _showCreateDialog(data.resource, data.dateTime);
  }

  void _handleResourceHeaderTap(ResourceHeaderTapData data) {
    // Filter to this resource or show resource details
  }

  void _handleDateHeaderTap(DateHeaderTapData data) {
    // Navigate to day view for this date
    _controller.goToDate(data.date);
    _controller.setViewType(CalendarViewType.day);
  }

  void _showAppointmentDialog(CalendarAppointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appointment.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (appointment.subtitle != null)
              Text(
                appointment.subtitle!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.access_time,
              'Start',
              appointment.startTime.toString(),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.access_time,
              'End',
              appointment.endTime.toString(),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.timer,
              'Duration',
              '${appointment.duration.inMinutes} minutes',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _controller.removeAppointment(appointment.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
        Expanded(
          child: Text(value, style: const TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }

  void _showContextMenu(
    BuildContext context,
    CalendarAppointment appointment,
    Offset position,
  ) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 18),
              SizedBox(width: 12),
              Text('Edit'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 18, color: Colors.red),
              SizedBox(width: 12),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'duplicate',
          child: Row(
            children: [
              Icon(Icons.content_copy, size: 18),
              SizedBox(width: 12),
              Text('Duplicate'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'delete') {
        _controller.removeAppointment(appointment.id);
      }
    });
  }

  void _showCreateDialog(CalendarResource resource, DateTime dateTime) {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Service',
                hintText: 'e.g., Haircut',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: subtitleController,
              decoration: const InputDecoration(
                labelText: 'Client Name',
                hintText: 'e.g., John Doe',
              ),
            ),
            const SizedBox(height: 16),
            Text('Resource: ${resource.name}'),
            const SizedBox(height: 8),
            Text('Time: ${dateTime.toString().substring(0, 16)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                final appointment = DefaultAppointment(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  resourceId: resource.id,
                  startTime: dateTime,
                  endTime: dateTime.add(const Duration(hours: 1)),
                  title: titleController.text,
                  subtitle: subtitleController.text.isNotEmpty
                      ? subtitleController.text
                      : null,
                  color: resource.color ?? Colors.blue,
                );
                _controller.addAppointment(appointment);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
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
