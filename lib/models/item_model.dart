
class Items {
  // Removed 'id' because items are now embedded directly in Event/BorrowedItem documents,
  // and Firebase doesn't assign separate IDs to sub-objects within a document's array.
  // If you *did* need a unique ID for an item within the list, you'd generate it yourself (e.g., UUID).

  late String name;
  late int quantity;
  // Removed 'description' field completely as it's not used in your UI or logic.
  late bool isReturned;

  Items({
    required this.name, // Made 'name' required as it's a core identifier for an item.
    required this.quantity, // Made 'quantity' required.
    this.isReturned =
        false, // Default to false if not provided during object creation.
  });

  // Factory constructor for creating an Items object from a Map (e.g., from Firestore array)
  factory Items.fromJson(Map<String, dynamic> json) {
    return Items(
      // Ensure we're casting safely and providing fallbacks in case data is missing in Firestore
      name: json['name'] as String? ?? '', // Use null-aware operator for safety
      quantity: json['quantity'] as int? ?? 0,
      isReturned: json['isReturned'] as bool? ?? false,
    );
  }

  // Convert an Items object to a Map<String, dynamic> for embedding in Firestore documents
  Map<String, dynamic> toJson() {
    return {'name': name, 'quantity': quantity, 'isReturned': isReturned};
  }

  // Removed these static methods as they are not needed when items are embedded
  // directly as a List<Map<String, dynamic>> in Firestore documents.
  // Firestore handles the list of maps natively.
  // static String toJsonOfList(List<Items> items) { /* ... */ }
  // static List<Items> fromListOfMap(List<dynamic> jsonList) { /* ... */ }
}
