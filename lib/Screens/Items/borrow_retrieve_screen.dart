import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/Database/db_helper.dart';
import 'package:myapp/Screens/Items/borrowed_item_view.dart';
import 'package:myapp/Styles/custom_colors.dart';
import 'package:myapp/controller/borrow_controller.dart';
import 'package:myapp/models/borrowed_item.dart';
import 'package:myapp/models/item_model.dart';
import '../../utils/custom_tools.dart';

class BorrowItemRetrieveScreen extends StatefulWidget {
  BorrowItemRetrieveScreen({super.key, required this.borrowedItem});
  BorrowedItem borrowedItem;
  @override
  State<BorrowItemRetrieveScreen> createState() =>
      _BorrowItemRetrieveScreenState();
}

class _BorrowItemRetrieveScreenState extends State<BorrowItemRetrieveScreen> {
  var controller = Get.put(BorrowController());
  List<Items> items = [];

  @override
  void initState() {
    super.initState();
    items = List<Items>.from(
      widget.borrowedItem.items.map(
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
              child: ListView.builder(
                itemCount: items.length,
                shrinkWrap: true,
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
                MaterialButton(
                  textColor: Colors.white,
                  color: primaryColor,
                  onPressed: () async {
                    widget.borrowedItem.items = items;
                    var updatedBorrowedItem = await FirebaseDbHelper.instance
                        .updateBorrowedItem(widget.borrowedItem);
                    gotoScreenReplacement(
                      context,
                      screen: ItemViewScreen(borrowedItem: updatedBorrowedItem),
                    );
                    controller.refresh();
                  },
                  child: const Text('Update Items'),
                ),
                gap(width: 12.0),
                MaterialButton(
                  textColor: Colors.white,
                  color: Colors.red,
                  onPressed: () async {
                    widget.borrowedItem.items = items;
                    widget.borrowedItem.status = 'Returned';
                    await FirebaseDbHelper.instance.updateBorrowedItem(
                      widget.borrowedItem,
                    );
                    controller.refresh();
                    Navigator.of(context).pop();
                  },
                  child: const Text('End Retrieval'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
