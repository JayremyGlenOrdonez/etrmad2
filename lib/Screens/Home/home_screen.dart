
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/Screens/Events/event_view.dart';
import 'package:myapp/Styles/custom_colors.dart';
import 'package:myapp/constant/global.dart';
import 'package:myapp/controller/event_controller.dart';
import 'package:myapp/utils/custom_tools.dart';

import '../../utils/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(EventController());

    //
    return Obx(() {
      if (EVENTLIST.isEmpty) {
        return const Center(
            child: Text(
          'No events found',
          style: TextStyle(
            fontSize: 14,
            color: labelColor,
            fontStyle: FontStyle.italic,
          ),
        ));
      } else {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reminders Section
              // sectionTitle(
              //   context,
              //   'Reminders',
              //   icon: Icons.alarm,
              //   color: Colors.deepOrange,
              // ),
              // gap(height: 10.0),
              // _buildRemindersList(),

              // gap(height: 20.0),
              // divider(),
              // gap(height: 20.0),

              // Current Events Section

              if (CURRENT_EVENTLIST.isNotEmpty)
                Wrap(
                  children: [
                    sectionTitle(
                      context,
                      'Current Events',
                      icon: Icons.event_note,
                      color: Colors.blue,
                    ),
                    gap(height: 10.0),
                    ...CURRENT_EVENTLIST.value.map((event) {
                      return InkWell(
                        onTap: () {
                          gotoScreen(context,
                              screen: EventViewScreen(event: event));
                        },
                        child: eventCard(
                          context,
                          title: event.name,
                          status: event.status,
                          items: event.items.length,
                          image: event.image,
                        ),
                      );
                    }),
                  ],
                ),

              if (CURRENT_EVENTLIST.isNotEmpty && UPCOMING_EVENTLIST.isNotEmpty)
                Wrap(
                  children: [
                    gap(height: 20.0),
                    divider(),
                    gap(height: 20.0),
                  ],
                ),
              // Upcoming Events Section

              if (UPCOMING_EVENTLIST.isNotEmpty)
                Wrap(
                  children: [
                    sectionTitle(
                      context,
                      'Upcoming Events',
                      icon: Icons.event,
                      color: Colors.green,
                    ),
                    gap(height: 10.0),
                    ...UPCOMING_EVENTLIST.value.map((event) {
                      return InkWell(
                        onTap: () {
                          gotoScreen(context,
                              screen: EventViewScreen(event: event));
                        },
                        child: eventCard(
                          context,
                          title: event.name,
                          status: event.status,
                          items: event.items.length,
                          image: event.image,
                        ),
                      );
                    }),
                  ],
                ),
            ],
          ),
        );
      }
    });
  }

  Widget _buildRemindersList() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        reminderCard(
          "Don’t forget to pack the speaker for Jessica’s Wedding tomorrow.",
        ),
        reminderCard("Return fairy lights to Michael by Dec 20."),
        reminderCard("Mark all items retrieved for Emily’s Party."),
      ],
    );
  }
}
