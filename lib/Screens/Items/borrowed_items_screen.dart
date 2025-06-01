import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/Database/db_helper.dart';
import 'package:myapp/Screens/Items/add_borrowed_item_screen.dart';
import 'package:myapp/Screens/Items/borrowed_item_view.dart';
import 'package:myapp/constant/global.dart';
import 'package:myapp/controller/borrow_controller.dart';
import 'package:myapp/models/borrowed_item.dart';
import 'package:myapp/utils/custom_tools.dart';
import '../../Styles/custom_colors.dart';
import '../../services/notification_helper.dart';
import '../../utils/widgets.dart';

class BorrowedItemScreen extends StatefulWidget {
  const BorrowedItemScreen({super.key});

  @override
  State<BorrowedItemScreen> createState() => _BorrowedItemScreenState();
}

class _BorrowedItemScreenState extends State<BorrowedItemScreen> {
  var controller = Get.put(BorrowController());
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
              addBorrowedButtonIcon(
                context,
                onTap: () {
                  gotoScreen(context, screen: const AddBorrowedItemScreen());
                },
              ),
              gap(height: 16.0),
              borrowedItemsDropDownButton(
                context,
                onSelected: (value) {
                  setState(() {
                    status = value!;
                  });
                },
              ),
            ],
          ),
          gap(height: 10.0),
          Obx(() {
            List<BorrowedItem> items = [];
            if (status == 'All') {
              items = BORROWEDLIST.value;
            } else if (status == 'Pending') {
              items = PENDING_BORROWEDLIST.value;
            } else if (status == 'Returned') {
              items = RETURNED_BORROWEDLIST.value;
            }

            if (items.isEmpty) {
              return SizedBox(
                width: size.width,
                height: size.height * 0.54,
                child: const Center(
                  child: Text(
                    'No borrowed items found',
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
              child: liftOfBorrowedItems(items: items),
            );
          }),
        ],
      ),
    );
  }

  Widget liftOfBorrowedItems({required List<BorrowedItem> items}) {
    return ListView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Dismissible(
          key: Key(items[index].id!),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              return await showDialog(
                context: context,
                builder: (context) => deleteEventModal(
                  context,
                  onDelete: () async {
                    await FirebaseDbHelper.instance.deleteBorrowedItem(
                      items[index].id!,
                    );
                    setState(() {
                      Navigator.of(context).pop();
                      controller.refresh();
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
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: InkWell(
            onTap: () {
              gotoScreen(
                context,
                screen: ItemViewScreen(borrowedItem: items[index]),
              );
            },
            child: borrowedCard(
              context,
              name: items[index].title,
              status: items[index].status,
              quantity: items[index].items.length,
            ),
          ),
        );
      },
    );
  }
}
