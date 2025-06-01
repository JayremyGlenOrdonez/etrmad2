import 'dart:io';

import 'package:flutter/material.dart';
import 'package:myapp/utils/custom_tools.dart';

import '../Screens/Events/create_event_screen.dart';
import '../Styles/custom_colors.dart';

Widget sectionTitle(
  BuildContext context,
  String title, {
  required IconData icon,
  required Color color,
}) {
  return Row(
    children: [
      Icon(icon, color: color),
      const SizedBox(width: 8.0),
      Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: labelColor,
        ),
      ),
    ],
  );
}

//CREATE BUTTON
Widget createEventButton(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [tertiaryColor, secondaryColor]),
      borderRadius: BorderRadius.circular(8.0),
    ),
    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left Side: Texts
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Event',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              'Be ready for upcoming events',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        // Right Side: Arrow Button
        InkWell(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.white, width: 0.5),
            ),
            child: const Icon(Icons.arrow_forward, color: Colors.white),
          ),
        ),
      ],
    ),
  );
}

//REMINDER CARD
Widget reminderCard(String text) {
  return Card(
    child: ListTile(
      leading: const Icon(Icons.check_box_outline_blank, color: Colors.black),
      title: Text(text),
    ),
  );
}

// EVENT CARD
Widget eventCard(
  BuildContext context, {
  required String title,
  required String status,
  required int items,
  File? image,
}) {
  return Card(
    child: ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(6.0),
                child: Image.file(image, fit: BoxFit.cover),
              )
            : const Center(child: Icon(Icons.event, color: labelColor)),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(
        '$items items',
        style: const TextStyle(
          fontSize: 14,
          color: labelColor,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: status == 'Upcoming'
                ? Colors.orange
                : status == 'Ended'
                ? labelColor
                : Colors.green,
            width: 1.5,
          ),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: status == 'Upcoming'
                ? Colors.orange
                : status == 'Ended'
                ? labelColor
                : Colors.green,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ),
  );
}

Widget borrowedCard(
  BuildContext context, {
  required String name,
  required String status,
  required int quantity,
  File? image,
}) {
  return Card(
    child: ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(6.0),
                child: Image.file(image, fit: BoxFit.cover),
              )
            : const Center(child: Icon(Icons.list_alt, color: labelColor)),
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(
        '$quantity items',
        style: const TextStyle(
          fontSize: 14,
          color: labelColor,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: status == 'Pending' ? Colors.orange : Colors.green,
            width: 1.5,
          ),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: status == 'Pending' ? Colors.orange : Colors.green,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ),
  );
}

// EVENTS DROPDOWN
Widget eventsDropDownButton(context, {Function(String?)? onSelected}) {
  return Row(
    mainAxisSize: MainAxisSize.max,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      sectionTitle(context, 'Events', icon: Icons.event, color: Colors.blue),
      DropdownMenu(
        onSelected: onSelected,
        width: 140,
        textAlign: TextAlign.end,
        textStyle: const TextStyle(
          color: labelColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        trailingIcon: const Icon(Icons.arrow_drop_down, color: labelColor),
        menuStyle: const MenuStyle(
          fixedSize: WidgetStatePropertyAll(Size(140, 200)),
        ),
        selectedTrailingIcon: const Icon(
          Icons.arrow_drop_up,
          color: Colors.grey,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(borderSide: BorderSide.none),
        ),
        initialSelection: 'All',
        dropdownMenuEntries: const [
          DropdownMenuEntry(label: 'All', value: 'All'),
          DropdownMenuEntry(label: 'Upcoming', value: 'Upcoming'),
          DropdownMenuEntry(label: 'Current', value: 'Current'),
          DropdownMenuEntry(label: 'Ended', value: 'Ended'),
        ],
      ),
    ],
  );
}

Widget borrowedItemsDropDownButton(context, {Function(String?)? onSelected}) {
  return Row(
    mainAxisSize: MainAxisSize.max,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      sectionTitle(
        context,
        'Items',
        icon: Icons.checklist,
        color: Colors.green,
      ),
      DropdownMenu(
        onSelected: onSelected,
        width: 140,
        textAlign: TextAlign.end,
        textStyle: const TextStyle(
          color: labelColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        trailingIcon: const Icon(Icons.arrow_drop_down, color: labelColor),
        menuStyle: const MenuStyle(
          fixedSize: WidgetStatePropertyAll(Size(140, 150)),
        ),
        selectedTrailingIcon: const Icon(
          Icons.arrow_drop_up,
          color: Colors.grey,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(borderSide: BorderSide.none),
        ),
        initialSelection: 'All',
        dropdownMenuEntries: const [
          DropdownMenuEntry(label: 'All', value: 'All'),
          DropdownMenuEntry(label: 'Pending', value: 'Pending'),
          DropdownMenuEntry(label: 'Returned', value: 'Returned'),
        ],
      ),
    ],
  );
}

Widget addEventButtonIcon(BuildContext context, {Function()? onTap}) {
  return Container(
    decoration: BoxDecoration(
      color: labelColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8.0),
    ),
    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.all(8.0),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
        gap(width: 16.0),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Event',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold, // Bold text
              ),
            ),
            Text(
              'Be ready for upcoming events',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget addBorrowedButtonIcon(BuildContext context, {Function()? onTap}) {
  return Container(
    decoration: BoxDecoration(
      color: labelColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8.0),
    ),
    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.all(8.0),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
        gap(width: 16.0),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Borrowed Items',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold, // Bold text
              ),
            ),
            Text(
              'Be aware of all your items',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ],
    ),
  );
}

//DATE FormField

Widget dateTimeFormField(
  BuildContext context, {
  required String label,
  TextEditingController? controller,
  Function()? onTap,
  bool readOnly = false,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    validator: validator,
    readOnly: true,
    controller: controller,
    decoration: InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(fontSize: 14, color: labelColor),
      border: const OutlineInputBorder(),
      suffixIcon: InkWell(
        onTap: readOnly ? null : onTap,
        child: Icon(
          Icons.calendar_month,
          color: readOnly ? labelColor : Colors.black,
        ),
      ),
    ),
  );
}

// Text Form Field
Widget textFormField({
  required String label,
  required TextEditingController controller,
  String? Function(String?)? validator,
  bool isNumber = false,
  int maxLine = 1,
  void Function(String)? onChanged, // Add this parameter
}) {
  return TextFormField(
    controller: controller,
    validator: validator,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    maxLines: maxLine,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
    onChanged: onChanged, // Pass the onChanged callback to the TextFormField
  );
}

//Modal delete event
Widget deleteEventModal(context, {Function()? onDelete}) {
  return AlertDialog(
    title: const Text('Delete Event?'),
    content: const Text('Are you sure you want to delete this event?'),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: onDelete,
        child: const Text('Delete', style: TextStyle(color: Colors.red)),
      ),
    ],
  );
}

Widget failedDialog(context, {required String message}) {
  return AlertDialog(
    title: const Text('Failed'),
    content: Text(message),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('OK'),
      ),
    ],
  );
}

Widget successDialog(context, {required String message}) {
  return AlertDialog(
    title: const Text('Success'),
    content: Text(message),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('OK'),
      ),
    ],
  );
}

void snackBar(context, {required String message}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
