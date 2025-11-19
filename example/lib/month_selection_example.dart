// Example: Month View with Multi-Date Selection
//
// This example demonstrates how to use the multi-date selection feature
// in the month calendar view.

import 'package:flutter/material.dart';
import 'package:calendar2/calendar2.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar Multi-Date Selection',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const CalendarPage(),
    );
  }
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late CalendarController _controller;
  DateSelectionMode _selectionMode = DateSelectionMode.single;
  Set<DateTime> _selectedDates = {};
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();
    _controller = CalendarController(
      config: CalendarConfig(
        viewType: CalendarViewType.month,
        dateSelectionMode: _selectionMode,
        firstDayOfWeek: DateTime.sunday,
      ),
    );

    // Add some sample resources
    _controller.updateResources([
      DefaultResource(id: '1', name: 'Conference Room A', color: Colors.blue),
      DefaultResource(id: '2', name: 'Conference Room B', color: Colors.green),
    ]);

    // Add some sample appointments
    final now = DateTime.now();
    _controller.updateAppointments([
      DefaultAppointment(
        id: '1',
        resourceId: '1',
        title: 'Team Meeting',
        startTime: DateTime(now.year, now.month, now.day, 10, 0),
        endTime: DateTime(now.year, now.month, now.day, 11, 30),
        color: Colors.blue,
      ),
      DefaultAppointment(
        id: '2',
        resourceId: '2',
        title: 'Client Presentation',
        startTime: DateTime(now.year, now.month, now.day, 14, 0),
        endTime: DateTime(now.year, now.month, now.day, 15, 30),
        color: Colors.green,
      ),
    ]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _changeSelectionMode(DateSelectionMode mode) {
    setState(() {
      _selectionMode = mode;
      _controller.updateConfig(
        _controller.config.copyWith(dateSelectionMode: mode),
      );
      // Clear selection when changing mode
      _controller.clearDateSelection();
      _selectedDates.clear();
      _rangeStart = null;
      _rangeEnd = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi-Date Selection Calendar'),
        actions: [
          // Navigation buttons
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () => _controller.goToToday(),
            tooltip: 'Today',
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _controller.previous(),
            tooltip: 'Previous Month',
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _controller.next(),
            tooltip: 'Next Month',
          ),
        ],
      ),
      body: Column(
        children: [
          // Selection mode controls
          _buildSelectionModeControls(),

          // Current period display
          Container(
            padding: const EdgeInsets.all(16),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Text(
                  _controller.getViewPeriodDescription(),
                  style: Theme.of(context).textTheme.titleLarge,
                );
              },
            ),
          ),

          // Selection status display
          _buildSelectionStatus(),

          // Calendar view
          Expanded(
            child: CalendarView(
              controller: _controller,
              config: CalendarConfig(
                viewType: CalendarViewType.month,
                dateSelectionMode: _selectionMode,
              ),
              theme: CalendarTheme(
                // Customize selection colors
                selectedDateBackgroundColor: Colors.blue,
                selectedDateTextColor: Colors.white,
                selectedDateBorderColor: Colors.blue.shade700,
                rangeSelectionColor: Colors.blue.shade100,
                rangeSelectionBorderColor: Colors.blue.shade300,
              ),
              onDateSelectionChanged: (selectedDates) {
                setState(() {
                  _selectedDates = selectedDates;
                });
                print('Selected dates: ${selectedDates.length}');
              },
              onDateRangeChanged: (start, end, selectedDates) {
                setState(() {
                  _rangeStart = start;
                  _rangeEnd = end;
                  _selectedDates = selectedDates;
                });
                if (start != null && end != null) {
                  print('Range: $start to $end (${selectedDates.length} days)');
                }
              },
              onAppointmentTap: (data) {
                print('Tapped: ${data.appointment.title}');
              },
            ),
          ),

          // Action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildSelectionModeControls() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey.shade100,
      child: Row(
        children: [
          const Text(
            'Selection Mode: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('None'),
            selected: _selectionMode == DateSelectionMode.none,
            onSelected: (_) => _changeSelectionMode(DateSelectionMode.none),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Single'),
            selected: _selectionMode == DateSelectionMode.single,
            onSelected: (_) => _changeSelectionMode(DateSelectionMode.single),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Multiple'),
            selected: _selectionMode == DateSelectionMode.multiple,
            onSelected: (_) => _changeSelectionMode(DateSelectionMode.multiple),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Range'),
            selected: _selectionMode == DateSelectionMode.range,
            onSelected: (_) => _changeSelectionMode(DateSelectionMode.range),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionStatus() {
    if (_selectionMode == DateSelectionMode.none || _selectedDates.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.blue.shade50,
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getSelectionStatusText(),
              style: TextStyle(color: Colors.blue.shade900),
            ),
          ),
        ],
      ),
    );
  }

  String _getSelectionStatusText() {
    switch (_selectionMode) {
      case DateSelectionMode.none:
        return 'Selection disabled';
      case DateSelectionMode.single:
        if (_selectedDates.isEmpty) return 'No date selected';
        final date = _selectedDates.first;
        return 'Selected: ${date.month}/${date.day}/${date.year}';
      case DateSelectionMode.multiple:
        return '${_selectedDates.length} dates selected';
      case DateSelectionMode.range:
        if (_rangeStart == null) {
          return 'Click to select range start';
        } else if (_rangeEnd == null) {
          return 'Click to select range end';
        } else {
          return 'Range: ${_rangeStart!.month}/${_rangeStart!.day} - ${_rangeEnd!.month}/${_rangeEnd!.day} (${_selectedDates.length} days)';
        }
    }
  }

  Widget _buildActionButtons() {
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
      child: Row(
        children: [
          if (_selectionMode != DateSelectionMode.none) ...[
            ElevatedButton.icon(
              onPressed: _selectedDates.isEmpty
                  ? null
                  : () {
                      _controller.clearDateSelection();
                      setState(() {
                        _selectedDates.clear();
                        _rangeStart = null;
                        _rangeEnd = null;
                      });
                    },
              icon: const Icon(Icons.clear),
              label: const Text('Clear Selection'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _selectedDates.isEmpty
                  ? null
                  : () {
                      // Process selected dates
                      _showSelectedDatesDialog();
                    },
              icon: const Icon(Icons.check),
              label: const Text('Confirm'),
            ),
          ],
          const Spacer(),
          if (_selectionMode == DateSelectionMode.multiple) ...[
            OutlinedButton.icon(
              onPressed: () {
                // Example: Select all weekends in current month
                _selectAllWeekends();
              },
              icon: const Icon(Icons.weekend),
              label: const Text('Select Weekends'),
            ),
          ],
        ],
      ),
    );
  }

  void _showSelectedDatesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selected Dates'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _selectedDates.length,
            itemBuilder: (context, index) {
              final date = _selectedDates.elementAt(index);
              return ListTile(
                leading: Icon(
                  Icons.calendar_today,
                  color: Colors.blue.shade700,
                ),
                title: Text('${date.month}/${date.day}/${date.year}'),
                subtitle: Text(_getDayOfWeek(date)),
              );
            },
          ),
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

  String _getDayOfWeek(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  void _selectAllWeekends() {
    final monthStart = _controller.viewStartDate;
    final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 0);

    final weekends = <DateTime>[];
    DateTime current = monthStart;

    while (current.isBefore(monthEnd) || current.isAtSameMomentAs(monthEnd)) {
      if (current.weekday == DateTime.saturday ||
          current.weekday == DateTime.sunday) {
        weekends.add(current);
      }
      current = current.add(const Duration(days: 1));
    }

    _controller.setSelectedDates(weekends);
    setState(() {
      _selectedDates = _controller.selectedDates;
    });
  }
}
