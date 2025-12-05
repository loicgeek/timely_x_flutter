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
      home: CompleteMonthView(),
    );
  }
}

class CompleteMonthView extends StatefulWidget {
  @override
  _CompleteMonthViewState createState() => _CompleteMonthViewState();
}

class _CompleteMonthViewState extends State<CompleteMonthView> {
  late CalendarController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CalendarController(
      config: CalendarConfig(
        viewType: CalendarViewType.month,
        firstDayOfWeek: DateTime.sunday,
      ),
    );
    _loadData();
  }

  void _loadData() {
    // Add resources
    _controller.updateResources([
      DefaultResource(id: '1', name: 'Conference Room A', color: Colors.blue),
      DefaultResource(id: '2', name: 'Conference Room B', color: Colors.green),
      DefaultResource(id: '3', name: 'Meeting Room', color: Colors.orange),
    ]);

    // Add sample appointments
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _controller.updateAppointments([
      // Today
      DefaultAppointment(
        id: '1',
        resourceId: '1',
        title: 'Team Standup',
        startTime: today.add(Duration(hours: 9)),
        endTime: today.add(Duration(hours: 10)),
        color: Colors.blue,
      ),
      DefaultAppointment(
        id: '2',
        resourceId: '2',
        title: 'Client Meeting',
        startTime: today.add(Duration(hours: 14)),
        endTime: today.add(Duration(hours: 15)),
        color: Colors.green,
      ),
      DefaultAppointment(
        id: '3',
        resourceId: '3',
        title: 'Design Review',
        startTime: today.add(Duration(hours: 11)),
        endTime: today.add(Duration(hours: 12)),
        color: Colors.orange,
      ),

      // Tomorrow
      DefaultAppointment(
        id: '4',
        resourceId: '1',
        title: 'Sprint Planning',
        startTime: today.add(Duration(days: 1, hours: 10)),
        endTime: today.add(Duration(days: 1, hours: 12)),
        color: Colors.blue,
      ),

      // Next week
      DefaultAppointment(
        id: '5',
        resourceId: '2',
        title: 'Quarterly Review',
        startTime: today.add(Duration(days: 7, hours: 13)),
        endTime: today.add(Duration(days: 7, hours: 15)),
        color: Colors.green,
      ),
    ]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complete Month View'),
        actions: [
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () => _controller.previous(),
          ),
          IconButton(
            icon: Icon(Icons.today),
            onPressed: () => _controller.goToToday(),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: () => _controller.next(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Month title
          Container(
            padding: EdgeInsets.all(16),
            child: Text(
              _controller.getViewPeriodDescription(),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),

          // Calendar
          Expanded(
            child: CalendarView(
              controller: _controller,
              theme: CalendarTheme(
                monthViewMaxVisibleAppointments: 3,
                monthViewCellAspectRatio: 1.0,
                todayHighlightColor: Colors.purple,
                weekendColor: Color(0xFFFFF8E1),
              ),

              // Appointment interactions
              onAppointmentTap: (data) {
                _showAppointmentDialog(data);
              },

              onAppointmentLongPress: (data) {
                _showAppointmentOptions(data);
              },

              onAppointmentSecondaryTap: (data) {
                _showContextMenu(data);
              },

              // Cell interactions
              onCellTap: (data) {
                _createAppointment(data);
              },

              onCellLongPress: (data) {
                _showDayDetails(data);
              },

              // Date header interaction
              onDateHeaderTap: (data) {
                _controller.goToDate(data.date);
                _controller.setViewType(CalendarViewType.day);
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _quickCreate,
        child: Icon(Icons.add),
        tooltip: 'Create Appointment',
      ),
    );
  }

  void _showAppointmentDialog(AppointmentTapData data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data.appointment.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.person),
              title: Text(data.resource.name),
              subtitle: Text('Resource'),
            ),
            ListTile(
              leading: Icon(Icons.access_time),
              title: Text(
                '${_formatTime(data.appointment.startTime)} - '
                '${_formatTime(data.appointment.endTime)}',
              ),
              subtitle: Text('Time'),
            ),
            if (data.appointment.subtitle != null)
              ListTile(
                leading: Icon(Icons.description),
                title: Text(data.appointment.subtitle!),
                subtitle: Text('Description'),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _editAppointment(data.appointment);
            },
            child: Text('Edit'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAppointment(data.appointment);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAppointmentOptions(AppointmentLongPressData data) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _editAppointment(data.appointment);
              },
            ),
            ListTile(
              leading: Icon(Icons.copy),
              title: Text('Duplicate'),
              onTap: () {
                Navigator.pop(context);
                _duplicateAppointment(data.appointment);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteAppointment(data.appointment);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showContextMenu(AppointmentSecondaryTapData data) {
    // Right-click menu
    _showAppointmentOptions(
      AppointmentLongPressData(
        appointment: data.appointment,
        resource: data.resource,
        globalPosition: data.globalPosition,
      ),
    );
  }

  void _createAppointment(CellTapData data) {
    showDialog(
      context: context,
      builder: (context) => CreateAppointmentDialog(
        date: data.dateTime,
        resource: data.resource,
        onSave: (appointment) {
          _controller.addAppointment(appointment);
        },
      ),
    );
  }

  void _showDayDetails(CellTapData data) {
    print('Show details for ${data.dateTime}');
    print('${data.appointments.length} appointments');
  }

  void _quickCreate() {
    final now = DateTime.now();
    _createAppointment(
      CellTapData(
        resource: _controller.resources.first,
        dateTime: DateTime(now.year, now.month, now.day, 9, 0),
        globalPosition: Offset.zero,
      ),
    );
  }

  void _editAppointment(appointment) {
    print('Edit: ${appointment.id}');
    // Implement edit dialog
  }

  void _duplicateAppointment(appointment) {
    final duplicate = (appointment as DefaultAppointment).copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: appointment.startTime.add(Duration(days: 1)),
      endTime: appointment.endTime.add(Duration(days: 1)),
    );
    _controller.addAppointment(duplicate);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Appointment duplicated')));
  }

  void _deleteAppointment(appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Appointment'),
        content: Text(
          'Are you sure you want to delete "${appointment.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _controller.removeAppointment(appointment.id);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Appointment deleted')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }
}

// Create Appointment Dialog
class CreateAppointmentDialog extends StatefulWidget {
  final DateTime date;
  final CalendarResource resource;
  final Function(DefaultAppointment) onSave;

  const CreateAppointmentDialog({
    Key? key,
    required this.date,
    required this.resource,
    required this.onSave,
  }) : super(key: key);

  @override
  _CreateAppointmentDialogState createState() =>
      _CreateAppointmentDialogState();
}

class _CreateAppointmentDialogState extends State<CreateAppointmentDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _startTime = TimeOfDay(hour: 9, minute: 0);
    _endTime = TimeOfDay(hour: 10, minute: 0);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create Appointment'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text('Start Time'),
                      subtitle: Text(_startTime.format(context)),
                      onTap: () => _selectTime(true),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text('End Time'),
                      subtitle: Text(_endTime.format(context)),
                      onTap: () => _selectTime(false),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: widget.resource.color,
                  radius: 12,
                ),
                title: Text(widget.resource.name),
                subtitle: Text('Resource'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(onPressed: _save, child: Text('Save')),
      ],
    );
  }

  Future<void> _selectTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final startDateTime = DateTime(
        widget.date.year,
        widget.date.month,
        widget.date.day,
        _startTime.hour,
        _startTime.minute,
      );

      final endDateTime = DateTime(
        widget.date.year,
        widget.date.month,
        widget.date.day,
        _endTime.hour,
        _endTime.minute,
      );

      final appointment = DefaultAppointment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        resourceId: widget.resource.id,
        title: _titleController.text,
        subtitle: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        startTime: startDateTime,
        endTime: endDateTime,
        color: widget.resource.color ?? Colors.blue,
      );

      widget.onSave(appointment);
      Navigator.pop(context);
    }
  }
}
