# Features Overview

This document provides a comprehensive overview of all features available in TimelyX.

## Table of Contents

1. [View Types](#view-types)
2. [Interactions](#interactions)
3. [Customization](#customization)
4. [Data Management](#data-management)
5. [Layout Options](#layout-options)
6. [Performance Features](#performance-features)
7. [Developer Features](#developer-features)

---

## View Types

### 📅 Day View

Display all resources for a single day with detailed time slots.

**Best for:**
- Detailed daily scheduling
- Professional services (doctors, consultants)
- Equipment booking for a specific day

**Features:**
- Scrollable resource columns
- Adjustable time range (e.g., 8 AM - 6 PM)
- Configurable hour height
- Current time indicator
- Zebra striping for hour blocks

**Example:**
```dart
CalendarController(
  config: CalendarConfig(
    viewType: CalendarViewType.day,
    dayStartHour: 8,
    dayEndHour: 18,
    hourHeight: 100.0,
  ),
)
```

---

### 📆 Week View

Display multiple days across multiple resources simultaneously.

**Best for:**
- Team scheduling
- Weekly planning
- Multi-day event management
- Conference room booking

**Features:**
- Two layout modes (resources-first or days-first)
- Configurable number of days (not limited to 7)
- Synchronized scrolling
- Weekend highlighting
- Responsive column sizing

**Layout Modes:**

#### Resources First
Groups by resource, then shows days for each resource.
```
Resource 1 [Mon] [Tue] [Wed] [Thu] [Fri]
Resource 2 [Mon] [Tue] [Wed] [Thu] [Fri]
```

```dart
CalendarConfig(
  viewType: CalendarViewType.week,
  weekViewLayout: WeekViewLayout.resourcesFirst,
)
```

#### Days First
Groups by day, then shows resources for each day.
```
Monday    [Resource 1] [Resource 2] [Resource 3]
Tuesday   [Resource 1] [Resource 2] [Resource 3]
```

```dart
CalendarConfig(
  viewType: CalendarViewType.week,
  weekViewLayout: WeekViewLayout.daysFirst,
)
```

---

### 📊 Month View

Monthly calendar overview with appointment summaries.

**Best for:**
- High-level planning
- Monthly overview
- Date selection
- Availability checking

**Features:**
- Configurable cell aspect ratio
- Max visible appointments per cell
- "+X more" indicator
- Other month day styling
- Weekend highlighting

**Example:**
```dart
CalendarController(
  config: CalendarConfig(
    viewType: CalendarViewType.month,
  ),
)

CalendarTheme(
  monthViewMaxVisibleAppointments: 3,
  monthViewCellAspectRatio: 1.2,
)
```

---

## Interactions

### 👆 Tap Interactions

#### Appointment Tap
```dart
onAppointmentTap: (data) {
  print('Tapped: ${data.appointment.title}');
  print('Resource: ${data.resource.name}');
  print('Position: ${data.globalPosition}');
  
  // Show details dialog
  showDialog(
    context: context,
    builder: (context) => AppointmentDetailsDialog(
      appointment: data.appointment,
    ),
  );
}
```

#### Cell Tap
Create new appointments by tapping empty cells:
```dart
onCellTap: (data) {
  print('Cell tapped at: ${data.dateTime}');
  print('Resource: ${data.resource.name}');
  print('Existing appointments: ${data.appointments.length}');
  
  // Quick create appointment
  showQuickCreateDialog(
    context: context,
    resource: data.resource,
    startTime: data.dateTime,
  );
}
```

#### Header Taps
```dart
onResourceHeaderTap: (data) {
  print('Resource tapped: ${data.resource.name}');
  showResourceDetails(data.resource);
}

onDateHeaderTap: (data) {
  print('Date tapped: ${data.date}');
  controller.goToDate(data.date);
}
```

---

### 🖱️ Long Press Interactions

#### Appointment Long Press
```dart
onAppointmentLongPress: (data) {
  showModalBottomSheet(
    context: context,
    builder: (context) => AppointmentOptionsSheet(
      appointment: data.appointment,
      onEdit: () => editAppointment(data.appointment),
      onDelete: () => deleteAppointment(data.appointment),
      onDuplicate: () => duplicateAppointment(data.appointment),
    ),
  );
}
```

#### Cell Long Press
```dart
onCellLongPress: (data) {
  showDialog(
    context: context,
    builder: (context) => CreateAppointmentDialog(
      resource: data.resource,
      startTime: data.dateTime,
    ),
  );
}
```

---

### 🖱️ Secondary Tap (Right-Click / Long Press)

Desktop/Web right-click or mobile long-press:
```dart
onAppointmentSecondaryTap: (data) {
  showContextMenu(
    context: context,
    position: data.globalPosition,
    items: [
      ContextMenuItem('Edit', Icons.edit, () => edit()),
      ContextMenuItem('Delete', Icons.delete, () => delete()),
      ContextMenuItem('Duplicate', Icons.copy, () => duplicate()),
    ],
  );
}
```

---

### 🔄 Drag and Drop

Full drag and drop support with visual feedback:

#### Enable Drag and Drop
```dart
CalendarConfig(
  enableDragAndDrop: true,
  enableSnapping: true,
  snapToMinutes: 15,
)
```

#### Handle Drag End
```dart
onAppointmentDragEnd: (data) {
  print('Dragged from: ${data.oldStartTime}');
  print('Dragged to: ${data.newStartTime}');
  print('Resource changed: ${data.resourceChanged}');
  print('Time difference: ${data.timeDifference}');
  
  // Validate and update
  if (controller.isTimeSlotAvailable(
    resourceId: data.newResource.id,
    startTime: data.newStartTime,
    endTime: data.newEndTime,
    excludeAppointmentId: data.appointment.id,
  )) {
    // Update appointment
    final updated = data.appointment.copyWith(
      resourceId: data.newResource.id,
      startTime: data.newStartTime,
      endTime: data.newEndTime,
    );
    controller.updateAppointment(updated);
    
    // Save to backend
    await saveAppointment(updated);
  } else {
    // Show conflict
    showConflictDialog();
  }
}
```

#### Customize Drag Appearance
```dart
CalendarTheme(
  dragFeedbackOpacity: 0.8,
  dragPlaceholderOpacity: 0.3,
  dragPlaceholderBorderColor: Colors.blue,
  dragPlaceholderBorderWidth: 2.0,
)
```

---

### 📏 Resize

Resize appointments to change duration:

```dart
CalendarConfig(
  enableResize: true,
)

onAppointmentResizeEnd: (data) {
  print('Resized from: ${data.oldStartTime} - ${data.oldEndTime}');
  print('Resized to: ${data.newStartTime} - ${data.newEndTime}');
  print('Duration change: ${data.durationDifference}');
  print('Resize edge: ${data.resizeEdge}'); // top or bottom
  
  // Update appointment
  final updated = data.appointment.copyWith(
    startTime: data.newStartTime,
    endTime: data.newEndTime,
  );
  controller.updateAppointment(updated);
}
```

---

## Customization

### 🎨 Complete Theme System

65+ customization properties organized into categories:

#### Colors (16 properties)
```dart
CalendarTheme(
  // Grid and lines
  gridLineColor: Color(0xFFE5E5E5),
  hourLineColor: Color(0xFFCCCCCC),
  zebraStripeOdd: Color(0xFFFAFAFA),
  zebraStripeEven: Colors.white,
  
  // Highlights
  todayHighlightColor: Colors.blue,
  currentTimeIndicatorColor: Colors.red,
  currentDayHighlight: Color(0xFFE3F2FD),
  selectedSlotColor: Color(0xFFBBDEFB),
  hoverColor: Color(0xFFF5F5F5),
  
  // Weekends
  weekendColor: Color(0xFFFAFAFA),
  weekendTextColor: Colors.red,
  
  // Backgrounds
  headerBackgroundColor: Colors.white,
  gridBackgroundColor: Colors.white,
  timeColumnBackgroundColor: Colors.white,
  
  // Month view
  monthViewHeaderBackgroundColor: Color(0xFFF5F5F5),
  otherMonthDayColor: Color(0xFFBDBDBD),
)
```

#### Text Styles (10 properties)
```dart
CalendarTheme(
  timeTextStyle: TextStyle(fontSize: 13, color: Colors.grey[700]),
  dateTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
  weekdayTextStyle: TextStyle(fontSize: 12, color: Colors.grey[600]),
  resourceNameStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
  appointmentTextStyle: TextStyle(fontSize: 13, color: Colors.white),
  appointmentSubtitleStyle: TextStyle(fontSize: 11, color: Colors.white70),
  appointmentTimeStyle: TextStyle(fontSize: 10, color: Colors.white70),
  monthViewDayTextStyle: TextStyle(fontSize: 14),
  monthViewAppointmentTextStyle: TextStyle(fontSize: 10, color: Colors.white),
  monthViewMoreTextStyle: TextStyle(fontSize: 10, color: Colors.grey),
)
```

#### Date Formats (6 properties)
```dart
CalendarTheme(
  timeFormat: 'HH:mm',              // 24-hour: "14:30"
  dateFormat: 'd',                  // Day: "15"
  weekdayFormat: 'E',               // Weekday: "Mon"
  monthFormat: 'MMMM yyyy',         // "November 2025"
  dateHeaderFormat: 'MMMM d, yyyy', // "November 18, 2025"
  weekPeriodFormat: 'MMM d',        // "Nov 18"
)
```

#### Spacing (7 properties)
```dart
CalendarTheme(
  resourceHeaderPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
  dateHeaderPadding: EdgeInsets.symmetric(vertical: 8),
  appointmentPadding: EdgeInsets.all(4),
  appointmentMargin: EdgeInsets.only(right: 4, bottom: 2),
  timeLabelPadding: EdgeInsets.only(top: 4, right: 8),
  resourceAvatarRadius: 20.0,
  appointmentSpacing: 2.0,
)
```

---

### 🛠️ Custom Builders

Replace any widget with your custom implementation:

#### Custom Resource Header
```dart
resourceHeaderBuilder: (context, resource, width, isHovered) {
  return Container(
    width: width,
    padding: EdgeInsets.all(16),
    color: isHovered ? Colors.blue[50] : Colors.white,
    child: Column(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundImage: NetworkImage(resource.avatarUrl!),
        ),
        SizedBox(height: 8),
        Text(
          resource.name,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          'Available',
          style: TextStyle(fontSize: 12, color: Colors.green),
        ),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => bookResource(resource),
          child: Text('Book'),
        ),
      ],
    ),
  );
}
```

#### Custom Appointment Widget
```dart
appointmentBuilder: (context, appointment, resource, rect, isSelected) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          appointment.color,
          appointment.color.withOpacity(0.7),
        ],
      ),
      borderRadius: BorderRadius.circular(12),
      border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
      boxShadow: [
        BoxShadow(
          color: appointment.color.withOpacity(0.3),
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
      ],
    ),
    padding: EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.event, color: Colors.white, size: 16),
            SizedBox(width: 4),
            Expanded(
              child: Text(
                appointment.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          'with ${resource.name}',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
        if (rect.height > 60) ...[
          SizedBox(height: 4),
          Text(
            '${DateFormat('h:mm a').format(appointment.startTime)} - '
            '${DateFormat('h:mm a').format(appointment.endTime)}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
            ),
          ),
        ],
      ],
    ),
  );
}
```

---

## Data Management

### CRUD Operations

#### Create
```dart
final appointment = DefaultAppointment(
  id: 'apt1',
  resourceId: 'user1',
  title: 'Team Meeting',
  startTime: DateTime.now().add(Duration(hours: 1)),
  endTime: DateTime.now().add(Duration(hours: 2)),
  color: Colors.blue,
);

controller.addAppointment(appointment);
```

#### Read
```dart
// Get all appointments
final allAppointments = controller.appointments;

// Get appointments for specific resource
final resourceAppointments = controller.getAppointmentsForResource('user1');

// Get appointments for specific date
final dateAppointments = controller.getAppointmentsForDate(DateTime.now());

// Get appointments for specific resource and date
final specificAppointments = controller.getAppointmentsForResourceDate(
  'user1',
  DateTime.now(),
);
```

#### Update
```dart
final updated = appointment.copyWith(
  title: 'Updated Meeting Title',
  startTime: DateTime.now().add(Duration(hours: 2)),
);

controller.updateAppointment(updated);
```

#### Delete
```dart
controller.removeAppointment('apt1');
```

---

### Conflict Detection

```dart
// Check if time slot is available
bool isAvailable = controller.isTimeSlotAvailable(
  resourceId: 'user1',
  startTime: proposedStart,
  endTime: proposedEnd,
  excludeAppointmentId: 'apt1', // Optional: exclude when updating
);

if (!isAvailable) {
  // Show conflict warning
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Scheduling Conflict'),
      content: Text('This time slot is already booked.'),
    ),
  );
}
```

---

### Custom Models

Extend base classes for your own models:

```dart
class Employee extends CalendarResource {
  final String department;
  final String email;
  final String phone;
  final bool isActive;
  
  Employee({
    required String id,
    required String name,
    required this.department,
    required this.email,
    required this.phone,
    this.isActive = true,
  });
  
  @override
  String get id => id;
  
  @override
  String get name => name;
  
  @override
  String? get category => department;
}

class Meeting extends CalendarAppointment {
  final String location;
  final List<String> attendees;
  final String meetingLink;
  final bool isRecurring;
  
  Meeting({
    required String id,
    required String resourceId,
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    required this.location,
    required this.attendees,
    required this.meetingLink,
    this.isRecurring = false,
  });
  
  @override
  String get id => id;
  
  @override
  String get resourceId => resourceId;
  
  @override
  String get title => title;
  
  @override
  DateTime get startTime => startTime;
  
  @override
  DateTime get endTime => endTime;
  
  @override
  String? get subtitle => location;
  
  @override
  Map<String, dynamic>? get customData => {
    'attendees': attendees,
    'meetingLink': meetingLink,
    'isRecurring': isRecurring,
  };
}
```

---

## Layout Options

### Responsive Column Sizing

```dart
CalendarConfig(
  minColumnWidth: 100.0,
  maxColumnWidth: 300.0,
  preferredColumnWidth: 180.0,
)
```

The calendar automatically calculates optimal column widths based on:
- Available viewport width
- Number of resources
- Number of visible days
- Min/max constraints

### Custom Number of Days

Not limited to full weeks:

```dart
CalendarConfig(
  viewType: CalendarViewType.week,
  numberOfDays: 5, // Show Monday-Friday only
)

// Or 14-day view
CalendarConfig(
  numberOfDays: 14,
)
```

---

## Performance Features

### Efficient Rendering

- **Virtualized scrolling**: Only visible items are rendered
- **Optimized overlap calculation**: Intelligent algorithm for positioning
- **Lazy loading**: Appointments loaded on demand
- **Debounced updates**: Prevents excessive rebuilds

### Memory Management

```dart
@override
void dispose() {
  controller.dispose(); // Always dispose controllers
  super.dispose();
}
```

---

## Developer Features

### Debug Information

```dart
// Get view period description
String period = controller.getViewPeriodDescription();
print('Viewing: $period'); // "Nov 18-24, 2025"

// Check controller state
print('Current date: ${controller.currentDate}');
print('View type: ${controller.viewType}');
print('Visible dates: ${controller.visibleDates}');
print('Resource count: ${controller.filteredResources.length}');
print('Appointment count: ${controller.appointments.length}');
```

### State Listening

```dart
controller.addListener(() {
  print('Calendar state changed!');
  setState(() {
    // Update UI
  });
});
```

### Type Safety

All models use abstract base classes for type safety:

```dart
abstract class CalendarResource {
  String get id;
  String get name;
  String? get avatarUrl;
  Color? get color;
}

abstract class CalendarAppointment {
  String get id;
  String get resourceId;
  DateTime get startTime;
  DateTime get endTime;
  String get title;
}
```

---

## Feature Comparison

| Feature | Day View | Week View | Month View |
|---------|----------|-----------|------------|
| Multiple resources | ✅ | ✅ | ✅ |
| Time slots | ✅ | ✅ | ❌ |
| Drag & drop | ✅ | ✅ | ❌ |
| Resize | ✅ | ✅ | ❌ |
| Current time indicator | ✅ | ✅ | ❌ |
| Overlap handling | ✅ | ✅ | ✅ |
| Weekend highlighting | N/A | ✅ | ✅ |
| Custom builders | ✅ | ✅ | ✅ |
| Responsive | ✅ | ✅ | ✅ |

---

For more details on any feature, see:
- [README.md](../README.md) - Main documentation
- [CUSTOMIZATION_GUIDE.md](CUSTOMIZATION_GUIDE.md) - Full customization guide
- [API Reference](../api/) - API documentation