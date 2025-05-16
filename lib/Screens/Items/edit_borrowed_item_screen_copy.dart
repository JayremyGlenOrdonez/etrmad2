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
  BorrowedItem borrowedItem;
  @override
  State<EditBorrowedItemScreen> createState() => _EditBorrowedItemScreenState();
}

class _EditBorrowedItemScreenState extends State<EditBorrowedItemScreen> {
  var controller = Get.find<BorrowController>();
  final List<Items> items = [];
  var formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final itemsController = TextEditingController();

  final itemQuantityController = TextEditingController();
  final dateReturnController = TextEditingController();

  DateTime? dateReturn;
  String status = 'Pending';

  @override
  void initState() {
    titleController.text = widget.borrowedItem.title;
    items.addAll(widget.borrowedItem.items);
    dateReturn = widget.borrowedItem.dateReturned;
    status = widget.borrowedItem.status;

    dateReturnController.text =
        DateFormat('MMMM dd, yyyy | h:mm a').format(dateReturn!);

    super.initState();
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
              if (!formKey.currentState!.validate()) {
                return;
              }

              if (titleController.text.isNotEmpty &&
                  dateReturnController.text.isNotEmpty) {
                var borrow = BorrowedItem(
                  id: widget.borrowedItem.id,
                  title: titleController.text,
                  items: items,
                  dateReturned: dateReturn!,
                  status: status,
                );

                var borrowed =
                    await DbHelper.instance.updateBorrowedItem(borrow);

                if (borrowed.id != 0) {
                  await showDialog(
                      context: context,
                      builder: (builder) {
                        return successDialog(context,
                            message:
                                'Borrowed item has been updated successfully');
                      });

                  Navigator.pop(context);
                  controller.refresh();
                }
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
                          if (itemsController.text.isEmpty ||
                              itemQuantityController.text.isEmpty) {
                            await showDialog(
                                context: context,
                                builder: (builder) {
                                  return failedDialog(context,
                                      message: 'All fields are required');
                                });
                            return;
                          }
                          if (!GetUtils.isNumericOnly(
                              itemQuantityController.text)) {
                            await showDialog(
                                context: context,
                                builder: (builder) {
                                  return failedDialog(context,
                                      message: 'Quantity must be a number');
                                });

                            return;
                          }
                          setState(() {
                            items.add(Items(
                              name: itemsController.text,
                              quantity:
                                  int.parse(itemQuantityController.text.trim()),
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
        ),
      ),
    );
  }

  void pickDateTime(BuildContext context) async {
    final date = await pickDate(context, initialDate: dateReturn);
    if (date == null) return;

    final time = await pickTime(context,
        initialTime: dateReturn == null
            ? null
            : TimeOfDay(hour: dateReturn!.hour, minute: dateReturn!.minute));

    //
    if (time != null) {
      setState(() {
        dateReturn =
            DateTime(date.year, date.month, date.day, time.hour, time.minute);

        log(dateReturn.toString());
        // Format date and time
        final formattedDate = DateFormat('MMMM dd, yyyy')
            .format(dateReturn!); // Example: November 5, 2023

        //
        final formattedTime =
            DateFormat('h:mm a').format(dateReturn!); // Example: 12:00 AM

        // Combine formatted date and time
        dateReturnController.text = '$formattedDate | $formattedTime';
      });
    }
  }
}
