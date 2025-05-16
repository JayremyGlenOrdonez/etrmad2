
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myapp/Database/db_helper.dart';
import 'package:myapp/Screens/Items/borrow_retrieve_screen.dart';
import 'package:myapp/Screens/Items/edit_borrowed_item_screen_copy.dart';
import 'package:myapp/Styles/custom_colors.dart';
import 'package:myapp/controller/borrow_controller.dart';
import 'package:myapp/models/borrowed_item.dart';
import 'package:myapp/utils/custom_tools.dart';
import 'package:myapp/utils/widgets.dart';

class ItemViewScreen extends StatefulWidget {
  const ItemViewScreen({super.key, required this.borrowedItem});
  final BorrowedItem borrowedItem;

  @override
  State<ItemViewScreen> createState() => _ItemViewScreenState();
}

class _ItemViewScreenState extends State<ItemViewScreen> {
  var controller = Get.put(BorrowController());

  @override
  Widget build(BuildContext context) {
    final items = widget.borrowedItem;
    final formattedDate = DateFormat('MMMM d, yyyy').format(items.dateReturned);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Item Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Event Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Name
                  Text(
                    items.title ?? 'No title',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                  const SizedBox(height: 8),

                  // Event Date & Time
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Colors.blueAccent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Return at [$formattedDate]',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Items
                  if (items.items.isNotEmpty) ...[
                    Text(
                      'Items',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ...items.items.map(
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
                                    .deleteBorrowedItem(widget.borrowedItem.id);
                                setState(() {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                  controller.refresh();
                                });
                              },
                            ),
                          );
                        },
                        child: const Text('Delete'),
                      ),
                      gap(width: 16.0),
                      Visibility(
                        visible: (widget.borrowedItem.status == 'Pending'),
                        child: MaterialButton(
                          textColor: Colors.white,
                          color: primaryColor,
                          onPressed: () {
                            gotoScreenReplacement(context,
                                screen: EditBorrowedItemScreen(
                                  borrowedItem: widget.borrowedItem,
                                ));
                          },
                          child: const Text('Edit'),
                        ),
                      ),

                      gap(width: 16.0),
                      //
                      Visibility(
                        visible: widget.borrowedItem.status == 'Pending',
                        child: MaterialButton(
                          textColor: Colors.white,
                          color: Colors.orange,
                          onPressed: () {
                            gotoScreenReplacement(context,
                                screen: BorrowItemRetrieveScreen(
                                    borrowedItem: widget.borrowedItem));
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
