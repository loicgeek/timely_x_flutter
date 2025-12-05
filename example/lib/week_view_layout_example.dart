// example/week_view_layout_example.dart
// Example demonstrating the new week view layout options and cell interactions

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:timely_x/timely_x.dart';
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
      title: 'Calendar Layout Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CalendarDemo(),
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
  WeekViewLayout _currentLayout = WeekViewLayout.resourcesFirst;

  @override
  void initState() {
    super.initState();

    // Initialize controller
    _controller = CalendarController(
      initialDate: DateTime.now(),
      config: CalendarConfig(
        viewType: CalendarViewType.week,
        weekViewLayout: _currentLayout,
        hourHeight: 80.0,
        dayStartHour: 8,
        dayEndHour: 18,
        firstDayOfWeek: DateTime.sunday,
      ),
    );

    // Setup sample data
    _setupSampleData();
  }

  void _setupSampleData() {
    // Add sample resources
    _controller.updateResources([
      DefaultResource(id: '1', name: 'Dr. Smith', color: Colors.blue),
      DefaultResource(id: '2', name: 'Dr. Johnson', color: Colors.green),
      DefaultResource(id: '3', name: 'Dr. Williams', color: Colors.purple),
    ]);

    // Add sample appointments
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _controller.updateAppointments([
      DefaultAppointment(
        id: '1',
        resourceId: '1',
        title: 'Patient Consultation',
        startTime: today.add(const Duration(hours: 9)),
        endTime: today.add(const Duration(hours: 10)),
        color: Colors.blue.shade300,
      ),
      DefaultAppointment(
        id: '2',
        resourceId: '1',
        title: 'Surgery',
        startTime: today.add(const Duration(hours: 14)),
        endTime: today.add(const Duration(hours: 16)),
        color: Colors.red.shade300,
      ),
      DefaultAppointment(
        id: '3',
        resourceId: '2',
        title: 'Team Meeting',
        startTime: today.add(const Duration(hours: 10)),
        endTime: today.add(const Duration(hours: 11)),
        color: Colors.green.shade300,
      ),
      DefaultAppointment(
        id: '4',
        resourceId: '3',
        title: 'Follow-up',
        startTime: today.add(const Duration(hours: 15)),
        endTime: today.add(const Duration(hours: 16)),
        color: Colors.purple.shade300,
      ),
    ]);
  }

  void _toggleLayout() {
    setState(() {
      _currentLayout = _currentLayout == WeekViewLayout.resourcesFirst
          ? WeekViewLayout.daysFirst
          : WeekViewLayout.resourcesFirst;

      // Update controller config
      _controller.updateConfig(
        _controller.config.copyWith(weekViewLayout: _currentLayout),
      );
    });
  }

  void _handleCellTap(CellTapData data) {
    final appointmentCount = data.appointments.length;
    final message = appointmentCount > 0
        ? 'Cell tapped!\n'
              'Resource: ${data.resource.name}\n'
              'Time: ${data.dateTime.hour}:00\n'
              'Appointments: $appointmentCount'
        : 'Empty cell tapped!\n'
              'Resource: ${data.resource.name}\n'
              'Time: ${data.dateTime.hour}:00\n'
              'Click here to create an appointment';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        action: appointmentCount == 0
            ? SnackBarAction(
                label: 'CREATE',
                onPressed: () => _createAppointment(data),
              )
            : null,
      ),
    );

    // If there are appointments, you can handle them
    if (data.appointments.isNotEmpty) {
      print('Appointments in this cell:');
      for (final apt in data.appointments) {
        print('  - ${apt.title} (${apt.startTime} - ${apt.endTime})');
      }
    }
  }

  void _createAppointment(CellTapData data) {
    // Create a new appointment at the tapped cell
    final newAppointment = DefaultAppointment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      resourceId: data.resource.id,
      title: 'New Appointment',
      startTime: data.dateTime,
      endTime: data.dateTime.add(const Duration(hours: 1)),
      color: Colors.orange.shade300,
    );

    _controller.addAppointment(newAppointment);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Appointment created!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _handleAppointmentTap(AppointmentTapData data) {
    print('Appointment tapped: ${data.appointment.title}');
    _controller.selectAppointment(data.appointment);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data.appointment.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resource: ${data.resource.name}'),
            const SizedBox(height: 8),
            Text(
              'Time: ${data.appointment.startTime.hour}:${data.appointment.startTime.minute.toString().padLeft(2, '0')} - '
              '${data.appointment.endTime.hour}:${data.appointment.endTime.minute.toString().padLeft(2, '0')}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _controller.removeAppointment(data.appointment.id);
              Navigator.pop(context);
            },
            child: const Text('DELETE'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar Layout Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () => _controller.goToToday(),
            tooltip: 'Go to Today',
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _controller.previous(),
            tooltip: 'Previous Week',
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _controller.next(),
            tooltip: 'Next Week',
          ),
          const SizedBox(width: 16),
          TextButton.icon(
            icon: const Icon(Icons.swap_horiz),
            label: Text(
              _currentLayout == WeekViewLayout.resourcesFirst
                  ? 'Resources First'
                  : 'Days First',
            ),
            onPressed: _toggleLayout,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Period indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              _controller.getViewPeriodDescription(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          // Calendar
          Expanded(
            child: CalendarView(
              controller: _controller,
              config: _controller.config,
              theme: const CalendarTheme(),
              // Cell interaction callbacks
              onCellTap: _handleCellTap,

              onCellLongPress: (data) {
                print(
                  'Cell long pressed: ${data.resource.name} at ${data.dateTime}',
                );
              },
              // Appointment interaction callbacks
              onAppointmentTap: _handleAppointmentTap,
              onAppointmentLongPress: (data) {
                print('Appointment long pressed: ${data.appointment.title}');
              },
            ),
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
