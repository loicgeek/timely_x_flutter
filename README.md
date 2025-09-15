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
      body:   Expanded(
              child: TyxCalendarView<AppointmentModel>(
                onViewChanged: (view) {
                  //  _activeView = view;
                },
                onDateChanged: (view, events) {},
                onBorderChanged: (border) {
                  _filter = (_filter ?? AppointmentFilter())
                      .copyWith(startDate: border.start, endDate: border.end);
                  _loadAppointments();
                },
                option: TyxCalendarOption<AppointmentModel>(
                  timesCellWidth: 60,
                  initialView: TyxView.day,
                  events: allEvents,
                  monthOption: TyxCalendarMonthOption<AppointmentModel>(
                    eventListTileBuilder: (context, event) {
                      var colorScheme = ColorScheme.fromSeed(
                        seedColor: event.provider!.appointmentColor != null
                            ? ColorsUtils.hexToColor(
                                event.provider!.appointmentColor!)
                            : event.color,
                      );
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 0.2,
                        surfaceTintColor: colorScheme.primaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 4,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 4, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: colorScheme.primaryContainer,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: SelectableText(
                                            event.code ?? 'N/A',
                                            style: TextStyle(
                                              color: colorScheme
                                                  .onPrimaryContainer,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            AppointmentUtils
                                                .getAppointmentTitle(event),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${TimeOfDay.fromDateTime(event.start).format(context)} - ${TimeOfDay.fromDateTime(event.end).format(context)}',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    if (event.store != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              size: 14,
                                              color: Theme.of(context)
                                                  .disabledColor,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                event.store!.name!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: Theme.of(context)
                                                          .disabledColor,
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                onEventTapped: (event) {
                  context.router.push(AppointmentDetailsRoute(id: event.id));
                },
              ),
            ),,
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

Made with ❤️ by <a href="https://github.com/loicgeek">Loic NGOU</a>
