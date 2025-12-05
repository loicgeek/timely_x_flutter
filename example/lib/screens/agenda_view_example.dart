// example/lib/screens/agenda_view_example.dart

import 'package:flutter/material.dart';
import 'package:timely_x/timely_x.dart';

/// Complete example demonstrating all agenda view features
class AgendaViewExample extends StatefulWidget {
  const AgendaViewExample({super.key});

  @override
  State<AgendaViewExample> createState() => _AgendaViewExampleState();
}

class _AgendaViewExampleState extends State<AgendaViewExample> {
  late CalendarController _controller;
  AgendaGroupingMode _groupingMode = AgendaGroupingMode.byDate;
  int _daysToShow = 7;
  bool _compactMode = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
    _loadSampleData();
  }

  void _initializeController() {
    _controller = CalendarController(
      config: CalendarConfig(
        viewType: CalendarViewType.agenda,
        agendaConfig: AgendaViewConfig(
          groupingMode: _groupingMode,
          daysToShow: _daysToShow,
          compactMode: _compactMode,
          showResourceAvatar: true,
          showAppointmentTime: true,
          showAppointmentDuration: true,
        ),
      ),
    );
  }

  void _loadSampleData() {
    // Sample resources
    final resources = [
      DefaultResource(
        id: '1',
        name: 'Dr. Sarah Smith',
        avatarUrl: 'https://i.pravatar.cc/150?img=1',
        color: Colors.blue,
        category: 'Cardiology',
      ),
      DefaultResource(
        id: '2',
        name: 'Dr. John Jones',
        avatarUrl: 'https://i.pravatar.cc/150?img=2',
        color: Colors.green,
        category: 'General Practice',
      ),
      DefaultResource(
        id: '3',
        name: 'Dr. Emily Davis',
        avatarUrl: 'https://i.pravatar.cc/150?img=3',
        color: Colors.orange,
        category: 'Pediatrics',
      ),
    ];

    // Sample appointments
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final appointments = [
      // Today
      DefaultAppointment(
        id: '1',
        resourceId: '1',
        title: 'Patient Consultation',
        subtitle: 'Room 101',
        startTime: today.add(const Duration(hours: 9)),
        endTime: today.add(const Duration(hours: 10)),
        color: Colors.blue,
        status: 'confirmed',
      ),
      DefaultAppointment(
        id: '2',
        resourceId: '2',
        title: 'Follow-up Appointment',
        subtitle: 'Room 202',
        startTime: today.add(const Duration(hours: 10)),
        endTime: today.add(const Duration(hours: 10, minutes: 30)),
        color: Colors.green,
        status: 'confirmed',
      ),
      DefaultAppointment(
        id: '3',
        resourceId: '1',
        title: 'Surgery Consultation',
        subtitle: 'Room 101',
        startTime: today.add(const Duration(hours: 14)),
        endTime: today.add(const Duration(hours: 15, minutes: 30)),
        color: Colors.blue,
        status: 'pending',
      ),

      // Tomorrow
      DefaultAppointment(
        id: '4',
        resourceId: '3',
        title: 'Child Checkup',
        subtitle: 'Room 303',
        startTime: today.add(const Duration(days: 1, hours: 9)),
        endTime: today.add(const Duration(days: 1, hours: 10)),
        color: Colors.orange,
        status: 'confirmed',
      ),
      DefaultAppointment(
        id: '5',
        resourceId: '2',
        title: 'Annual Physical',
        subtitle: 'Room 202',
        startTime: today.add(const Duration(days: 1, hours: 11)),
        endTime: today.add(const Duration(days: 1, hours: 12)),
        color: Colors.green,
        status: 'confirmed',
      ),

      // Day after tomorrow
      DefaultAppointment(
        id: '6',
        resourceId: '1',
        title: 'Emergency Consultation',
        subtitle: 'ER',
        startTime: today.add(const Duration(days: 2, hours: 8)),
        endTime: today.add(const Duration(days: 2, hours: 9)),
        color: Colors.red,
        status: 'urgent',
      ),
      DefaultAppointment(
        id: '7',
        resourceId: '3',
        title: 'Vaccination',
        subtitle: 'Room 303',
        startTime: today.add(const Duration(days: 2, hours: 10)),
        endTime: today.add(const Duration(days: 2, hours: 10, minutes: 15)),
        color: Colors.orange,
        status: 'confirmed',
      ),
    ];

    _controller.updateResources(resources);
    _controller.updateAppointments(appointments);
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
        title: const Text('Agenda View Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildControlBar(),
          const Divider(height: 1),
          Expanded(
            child: CalendarView(
              controller: _controller,
              config: CalendarConfig(
                viewType: CalendarViewType.agenda,
                agendaConfig: AgendaViewConfig(
                  groupingMode: _groupingMode,
                  daysToShow: _daysToShow,
                  compactMode: _compactMode,
                  showResourceAvatar: true,
                  showAppointmentTime: true,
                  showAppointmentDuration: true,
                ),
              ),
              theme: CalendarTheme(
                agendaItemBorderRadius: 8.0,
                agendaItemMargin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                agendaItemShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              onAppointmentTap: (data) {
                _showAppointmentDetails(data.appointment, data.resource);
              },
              onAppointmentLongPress: (data) {
                _showAppointmentOptions(data.appointment);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAppointment,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _controller.getAgendaViewPeriodDescription(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_controller.filteredAppointments.length} appointments',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              _controller.goToToday();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              _controller.previousAgendaPeriod(_daysToShow);
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              _controller.nextAgendaPeriod(_daysToShow);
            },
          ),
          const Spacer(),
          Text(
            _getGroupingModeLabel(_groupingMode),
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agenda Settings'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Grouping Mode',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButton<AgendaGroupingMode>(
                  value: _groupingMode,
                  isExpanded: true,
                  items: AgendaGroupingMode.values.map((mode) {
                    return DropdownMenuItem(
                      value: mode,
                      child: Text(_getGroupingModeLabel(mode)),
                    );
                  }).toList(),
                  onChanged: (mode) {
                    if (mode != null) {
                      setState(() {
                        _groupingMode = mode;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Days to Show',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButton<int>(
                  value: _daysToShow,
                  isExpanded: true,
                  items: [1, 3, 7, 14, 30].map((days) {
                    return DropdownMenuItem(
                      value: days,
                      child: Text('$days day${days > 1 ? 's' : ''}'),
                    );
                  }).toList(),
                  onChanged: (days) {
                    if (days != null) {
                      setState(() {
                        _daysToShow = days;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Compact Mode'),
                  value: _compactMode,
                  onChanged: (value) {
                    setState(() {
                      _compactMode = value ?? false;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _applySettings();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _applySettings() {
    setState(() {
      _controller = CalendarController(
        config: CalendarConfig(
          viewType: CalendarViewType.agenda,
          agendaConfig: AgendaViewConfig(
            groupingMode: _groupingMode,
            daysToShow: _daysToShow,
            compactMode: _compactMode,
            showResourceAvatar: true,
            showAppointmentTime: true,
            showAppointmentDuration: true,
          ),
        ),
      );
      _loadSampleData();
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Resource'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: _controller.resources.map((resource) {
              return CheckboxListTile(
                title: Text(resource.name),
                subtitle: Text(resource.category ?? ''),
                secondary: CircleAvatar(
                  backgroundImage: NetworkImage(resource.avatarUrl!),
                ),
                value: _controller.isResourceFiltered(resource.id),
                onChanged: (_) {
                  setState(() {
                    _controller.toggleResourceFilter(resource.id);
                  });
                  Navigator.pop(context);
                  _showFilterDialog(); // Reopen to show updated state
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _controller.clearResourceFilter();
              });
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showAppointmentDetails(
    CalendarAppointment appointment,
    CalendarResource resource,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appointment.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.access_time),
              title: Text(
                '${_formatDateTime(appointment.startTime)} - '
                '${_formatTime(appointment.endTime)}',
              ),
              contentPadding: EdgeInsets.zero,
            ),
            if (appointment.subtitle != null)
              ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(appointment.subtitle!),
                contentPadding: EdgeInsets.zero,
              ),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(resource.avatarUrl!),
              ),
              title: Text(resource.name),
              subtitle: Text(resource.category ?? ''),
              contentPadding: EdgeInsets.zero,
            ),
            if (appointment.status != null)
              Chip(
                label: Text(appointment.status!),
                backgroundColor: _getStatusColor(appointment.status!),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _editAppointment(appointment);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  void _showAppointmentOptions(CalendarAppointment appointment) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit'),
            onTap: () {
              Navigator.pop(context);
              _editAppointment(appointment);
            },
          ),
          ListTile(
            leading: const Icon(Icons.content_copy),
            title: const Text('Duplicate'),
            onTap: () {
              Navigator.pop(context);
              _duplicateAppointment(appointment);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _deleteAppointment(appointment);
            },
          ),
        ],
      ),
    );
  }

  void _addAppointment() {
    // Implementation for adding appointment
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add appointment dialog would open here')),
    );
  }

  void _editAppointment(CalendarAppointment appointment) {
    // Implementation for editing appointment
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit appointment: ${appointment.title}')),
    );
  }

  void _duplicateAppointment(CalendarAppointment appointment) {
    // Implementation for duplicating appointment
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Duplicate appointment: ${appointment.title}')),
    );
  }

  void _deleteAppointment(CalendarAppointment appointment) {
    setState(() {
      _controller.removeAppointment(appointment.id);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Deleted: ${appointment.title}')));
  }

  String _getGroupingModeLabel(AgendaGroupingMode mode) {
    switch (mode) {
      case AgendaGroupingMode.chronological:
        return 'Chronological';
      case AgendaGroupingMode.byDate:
        return 'By Date';
      case AgendaGroupingMode.byResource:
        return 'By Resource';
      case AgendaGroupingMode.byDateThenResource:
        return 'By Date > Resource';
      case AgendaGroupingMode.byResourceThenDate:
        return 'By Resource > Date';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green.shade100;
      case 'pending':
        return Colors.orange.shade100;
      case 'cancelled':
        return Colors.red.shade100;
      case 'urgent':
        return Colors.red.shade200;
      default:
        return Colors.grey.shade100;
    }
  }
}
