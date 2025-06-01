import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/Database/db_helper.dart';
// Change this import to point to your new FirebaseDbHelper
import 'package:myapp/Screens/Events/event_view.dart';
import 'package:myapp/Styles/custom_colors.dart';
import 'package:myapp/controller/event_controller.dart';
import 'package:myapp/models/event_model.dart';
import 'package:myapp/models/item_model.dart';

import '../../utils/custom_tools.dart';

class ItemRetrieveScreen extends StatefulWidget {
  ItemRetrieveScreen({super.key, required this.event});
  Event event;
  @override
  State<ItemRetrieveScreen> createState() => _ItemRetrieveScreenState();
}

class _ItemRetrieveScreenState extends State<ItemRetrieveScreen> {
  var controller = Get.put(EventController());

  // Local list to hold the items for modification
  List<Items> items = [];

  @override
  void initState() {
    super.initState();
    // Deep copy the list to avoid modifying the original event object directly
    items = List<Items>.from(
      widget.event.items.map(
        (item) => Items(
          name: item.name,
          quantity: item.quantity,
          isReturned: item.isReturned,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Retrieve Items')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              // Wrap ListView.builder with Expanded to give it bounded height
              child: ListView.builder(
                itemCount: items.length,
                shrinkWrap: true, // This is fine when inside Expanded
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.all(8.0),
                    child: Card(
                      child: ListTile(
                        leading: Checkbox(
                          value: items[index].isReturned,
                          onChanged: (value) {
                            setState(() {
                              items[index].isReturned = value!;
                            });
                          },
                        ),
                        // 'name' is non-nullable in Item model now
                        title: Text(items[index].name),
                        trailing: Text('${items[index].quantity} Items'),
                      ),
                    ),
                  );
                },
              ),
            ),
            gap(height: 12.0),
            Row(
              children: [
                // Update Event Button
                MaterialButton(
                  textColor: Colors.white,
                  color: primaryColor,
                  onPressed: () async {
                    // Update the event object with the modified items list
                    widget.event.items = items;
                    // Use FirebaseDbHelper.instance to update the event
                    var updatedEvent = await FirebaseDbHelper.instance
                        .updateEvent(widget.event); // <--- UPDATED INSTANCE

                    // Navigate back to EventViewScreen with the updated event
                    gotoScreenReplacement(
                      context,
                      screen: EventViewScreen(event: updatedEvent),
                    );
                    controller.refresh(); // Refresh the main event list
                  },
                  child: const Text('Update Event'),
                ),

                gap(width: 12.0),
                // End Event Button
                MaterialButton(
                  textColor: Colors.white,
                  color: Colors.red,
                  onPressed: () async {
                    // Update the event object with modified items and status
                    widget.event.items = items;
                    widget.event.status = 'Ended';
                    // Use FirebaseDbHelper.instance to update the event
                    var updatedEvent = await FirebaseDbHelper.instance
                        .updateEvent(widget.event); // <--- UPDATED INSTANCE

                    // Navigate back to EventViewScreen with the updated event
                    gotoScreenReplacement(
                      context,
                      screen: EventViewScreen(event: updatedEvent),
                    );
                    controller.refresh(); // Refresh the main event list
                  },
                  child: const Text('End Event'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
