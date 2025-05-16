import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:myapp/Styles/custom_colors.dart';
import 'package:myapp/Styles/fonts.dart';
import 'package:myapp/controller/event_controller.dart';
import 'package:myapp/models/item_model.dart';
import 'package:myapp/utils/custom_tools.dart';
import 'package:myapp/utils/widgets.dart';
import '../../Database/db_helper.dart';
import '../../models/event_model.dart';
import '../../services/notification_helper.dart';

class EditEventScreen extends StatefulWidget {
  EditEventScreen({super.key, required this.event});
  Event event;
  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  var controller = Get.find<EventController>();

  @override
  void initState() {
    super.initState();

    eventNameController.text = widget.event.name;
    eventVenueController.text = widget.event.venue ?? "";
    eventDescriptionController.text = widget.event.description ?? "";
    selectedDateTime = widget.event.dateTime;
    packingDatetime = widget.event.packingDatetime;
    retrieveDatetime = widget.event.retrieveDatetime;

    items = widget.event.items;

    //
    if (widget.event.image != null) {
      imageFile = widget.event.image!;
    }
    if (widget.event.isPackingReminder || widget.event.isRetrieveReminder) {
      isReminder = true;
      isPackingReminder = widget.event.isPackingReminder;
      isRetrieveReminder = widget.event.isRetrieveReminder;
    }

    //

    //December 5, 2023 | 5:00 PM
    eventDateTimeController.text =
        DateFormat('MMMM d, yyyy | h:mm a').format(selectedDateTime!);
    eventPackingDateTimeController.text = packingDatetime == null
        ? ""
        : DateFormat('MMMM d, yyyy | h:mm a').format(packingDatetime!);
    eventRetrieveDateTimeController.text = retrieveDatetime == null
        ? ""
        : DateFormat('MMMM d, yyyy | h:mm a').format(retrieveDatetime!);
  }

  //

  Size size = const Size(0, 0);

  File? imageFile;

  final formKey = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();
  final eventNameController = TextEditingController();

  final eventVenueController = TextEditingController();

  final eventDescriptionController = TextEditingController();

  final eventDateTimeController = TextEditingController();

  final eventPackingDateTimeController = TextEditingController();
  final eventRetrieveDateTimeController = TextEditingController();

  final itemsController = TextEditingController();

  final itemQuantityController = TextEditingController();

  List<Items> items = [];

  DateTime? selectedDateTime;
  DateTime? packingDatetime;
  DateTime? retrieveDatetime;

