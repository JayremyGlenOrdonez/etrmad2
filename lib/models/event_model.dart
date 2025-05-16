import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:myapp/Database/db_helper.dart';
import 'package:myapp/models/item_model.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class Event {
  int id = 0;
  late String name;
  late String? venue;
  late String? description;
  late DateTime dateTime;
  late bool isPackingReminder;
  late bool isRetrieveReminder;

  //
  late DateTime? packingDatetime;
  late DateTime? retrieveDatetime;
  late String status;
  File? image;
  List<Items> items = [];

  Event({
    this.id = 0,
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
    this.items = const [],
  });

  Event.fromJson(Map<String, dynamic> json) {
    DbHelper dbHelper = DbHelper.instance;

    id = json[dbHelper.EVENT_ID];
    name = json[dbHelper.EVENT_NAME];
    venue = json[dbHelper.EVENT_VENUE];
    description = json[dbHelper.EVENT_DESCRIPTION];
    dateTime = DateTime.parse(json[dbHelper.EVENT_DATE]);

    isPackingReminder = json[dbHelper.EVENT_PACK_REMINDER] == 1;
    isRetrieveReminder = json[dbHelper.EVENT_RETRIEVE_REMINDER] == 1;

    packingDatetime = DateTime.tryParse(json[dbHelper.EVENT_PACK_DATE] ?? '');

    retrieveDatetime = DateTime.tryParse(
      json[dbHelper.EVENT_RETRIEVE_DATE] ?? '',
    );
    status = json[dbHelper.EVENT_STATUS];
    image =
        json[dbHelper.EVENT_IMAGE] != null
            ? File(json[dbHelper.EVENT_IMAGE])
            : null;

    items = Items.fromListOfMap(jsonDecode(json[dbHelper.EVENT_ITEMS]));
  }

  Future<Map<String, dynamic>> createJsonEvent() async {
    DbHelper dbHelper = DbHelper.instance;
    Map<String, dynamic> data = {};

    data[dbHelper.EVENT_NAME] = name;
    data[dbHelper.EVENT_VENUE] = venue;
    data[dbHelper.EVENT_DESCRIPTION] = description;
    data[dbHelper.EVENT_DATE] = dateTime.toString();

    data[dbHelper.EVENT_PACK_REMINDER] = isPackAReminder() ? 1 : 0;
    data[dbHelper.EVENT_RETRIEVE_REMINDER] = isRetrieveAReminder() ? 1 : 0;

    data[dbHelper.EVENT_PACK_DATE] =
        isPackAReminder() ? packingDatetime.toString() : null;

    data[dbHelper.EVENT_RETRIEVE_DATE] =
        isRetrieveAReminder() ? retrieveDatetime.toString() : null;
    data[dbHelper.EVENT_STATUS] = status;
    data[dbHelper.EVENT_IMAGE] = await saveImageToDirectory();
    data[dbHelper.EVENT_ITEMS] = Items.toJsonOfMap(items);

    return data;
  }

  Future<Map<String, dynamic>> updateJsonEvent() async {
    DbHelper dbHelper = DbHelper.instance;
    Map<String, dynamic> data = {};

    data[dbHelper.EVENT_NAME] = name;
    data[dbHelper.EVENT_VENUE] = venue;
    data[dbHelper.EVENT_DESCRIPTION] = description;
    data[dbHelper.EVENT_DATE] = dateTime.toString();

    data[dbHelper.EVENT_PACK_REMINDER] = isPackAReminder() ? 1 : 0;
    data[dbHelper.EVENT_RETRIEVE_REMINDER] = isRetrieveAReminder() ? 1 : 0;

    data[dbHelper.EVENT_PACK_DATE] =
        isPackAReminder() ? packingDatetime.toString() : null;
    data[dbHelper.EVENT_RETRIEVE_DATE] =
        isRetrieveAReminder() ? retrieveDatetime.toString() : null;

    data[dbHelper.EVENT_STATUS] = status;
    data[dbHelper.EVENT_IMAGE] = image?.path;
    data[dbHelper.EVENT_ITEMS] = Items.toJsonOfMap(items);

    return data;
  }

  bool isPackAReminder() {
    if (!isPackingReminder) return false;
    return true;
  }

  bool isRetrieveAReminder() {
    if (!isRetrieveReminder) return false;
    return true;
  }

  Future<String?> saveImageToDirectory() async {
    if (image == null) return null;

    final directory = await getApplicationDocumentsDirectory();
    final subDirectory = Directory(
      join(directory.path, '${DateTime.now().millisecondsSinceEpoch}'),
    );

    if (!await subDirectory.exists()) {
      await subDirectory.create(recursive: true);
    }

    final imagePath = join(subDirectory.path, basename(image!.path));

    // Copy the image to the subdirectory
    File copiedImage = await image!.copy(imagePath);

    // Return the path where the image is saved
    return copiedImage.path;
  }
}
