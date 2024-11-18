// Generate resources
import 'dart:math';
import 'dart:ui';

import 'package:timely_x_flutter/src/models/tyx_resource.dart';

import 'models/tyx_event.dart';

List<TyxResource> generateResources(int count) {
  List<TyxResource> resources = List.generate(count, (index) {
    return TyxResource(
      id: 'table_$index',
      name: 'Table $index',
    );
  });
  return resources;
}

// Function to generate random events for today associated with resources
List<TyxEvent> generateEventsForDay(List<TyxResource> resources, DateTime day) {
  var now = day;
  var todayStart = DateTime(now.year, now.month, now.day);
  var todayEnd = DateTime(now.year, now.month, now.day, 23, 59);

  List<TyxEvent> events = [];
  Random random = Random();

  for (var resource in resources) {
    int eventCount = random.nextInt(4) + 1; // 1-4 events per resource
    for (int i = 0; i < eventCount; i++) {
      // Generate random start and end times within today
      DateTime start = todayStart.add(Duration(
          minutes: random.nextInt(1440))); // random minute within the day
      DateTime end = start.add(Duration(
          minutes: random.nextInt(120) +
              15)); // random duration between 15-135 minutes

      // Ensure end time doesn't exceed today's end
      if (end.isAfter(todayEnd)) {
        end = todayEnd;
      }

      // Create event and add to the list
      events.add(TyxEvent(
        start: start,
        end: end,
        color: Color.fromARGB(
            255, random.nextInt(256), random.nextInt(256), random.nextInt(256)),
        resourceId: resource.id,
      ));
    }
  }

  return events;
}
