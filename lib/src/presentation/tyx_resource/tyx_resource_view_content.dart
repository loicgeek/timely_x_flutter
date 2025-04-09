import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:timely_x_flutter/src/models/tyx_event_enhanced.dart';
import 'package:timely_x_flutter/src/models/tyx_resource_enhanced.dart';
import 'package:timely_x_flutter/src/models/tyx_resource_option.dart';

import '../../models/tyx_event.dart';

class TyxResourceViewContent extends StatefulWidget {
  final TyxResourceOption? option;
  const TyxResourceViewContent({
    super.key,
    this.option,
  });

  @override
  State<TyxResourceViewContent> createState() => _TyxResourceViewContentState();
}

class _TyxResourceViewContentState extends State<TyxResourceViewContent> {
  @override
  Widget build(BuildContext context) {
    var primaryColor = Theme.of(context).primaryColor;
    double timeslotHeight = widget.option?.timeslotHeight ?? 30;
    Duration timelotSlotDuration =
        widget.option?.timelotSlotDuration ?? const Duration(minutes: 15);
    var now = widget.option?.initialDate ?? DateTime.now();

    //int minute = now.minute;
// Find the nearest 5-minute interval
    var initialDate = Jiffy.parseFromDateTime(
      DateTime(
        now.year,
        now.month,
        now.day,
        widget.option?.timeslotStartTime?.hour ?? 0,
        widget.option?.timeslotStartTime?.minute ?? 0,
      ),
    );

    var endOfDate = initialDate.endOf(Unit.day);
    var totalDayDurationInMinutes = endOfDate.diff(
      initialDate,
      unit: Unit.minute,
    );
    num timeslotCount =
        totalDayDurationInMinutes ~/ timelotSlotDuration.inMinutes + 1;
    double cellW = widget.option?.cellWidth ?? 120;
    double timesCellW = widget.option?.timesCellWidth ?? 60;
    double resourceHeaderH = widget.option?.resourceHeaderHeight ?? 40;

    var resources = widget.option!.resources!;
    var allEvents = widget.option!.events!;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SizedBox(
          //width: MediaQuery.of(context).size.width,
          height: timeslotCount * timeslotHeight +
              resourceHeaderH, // Enough height for vertical scroll
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Positioned timeslots for each hour
              for (int i = 0; i < timeslotCount; i++) ...[
                Builder(
                  builder: (context) {
                    return Positioned(
                      left: 0,
                      right: 0,
                      top: i * timeslotHeight + resourceHeaderH,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: timesCellW + resources.length * cellW,
                            color: Colors.grey.shade300,
                            height: 1,
                          ),
                          Positioned(
                            top: 0,
                            height: timeslotHeight,
                            width: timesCellW,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text(
                                  TimeOfDay.fromDateTime(initialDate
                                          .addDuration(
                                            Duration(
                                                minutes: i *
                                                    timelotSlotDuration
                                                        .inMinutes),
                                          )
                                          .dateTime)
                                      .format(context),
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Color(0xFF7F7F7F),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
              // Horizontal scrolling container
              Row(
                children: [
                  Container(
                    width: timesCellW,
                    height: timeslotCount *
                        timeslotHeight, // Match height for alignment
                    decoration: const BoxDecoration(
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

                              return TyxEventEnhanced(
                                e: e,
                                position: position,
                                height: height,
                                width: width,
                                offsetX: offsetX,
                                groupSize: groupSize,
                              );
                            }).toList();

                            return Column(
                              children: [
                                SizedBox(
                                  height: resourceHeaderH,
                                  width: cellW,
                                  child: widget.option?.resourceBuilder != null
                                      ? Container(
                                          height: resourceHeaderH,
                                          width: cellW,
                                          decoration: BoxDecoration(
                                            border: Border(
                                              left: BorderSide(
                                                color: Colors.grey.shade300,
                                              ),
                                            ),
                                          ),
                                          child:
                                              widget.option?.resourceBuilder!(
                                            context,
                                            TyxResourceEnhanced(
                                              width: cellW,
                                              height: resourceHeaderH,
                                              resource: resources[index],
                                            ),
                                          ),
                                        )
                                      : Container(
                                          height: resourceHeaderH,
                                          width: cellW,
                                          decoration: BoxDecoration(
                                            border: Border(
                                              left: BorderSide(
                                                color: Colors.grey.shade300,
                                              ),
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: primaryColor),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    child: Text(
                                                      resources[index].name,
                                                      style: const TextStyle(
                                                          fontSize: 10),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                            ],
                                          ),
                                        ),
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
                                          left: item.offsetX,
                                          right: 0,
                                          top: item.position,
                                          height: item.height,
                                          child: widget.option?.eventBuilder !=
                                                  null
                                              ? Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 2),
                                                  child: widget.option!
                                                          .eventBuilder!(
                                                      context, item),
                                                )
                                              : InkWell(
                                                  onTap: () {},
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 1),
                                                    child: SizedBox(
                                                      height: item.height,
                                                      width: item.width,
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4),
                                                        height: item.height,
                                                        //   width: item['width'] as double,
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color:
                                                                  primaryColor),
                                                          color: item.e.color,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                              "${TimeOfDay.fromDateTime((item.e).start).format(context)}- ${TimeOfDay.fromDateTime((item.e).end).format(context)}",
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          10),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
