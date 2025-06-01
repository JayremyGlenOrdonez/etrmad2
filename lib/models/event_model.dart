import 'dart:convert';
import 'dart:developer';
import 'dart:io';

// Remove DbHelper import as it's no longer directly used for map keys
// import 'package:myapp/Database/db_helper.dart'; // <-- REMOVE THIS LINE
import 'package:myapp/models/item_model.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class Event {
  // Change ID type to String and make it nullable for new events
  String? id;
  late String name;
  String? venue;
  String? description;
  late DateTime dateTime;
  late bool isPackingReminder;
  late bool isRetrieveReminder;

  DateTime? packingDatetime;
  DateTime? retrieveDatetime;
  late String status;
  File? image; // Consider Firebase Storage for production apps
  List<Items> items; // Initialize in constructor, no const [] default here

  double? latitude;
  double? longitude;
  String? weatherDetails;

  Event({
    this.id, // Now nullable String
    this.name = 'No name',
    this.venue,
    this.description,
    required this.dateTime,
    this.isPackingReminder = false,
    this.isRetrieveReminder = false,
    this.packingDatetime,
    this.retrieveDatetime,
    required this.status,
    this.image,
    this.items = const [], // Keep const [] default for safety in constructor
    this.latitude,
    this.longitude,
    this.weatherDetails,
  });

  // Factory constructor for creating an Event from a Firestore Map
  factory Event.fromJson(Map<String, dynamic> json) {
    // No need for DbHelper constants, use string literals directly
    return Event(
      id:
          json['id']
              as String?, // If you pass the id in the map, otherwise null
      name: json['name'] as String? ?? 'No name',
      venue: json['venue'] as String?,
      description: json['description'] as String?,
      dateTime: DateTime.parse(
        json['date'] as String,
      ), // Match 'date' key in Firestore
      isPackingReminder:
          json['pack_reminder'] as bool? ?? false, // Read as bool
      isRetrieveReminder:
          json['retrieve_reminder'] as bool? ?? false, // Read as bool
      packingDatetime: DateTime.tryParse(json['pack_date'] as String? ?? ''),
      retrieveDatetime: DateTime.tryParse(
        json['retrieve_date'] as String? ?? '',
      ),
      status: json['status'] as String? ?? '',
      // For images, if you stored a path, it will still be a path.
      // If you switch to Firebase Storage, this would be a URL.
      image: json['image'] != null ? File(json['image'] as String) : null,
      // IMPORTANT: items should be read as a List of Maps directly from Firestore
      // Then map each map to an Items object using Items.fromJson()
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (itemJson) => Items.fromJson(itemJson as Map<String, dynamic>),
              )
              .toList() ??
          [],
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      weatherDetails: json['weatherDetails'] as String?,
    );
  }

  // Convert an Event object to a Map<String, dynamic> for Firestore insertion/update
  Map<String, dynamic> toJson() {
    // No need for DbHelper constants, use string literals directly
    return {
      // 'id' is typically not included here for Firestore as it's the document ID.
      // If you *need* to store it inside the document, uncomment this:
      // 'id': id,
      'name': name,
      'venue': venue,
      'description': description,
      'date': dateTime.toIso8601String(), // Consistent string format for dates
      'pack_reminder': isPackingReminder, // Store as bool directly
      'retrieve_reminder': isRetrieveReminder, // Store as bool directly
      'pack_date': isPackingReminder
          ? packingDatetime?.toIso8601String()
          : null,
      'retrieve_date': isRetrieveReminder
          ? retrieveDatetime?.toIso8601String()
          : null,
      'status': status,
      'image': image
          ?.path, // If still storing local paths. Recommend Firebase Storage URLs.
      // IMPORTANT: Convert List<Items> to List<Map<String, dynamic>> using Items.toJson()
      'items': items
          .map((item) => item.toJson())
          .toList(), // Store as Firestore Array
      'latitude': latitude,
      'longitude': longitude,
      'weatherDetails': weatherDetails,
    };
  }

  // You can combine createJsonEvent and updateJsonEvent into a single toJson()
  // as Firestore update() method intelligently merges fields.
  // No need for separate updateJsonEvent() unless you have specific logic.

  // Keep these helper methods as is
  bool isPackAReminder() {
    return isPackingReminder;
  }

  bool isRetrieveAReminder() {
    return isRetrieveReminder;
  }

  // This method saves locally. Consider moving image uploads to Firebase Storage
  // and storing the download URL in the 'image' field instead of local path.
  Future<String?> saveImageToDirectory() async {
    if (image == null) return null;

    final directory = await getApplicationDocumentsDirectory();
    final subDirectory = Directory(
      join(
        directory.path,
        'events_images',
        '${DateTime.now().millisecondsSinceEpoch}',
      ), // Organized subdirectory
    );

    if (!await subDirectory.exists()) {
      await subDirectory.create(recursive: true);
    }

    final imagePath = join(subDirectory.path, basename(image!.path));

    try {
      File copiedImage = await image!.copy(imagePath);
      return copiedImage.path;
    } catch (e) {
      log(name: 'ImageSave', 'Error saving image to directory: $e');
      return null;
    }
  }
}
