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

    return Obx(() {
      // Check if data is still loading
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      // If not loading and no events are found
      else if (EVENTLIST.isEmpty) {
        return const Center(
          child: Text(
            'No events found',
            style: TextStyle(
              fontSize: 14,
              color: labelColor,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      }
      // If events are loaded
      else {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Events Section
              if (CURRENT_EVENTLIST.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                          gotoScreen(
                            context,
                            screen: EventViewScreen(event: event),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: eventCard(
                            context,
                            title: event.name,
                            status: event.status,
                            items: event.items.length,
                            image: event.image,
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),

              // Divider between Current and Upcoming only if both exist
              if (CURRENT_EVENTLIST.isNotEmpty && UPCOMING_EVENTLIST.isNotEmpty)
                Column(
                  children: [gap(height: 20.0), divider(), gap(height: 20.0)],
                ),
              // Upcoming Events Section
              if (UPCOMING_EVENTLIST.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                          gotoScreen(
                            context,
                            screen: EventViewScreen(event: event),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: eventCard(
                            context,
                            title: event.name,
                            status: event.status,
                            items: event.items.length,
                            image: event.image,
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
            ],
          ),
        );
      }
    });
  }

  // The _buildRemindersList was commented out because it contained static content.
  // If you wish to implement dynamic reminders based on actual event data,
  // this section would need significant logic to pull reminder information from events
  // and display it, possibly scheduling notifications via notification_helper.dart.
  // For now, it's best to leave it commented out if it's not being actively used
  // with dynamic data, to avoid confusing static vs. dynamic content.
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
