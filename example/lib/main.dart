// example/lib/main.dart

import 'package:flutter/material.dart';
import 'package:calendar2/calendar2.dart';
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
      title: 'Calendar View Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      debugShowCheckedModeBanner: false,
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
  late CustomCalendarBuilders _builders;

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
  }

  void _loadSampleData() {
    final resources = [
      DefaultResourceWithBusinessHours(
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
      ),
      DefaultResource(
        id: '2',
        name: 'Fernanda Martinez',
        color: const Color(0xFF4CAF50),
      ),
      DefaultResource(
        id: '3',
        name: 'Dayana Arteag',
        color: const Color(0xFFFF9800),
      ),
      DefaultResource(
        id: '4',
        name: 'na Llamuca',
        color: const Color(0xFF9C27B0),
      ),
    ];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final appointments = <DefaultAppointment>[];

    for (int day = 0; day < 7; day++) {
      final date = today.add(Duration(days: day));

      appointments.addAll([
        DefaultAppointment(
          id: 'apt${day}_1',
          resourceId: '1',
          startTime: date.add(const Duration(hours: 9)),
          endTime: date.add(const Duration(hours: 10)),
          title: 'Haircut',
          subtitle: 'John Doe',
          color: const Color(0xFF2196F3),
        ),
        DefaultAppointment(
          id: 'apt${day}_2',
          resourceId: '2',
          startTime: date.add(const Duration(hours: 10)),
          endTime: date.add(const Duration(hours: 11, minutes: 30)),
          title: 'Color Treatment',
          subtitle: 'Jane Smith',
          color: const Color(0xFF4CAF50),
        ),
        DefaultAppointment(
          id: 'apt${day}_3',
          resourceId: '3',
          startTime: date.add(const Duration(hours: 13)),
          endTime: date.add(const Duration(hours: 14)),
          title: 'Manicure',
          subtitle: 'Alice Johnson',
          color: const Color(0xFFFF9800),
        ),
        if (day % 2 == 0)
          DefaultAppointment(
            id: 'apt${day}_4',
            resourceId: '1',
            startTime: date.add(const Duration(hours: 9, minutes: 30)),
            endTime: date.add(const Duration(hours: 10, minutes: 30)),
            title: 'Consultation',
            subtitle: 'Bob Wilson',
            color: const Color(0xFF1976D2),
          ),
      ]);
    }

    _controller.updateResources(resources);
    _controller.updateAppointments(appointments);
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
              onResourceHeaderTap: _handleResourceHeaderTap,
              onDateHeaderTap: _handleDateHeaderTap,
            ),
          ),
        ],
      ),
    );
  }

  void _handleAddPressed() {
    if (_controller.resources.isNotEmpty) {
      _showCreateDialog(_controller.resources.first, DateTime.now());
    }
  }

  void _handleWaitlistPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Waitlist feature coming soon')),
    );
  }

  void _handleQuickSalePressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quick sale feature coming soon')),
    );
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
