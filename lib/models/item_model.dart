import 'dart:convert';
import 'dart:developer';
import 'package:myapp/Database/db_helper.dart';

class Items {
  int id = 0;
  String? name;
  int quantity = 0;
  String? description;
  bool isReturned = false;

  Items({
    this.id = 0,
    this.name,
    this.quantity = 0,
    this.description,
    this.isReturned = false,
  });

  static String toJsonOfMap(List<Items> item) {
    List<Map<String, dynamic>> data = [];
    for (var i = 0; i < item.length; i++) {
      data.add(item[i].toJson());
    }
    return jsonEncode(data);
  }

  static List<Items> fromListOfMap(List<dynamic> item) {
    List<Items> data = [];
    for (var i = 0; i < item.length; i++) {
      data.add(Items.fromJson(item[i]));
    }

    return data;
  }

  Map<String, dynamic> toJson() {
    DbHelper dbHelper = DbHelper.instance;
    Map<String, dynamic> data = {};

    data[dbHelper.ITEM_ID] = id;
    data[dbHelper.ITEM_NAME] = name;
    data[dbHelper.ITEM_QUANTITY] = quantity;
    data[dbHelper.ITEM_DESCRIPTION] = description;
    data[dbHelper.ITEM_IS_RETURNED] = isReturned ? 1 : 0;

    return data;
  }

  Items.fromJson(Map<String, dynamic> json) {
    DbHelper dbHelper = DbHelper.instance;
    id = json[dbHelper.ITEM_ID] ?? 0;
    name = json[dbHelper.ITEM_NAME] ?? '';
    quantity = json[dbHelper.ITEM_QUANTITY] ?? 0;
    description = json[dbHelper.ITEM_DESCRIPTION] ?? '';
    isReturned = json[dbHelper.ITEM_IS_RETURNED] == 1 ? true : false;
  }
}
