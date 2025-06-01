import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/borrowed_item.dart';
import 'package:myapp/models/event_model.dart';

class FirebaseDbHelper {
  static final FirebaseDbHelper instance = FirebaseDbHelper._();
  FirebaseDbHelper._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection names (matching your old table names for conceptual clarity)
  static const String EVENTS_COLLECTION = 'events';
  static const String BORROWED_ITEMS_COLLECTION = 'borrowed_items';

  // Field names (consistent with your old column names)
  // For Firebase, these are just string constants, not dependent on DbHelper instance.
  static const String EVENT_ID =
      'id'; // Firebase will auto-generate document IDs
  static const String EVENT_NAME = 'name';
  static const String EVENT_DATE = 'date'; // Will store as String or Timestamp
  static const String EVENT_TIME =
      'time'; // Note: Was not used in SQLite table creation.
  static const String EVENT_DESCRIPTION = 'description';
  static const String EVENT_STATUS = 'status';
  static const String EVENT_PACK_REMINDER =
      'pack_reminder'; // Will store as boolean
  static const String EVENT_RETRIEVE_REMINDER =
      'retrieve_reminder'; // Will store as boolean
  static const String EVENT_PACK_DATE =
      'pack_date'; // Will store as String or Timestamp
  static const String EVENT_RETRIEVE_DATE =
      'retrieve_date'; // Will store as String or Timestamp
  static const String EVENT_VENUE = 'venue';
  static const String EVENT_IMAGE =
      'image'; // Will store as URL (Firebase Storage) or local path
  static const String EVENT_ITEMS =
      'items'; // Will store as List<Map<String, dynamic>> (Firestore Array)
  static const String EVENT_LATITUDE = 'latitude';
  static const String EVENT_LONGITUDE = 'longitude';
  static const String EVENT_WEATHER_DETAILS = 'weatherDetails';

  static const String BORROWED_ID =
      'id'; // Firebase will auto-generate document IDs
  static const String BORROWED_TITLE = 'title';
  static const String BORROWED_ITEMS =
      'items'; // Will store as List<Map<String, dynamic>> (Firestore Array)
  static const String BORROWED_DATE_RETURNED =
      'dateReturned'; // Will store as String or Timestamp
  static const String BORROWED_STATUS = 'status';

  // ==================== EVENTS OPERATIONS ====================

  /// Inserts a new event into Firestore.
  /// The Event object's `id` field will be populated with the Firestore document ID.
  Future<Event> insertEvent(Event event) async {
    try {
      log('Inserting event: ${event.toJson()}'); // Debug log
      final eventData = event.toJson();
      eventData.remove('latitude'); // Remove latitude before saving
      eventData.remove('longitude'); // Remove longitude before saving
      eventData.remove(
        'weatherDetails',
      ); // Remove weather details before saving
      eventData['latitude'] = event.latitude; // Add latitude
      eventData['longitude'] = event.longitude; // Add longitude
      eventData['weatherDetails'] = event.weatherDetails; // Add weather details
      DocumentReference docRef = await _firestore
          .collection(EVENTS_COLLECTION)
          .add(eventData);

      DocumentSnapshot snapshot = await docRef.get();

      if (snapshot.exists) {
        log('Event inserted successfully: ${snapshot.data()}'); // Debug log
        return Event.fromJson(snapshot.data() as Map<String, dynamic>)
          ..id = snapshot.id;
      } else {
        throw Exception('Failed to retrieve inserted event.');
      }
    } catch (e) {
      log('Error inserting event: $e'); // Debug log
      rethrow;
    }
  }

  /// Fetches a list of events from Firestore, optionally filtered by status.
  Future<List<Event>> fetchAllEvents({String status = 'All'}) async {
    try {
      Query query = _firestore.collection(EVENTS_COLLECTION);

      if (status != 'All') {
        query = query.where(EVENT_STATUS, isEqualTo: status);
      }
      query = query.orderBy(EVENT_DATE, descending: true);

      QuerySnapshot querySnapshot = await query.get();

      return querySnapshot.docs.map((doc) {
        // Convert each document to an Event object, assigning the document ID.
        return Event.fromJson(doc.data() as Map<String, dynamic>)..id = doc.id;
      }).toList();
    } catch (e) {
      log('Error fetching events: $e');
      return []; // Return an empty list on error to prevent app crash
    }
  }

  /// Deletes an event from Firestore by its document ID.
  Future<void> deleteEvent(String id) async {
    try {
      await _firestore.collection(EVENTS_COLLECTION).doc(id).delete();
      log(name: 'Firebase', 'Event deleted with ID: $id');
    } catch (e) {
      log(name: 'Firebase', 'Error deleting event with ID $id: $e');
      rethrow;
    }
  }

  /// Updates an existing event in Firestore.
  /// The Event object must have a non-null `id`.
  Future<Event> updateEvent(Event event) async {
    try {
      if (event.id == null || event.id!.isEmpty) {
        throw Exception(
          'Event ID cannot be null or empty for update operation.',
        );
      }
      // event.toJson() should return a Map<String, dynamic> with updated data.
      // Firestore will merge updates; fields not present in the map won't be changed.
      await _firestore
          .collection(EVENTS_COLLECTION)
          .doc(event.id!)
          .update(event.toJson());

      // After update, fetch the updated event to return the complete object.
      // The getEventById method now takes a String id, which is correct for Firebase.
      Event? updatedEvent = await getEventById(event.id!);
      if (updatedEvent != null) {
        return updatedEvent;
      } else {
        throw Exception(
          'Failed to retrieve updated event with ID: ${event.id}',
        );
      }
    } catch (e) {
      log(name: 'Firebase', 'Error updating event with ID ${event.id}: $e');
      rethrow;
    }
  }

