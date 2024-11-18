import 'package:flutter/material.dart';
import 'package:timely_x_flutter/timely_x_flutter.dart';

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
        padding: EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Reservations",
              style: TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 5),
            const Text("Tous vos services enregistrées sur la plateforme"),
            const SizedBox(height: 10),
            Expanded(
              child: TyxResourceView(
                onDateChanged: (date) {
                  setState(() {
                    _currentDate = date;
                    allEvents =
                        generateEventsForDay(allResources, _currentDate);
                  });
                },
                option: TyxResourceOption(
                  initialDate: _currentDate,
                  resources: allResources,
                  events: allEvents,
                  eventBuilder: (context, e) {
                    return InkWell(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        width: e.width,
                        height: e.height,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 255, 250, 244),
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView(
                          children: [
                            Text(
                              "${TimeOfDay.fromDateTime(e.e.start).format(context)} - ${TimeOfDay.fromDateTime(e.e.end).format(context)}",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              "${e.e.resourceId}",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  resourceBuilder: (context, item) {
                    return Container(
                      decoration: BoxDecoration(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                )),
                            child: Text(
                              item.resource?.name ?? "",
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                          const SizedBox(height: 5),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
