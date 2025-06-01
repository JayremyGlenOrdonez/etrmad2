import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myapp/Database/db_helper.dart';
import 'package:myapp/Styles/custom_colors.dart';
import 'package:myapp/controller/borrow_controller.dart';
import 'package:myapp/models/borrowed_item.dart';
import 'package:myapp/models/item_model.dart';
import 'package:myapp/utils/custom_tools.dart';
import 'package:myapp/utils/widgets.dart';

class EditBorrowedItemScreen extends StatefulWidget {
  EditBorrowedItemScreen({super.key, required this.borrowedItem});
  final BorrowedItem
  borrowedItem; // Made final as it's passed in the constructor

  @override
  State<EditBorrowedItemScreen> createState() => _EditBorrowedItemScreenState(); // Corrected State class name
}

class _EditBorrowedItemScreenState extends State<EditBorrowedItemScreen> {
  // Corrected State class name
  var controller = Get.find<BorrowController>();
  final List<Items> items = []; // Local list to hold and modify items
  var formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final itemsController = TextEditingController();

  final itemQuantityController = TextEditingController();
  final dateReturnController = TextEditingController();

  DateTime? dateReturn;
  String status =
      'Pending'; // Default status when editing, usually retains original status

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data from the passed borrowedItem
    titleController.text = widget.borrowedItem.title;
    dateReturn = widget.borrowedItem.dateReturned;
    status = widget.borrowedItem.status; // Retain the existing status

    // Deep copy the list of items from the original borrowedItem
    // This ensures modifications here don't affect the original object until saved.
    items.addAll(
      widget.borrowedItem.items.map(
        (item) => Items(
          name: item.name,
          quantity: item.quantity,
          isReturned: item.isReturned,
        ),
      ),
    );

    // Format and set the date return controller's text for display
    dateReturnController.text = DateFormat(
      'MMMM dd,yyyy | h:mm a',
    ).format(dateReturn!);
  }

  @override
  void dispose() {
    // Dispose all TextEditingControllers to prevent memory leaks
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
        title: const Text('Edit Borrowed Item'),
        actions: [
          IconButton(
            onPressed: () async {
              // Validate the main form fields first
              if (!formKey.currentState!.validate()) {
                return;
              }

              // Double-check if title and return date are populated (should be covered by validators)
              if (titleController.text.isEmpty ||
                  dateReturnController.text.isEmpty) {
                // Fallback message if validators somehow miss it
                await showDialog(
                  context: context,
                  builder: (context) => failedDialog(
                    context,
                    message: 'Title and Date to return are required.',
                  ),
                );
                return;
              }

              // Construct the updated BorrowedItem object
              var borrow = BorrowedItem(
                id: widget
                    .borrowedItem
                    .id, // CRITICAL: Retain the existing Firebase ID for update
                title: titleController.text,
                items: items, // Use the locally modified list of items
                dateReturned: dateReturn!, // Must be non-null due to validator
                status: status, // Retain the current status
              );

              // Call FirebaseDbHelper to update the borrowed item
              var updatedBorrowed = await FirebaseDbHelper.instance
                  .updateBorrowedItem(borrow);

              // Check if the update was successful (assuming updateBorrowedItem returns the updated object with its ID)
              if (updatedBorrowed != null && updatedBorrowed.id != null) {
                await showDialog(
                  context: context,
                  builder: (builder) {
                    return successDialog(
                      context,
                      message: 'Borrowed item has been updated successfully!',
                    );
                  },
                );
                Navigator.pop(
                  context,
                ); // Pop the EditBorrowedItemScreen to go back
                controller
                    .refresh(); // Refresh the list in the previous screen(s)
              } else {
                await showDialog(
                  context: context,
                  builder: (context) => failedDialog(
                    context,
                    message:
                        'Failed to update borrowed item. Please try again.',
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
                          ),
                        ),
                      ],
                    ),
                    gap(height: 4.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: MaterialButton(
                        onPressed: () async {
                          // Validate new item fields before adding to the list
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
                          // Check if quantity is a valid number
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
                          // Add the new item to the local 'items' list
                          setState(() {
                            items.add(
                              Items(
                                name: itemsController.text.trim(),
                                quantity: int.parse(
                                  itemQuantityController.text.trim(),
                                ),
                                isReturned:
                                    false, // Newly added items are not returned by default
                              ),
                            );
                            itemsController.clear(); // Clear input fields
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
                // Display the list of existing and newly added items
                ListView.builder(
                  itemCount: items.length,
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(), // Important when nested in SingleChildScrollView
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(
                        vertical: 4.0,
                      ), // Add vertical spacing
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
                              items.removeAt(
                                index,
                              ); // Remove item from local list
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

  // Helper method to pick date and time for the return date
  void pickDateTime(BuildContext context) async {
    final date = await pickDate(context, initialDate: dateReturn);
    if (date == null) return; // User cancelled date selection

    final time = await pickTime(
      context,
      initialTime: dateReturn == null
          ? null
          : TimeOfDay(hour: dateReturn!.hour, minute: dateReturn!.minute),
    );

    if (time != null) {
      setState(() {
        // Combine selected date and time into a single DateTime object
        dateReturn = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        log(dateReturn.toString()); // Log the DateTime object for debugging

        // Format date and time for display in the text field
        final formattedDate = DateFormat('MMMM dd,yyyy').format(dateReturn!);
        final formattedTime = DateFormat('h:mm a').format(dateReturn!);
        dateReturnController.text = '$formattedDate | $formattedTime';
      });
    }
  }
}
