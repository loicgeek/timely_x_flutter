# Project Structure

This document explains the organization of the TimelyX codebase.

## Directory Structure

```
timely_x/
├── lib/
│   ├── src/
│   │   ├── builders/          # Widget builders and delegates
│   │   │   ├── builder_delegates.dart
│   │   │   └── default_builders.dart
│   │   │
│   │   ├── controllers/       # State management
│   │   │   ├── calendar_controller.dart
│   │   │   └── scroll_sync_controller.dart
│   │   │
│   │   ├── gestures/          # Gesture detection
│   │   │   ├── appointment_gesture_detector.dart
│   │   │   └── grid_gesture_detector.dart
│   │   │
│   │   ├── models/            # Data models
│   │   │   ├── appointment_position.dart
│   │   │   ├── calendar_appointment.dart
│   │   │   ├── calendar_config.dart
│   │   │   ├── calendar_resource.dart
│   │   │   ├── calendar_theme.dart
│   │   │   ├── calendar_view_type.dart
│   │   │   ├── interaction_data.dart
│   │   │   └── week_view_layout.dart
│   │   │
│   │   ├── utils/             # Utility functions
│   │   │   ├── date_time_utils.dart
│   │   │   ├── overlap_calculator.dart
│   │   │   └── position_calculator.dart
│   │   │
│   │   └── widgets/           # UI components
│   │       ├── appointment_widget.dart
│   │       ├── calendar_view.dart
│   │       ├── date_header.dart
│   │       ├── day_view.dart
│   │       ├── grid_painter.dart
│   │       ├── month_view.dart
│   │       ├── resource_header.dart
│   │       ├── time_column.dart
│   │       └── week_view.dart
│   │
│   └── timely_x.dart  # Main export file
│
├── test/                      # Unit and widget tests
│   ├── controllers/
│   │   └── calendar_controller_test.dart
│   ├── models/
│   │   └── calendar_config_test.dart
│   ├── utils/
│   │   ├── date_time_utils_test.dart
│   │   └── overlap_calculator_test.dart
│   └── widgets/
│       └── calendar_view_test.dart
│
├── example/                   # Example application
│   ├── lib/
│   │   └── main.dart
│   └── pubspec.yaml
│
├── doc/                      # Documentation
│   ├── CUSTOMIZATION_GUIDE.md
│   ├── THEME_QUICK_REFERENCE.md
│   ├── MIGRATION_GUIDE.md
│   ├── FEATURES.md
│   └── EXAMPLE_APP.md
│
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
├── README.md
└── pubspec.yaml
```

---

## Core Modules

### 1. Builders (`lib/src/builders/`)

Responsible for building calendar widgets.

#### `builder_delegates.dart`
- Type definitions for custom builders
- Callback signatures for interactions
- Widget builder function types

```dart
typedef ResourceHeaderBuilder = Widget Function(
  BuildContext context,
  CalendarResource resource,
  double width,
  bool isHovered,
);
```

#### `default_builders.dart`
- Default implementations of all builders
- Uses theme properties for styling
- Provides fallback widgets

**Key Functions:**
- `resourceHeader()` - Builds resource headers
- `dateHeader()` - Builds date headers
- `timeLabel()` - Builds time labels
- `appointment()` - Builds appointment widgets
- `currentTimeIndicator()` - Builds time indicator

---

### 2. Controllers (`lib/src/controllers/`)

Manage calendar state and behavior.

#### `calendar_controller.dart`
**Purpose:** Main state management for the calendar

**Responsibilities:**
- Store and manage calendar data
- Handle navigation (next/previous/today)
- Manage view types
- CRUD operations for appointments
- Calculate visible dates
- Notify listeners of changes

**Key Properties:**
- `currentDate` - Currently displayed date
- `viewType` - Current view type
- `resources` - List of resources
- `appointments` - List of appointments
- `selectedAppointment` - Currently selected appointment

**Key Methods:**
- `next()` / `previous()` - Navigate
- `goToDate()` / `goToToday()` - Jump to date
- `setViewType()` - Change view
- `updateAppointments()` - Update data
- `isTimeSlotAvailable()` - Check conflicts

#### `scroll_sync_controller.dart`
**Purpose:** Synchronize scrolling across calendar sections

**Responsibilities:**
- Link horizontal scroll controllers
- Link vertical scroll controllers
- Prevent scroll loops
- Smooth scroll animations

**Key Methods:**
- `linkHorizontal()` / `unlinkHorizontal()`
- `linkVertical()` / `unlinkVertical()`
- `scrollToTime()` - Scroll to specific time
- `scrollToNow()` - Scroll to current time

---

### 3. Gestures (`lib/src/gestures/`)

Handle user interactions with gestures.

#### `appointment_gesture_detector.dart`
**Purpose:** Detect gestures on appointments

**Handles:**
- Tap detection
- Long press detection
- Secondary tap (right-click)
- Drag start/update/end
- Resize gestures

#### `grid_gesture_detector.dart`
**Purpose:** Detect gestures on calendar grid cells

