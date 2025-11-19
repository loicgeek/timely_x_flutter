# Calendar Theme Quick Reference

A quick cheat sheet for the most commonly used theme properties.

## Quick Start

```dart
CalendarView(
  controller: controller,
  theme: CalendarTheme(
    // Add your customizations here
  ),
)
```

---

## 🎨 Colors Cheat Sheet

### Essential Colors
```dart
CalendarTheme(
  // Today & Current Time
  todayHighlightColor: Colors.blue,           // Today's date accent
  currentTimeIndicatorColor: Colors.red,      // Current time line
  currentDayHighlight: Color(0xFFE3F2FD),    // Today's background
  
  // Grid & Lines
  gridLineColor: Color(0xFFE5E5E5),          // Minor grid lines
  hourLineColor: Color(0xFFCCCCCC),          // Hour lines
  
  // Weekends
  weekendColor: Color(0xFFFAFAFA),           // Weekend background
  weekendTextColor: Color(0xFFD32F2F),       // Weekend text
  
  // Backgrounds
  headerBackgroundColor: Colors.white,        // Headers
  gridBackgroundColor: Colors.white,          // Grid
  timeColumnBackgroundColor: Colors.white,    // Time column
)
```

### All Color Properties
| Property | Purpose | Default |
|----------|---------|---------|
| `gridLineColor` | Minor grid lines | `#E5E5E5` |
| `hourLineColor` | Hour separator lines | `#CCCCCC` |
| `zebraStripeOdd` | Odd hour background | `#FAFAFA` |
| `zebraStripeEven` | Even hour background | `white` |
| `currentDayHighlight` | Today background | `#E3F2FD` |
| `currentTimeIndicatorColor` | Time line | `#FF5252` |
| `selectedSlotColor` | Selected slot | `#BBDEFB` |
| `hoverColor` | Hover state | `#F5F5F5` |
| `weekendColor` | Weekend background | `#FAFAFA` |
| `weekendTextColor` | Weekend text | `#D32F2F` |
| `todayHighlightColor` | Today accent | `#2196F3` |
| `otherMonthDayColor` | Other month days | `#BDBDBD` |
| `headerBackgroundColor` | Headers | `white` |
| `gridBackgroundColor` | Grid | `white` |
| `timeColumnBackgroundColor` | Time column | `white` |
| `monthViewHeaderBackgroundColor` | Month header | `#F5F5F5` |

---

## 📝 Text Styles Cheat Sheet

```dart
CalendarTheme(
  // Time & Dates
  timeTextStyle: TextStyle(fontSize: 13, color: Color(0xFF666666)),
  dateTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
  weekdayTextStyle: TextStyle(fontSize: 12, color: Color(0xFF757575)),
  
  // Resources
  resourceNameStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
  
  // Appointments
  appointmentTextStyle: TextStyle(fontSize: 13, color: Colors.white),
  appointmentSubtitleStyle: TextStyle(fontSize: 11, color: Colors.white70),
  appointmentTimeStyle: TextStyle(fontSize: 10, color: Colors.white70),
)
```

### All Text Style Properties
| Property | Purpose | Default Size |
|----------|---------|--------------|
| `timeTextStyle` | Time column labels | 13 |
| `dateTextStyle` | Date numbers | 16 |
| `weekdayTextStyle` | Weekday labels | 12 |
| `resourceNameStyle` | Resource names | 14 |
| `appointmentTextStyle` | Appointment titles | 13 |
| `appointmentSubtitleStyle` | Appointment subtitles | 11 |
| `appointmentTimeStyle` | Time in appointments | 10 |
| `monthViewDayTextStyle` | Month view days | 14 |
| `monthViewAppointmentTextStyle` | Month appointments | 10 |
| `monthViewMoreTextStyle` | "+X more" text | 10 |

---

## 📅 Date Format Cheat Sheet

```dart
CalendarTheme(
  timeFormat: 'HH:mm',              // 24-hour: "14:30"
  timeFormat: 'h:mm a',             // 12-hour: "2:30 PM"
  
  dateFormat: 'd',                  // Day: "15"
  weekdayFormat: 'E',               // Weekday: "Mon"
  weekdayFormat: 'EEEE',            // Full: "Monday"
  
  dateHeaderFormat: 'MMMM d, yyyy', // "November 18, 2025"
  monthFormat: 'MMMM yyyy',         // "November 2025"
)
```

### Common Format Patterns
| Pattern | Example | Description |
|---------|---------|-------------|
| **Time Formats** |
| `'HH:mm'` | "14:30" | 24-hour time |
| `'h:mm a'` | "2:30 PM" | 12-hour with AM/PM |
| `'HH:mm:ss'` | "14:30:45" | With seconds |
| **Date Formats** |
| `'d'` | "15" | Day number |
| `'dd'` | "15" | Two-digit day |
| `'E'` | "Mon" | Short weekday |
| `'EEE'` | "Mon" | Short weekday |
| `'EEEE'` | "Monday" | Full weekday |
| `'MMM'` | "Nov" | Short month |
| `'MMMM'` | "November" | Full month |
| `'yy'` | "25" | Two-digit year |
| `'yyyy'` | "2025" | Four-digit year |
| **Combined Formats** |
| `'MMMM d, yyyy'` | "November 18, 2025" | US format |
| `'d MMMM yyyy'` | "18 November 2025" | European format |
| `'MMM d'` | "Nov 18" | Short date |
| `'EEEE, MMMM d'` | "Monday, November 18" | Long format |

---

## 📏 Spacing Cheat Sheet

