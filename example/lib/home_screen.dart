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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Reservations",
              style: TextStyle(fontSize: 22),
            ),
            SizedBox(height: 5),
            Text("Tous vos services enregistrées sur la plateforme"),
            SizedBox(height: 10),
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
              child: TyxCalendarView(
                  option: TyxCalendarOption(
                      initialView: TyxView.day,
                      events:
                          generateEventsForMonth(allResources, _currentDate))),
            ),
          ],
        ),
      ),
    );
  }
}
