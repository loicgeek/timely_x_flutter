# Example Application

This is a complete, working example of a Flutter Resource Calendar application.

## Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:timely_x/timely_x.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: CalendarPage(),
    );
  }
}

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late CalendarController _controller;
  CalendarViewType _currentView = CalendarViewType.week;

  @override
  void initState() {
    super.initState();
    _initializeCalendar();
  }

  void _initializeCalendar() {
    _controller = CalendarController(
      config: CalendarConfig(
        viewType: _currentView,
        hourHeight: 100,
        dayStartHour: 8,
        dayEndHour: 18,
        enableDragAndDrop: true,
        enableSnapping: true,
        snapToMinutes: 15,
      ),
    );

    // Add sample resources
    _controller.updateResources([
      DefaultResource(
        id: '1',
        name: 'John Doe',
        color: Colors.blue,
        avatarUrl: 'https://i.pravatar.cc/150?img=1',
        category: 'Engineering',
      ),
      DefaultResource(
        id: '2',
        name: 'Jane Smith',
        color: Colors.green,
        avatarUrl: 'https://i.pravatar.cc/150?img=2',
        category: 'Design',
      ),
      DefaultResource(
        id: '3',
        name: 'Bob Johnson',
        color: Colors.orange,
        avatarUrl: 'https://i.pravatar.cc/150?img=3',
        category: 'Marketing',
      ),
    ]);

    // Add sample appointments
    _addSampleAppointments();
  }

  void _addSampleAppointments() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _controller.updateAppointments([
      // Today's appointments
      DefaultAppointment(
        id: '1',
        resourceId: '1',
        title: 'Team Meeting',
        subtitle: 'Quarterly Review',
        startTime: today.add(Duration(hours: 10)),
        endTime: today.add(Duration(hours: 11, minutes: 30)),
        color: Colors.blue,
        status: 'confirmed',
      ),
      DefaultAppointment(
        id: '2',
        resourceId: '1',
        title: 'Code Review',
        startTime: today.add(Duration(hours: 14)),
        endTime: today.add(Duration(hours: 15)),
        color: Colors.blue.shade700,
      ),
      DefaultAppointment(
        id: '3',
        resourceId: '2',
        title: 'Design Workshop',
        subtitle: 'New Feature Mockups',
        startTime: today.add(Duration(hours: 9)),
        endTime: today.add(Duration(hours: 11)),
        color: Colors.green,
      ),
      DefaultAppointment(
        id: '4',
        resourceId: '2',
        title: 'Client Presentation',
        startTime: today.add(Duration(hours: 15)),
        endTime: today.add(Duration(hours: 16, minutes: 30)),
        color: Colors.green.shade700,
      ),
      DefaultAppointment(
        id: '5',
        resourceId: '3',
        title: 'Marketing Strategy',
        startTime: today.add(Duration(hours: 11)),
        endTime: today.add(Duration(hours: 12, minutes: 30)),
        color: Colors.orange,
      ),

      // Tomorrow's appointments
      DefaultAppointment(
        id: '6',
        resourceId: '1',
        title: 'Sprint Planning',
        startTime: today.add(Duration(days: 1, hours: 9)),
        endTime: today.add(Duration(days: 1, hours: 10, minutes: 30)),
        color: Colors.blue,
      ),
      DefaultAppointment(
        id: '7',
        resourceId: '2',
        title: 'Design Review',
        startTime: today.add(Duration(days: 1, hours: 13)),
        endTime: today.add(Duration(days: 1, hours: 14)),
        color: Colors.green,
      ),

      // Next week
      DefaultAppointment(
        id: '8',
        resourceId: '3',
        title: 'Campaign Launch',
        startTime: today.add(Duration(days: 7, hours: 10)),
        endTime: today.add(Duration(days: 7, hours: 12)),
        color: Colors.orange.shade700,
      ),
    ]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _changeView(CalendarViewType viewType) {
    setState(() {
      _currentView = viewType;
      _controller.setViewType(viewType);
    });
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
            if (data.appointment.subtitle != null) ...[
              Text(data.appointment.subtitle!),
              SizedBox(height: 8),
            ],
            Text(
              'Resource: ${data.resource.name}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Time: ${_formatTime(data.appointment.startTime)} - '
              '${_formatTime(data.appointment.endTime)}',
            ),
            SizedBox(height: 8),
            Text(
              'Duration: ${data.appointment.duration.inMinutes} minutes',
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
        ],
      ),
    );
  }

  void _editAppointment(CalendarAppointment appointment) {
    // Implement edit functionality
    print('Edit appointment: ${appointment.id}');
  }

  void _createAppointment(CellTapData data) {
    final endTime = data.dateTime.add(Duration(hours: 1));

    showDialog(
      context: context,
      builder: (context) => CreateAppointmentDialog(
        resource: data.resource,
        startTime: data.dateTime,
        endTime: endTime,
        onSave: (appointment) {
          _controller.addAppointment(appointment);
        },
      ),
    );
  }

  void _handleDragEnd(AppointmentDragData data) {
    // Check for conflicts
    if (!_controller.isTimeSlotAvailable(
      resourceId: data.newResource.id,
      startTime: data.newStartTime,
      endTime: data.newEndTime,
      excludeAppointmentId: data.appointment.id,
    )) {
      _showConflictDialog();
      return;
    }

    // Update appointment
    final updated = (data.appointment as DefaultAppointment).copyWith(
      resourceId: data.newResource.id,
      startTime: data.newStartTime,
      endTime: data.newEndTime,
    );

    _controller.updateAppointment(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Appointment moved to ${data.newResource.name}'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showConflictDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Scheduling Conflict'),
        content: Text('This time slot is already booked.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
           '${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Team Calendar'),
        actions: [
          // View type selector
          PopupMenuButton<CalendarViewType>(
            icon: Icon(Icons.view_module),
            onSelected: _changeView,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: CalendarViewType.day,
                child: Text('Day View'),
              ),
              PopupMenuItem(
                value: CalendarViewType.week,
                child: Text('Week View'),
              ),
              PopupMenuItem(
                value: CalendarViewType.month,
                child: Text('Month View'),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.today),
            onPressed: () => _controller.goToToday(),
            tooltip: 'Go to Today',
          ),
        ],
      ),
      body: Column(
        children: [
          // Navigation bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left),
                  onPressed: () => _controller.previous(),
                ),
                Text(
                  _controller.getViewPeriodDescription(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right),
                  onPressed: () => _controller.next(),
                ),
              ],
            ),
          ),

          // Calendar
          Expanded(
            child: CalendarView(
              controller: _controller,
              theme: CalendarTheme(
                // Customize colors
                todayHighlightColor: Colors.blue,
                currentTimeIndicatorColor: Colors.red,
                weekendColor: Color(0xFFFFF8E1),
                
                // Customize formats
                timeFormat: 'HH:mm',
                weekdayFormat: 'EEE',
                
                // Customize spacing
                appointmentPadding: EdgeInsets.all(6),
                appointmentMargin: EdgeInsets.only(right: 4, bottom: 2),
              ),
              onAppointmentTap: _showAppointmentDetails,
              onCellTap: _createAppointment,
              onAppointmentDragEnd: _handleDragEnd,
              onResourceHeaderTap: (data) {
                print('Resource header tapped: ${data.resource.name}');
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Quick create
          _createAppointment(
            CellTapData(
              resource: _controller.resources.first,
              dateTime: DateTime.now(),
              globalPosition: Offset.zero,
            ),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Create Appointment',
      ),
    );
  }
}