```dart
CalendarTheme(
  // Padding (space inside)
  resourceHeaderPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
  dateHeaderPadding: EdgeInsets.symmetric(vertical: 8),
  appointmentPadding: EdgeInsets.all(4),
  timeLabelPadding: EdgeInsets.only(top: 4, right: 8),
  
  // Margins (space between)
  appointmentMargin: EdgeInsets.only(right: 4, bottom: 2),
  
  // Sizing
  resourceAvatarRadius: 20.0,
  appointmentSpacing: 2.0,
)
```

### EdgeInsets Quick Reference
```dart
EdgeInsets.all(8)                              // All sides: 8
EdgeInsets.symmetric(vertical: 12, horizontal: 8) // Top/Bottom: 12, Left/Right: 8
EdgeInsets.only(top: 4, right: 8)             // Specific sides
EdgeInsets.fromLTRB(8, 12, 8, 12)            // Left, Top, Right, Bottom
```

---

## 🎯 Month View Cheat Sheet

```dart
CalendarTheme(
  // Dimensions
  monthViewHeaderHeight: 40.0,
  monthViewCellAspectRatio: 1.2,        // Width:height ratio
  
  // Styling
  monthViewHeaderBackgroundColor: Color(0xFFF5F5F5),
  monthViewAppointmentBorderRadius: 2.0,
  
  // Spacing
  monthViewCellPadding: EdgeInsets.all(4),
  monthViewAppointmentMargin: EdgeInsets.only(bottom: 2),
  monthViewAppointmentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
  
  // Behavior
  monthViewMaxVisibleAppointments: 3,   // Before "+X more"
)
```

---

## 🎨 Drag & Drop Cheat Sheet

```dart
CalendarTheme(
  dragFeedbackOpacity: 0.8,              // Dragged item opacity
  dragPlaceholderOpacity: 0.3,           // Placeholder opacity
  dragPlaceholderBorderColor: Color(0x80000000),
  dragPlaceholderBorderWidth: 2.0,
)
```

---

## 🌟 Common Use Cases

### 1. Dark Mode
```dart
CalendarTheme(
  gridLineColor: Color(0xFF424242),
  gridBackgroundColor: Color(0xFF121212),
  headerBackgroundColor: Color(0xFF1E1E1E),
  timeTextStyle: TextStyle(color: Color(0xFFB0B0B0)),
)
```

### 2. Compact Mobile
```dart
CalendarTheme(
  resourceHeaderPadding: EdgeInsets.all(8),
  appointmentPadding: EdgeInsets.all(2),
  resourceAvatarRadius: 16.0,
  timeTextStyle: TextStyle(fontSize: 11),
)
```

### 3. 12-Hour Time
```dart
CalendarTheme(
  timeFormat: 'h:mm a',  // 2:30 PM instead of 14:30
)
```

### 4. European Date Format
```dart
CalendarTheme(
  dateHeaderFormat: 'd MMMM yyyy',  // 18 November 2025
  weekdayFormat: 'EEEE',             // Monday
)
```

### 5. High Contrast
```dart
CalendarTheme(
  gridLineColor: Colors.black,
  timeTextStyle: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  ),
)
```

### 6. Colorful Weekends
```dart
CalendarTheme(
  weekendColor: Color(0xFFFFF3E0),      // Light orange
  weekendTextColor: Color(0xFFD84315),  // Dark orange
)
```

---

## 🔧 Tips & Tricks

### Create Theme Variants
```dart
final baseTheme = CalendarTheme(/* ... */);
final darkTheme = baseTheme.copyWith(/* ... */);
final compactTheme = baseTheme.copyWith(/* ... */);
```

### Responsive Sizing
```dart
final isMobile = MediaQuery.of(context).size.width < 600;
final theme = CalendarTheme(
  appointmentPadding: isMobile 
    ? EdgeInsets.all(2) 
    : EdgeInsets.all(4),
);
```

### Color Utilities
```dart
// Lighten/darken colors
Color(0xFF2196F3).withOpacity(0.5)  // 50% transparent
Color(0xFF2196F3).withAlpha(128)    // 50% alpha

// Material colors
Colors.blue
Colors.blue.shade50
Colors.blue.shade900
```

### Test Contrast
```dart
// Ensure good contrast for accessibility
// Aim for ratio of 4.5:1 or higher (WCAG AA)
final textColor = theme.timeTextStyle.color;
final bgColor = theme.timeColumnBackgroundColor;
```

---

## 📱 Platform-Specific Defaults

### Material Design (Android)
```dart
CalendarTheme(
  todayHighlightColor: Color(0xFF2196F3),   // Blue
  appointmentBorderRadius: 4.0,
  timeFormat: 'HH:mm',
)
```

### iOS (Cupertino)
```dart
CalendarTheme(
  todayHighlightColor: Color(0xFF007AFF),   // iOS Blue
  appointmentBorderRadius: 8.0,
  timeFormat: 'h:mm a',
)
```

---

## 🔍 Property Index

### By Category

**Colors**: 16 properties  
**Text Styles**: 10 properties  
**Date Formats**: 6 properties  
**Spacing**: 7 properties  
**Month View**: 8 properties  
**Decorations**: 3 properties  
**Drag & Drop**: 4 properties  

**Total**: 65+ customization properties

---

## 📚 More Resources

- **Full Documentation**: [CUSTOMIZATION_GUIDE.md](./CUSTOMIZATION_GUIDE.md)
- **Migration Guide**: [MIGRATION_GUIDE.md](./MIGRATION_GUIDE.md)
- **Change Summary**: [CHANGES_SUMMARY.md](./CHANGES_SUMMARY.md)
- **Examples**: `/example` directory

---

## 💡 Remember

1. All properties are **optional** with sensible defaults
2. Use `copyWith()` to create theme variants
3. Test on multiple screen sizes
4. Check color contrast for accessibility
5. Use const constructors when possible
6. Reuse theme instances for better performance

Happy theming! 🎨