**Handles:**
- Cell tap
- Cell long press
- Drag targets for drop operations
- Hover detection

---

### 4. Models (`lib/src/models/`)

Define data structures and types.

#### `calendar_appointment.dart`
**Abstract base class** for appointments

Required properties:
- `id` - Unique identifier
- `resourceId` - Associated resource
- `startTime` - Start date/time
- `endTime` - End date/time
- `title` - Display title

Optional properties:
- `subtitle` - Additional description
- `color` - Custom color
- `status` - Status string
- `customData` - Additional data

**Default implementation:** `DefaultAppointment`

#### `calendar_resource.dart`
**Abstract base class** for resources

Required properties:
- `id` - Unique identifier
- `name` - Display name

Optional properties:
- `avatarUrl` - Avatar image URL
- `color` - Resource color
- `isActive` - Active status
- `category` - Category/department
- `customData` - Additional data

**Default implementation:** `DefaultResource`

#### `calendar_config.dart`
**Configuration** for calendar behavior

**Categories:**
- View configuration (type, layout)
- Time range (start/end hour)
- Sizing (heights, widths)
- Features (drag, resize, snap)
- Display options (weekends, all-day)

**Key Methods:**
- `calculateColumnDimensions()` - Calculate column sizing

#### `calendar_theme.dart`
**Visual customization** with 65+ properties

**Categories:**
- Colors (16 properties)
- Text styles (10 properties)
- Date formats (6 properties)
- Spacing (7 properties)
- Month view (8 properties)
- Decorations (3 properties)
- Drag & drop (4 properties)

#### `appointment_position.dart`
**Position and layout** information for appointments

Properties:
- `appointment` - The appointment
- `rect` - Absolute position
- `overlapIndex` - Position in overlap group
- `totalOverlaps` - Total overlapping appointments
- `widthMultiplier` - Width adjustment
- `leftOffset` - Left offset

#### `interaction_data.dart`
**Data classes** for interaction callbacks

Classes:
- `AppointmentTapData`
- `AppointmentLongPressData`
- `AppointmentSecondaryTapData`
- `CellTapData`
- `AppointmentDragData`
- `AppointmentResizeData`
- `ResourceHeaderTapData`
- `DateHeaderTapData`

#### `calendar_view_type.dart`
**Enum** for view types

```dart
enum CalendarViewType {
  day,
  week,
  month,
}
```

#### `week_view_layout.dart`
**Enum** for week view layouts

```dart
enum WeekViewLayout {
  resourcesFirst,
  daysFirst,
}
```

---

### 5. Utils (`lib/src/utils/`)

Helper functions and calculations.

#### `date_time_utils.dart`
**Purpose:** Date and time operations

**Functions:**
- `getWeekStart()` - Get Monday of week
- `generateDateRange()` - Generate date list
- `snapToInterval()` - Snap to time interval
- `isSameDay()` - Compare dates
- `isToday()` - Check if today
- `isWeekend()` - Check if weekend
- `toDecimalHours()` - Convert to decimal
- `fromDecimalHours()` - Convert from decimal
- `calculateVerticalOffset()` - Calculate pixel offset
- `calculateTimeFromOffset()` - Calculate time from pixels
- `formatDate()` - Format with pattern
- `getDaysInMonth()` - Get days in month

#### `overlap_calculator.dart`
**Purpose:** Calculate overlapping appointment positions

**Algorithm:**
1. Sort appointments by start time
2. Find overlap groups
3. Assign columns using greedy algorithm
4. Calculate positions and widths
5. Expand appointments where possible

**Key Functions:**
- `calculatePositions()` - Main entry point
- `_findOverlapGroups()` - Group overlapping appointments
- `_calculateGroupPositions()` - Position within group

#### `position_calculator.dart`
**Purpose:** Calculate appointment positions in grid

**Functions:**
- Calculate absolute positions
- Handle different view types
- Account for column widths
- Calculate vertical offsets

---

### 6. Widgets (`lib/src/widgets/`)

UI components for the calendar.

#### `calendar_view.dart`
**Main widget** - Entry point for the calendar

**Responsibilities:**
- Switch between view types
- Pass configuration to views
- Handle theme application
- Coordinate callbacks

**Properties:**
- `controller` - Calendar controller
- `config` - Configuration
- `theme` - Visual theme
- All custom builders
- All callbacks

#### `day_view.dart`
**Day view implementation**

**Structure:**
```
┌─────────────┬─────────┬─────────┬─────────┐
│ Date Header │Resource1│Resource2│Resource3│
├─────────────┼─────────┼─────────┼─────────┤
│ 08:00       │         │         │         │
│ 09:00       │   📅    │         │         │
│ 10:00       │         │   📅    │   📅    │
│ ...         │         │         │         │
└─────────────┴─────────┴─────────┴─────────┘
```

**Features:**
- Horizontal scroll for resources
- Vertical scroll for time
- Synchronized scrolling
- Current time indicator