  bool isReminder = false;
  bool isPackingReminder = false;
  bool isRetrieveReminder = false;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    //
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              colors: [
                primaryColor,
                secondaryColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: const Text(
            'Edit Event',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              fontFamily: fontFamily,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.black),
            onPressed: () async {
              if (!(formKey.currentState?.validate() ?? true)) {
                return;
              }

              if (eventDateTimeController.text.isEmpty ||
                  eventVenueController.text.isEmpty ||
                  eventDescriptionController.text.isEmpty ||
                  eventNameController.text.isEmpty) {
                showDialog(
                    context: context,
                    builder: (context) => failedDialog(context,
                        message: 'Please fill all the fields'));
                return;
              }

              if (selectedDateTime == null) {
                showDialog(
                    context: context,
                    builder: (context) => failedDialog(context,
                        message: 'Please select event date and time'));
                return;
              }

              if (packingDatetime == null && isPackingReminder) {
                showDialog(
                    context: context,
                    builder: (context) => failedDialog(context,
                        message: 'Please select packing date and time'));
                return;
              }

              if (retrieveDatetime == null && isRetrieveReminder) {
                showDialog(
                    context: context,
                    builder: (context) => failedDialog(context,
                        message: 'Please select retrieve date and time'));
                return;
              }

              if (items.isEmpty) {
                showDialog(
                    context: context,
                    builder: (context) => failedDialog(context,
                        message: 'Please add at least one items'));
                return;
              }

              var database = DbHelper.instance;

              var eventDateTime = DateTime(
                selectedDateTime!.year,
                selectedDateTime!.month,
                selectedDateTime!.day,
                selectedDateTime!.hour,
                selectedDateTime!.minute,
              );

              log(eventDateTime.toString());

              Event event = Event(
                id: widget.event.id,
                name: eventNameController.text,
                venue: eventVenueController.text,
                description: eventDescriptionController.text,
                dateTime: widget.event.dateTime,
                packingDatetime: packingDatetime,
                retrieveDatetime: retrieveDatetime,
                isPackingReminder: isPackingReminder,
                isRetrieveReminder: isRetrieveReminder,
                image: imageFile,
                status: widget.event.status,
                items: items,
              );

              // //
              var eventAdded = await database.updateEvent(event);

              if (eventAdded.id == 0) {
                return;
              }

              if (eventAdded.isPackingReminder) {
                var datetime = eventAdded.packingDatetime!;

                //
                NotificationHelper.scheduleNotification(
                  id: UniqueKey().hashCode,
                  title: 'Packing Reminder',
                  body: 'You need to pack items for ${eventAdded.name}',
                  date: datetime,
                  bigPicture: eventAdded.image?.path,
                );
              }

              if (eventAdded.isRetrieveReminder) {
                var datetime = eventAdded.retrieveDatetime!;

                //
                NotificationHelper.scheduleNotification(
                  id: UniqueKey().hashCode,
                  title: 'Retrieve Reminder',
                  body: 'It is time to retrieve items for ${eventAdded.name}',
                  date: datetime,
                  bigPicture: eventAdded.image?.path,
                );
              }

              Navigator.of(context).pop();
              controller.refresh();
            },
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color(0xFF00A6D8),
              tabs: [
                Tab(text: 'Details'),
                Tab(text: 'Item List'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  eventDetailsForm(context),
                  itemList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget eventDetailsForm(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              imageDisplay(),

              gap(height: 14.0),
              textFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event name';
                  }
                  return null;
                },
                label: 'Enter event name',
                controller: eventNameController,
              ),

              gap(height: 14.0),
              textFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event venue or address';
                  }
                  return null;
                },
                label: 'Enter venue or address (Optional)',
                controller: eventVenueController,
              ),
              gap(height: 14.0),
              textFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event description';
                  }
                  return null;
                },
                label: 'Add extra details (e.g., theme, dress code)',
                controller: eventDescriptionController,
                maxLine: 3,
              ),
              gap(height: 14.0),

              // Date Picker
              dateTimeFormField(
                context,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select event date and time';
                  }
                  return null;
                },
                controller: eventDateTimeController,
                label: 'Event Date & Time',
                readOnly: true,
                onTap: () => pickEventDateTime(context),
              ),

              gap(height: 16.0),
              divider(),
              gap(height: 16.0),

              reminderToggle(),
              gap(height: 16.0),
              createReminder(),
            ],
          ),
        ),
      ),
    );
  }

  Widget itemList() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Form(
        key: formKey2,
        child: Column(
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: textFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter item name';
                          }
                          return null;
                        },
                        label: 'Item name',
                        controller: itemsController,
                      ),
                    ),
                    gap(width: 8.0),
                    Expanded(
                      flex: 1,
                      child: textFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter quantity';
                          }
                          if (GetUtils.isNumericOnly(value) == false) {
                            return 'Invalid';
                          }
                          return null;
                        },
                        label: 'Quantity',
                        isNumber: true,
                        controller: itemQuantityController,
                      ),
                    ),
                  ],
                ),
                gap(height: 4.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: MaterialButton(
                    onPressed: () {
                      if (formKey2.currentState!.validate() == false) return;

                      setState(() {
                        if (itemsController.text.isEmpty ||
                            itemQuantityController.text.isEmpty) return;

                        items.add(Items(
                          name: itemsController.text,
                          quantity:
                              int.parse(itemQuantityController.text.trim()),
                          isReturned: false,
                        ));
                        itemsController.clear();
                        itemQuantityController.clear();
                      });
                    },
                    color: primaryColor,
                    child: const Text('Add',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            ListView.builder(
              itemCount: items.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 2,
                  child: ListTile(
                      title: Text(items[index].name ?? 'N/A'),
                      subtitle: Text('${items[index].quantity} Items'),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          setState(() {
                            snackBar(context,
                                message: '${items[index].name} removed');
                            items.removeAt(index);
                          });
                        },
                      )),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget imageDisplay() {
    return InkWell(
      onTap: () async {
        var file = await pickImage(ImageSource.gallery);
        if (file != null) {
          setState(() {
            imageFile = file;
          });
        }
      },
      child: Container(
        width: size.width * 0.55,
        height: size.width * 0.55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: labelColor, width: 2.0),
        ),
        child: imageFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(6.0),
                child: Image.file(
                  imageFile!,
                  fit: BoxFit.cover,
                ),
              )
            : const Center(
                child: Icon(
                  Icons.add_a_photo,
                  color: labelColor,
                ),
              ),
      ),
    );
  }

  // Reminder
  Widget reminderToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Reminder',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: labelColor,
          ),
        ),
        Transform.scale(
          scale: 0.80,
          child: Switch(
            value: isReminder,
            onChanged: (value) {
              setState(() {
                isReminder = value;
                isPackingReminder = isReminder ? true : false;
                isRetrieveReminder = false;
                eventPackingDateTimeController.clear();
                eventRetrieveDateTimeController.clear();
                packingDatetime = null;
                retrieveDatetime = null;
              });
            },
            activeTrackColor: primaryColor,
            trackOutlineWidth: const WidgetStatePropertyAll(0),
            thumbIcon: WidgetStatePropertyAll(Icon(
              Icons.notifications,
              color: isReminder ? secondaryColor : Colors.white,
            )),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

  Widget createReminder() {
    if (!isReminder) {
      return Container();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
          leading: Icon(
            isPackingReminder
                ? Icons.notifications_active_outlined
                : Icons.notifications_off_outlined,
            color: Colors.black,
          ),
          title: const Text('Remind me to pack all items before the event.',
              style: TextStyle(color: Colors.black, fontSize: 14)),
          trailing: Transform.scale(
            scale: 0.7,
            child: Switch(
              value: isPackingReminder,
              onChanged: (value) {
                setState(() {
                  isPackingReminder = value;
                  if (!isPackingReminder && !isRetrieveReminder) {
                    isReminder = false;
                  }
                });
              },
              activeTrackColor: primaryColor,
              trackOutlineWidth: const WidgetStatePropertyAll(0),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),

        if (isPackingReminder) packDateTimeForm(),
        //
        gap(height: 10.0),
        divider(),
        gap(height: 10.0),

        //
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
          leading: Icon(
            isRetrieveReminder
                ? Icons.notifications_active_outlined
                : Icons.notifications_off_outlined,
            color: Colors.black,
          ),
          title: const Text('Remind me to retrieve an items after the event.',
              style: TextStyle(color: Colors.black, fontSize: 14)),
          trailing: Transform.scale(
            scale: 0.7,
            child: Switch(
              value: isRetrieveReminder,
              onChanged: (value) {
                setState(() {
                  isRetrieveReminder = value;
                  if (!isPackingReminder && !isRetrieveReminder) {
                    isReminder = false;
                  }
                });
              },
              activeTrackColor: primaryColor,
              trackOutlineWidth: const WidgetStatePropertyAll(0),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),

        if (isRetrieveReminder) retrieveDateTimeForm(),
      ],
    );
  }

//REMINDERS DATETIME FORMS
  Widget packDateTimeForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      child: dateTimeFormField(
        context,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please pick a date & time';
          }

          if (selectedDateTime == null) {
            return 'Please assign a event date & time';
          }

          if (packingDatetime != null) {
            if (packingDatetime!.isAtSameMomentAs(selectedDateTime!)) {
              return 'Pack date & time cannot be the same as event date & time';
            }
            if (packingDatetime!.isAfter(selectedDateTime!)) {
              return 'Pack date & time cannot be after event date & time';
            }
          }

          return null;
        },
        controller: eventPackingDateTimeController,
        label: 'Date & Time',
        onTap: () => pickPackDateTime(context),
      ),
    );
  }

  Widget retrieveDateTimeForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      child: dateTimeFormField(
        context,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please pick a date & time';
          }

          if (selectedDateTime == null) {
            return 'Please assign a event date & time';
          }

          if (retrieveDatetime != null) {
            if (retrieveDatetime!.isAtSameMomentAs(selectedDateTime!)) {
              return 'Retrieve date & time cannot be the same as event date & time';
            }
            if (retrieveDatetime!.isBefore(selectedDateTime!)) {
              return 'Retrieve date & time cannot be before event date & time';
            }
          }

          return null;
        },
        controller: eventRetrieveDateTimeController,
        label: 'Date & Time',
        onTap: () => pickRetrieveDateTime(context),
      ),
    );
  }

  // EVENT DATETIME
  void pickEventDateTime(BuildContext context) async {
    final date = await pickDate(context, initialDate: selectedDateTime);
    if (date == null) return;

    final time = await pickTime(context,
        initialTime: selectedDateTime == null
            ? null
            : TimeOfDay(
                hour: selectedDateTime!.hour,
                minute: selectedDateTime!.minute));

    //
    if (time != null) {
      setState(() {
        selectedDateTime =
            DateTime(date.year, date.month, date.day, time.hour, time.minute);

        log(selectedDateTime.toString());
        // Format date and time
        final formattedDate = DateFormat('MMMM dd, yyyy')
            .format(selectedDateTime!); // Example: November 5, 2023
        //
        final formattedTime =
            DateFormat('h:mm a').format(selectedDateTime!); // Example: 12:00 AM

        // Combine formatted date and time
        eventDateTimeController.text = '$formattedDate | $formattedTime';
      });
    }
  }

  // PACK DATETIME
  void pickPackDateTime(BuildContext context) async {
    final date = await pickDate(context, initialDate: packingDatetime);
    if (date == null) return;

    final time = await pickTime(context,
        initialTime: packingDatetime == null
            ? null
            : TimeOfDay(
                hour: packingDatetime!.hour, minute: packingDatetime!.minute));

    //
    if (time != null) {
      setState(() {
        packingDatetime =
            DateTime(date.year, date.month, date.day, time.hour, time.minute);

        log(packingDatetime.toString());
        // Format date and time
        final formattedDate = DateFormat('MMMM dd, yyyy')
            .format(packingDatetime!); // Example: November 5, 2023

        //
        final formattedTime =
            DateFormat('h:mm a').format(packingDatetime!); // Example: 12:00 AM

        // Combine formatted date and time
        eventPackingDateTimeController.text = '$formattedDate | $formattedTime';
      });
    }
  }

  //RETRIEVE DATETIME
  void pickRetrieveDateTime(BuildContext context) async {
    final date = await pickDate(context, initialDate: retrieveDatetime);
    if (date == null) return;

    final time = await pickTime(context,
        initialTime: retrieveDatetime == null
            ? null
            : TimeOfDay(
                hour: retrieveDatetime!.hour,
                minute: retrieveDatetime!.minute));

    //
    if (time != null) {
      setState(() {
        retrieveDatetime =
            DateTime(date.year, date.month, date.day, time.hour, time.minute);

        log(retrieveDatetime.toString());
        // Format date and time
        final formattedDate = DateFormat('MMMM dd, yyyy')
            .format(retrieveDatetime!); // Example: November 5, 2023

        //
        final formattedTime =
            DateFormat('h:mm a').format(retrieveDatetime!); // Example: 12:00 AM

        // Combine formatted date and time
        eventRetrieveDateTimeController.text =
            '$formattedDate | $formattedTime';
      });
    }
  }
}
