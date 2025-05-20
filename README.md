# Timely X Flutter

[![pub package](https://img.shields.io/pub/v/timely_x.svg)](https://pub.dev/packages/timely_x)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/loicgeek/timely_x_flutter/pulls)

A powerful and customizable calendar and resource scheduling library for Flutter applications. Timely X provides beautiful, responsive calendar views and resource scheduling components to help you build professional scheduling applications with ease.

## 📱 Screenshots

| Day View | Week View | Month View | Resource View |
|----------|-----------|------------|----------------|
| ![Day View](assets/day_view.png) | ![Week View](assets/week_view.png) | ![Month View](assets/month_view.png) | ![Resource View](assets/resource_view.png) |

## ✨ Features

- **Multiple View Modes**: Switch between Day, Week, and Month views
- **Resource Scheduling**: Manage resources like rooms, employees, or equipment
- **Fully Customizable**: Customize colors, layouts, and behaviors
- **Responsive Design**: Works on mobile, tablet, and desktop
- **Interactive**: Support for drag & drop, swipe gestures, and more
- **Localization**: Built-in support for multiple languages
- **Theming**: Seamlessly integrates with your app's theme

## 🚀 Installation

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  timely_x: ^0.0.1  # Check for the latest version
  intl: ^0.18.0      # For date formatting
  jiffy: ^6.2.0      # For date manipulation
```

Then run:

```bash
flutter pub get
```

## 🎯 Quick Start

### Basic Calendar

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
      title: 'Timely X Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CalendarScreen(),
    );
  }
}

class CalendarScreen extends StatelessWidget {
  final List<TyxEvent> events = [
    TyxEvent(
      id: '1',
      title: 'Team Meeting',
      start: DateTime.now().add(Duration(hours: 10)),
      end: DateTime.now().add(Duration(hours: 11)),
      color: Colors.blue,
    ),
    // Add more events...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timely X Calendar'),
        actions: [
          IconButton(
            icon: Icon(Icons.today),
            onPressed: () {
              // Handle today button press
            },
          ),
        ],
      ),
      body: TyxCalendarView(
        option: TyxCalendarOption(
          initialView: TyxView.week,
          initialDate: DateTime.now(),
          events: events,
          timeslotStartTime: TimeOfDay(hour: 8, minute: 0),
          timeslotEndTime: TimeOfDay(hour: 20, minute: 0),
        ),
        onDateChanged: (date) {
          // Handle date selection
          print('Selected date: $date');
        },
        onEventTapped: (event) {
          // Handle event tap
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(event.title ?? 'Event'),
              content: Text('Event details here'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close'),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new event
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
```

## 🛠️ Advanced Usage

### Custom Event Widget

```dart
eventBuilder: (context, event) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
    padding: EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: event.color?.withOpacity(0.2) ?? Theme.of(context).primaryColor.withOpacity(0.2),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(
        color: event.color ?? Theme.of(context).primaryColor,
        width: 1,
      ),
    ),
    child: Text(
      event.title ?? '',
      style: TextStyle(
        color: event.color ?? Theme.of(context).primaryColor,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    ),
  );
},
```

### Localization

```dart
import 'package:flutter_localizations/flutter_localizations.dart';

// In your MaterialApp
MaterialApp(
  localizationsDelegates: [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: [
    const Locale('en', ''), // English
    const Locale('fr', ''), // French
    // Add other locales
  ],
  // ...
)
```

## 📚 API Reference

### TyxCalendarView Properties

| Property | Type | Description |
|----------|------|-------------|
| `option` | `TyxCalendarOption` | Required. Configuration options for the calendar |
| `onDateChanged` | `Function(DateTime)` | Callback when the selected date changes |
| `onEventTapped` | `Function(TyxEvent)` | Callback when an event is tapped |
| `onViewChanged` | `Function(TyxView)` | Callback when the view type changes |

### TyxCalendarOption Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `initialView` | `TyxView` | `TyxView.month` | Initial view type (day, week, month) |
| `initialDate` | `DateTime` | `DateTime.now()` | Initial selected date |
| `events` | `List<TyxEvent>` | `[]` | List of events to display |
| `timeslotHeight` | `double` | `60.0` | Height of each time slot in pixels |
| `timeslotStartTime` | `TimeOfDay` | `TimeOfDay(hour: 0, minute: 0)` | Start time for day/week view |
| `timeslotEndTime` | `TimeOfDay` | `TimeOfDay(hour: 23, minute: 59)` | End time for day/week view |
| `showTrailingDays` | `bool` | `false` | Whether to show days from next/previous months |
| `startWeekDay` | `int` | `7` (Sunday) | First day of week (1 = Monday, 7 = Sunday) |

## 🤝 Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) before submitting pull requests.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with ❤️ using Flutter
- Inspired by various calendar and scheduling applications
- Special thanks to all contributors

---

Made with ❤️ by Loic NGOU
