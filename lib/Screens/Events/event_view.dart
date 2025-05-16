
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myapp/Database/db_helper.dart';
import 'package:myapp/Screens/Events/edit_event_screen_copy.dart';
import 'package:myapp/Screens/Events/item_retrieve_screen.dart';
import 'package:myapp/Styles/custom_colors.dart';
import 'package:myapp/controller/event_controller.dart';
import 'package:myapp/models/event_model.dart';
import 'package:myapp/utils/custom_tools.dart';
import 'package:myapp/utils/widgets.dart';

class EventViewScreen extends StatefulWidget {
  const EventViewScreen({super.key, required this.event});
  final Event event;

  @override
  State<EventViewScreen> createState() => _EventViewScreenState();
}

class _EventViewScreenState extends State<EventViewScreen> {
  var eventController = Get.put(EventController());

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final formattedDate =
        DateFormat('MMMM d, yyyy • h:mm a').format(event.dateTime);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Event Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Event Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(20)),
              child: widget.event.image != null
                  ? Image.file(
                      event.image!,
                      fit: BoxFit.cover,
                      height: 250,
                      width: double.infinity,
                    )
                  : const Center(
                      child: Icon(
                        Icons.event,
                        color: labelColor,
                      ),
                    ),
            ),
            const SizedBox(height: 16),

            // Event Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Name
                  Text(
                    event.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),

                  // Event Venue
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.redAccent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        event.venue ?? 'No venue',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Event Date & Time
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Colors.blueAccent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        formattedDate,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Event Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description ?? 'No description provided',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  // Event Items
                  if (event.items.isNotEmpty) ...[
                    Text(
                      'Items',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ...event.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          '- ${item.name ?? 'N/A'} (${item.quantity ?? 'N/A'} items) ${item.isReturned ? '[Retrieved]' : '[Not retrieved]'}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ],

                  gap(height: 16.0),
                  //
                  Row(
                    children: [
                      //
                      MaterialButton(
                        textColor: Colors.white,
                        color: Colors.red,
                        onPressed: () async {
                          await showDialog(
                            context: context,
                            builder: (context) => deleteEventModal(
                              context,
                              onDelete: () async {
                                await DbHelper.instance
                                    .deleteEvent(widget.event.id);
                                setState(() {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                  eventController.refresh();
                                });
                              },
                            ),
                          );
                        },
                        child: const Text('Delete'),
                      ),
                      gap(width: 16.0),
                      Visibility(
                        visible: !(widget.event.status == 'Current' ||
                            widget.event.status == 'Ended'),
                        child: MaterialButton(
                          textColor: Colors.white,
                          color: primaryColor,
                          onPressed: () {
                            gotoScreenReplacement(context,
                                screen: EditEventScreen(event: event));
                          },
                          child: const Text('Edit'),
                        ),
                      ),

                      gap(width: 16.0),
                      //
                      Visibility(
                        visible: widget.event.status == 'Current',
                        child: MaterialButton(
                          textColor: Colors.white,
                          color: Colors.orange,
                          onPressed: () {
                            gotoScreenReplacement(context,
                                screen:
                                    ItemRetrieveScreen(event: widget.event));
                          },
                          child: const Text('Retrieve Items'),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
