# Calendar Customization Guide

This guide documents all customizable design elements in the calendar package. Every visual aspect of the calendar can be customized through the `CalendarTheme` class.

## Table of Contents

1. [Theme Overview](#theme-overview)
2. [Colors](#colors)
3. [Text Styles](#text-styles)
4. [Date Formats](#date-formats)
5. [Spacing & Sizing](#spacing--sizing)
6. [Month View Specific](#month-view-specific)
7. [Decorations](#decorations)
8. [Drag & Drop](#drag--drop)
9. [Usage Examples](#usage-examples)

---

## Theme Overview

All customization is done through the `CalendarTheme` class. Pass your custom theme to the `CalendarView` widget:

```dart
CalendarView(
  controller: controller,
  theme: CalendarTheme(
    // Your customizations here
  ),
)
```

---

## Colors

### Grid Colors
- **`gridLineColor`** - Color of minor grid lines (default: `Color(0xFFE5E5E5)`)
- **`hourLineColor`** - Color of hour separator lines (default: `Color(0xFFCCCCCC)`)
- **`zebraStripeOdd`** - Odd hour background color (default: `Color(0xFFFAFAFA)`)
- **`zebraStripeEven`** - Even hour background color (default: `Colors.white`)

### Highlight Colors
- **`currentDayHighlight`** - Background for today's date (default: `Color(0xFFE3F2FD)`)
- **`currentTimeIndicatorColor`** - Color of current time line (default: `Color(0xFFFF5252)`)
- **`selectedSlotColor`** - Selected time slot background (default: `Color(0xFFBBDEFB)`)
- **`hoverColor`** - Hover state color (default: `Color(0xFFF5F5F5)`)
- **`todayHighlightColor`** - Today's date accent color (default: `Color(0xFF2196F3)`)

### Weekend & Special Colors
- **`weekendColor`** - Weekend column background (default: `Color(0xFFFAFAFA)`)
- **`weekendTextColor`** - Weekend text color (default: `Color(0xFFD32F2F)`)
- **`otherMonthDayColor`** - Other month days in month view (default: `Color(0xFFBDBDBD)`)

### Background Colors
- **`headerBackgroundColor`** - Header area background (default: `Colors.white`)
- **`gridBackgroundColor`** - Grid background (default: `Colors.white`)
- **`timeColumnBackgroundColor`** - Time column background (default: `Colors.white`)

---

## Text Styles

### Time & Date Styles
- **`timeTextStyle`** - Time labels in time column
  ```dart
  TextStyle(fontSize: 13, color: Color(0xFF666666))
  ```

- **`dateTextStyle`** - Date numbers in headers
  ```dart
  TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF212121))
  ```

- **`weekdayTextStyle`** - Weekday labels (Mon, Tue, etc.)
  ```dart
  TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF757575))
  ```

### Resource & Appointment Styles
- **`resourceNameStyle`** - Resource/person names
  ```dart
  TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF212121))
  ```

- **`appointmentTextStyle`** - Appointment title text
  ```dart
  TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)
  ```

- **`appointmentSubtitleStyle`** - Appointment subtitle
  ```dart
  TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: Colors.white70)
  ```

- **`appointmentTimeStyle`** - Appointment time display
  ```dart
  TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: Colors.white70)
  ```

### Month View Styles
- **`monthViewDayTextStyle`** - Day numbers in month grid
  ```dart
  TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF212121))
  ```

- **`monthViewAppointmentTextStyle`** - Appointment text in month cells
  ```dart
  TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: Colors.white)
  ```

- **`monthViewMoreTextStyle`** - "+X more" text
  ```dart
  TextStyle(fontSize: 10, color: Color(0xFF757575))
  ```

---

## Date Formats

All date formats use the `intl` package pattern syntax.

- **`timeFormat`** - Time display format (default: `'HH:mm'`)
  - Example: `'HH:mm'` → "14:30"
  - Example: `'h:mm a'` → "2:30 PM"

- **`dateFormat`** - Date number format (default: `'d'`)
  - Example: `'d'` → "15"
  - Example: `'dd'` → "15"

- **`weekdayFormat`** - Weekday format (default: `'E'`)
  - Example: `'E'` → "Mon"
  - Example: `'EEEE'` → "Monday"
  - Example: `'EEE'` → "Mon"

- **`monthFormat`** - Month view title format (default: `'MMMM yyyy'`)
  - Example: `'MMMM yyyy'` → "November 2025"
  - Example: `'MMM yy'` → "Nov 25"

- **`dateHeaderFormat`** - Day view date header (default: `'MMMM d, yyyy'`)
  - Example: `'MMMM d, yyyy'` → "November 18, 2025"

- **`weekPeriodFormat`** - Week range format (default: `'MMM d'`)
  - Example: `'MMM d'` → "Nov 18"

### Date Format Examples

```dart
CalendarTheme(
  // 12-hour format with AM/PM
  timeFormat: 'h:mm a',
  
  // Short weekday names
  weekdayFormat: 'EEE',
  
  // European date format
  dateHeaderFormat: 'd MMMM yyyy',
  
  // Short month and year
  monthFormat: 'MMM yyyy',
)
```

---

## Spacing & Sizing

### Padding
- **`resourceHeaderPadding`** - Padding inside resource headers (default: `EdgeInsets.symmetric(vertical: 12, horizontal: 8)`)
- **`dateHeaderPadding`** - Padding inside date headers (default: `EdgeInsets.symmetric(vertical: 8)`)
- **`appointmentPadding`** - Padding inside appointments (default: `EdgeInsets.all(4)`)
- **`appointmentMargin`** - Margin around appointments (default: `EdgeInsets.only(right: 4, bottom: 2)`)
- **`timeLabelPadding`** - Padding for time labels (default: `EdgeInsets.only(top: 4, right: 8)`)

### Sizing
- **`resourceAvatarRadius`** - Radius of resource avatar circles (default: `20.0`)
- **`appointmentSpacing`** - Base spacing unit for appointments (default: `2.0`)

---

## Month View Specific

- **`monthViewHeaderHeight`** - Height of weekday header row (default: `40.0`)
- **`monthViewHeaderBackgroundColor`** - Weekday header background (default: `Color(0xFFF5F5F5)`)
- **`monthViewCellPadding`** - Padding inside month cells (default: `EdgeInsets.all(4)`)
- **`monthViewCellAspectRatio`** - Width:height ratio of cells (default: `1.2`)
- **`monthViewAppointmentMargin`** - Margin between appointments (default: `EdgeInsets.only(bottom: 2)`)
- **`monthViewAppointmentPadding`** - Padding in appointment pills (default: `EdgeInsets.symmetric(horizontal: 4, vertical: 2)`)
- **`monthViewAppointmentBorderRadius`** - Border radius of appointment pills (default: `2.0`)
- **`monthViewMaxVisibleAppointments`** - Max appointments before "+X more" (default: `3`)

---

## Decorations

### Appointment Decorations
- **`appointmentBorderRadius`** - Corner radius for appointments (default: `4.0`)
- **`appointmentShadow`** - Shadow for appointments
  ```dart
  [BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 2))]
  ```

### Header Decorations
- **`headerShadow`** - Shadow for header areas
  ```dart
  [BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1))]
  ```

---

## Drag & Drop

- **`dragFeedbackOpacity`** - Opacity of dragged appointment (default: `0.8`)
- **`dragPlaceholderOpacity`** - Opacity of placeholder (default: `0.3`)
- **`dragPlaceholderBorderColor`** - Color of placeholder border (default: `Color(0x80000000)`)
- **`dragPlaceholderBorderWidth`** - Width of placeholder border (default: `2.0`)

---

## Usage Examples

### Example 1: Dark Theme

```dart
final darkTheme = CalendarTheme(
  // Grid colors
  gridLineColor: Color(0xFF424242),
  hourLineColor: Color(0xFF616161),
  zebraStripeOdd: Color(0xFF212121),
  zebraStripeEven: Color(0xFF303030),
  
  // Background colors
  headerBackgroundColor: Color(0xFF1E1E1E),
  gridBackgroundColor: Color(0xFF121212),
  timeColumnBackgroundColor: Color(0xFF1E1E1E),
  
  // Text styles
  timeTextStyle: TextStyle(fontSize: 13, color: Color(0xFFB0B0B0)),
  resourceNameStyle: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFFE0E0E0),
  ),
  dateTextStyle: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Color(0xFFE0E0E0),
  ),
  
  // Highlights
  currentDayHighlight: Color(0xFF1565C0),
  todayHighlightColor: Color(0xFF42A5F5),
  currentTimeIndicatorColor: Color(0xFFFF5252),
);
```

### Example 2: Compact View

```dart
final compactTheme = CalendarTheme(
  // Smaller text
  timeTextStyle: TextStyle(fontSize: 11, color: Color(0xFF666666)),
  resourceNameStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
  appointmentTextStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
  
  // Tighter spacing
  resourceHeaderPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
  dateHeaderPadding: EdgeInsets.symmetric(vertical: 4),
  appointmentPadding: EdgeInsets.all(2),
  appointmentMargin: EdgeInsets.only(right: 2, bottom: 1),
  
  // Smaller avatar
  resourceAvatarRadius: 16.0,
  
  // Minimal spacing
  appointmentSpacing: 1.0,
);
```

### Example 3: High Contrast

```dart
final highContrastTheme = CalendarTheme(
  // Strong grid lines
  gridLineColor: Colors.black,
  hourLineColor: Colors.black,
  
  // High contrast backgrounds
  zebraStripeOdd: Colors.white,
  zebraStripeEven: Color(0xFFF0F0F0),
  currentDayHighlight: Color(0xFFFFEB3B),
  
  // Bold text
  timeTextStyle: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  ),
  resourceNameStyle: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  ),
  
  // Strong shadows
  appointmentShadow: [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ],
);
```

### Example 4: Custom Date Formats (European)

```dart
final europeanTheme = CalendarTheme(
  // 24-hour time
  timeFormat: 'HH:mm',
  
  // Day/Month/Year
  dateHeaderFormat: 'd MMMM yyyy',
  
  // Full weekday names
  weekdayFormat: 'EEEE',
  
  // Month and year
  monthFormat: 'MMMM yyyy',
  weekPeriodFormat: 'd MMM',
);
```

### Example 5: Colorful & Playful

```dart
final colorfulTheme = CalendarTheme(
  // Colored backgrounds
  weekendColor: Color(0xFFFFF3E0),
  currentDayHighlight: Color(0xFFE1F5FE),
  hoverColor: Color(0xFFF3E5F5),
  
  // Colorful accents
  todayHighlightColor: Color(0xFFFF6F00),
  currentTimeIndicatorColor: Color(0xFFE91E63),
  weekendTextColor: Color(0xFFD84315),
  
  // Round appointments
  appointmentBorderRadius: 12.0,
  
  // Playful month view
  monthViewAppointmentBorderRadius: 8.0,
  monthViewCellAspectRatio: 1.0, // Square cells
);
```

---

## Complete Reference

For a complete list of all properties with their default values, refer to the `CalendarTheme` class definition in `calendar_theme.dart`.

### Key Features

✅ **Every color is customizable** - No hardcoded colors  
✅ **All text styles are configurable** - Complete typography control  
✅ **Date formats are flexible** - Support for any locale/format  
✅ **Spacing is adjustable** - Control all padding and margins  
✅ **Month view is fully themed** - Separate styling for month view  
✅ **Drag & drop appearance** - Customize drag feedback  

---

## Tips

1. **Use consistent color schemes** - Pick a base palette and stick to it
2. **Test with different screen sizes** - Ensure your spacing works everywhere
3. **Consider accessibility** - Use sufficient color contrast
4. **Theme inheritance** - Use `copyWith()` to create theme variations
5. **Date format localization** - Use appropriate formats for your locale

```dart
// Create a base theme
final baseTheme = CalendarTheme(
  todayHighlightColor: Colors.blue,
  appointmentBorderRadius: 8.0,
);

// Create a variant
final darkVariant = baseTheme.copyWith(
  gridBackgroundColor: Color(0xFF121212),
  headerBackgroundColor: Color(0xFF1E1E1E),
);
```

---

## Support

For more examples and advanced usage, check the `/example` directory in the package.