#### `week_view.dart`
**Week view implementation**

**Two layouts:**

**Resources First:**
```
┌──────┬─────┬─────┬─────┬─────┬─────┐
│      │ Mon │ Tue │ Wed │ Thu │ Fri │
├──────┼─────┼─────┼─────┼─────┼─────┤
│ Res1 │     │     │     │     │     │
│ Res2 │     │     │     │     │     │
└──────┴─────┴─────┴─────┴─────┴─────┘
```

**Days First:**
```
┌──────┬─────┬─────┬─────┐
│      │Res1 │Res2 │Res3 │
├──────┼─────┼─────┼─────┤
│ Mon  │     │     │     │
│ Tue  │     │     │     │
└──────┴─────┴─────┴─────┘
```

#### `month_view.dart`
**Month view implementation**

**Structure:**
```
┌─────┬─────┬─────┬─────┬─────┬─────┬─────┐
│ Mon │ Tue │ Wed │ Thu │ Fri │ Sat │ Sun │
├─────┼─────┼─────┼─────┼─────┼─────┼─────┤
│  1  │  2  │  3  │  4  │  5  │  6  │  7  │
│ 📅  │     │ 📅  │     │     │     │     │
├─────┼─────┼─────┼─────┼─────┼─────┼─────┤
│  8  │  9  │ 10  │ 11  │ 12  │ 13  │ 14  │
│     │ 📅  │     │ 📅  │     │     │     │
└─────┴─────┴─────┴─────┴─────┴─────┴─────┘
```

**Features:**
- Grid view layout
- Appointment summaries
- "+X more" indicator
- Weekend highlighting

#### `appointment_widget.dart`
**Individual appointment widget**

**Features:**
- Custom rendering
- Selection state
- Drag feedback
- Gesture detection

#### `resource_header.dart`
**Resource header component**

**Displays:**
- Avatar (image or initial)
- Resource name
- Category (optional)

**Features:**
- Hover state
- Tap detection
- Custom builder support

#### `date_header.dart`
**Date header component**

**Displays:**
- Weekday name
- Day number

**Features:**
- Today highlighting
- Weekend styling
- Custom format

#### `time_column.dart`
**Time column component**

**Displays:**
- Time labels at intervals
- Hour markers

**Features:**
- Synchronized scrolling
- Custom format
- Adjustable height

#### `grid_painter.dart`
**Custom painter** for grid background

**Draws:**
- Vertical column lines
- Horizontal time slot lines
- Hour separator lines (thicker)
- Zebra striping (alternating hours)

---

## Data Flow

```
User Interaction
       ↓
   GestureDetector
       ↓
   Callback (onTap, etc.)
       ↓
CalendarController
       ↓
  notifyListeners()
       ↓
  Calendar Rebuilds
       ↓
  Updated UI
```

## Testing Structure

```
test/
├── controllers/
│   └── calendar_controller_test.dart
│       - Navigation tests
│       - CRUD operation tests
│       - Conflict detection tests
│
├── models/
│   └── calendar_config_test.dart
│       - Configuration tests
│       - Column calculation tests
│
├── utils/
│   ├── date_time_utils_test.dart
│   │   - Date manipulation tests
│   │   - Format tests
│   └── overlap_calculator_test.dart
│       - Overlap detection tests
│       - Position calculation tests
│
└── widgets/
    └── calendar_view_test.dart
        - Widget rendering tests
        - Interaction tests
```

---

## Build & Export

### Main Export File

`lib/timely_x.dart` exports all public APIs:

```dart
library timely_x;

// Models
export 'src/models/calendar_appointment.dart';
export 'src/models/calendar_resource.dart';
export 'src/models/calendar_config.dart';
export 'src/models/calendar_theme.dart';
export 'src/models/calendar_view_type.dart';
export 'src/models/week_view_layout.dart';
export 'src/models/interaction_data.dart';

// Controllers
export 'src/controllers/calendar_controller.dart';

// Widgets
export 'src/widgets/calendar_view.dart';

// Builders
export 'src/builders/builder_delegates.dart';
```

---

## Architecture Principles

### 1. Separation of Concerns
- **Models**: Data structures only
- **Controllers**: State management
- **Widgets**: UI rendering
- **Utils**: Pure functions

### 2. Extensibility
- Abstract base classes for customization
- Builder pattern for widget replacement
- Theme system for styling
- Callback system for interactions

### 3. Type Safety
- Strong typing throughout
- Abstract classes for contracts
- Generic types where appropriate

### 4. Performance
- Efficient overlap calculation
- Optimized rendering
- Lazy loading
- Minimal rebuilds

### 5. Testability
- Pure functions in utils
- Mockable interfaces
- Isolated components
- Clear dependencies

---

## Contributing

When contributing, maintain this structure:

1. **New features** go in appropriate directories
2. **Tests** mirror the `lib/` structure
3. **Documentation** goes in `doc/`
4. **Examples** go in `example/`

See [CONTRIBUTING.md](../CONTRIBUTING.md) for details.