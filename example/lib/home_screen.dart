import 'package:flutter/material.dart';
import 'package:timely_x/timely_x.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _currentDate;
  late List<TyxEvent> allEvents;
  late List<TyxResource> allResources;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    allResources = generateResources(10);
    allEvents = generateEventsForDay(allResources, _currentDate);
  }

  OverlayEntry? _contextMenu;

  void _showContextMenu(BuildContext context, Offset position) {
    _contextMenu?.remove();

    _contextMenu = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Transparent area to detect outside taps
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                _removeContextMenu();
              },
              behavior: HitTestBehavior.translucent,
              child: Container(),
            ),
          ),

          // Actual context menu
          Positioned(
            left: position.dx,
            top: position.dy,
            child: Material(
              elevation: 4,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.add),
                      title: const Text("New Event"),
                      onTap: () {
                        _removeContextMenu();
                        print("Create new event at $position");
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text("Details"),
                      onTap: () {
                        _removeContextMenu();
                        print("Details clicked");
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_contextMenu!);
  }

  void _removeContextMenu() {
    _contextMenu?.remove();
    _contextMenu = null;
  }

  GlobalKey<TyxCalendarViewState<TyxEvent>> _calendarKey =
      GlobalKey<TyxCalendarViewState<TyxEvent>>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expanded(
            //   child: TyxResourceView(
            //     option: TyxResourceOption(
            //       resources: allResources,
            //       events: allEvents,
            //       initialDate: _currentDate,
            //       timeslotStartTime: TimeOfDay(hour: 8, minute: 0),
            //     ),
            //   ),
            // ),
            Expanded(
              child: Row(
                children: [
                  // SizedBox(
                  //   width: 200,
                  // ),
                  // Expanded(
                  //   child: TyxResourceView(
                  //     resources: allResources,
                  //     events: allEvents,
                  //     option: TyxResourceOption(
                  //       initialDate: _currentDate,
                  //       timeslotStartTime: const TimeOfDay(hour: 0, minute: 0),
                  //       timeslotHeight: 50,
                  //       cellWidth: 200,
                  //       resourceHeaderHeight: 100,
                  //       layoutDirection: TyxResourceLayoutDirection.vertical,
                  //       resourceGrouping: TyxResourceGrouping.separate,
                  //     ),
                  //     viewMode: TyxResourceViewMode.week,
                  //   ),
                  // ),
                  Expanded(
                    child: TyxCalendarView(
                      key: _calendarKey,
                      onBorderChanged: (border) {
                        setState(() {
                          allEvents = generateEventsForMonth(
                              allResources, border.start!);
                        });
                        debugPrint(
                            "border changed: ${border.start}-${border.end}");
                      },
                      onRightClick: (position, date, events) {
                        _showContextMenu(context, position);
                      },
                      events: allEvents,
                      option: TyxCalendarOption(
                        // eventsRetriever: (border) async {
                        //   return generateEventsForMonth(
                        //       allResources, _currentDate);
                        // },
                        initialView: TyxView.day,
                      ),
                      mode: TyxCalendarMode.multiSelection,
                      onSelectedDatesChanged: (dates) {
                        print(dates);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
