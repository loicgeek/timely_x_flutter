// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:jiffy/jiffy.dart';

import 'package:timely_x_flutter/timely_x_flutter.dart';
import 'package:timely_x_flutter_example/helpers.dart';
import 'package:timely_x_flutter_example/models/tyx_event.dart';

void main() {
  runApp(const MyApp());
}

class TableResource {
  String id;
  String name;
  TableResource({
    required this.id,
    required this.name,
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _timelyXFlutterPlugin = TimelyXFlutter();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _timelyXFlutterPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    double timeslotHeight = 30;
    const timelotSlotDuration = Duration(minutes: 15);
    var now = Jiffy.now().startOf(Unit.day); //DateTime.now();

    int minute = now.minute;
// Find the nearest 5-minute interval
    int roundedMinute = (minute ~/ timelotSlotDuration.inMinutes) *
        timelotSlotDuration.inMinutes;
    var initialDate = Jiffy.parseFromDateTime(
      DateTime(
        now.year,
        now.month,
        now.date,
        10,
        0,
      ),
    );

    var endOfDate = initialDate.endOf(Unit.day);
    var totalDayDurationInMinutes = endOfDate.diff(
      initialDate,
      unit: Unit.minute,
    );

    num timeslotCount =
        totalDayDurationInMinutes ~/ timelotSlotDuration.inMinutes + 1;
    double cellW = 100;

    var resources = generateResources(10);
    var allEvents = generateEventsForToday(resources);
    double timesCellW = 50;
    double resourceHeaderH = 50;

    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            //width: MediaQuery.of(context).size.width,
            height: timeslotCount * timeslotHeight +
                resourceHeaderH, // Enough height for vertical scroll
            child: Stack(
              clipBehavior: Clip.none,
              fit: StackFit.expand,
              children: [
                // Positioned timeslots for each hour
                for (int i = 0; i < timeslotCount; i++) ...[
                  Builder(builder: (context) {
                    return Positioned(
                      left: 0,
                      right: 0,
                      top: i * timeslotHeight + resourceHeaderH,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            color: Colors.grey.shade300,
                            height: 1,
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            child: Text('${initialDate.addDuration(
                                  Duration(
                                      minutes:
                                          i * timelotSlotDuration.inMinutes),
                                ).format(pattern: 'HH:mm')}'),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
                // Horizontal scrolling container
                Row(children: [
                  Container(
                    width: timesCellW,
                    height: timeslotCount *
                        timeslotHeight, // Match height for alignment
                    decoration: BoxDecoration(
                      // border: Border.all(color: Colors.grey),
                      color: Colors.transparent,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          resources.length,
                          (index) {
                            // Sample events with colors for visualization
                            var events = allEvents
                                .where((element) =>
                                    element.resourceId == resources[index].id)
                                .toList();

                            // Function to check if two events overlap
                            bool checkOverlap(TyxEvent e1, TyxEvent e2) {
                              return e1.start.isBefore(e2.end) &&
                                  e2.start.isBefore(e1.end);
                            }

                            // Group overlapping events
                            List<List<TyxEvent>> getCollisionGroups(
                                List<TyxEvent> events) {
                              List<List<TyxEvent>> groups = [];

                              for (var event in events) {
                                bool addedToGroup = false;
                                for (var group in groups) {
                                  if (group
                                      .any((e) => checkOverlap(e, event))) {
                                    group.add(event);
                                    addedToGroup = true;
                                    break;
                                  }
                                }
                                if (!addedToGroup) {
                                  groups.add([event]);
                                }
                              }

                              return groups;
                            }

                            // Calculate event positions
                            var collisionGroups = getCollisionGroups(events);

                            var eventPositions = events.map((e) {
                              int startMinutes = e.start
                                  .difference(initialDate.dateTime)
                                  .inMinutes;
                              double position = (startMinutes /
                                      timelotSlotDuration.inMinutes) *
                                  timeslotHeight;

                              int eventDurationInMinutes =
                                  e.end.difference(e.start).inMinutes;
                              double height = (eventDurationInMinutes /
                                      timelotSlotDuration.inMinutes) *
                                  timeslotHeight;

                              // Find the group for this event
                              var group = collisionGroups
                                  .firstWhere((g) => g.contains(e));
                              int groupSize = group.length;
                              int eventIndex = group.indexOf(e);

                              // Adjust width and horizontal offset
                              double width = cellW / groupSize;
                              double offsetX = width * eventIndex;

                              return {
                                "e": e,
                                "position": position,
                                "height": height,
                                "width": width,
                                "offsetX": offsetX,
                                "collision": groupSize - 1 // Number of overlaps
                              };
                            }).toList();

                            return Column(
                              children: [
                                Container(
                                  height: resourceHeaderH,
                                  width: cellW,
                                  color: Colors.red,
                                  child: Text("${resources[index].name}"),
                                ),
                                Stack(
                                  children: [
                                    Container(
                                      width: cellW,
                                      height: timeslotCount *
                                          timeslotHeight, // Match height for alignment
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        // color: Colors.red,
                                      ),
                                    ),
                                    for (int i = 0;
                                        i < eventPositions.length;
                                        i++) ...[
                                      Builder(builder: (context) {
                                        var item = eventPositions[i];
                                        return Positioned(
                                          left: item['offsetX'] as double,
                                          right: 0,
                                          top: item['position'] as double,
                                          child: SizedBox(
                                            height: item['height'] as double,
                                            width:
                                                (item['width'] as double) / 2,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              height: item['height'] as double,
                                              //   width: item['width'] as double,
                                              decoration: BoxDecoration(
                                                color: (item['e'] as TyxEvent)
                                                    .color,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    "${TimeOfDay.fromDateTime((item['e'] as TyxEvent).start).format(context)}- ${TimeOfDay.fromDateTime((item['e'] as TyxEvent).end).format(context)}",
                                                    style:
                                                        TextStyle(fontSize: 10),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      })
                                    ],
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