  /// Fetches a single event by its document ID.
  Future<Event?> getEventById(String id) async {
    try {
      DocumentSnapshot snapshot = await _firestore
          .collection(EVENTS_COLLECTION)
          .doc(id)
          .get();
      if (snapshot.exists) {
        // Convert document data to Event object, assigning the document ID.
        return Event.fromJson(snapshot.data() as Map<String, dynamic>)
          ..id = snapshot.id;
      } else {
        log(name: 'Firebase', 'Event not found with ID: $id');
        return null; // Return null if event doesn't exist
      }
    } catch (e) {
      log(name: 'Firebase', 'Error getting event with ID $id: $e');
      rethrow;
    }
  }

  // ==================== BORROWED ITEMS OPERATIONS ====================

  /// Inserts a new borrowed item into Firestore.
  /// The BorrowedItem object's `id` field will be populated with the Firestore document ID.
  Future<BorrowedItem> insertBorrowedItem(BorrowedItem borrowedItem) async {
    try {
      // borrowedItem.toJson() should return a Map<String, dynamic>.
      DocumentReference docRef = await _firestore
          .collection(BORROWED_ITEMS_COLLECTION)
          .add(borrowedItem.toJson());

      // Get the document snapshot to retrieve the full data and the Firebase-generated ID.
      DocumentSnapshot snapshot = await docRef.get();

      if (snapshot.exists) {
        // Create BorrowedItem object from Firestore data, assigning the document ID.
        return BorrowedItem.fromJson(snapshot.data() as Map<String, dynamic>)
          ..id = snapshot.id;
      } else {
        throw Exception(
          'Failed to retrieve inserted borrowed item with ID: ${docRef.id}',
        );
      }
    } catch (e) {
      log(name: 'Firebase', 'Error inserting borrowed item: $e');
      rethrow;
    }
  }

  /// Fetches a list of borrowed items from Firestore, optionally filtered by status.
  Future<List<BorrowedItem>> fetchAllBorrowedItems({
    String status = 'All',
  }) async {
    try {
      Query query = _firestore.collection(BORROWED_ITEMS_COLLECTION);

      if (status != 'All') {
        query = query.where(BORROWED_STATUS, isEqualTo: status);
      }
      // Order by a timestamp if you have one, or a specific field.
      // BORROWED_ID is a string in Firebase, so ordering by it might not be numerical.
      // If you want to order by creation time, consider adding a 'createdAt' timestamp field.
      query = query.orderBy(
        BORROWED_TITLE,
        descending: false,
      ); // Example: order by title

      QuerySnapshot querySnapshot = await query.get();

      return querySnapshot.docs.map((doc) {
        // Convert each document to a BorrowedItem object, assigning the document ID.
        return BorrowedItem.fromJson(doc.data() as Map<String, dynamic>)
          ..id = doc.id;
      }).toList();
    } catch (e) {
      log(name: 'Firebase', 'Error fetching borrowed items: $e');
      return [];
    }
  }

  /// Deletes a borrowed item from Firestore by its document ID.
  Future<void> deleteBorrowedItem(String id) async {
    try {
      await _firestore.collection(BORROWED_ITEMS_COLLECTION).doc(id).delete();
      log(name: 'Firebase', 'Borrowed item deleted with ID: $id');
    } catch (e) {
      log(name: 'Firebase', 'Error deleting borrowed item with ID $id: $e');
      rethrow;
    }
  }

  /// Updates an existing borrowed item in Firestore.
  /// The BorrowedItem object must have a non-null `id`.
  Future<BorrowedItem> updateBorrowedItem(BorrowedItem borrowedItem) async {
    try {
      if (borrowedItem.id == null || borrowedItem.id!.isEmpty) {
        throw Exception(
          'BorrowedItem ID cannot be null or empty for update operation.',
        );
      }
      // borrowedItem.toJson() should return a Map<String, dynamic> with updated data.
      await _firestore
          .collection(BORROWED_ITEMS_COLLECTION)
          .doc(borrowedItem.id!)
          .update(borrowedItem.toJson());

      // After update, fetch the updated item to return the complete object.
      // The getBorrowedItemById method now takes a String id, which is correct for Firebase.
      BorrowedItem? updatedBorrowedItem = await getBorrowedItemById(
        borrowedItem.id!,
      );
      if (updatedBorrowedItem != null) {
        return updatedBorrowedItem;
      } else {
        throw Exception(
          'Failed to retrieve updated borrowed item with ID: ${borrowedItem.id}',
        );
      }
    } catch (e) {
      log(
        name: 'Firebase',
        'Error updating borrowed item with ID ${borrowedItem.id}: $e',
      );
      rethrow;
    }
  }

  /// Fetches a single borrowed item by its document ID.
  Future<BorrowedItem?> getBorrowedItemById(String id) async {
    try {
      DocumentSnapshot snapshot = await _firestore
          .collection(BORROWED_ITEMS_COLLECTION)
          .doc(id)
          .get();
      if (snapshot.exists) {
        // Convert document data to BorrowedItem object, assigning the document ID.
        return BorrowedItem.fromJson(snapshot.data() as Map<String, dynamic>)
          ..id = snapshot.id;
      } else {
        log(name: 'Firebase', 'Borrowed item not found with ID: $id');
        return null;
      }
    } catch (e) {
      log(name: 'Firebase', 'Error getting borrowed item with ID $id: $e');
      rethrow;
    }
  }
}
