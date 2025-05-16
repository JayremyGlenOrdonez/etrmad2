import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/Database/db_helper.dart';
import 'package:myapp/Screens/Events/create_event_screen.dart';
import 'package:myapp/Screens/Events/event_view.dart';
import 'package:myapp/constant/global.dart';
import 'package:myapp/controller/event_controller.dart';
import 'package:myapp/models/event_model.dart';
import 'package:myapp/utils/custom_tools.dart';

import '../../Styles/custom_colors.dart';
import '../../services/notification_helper.dart';
import '../../utils/widgets.dart'; // Ensure this import is added for MenuScreen

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  var eventController = Get.put(EventController());

  //

  String status = 'All';

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              addEventButtonIcon(
                context,
                onTap: () {
                  gotoScreen(context, screen: const CreateEventScreen());
                },
              ),
              gap(height: 16.0),
              eventsDropDownButton(context, onSelected: (value) {
                setState(() {
                  status = value!;
                });
              }),
            ],
          ),
          gap(height: 10.0),
          Obx(() {
            List<Event> events = [];
            if (status == 'All') {
              events = EVENTLIST.value;
            } else if (status == 'Upcoming') {
              events = UPCOMING_EVENTLIST.value;
            } else if (status == 'Current') {
              events = CURRENT_EVENTLIST.value;
            } else if (status == 'Ended') {
              events = ENDED_EVENTLIST.value;
            }

            if (events.isEmpty) {
              return SizedBox(
                width: size.width,
                height: size.height * 0.54,
                child: const Center(
                  child: Text(
                    'No events found',
                    style: TextStyle(
                      fontSize: 14,
                      color: labelColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              );
            }

            return SizedBox(
              width: size.width,
              height: size.height * 0.54,
              child: listOfEvents(events: events),
            );
          }),
        ],
      ),
    );
  }

  Widget listOfEvents({required List<Event> events}) {
    return ListView.builder(
      itemCount: events.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Dismissible(
          key: Key(events[index].id.toString()),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              return await showDialog(
                context: context,
                builder: (context) => deleteEventModal(
                  context,
                  onDelete: () async {
                    await DbHelper.instance.deleteEvent(events[index].id);
                    setState(() {
                      Navigator.of(context).pop();
                      eventController.refresh();
                    });
                  },
                ),
              );
            }
            return false;
          },
          background: Container(
            padding: const EdgeInsets.only(right: 16.0),
            alignment: Alignment.centerRight,
            color: Colors.red,
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          child: InkWell(
            onTap: () {
              gotoScreen(
                context,
                screen: EventViewScreen(event: events[index]),
              );
            },
            child: eventCard(
              context,
              title: events[index].name,
              status: events[index].status,
              image: events[index].image,
              items: events[index].items.length,
            ),
          ),
        );
      },
    );
  }
}