// Create Appointment Dialog
class CreateAppointmentDialog extends StatefulWidget {
  final CalendarResource resource;
  final DateTime startTime;
  final DateTime endTime;
  final Function(CalendarAppointment) onSave;

  const CreateAppointmentDialog({
    Key? key,
    required this.resource,
    required this.startTime,
    required this.endTime,
    required this.onSave,
  }) : super(key: key);

  @override
  _CreateAppointmentDialogState createState() =>
      _CreateAppointmentDialogState();
}

class _CreateAppointmentDialogState extends State<CreateAppointmentDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late DateTime _startTime;
  late DateTime _endTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _subtitleController = TextEditingController();
    _startTime = widget.startTime;
    _endTime = widget.endTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final appointment = DefaultAppointment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        resourceId: widget.resource.id,
        title: _titleController.text,
        subtitle: _subtitleController.text.isEmpty
            ? null
            : _subtitleController.text,
        startTime: _startTime,
        endTime: _endTime,
        color: widget.resource.color ?? Colors.blue,
      );

      widget.onSave(appointment);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create Appointment'),
      content: Form(
        key: _formKey,
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
              controller: _subtitleController,
              decoration: InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Resource: '),
                Text(
                  widget.resource.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text('Time: '),
                Text(
                  '${_formatTime(_startTime)} - ${_formatTime(_endTime)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: Text('Save'),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
           '${time.minute.toString().padLeft(2, '0')}';
  }
}
```

## Running the Example

1. Create a new Flutter project:
```bash
flutter create calendar_example
cd calendar_example
```

2. Add dependencies to `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  timely_x: ^1.0.0
  intl: ^0.18.0
```

3. Replace `lib/main.dart` with the code above

4. Run the app:
```bash
flutter run
```

## Features Demonstrated

This example shows:

✅ **Multiple view types** - Day, Week, and Month views  
✅ **Sample data** - Pre-populated resources and appointments  
✅ **Navigation** - Previous, Next, and Today buttons  
✅ **Interactions** - Tap to view details, tap cells to create  
✅ **Drag and drop** - Move appointments between resources  
✅ **Conflict detection** - Prevents double-booking  
✅ **Customization** - Custom theme with colors and formats  
✅ **Dialogs** - Appointment details and creation  

## Next Steps

Try customizing:

1. **Theme** - Change colors and styling
2. **Builders** - Replace widgets with custom implementations
3. **Data** - Connect to your backend
4. **Features** - Add edit, delete, and more functionality

See the full documentation for more examples and advanced features!