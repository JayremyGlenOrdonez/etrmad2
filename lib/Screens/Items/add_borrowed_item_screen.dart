// lib/Screens/Items/add_borrowed_item_screen.dart

import 'dart:developer';
import 'dart:io';
import 'dart:math' as math; // <--- CORRECT LOCATION for dart:math import

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myapp/Database/db_helper.dart';
// IMPORTANT: Make sure this points to your FirebaseDbHelper
import 'package:myapp/Styles/custom_colors.dart';
import 'package:myapp/models/borrowed_item.dart';
import 'package:myapp/models/item_model.dart';
import 'package:myapp/services/notification_helper.dart';
import 'package:myapp/utils/custom_tools.dart';
import 'package:myapp/utils/widgets.dart';

import '../../controller/borrow_controller.dart';

class AddBorrowedItemScreen extends StatefulWidget {
  const AddBorrowedItemScreen({super.key});

  @override
  State<AddBorrowedItemScreen> createState() => _AddBorrowedItemScreenState();
}

class _AddBorrowedItemScreenState extends State<AddBorrowedItemScreen> {
  var controller = Get.put(BorrowController());
  final List<Items> items = []; // List to hold items temporarily
  var formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final itemsController = TextEditingController(); // For new item name input

  final itemQuantityController =
      TextEditingController(); // For new item quantity input
  final dateReturnController = TextEditingController();

  DateTime? dateReturn;
  String status = 'Pending'; // Default status for new borrowed items

  @override
  void dispose() {
    titleController.dispose();
    itemsController.dispose();
    itemQuantityController.dispose();
    dateReturnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Add Borrowed Item'),
        actions: [
          IconButton(
            onPressed: () async {
              // Validate the main form fields
              if (!formKey.currentState!.validate()) {
                return;
              }

              // Ensure title and return date are present.
              if (titleController.text.isEmpty ||
                  dateReturnController.text.isEmpty) {
                await showDialog(
                  context: context,
                  builder: (context) => failedDialog(
                    context,
                    message: 'Title and Date to return are required.',
                  ),
                );
                return;
              }

              // Check if any items have been added to the list
              if (items.isEmpty) {
                await showDialog(
                  context: context,
                  builder: (context) => failedDialog(
                    context,
                    message: 'Please add at least one item.',
                  ),
                );
                return;
              }

              // Create the BorrowedItem model
              var borrow = BorrowedItem(
                title: titleController.text,
                items: items,
                dateReturned: dateReturn!,
                status: 'Pending', // Default status for new borrowed items
                // Firebase will automatically assign an ID upon insertion,
                // so we don't set it here for a new item.
              );

              // Insert the borrowed item into Firebase
              var borrowedItem = await FirebaseDbHelper.instance
                  .insertBorrowedItem(borrow);

              // **CRITICAL FIX FOR NOTIFICATION ID & SUCCESS CHECK:**
              // Check if the returned borrowedItem is not null AND its ID is not null AND not empty.
              if (borrowedItem != null &&
                  borrowedItem.id != null &&
                  borrowedItem.id!.isNotEmpty) {
                // Generate a random integer ID for the notification.
                // This is the safest way to get an int ID from a Firebase String ID.
                final int notificationId = math.Random().nextInt(
                  2147483647,
                ); // Max value for a 32-bit signed int

                NotificationHelper.scheduleNotification(
                  id: notificationId, // Use the generated random int ID
                  title: 'Borrowed Item Reminder', // More specific title
                  body:
                      'Time to return "${borrowedItem.title}"!', // Dynamic body
                  date: borrowedItem.dateReturned,
                );

                await showDialog(
                  context: context,
                  builder: (context) => successDialog(
                    context,
                    message: 'Borrowed item added successfully!',
                  ),
                );
                // Correctly pop the AddBorrowedItemScreen and refresh the list
                Navigator.pop(context); // Pop AddBorrowedItemScreen to go back
                controller.refresh(); // Refresh the list on the previous screen
              } else {
                // If the borrowedItem or its ID is null/empty after insertion, show a failed message.
                await showDialog(
                  context: context,
                  builder: (context) => failedDialog(
                    context,
                    message:
                        'Failed to add borrowed item to Firebase. Please try again.',
                  ),
                );
              }
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Column(
                  children: [
                    textFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Title is required';
                        }
                        return null;
                      },
                      label: 'Title',
                      controller: titleController,
                    ),
                    gap(height: 10.0),
                    dateTimeFormField(
                      context,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Date to return is required';
                        }
                        return null;
                      },
                      label: 'Date to return',
                      onTap: () => pickDateTime(context),
                      controller: dateReturnController,
                    ),
                    gap(height: 10.0),
                    divider(),
                    gap(height: 10.0),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: textFormField(
                            label: 'Item name',
                            controller: itemsController,
                          ),
                        ),
                        gap(width: 8.0),
                        Expanded(
                          flex: 1,
                          child: textFormField(
                            label: 'Quantity',
                            isNumber: true,
                            controller: itemQuantityController,
                            // Ensure numeric keyboard
                          ),
                        ),
                      ],
                    ),
                    gap(height: 4.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: MaterialButton(
                        onPressed: () async {
                          // Basic validation for item addition
                          if (itemsController.text.isEmpty ||
                              itemQuantityController.text.isEmpty) {
                            await showDialog(
                              context: context,
                              builder: (builder) {
                                return failedDialog(
                                  context,
                                  message:
                                      'Item name and Quantity are required',
                                );
                              },
                            );
                            return;
                          }

                          if (!GetUtils.isNumericOnly(
                            itemQuantityController.text.trim(),
                          )) {
                            await showDialog(
                              context: context,
                              builder: (builder) {
                                return failedDialog(
                                  context,
                                  message: 'Quantity must be a valid number',
                                );
                              },
                            );
                            return;
                          }

                          // Add the new item to the local list
                          setState(() {
                            items.add(
                              Items(
                                name: itemsController.text.trim(),
                                quantity: int.parse(
                                  itemQuantityController.text.trim(),
                                ),
                                isReturned:
                                    false, // Newly added items are not returned yet
                              ),
                            );
                            itemsController.clear();
                            itemQuantityController.clear();
                          });
                        },
                        color: primaryColor,
                        child: const Text(
                          'Add',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                // Display the list of added items
                ListView.builder(
                  itemCount: items.length,
                  shrinkWrap:
                      true, // Use shrinkWrap when ListView is inside another scrollable widget
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable internal scrolling
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(
                        vertical: 4.0,
                      ), // Add vertical margin for separation
                      child: ListTile(
                        title: Text(
                          items[index].name,
                        ), // 'name' is non-nullable now
                        subtitle: Text('${items[index].quantity} Items'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              snackBar(
                                context,
                                message: '${items[index].name} removed',
                              );
                              items.removeAt(index);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to pick date and time
  void pickDateTime(BuildContext context) async {
    final date = await pickDate(context, initialDate: dateReturn);
    if (date == null) return;

    final time = await pickTime(
      context,
      initialTime: dateReturn == null
          ? null
          : TimeOfDay(hour: dateReturn!.hour, minute: dateReturn!.minute),
    );

    if (time != null) {
      setState(() {
        dateReturn = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        log(dateReturn.toString());
        // Format date and time for display in the text field
        final formattedDate = DateFormat('MMMM dd,yyyy').format(dateReturn!);
        final formattedTime = DateFormat('h:mm a').format(dateReturn!);
        dateReturnController.text = '$formattedDate | $formattedTime';
      });
    }
  }
}
