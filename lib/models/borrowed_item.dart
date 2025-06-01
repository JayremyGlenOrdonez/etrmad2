import 'dart:convert';

// Remove DbHelper import
// import 'package:myapp/Database/db_helper.dart'; // <-- REMOVE THIS LINE
import 'package:myapp/models/item_model.dart'; // Make sure this model is updated as well

class BorrowedItem {
  // Change ID type to String and make it nullable for new items
  String? id;
  late String title;
  List<Items> items;
  late String status;
  late DateTime dateReturned;

  BorrowedItem({
    this.id, // Now nullable String
    required this.title,
    this.items = const [], // Initialize in constructor
    required this.dateReturned,
    required this.status,
  });

  // Factory constructor for creating a BorrowedItem from a Firestore Map
  factory BorrowedItem.fromJson(Map<String, dynamic> json) {
    // No need for DbHelper constants, use string literals directly
    return BorrowedItem(
      id:
          json['id']
              as String?, // If you pass the id in the map, otherwise null
      title: json['title'] as String? ?? '',
      // IMPORTANT: items should be read as a List of Maps directly from Firestore
      // Then map each map to an Items object using Items.fromJson()
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (itemJson) => Items.fromJson(itemJson as Map<String, dynamic>),
              )
              .toList() ??
          [],
      dateReturned: DateTime.parse(
        json['dateReturned'] as String,
      ), // Match 'dateReturned' key
      status: json['status'] as String? ?? '',
    );
  }

  // Convert a BorrowedItem object to a Map<String, dynamic> for Firestore insertion/update
  // Renamed from toMap/toCreateMap/toUpdateMap for clarity and consistency
  Map<String, dynamic> toJson() {
    // No need for DbHelper constants, use string literals directly
    return {
      // 'id' is typically not included here for Firestore
      // If you *need* to store it inside the document, uncomment this:
      // 'id': id,
      'title': title,
      // IMPORTANT: Convert List<Items> to List<Map<String, dynamic>> using Items.toJson()
      'items': items
          .map((item) => item.toJson())
          .toList(), // Store as Firestore Array
      'dateReturned': dateReturned
          .toIso8601String(), // Consistent string format for dates
      'status': status,
    };
  }
}
