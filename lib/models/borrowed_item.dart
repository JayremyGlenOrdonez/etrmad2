import 'dart:convert';

import 'package:myapp/Database/db_helper.dart';
import 'package:myapp/models/item_model.dart';


class BorrowedItem {
  String title;
  List<Items> items = [];
  String status;
  DateTime dateReturned;
  int id;

  BorrowedItem({
    this.id = 0,
    required this.title,
    required this.items,
    required this.dateReturned,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    DbHelper dbHelper = DbHelper.instance;
    Map<String, dynamic> map = {};

    map[dbHelper.BORROWED_ID] = id;
    map[dbHelper.BORROWED_TITLE] = title;
    map[dbHelper.BORROWED_ITEMS] = Items.toJsonOfMap(items);
    map[dbHelper.BORROWED_DATE_RETURNED] = dateReturned.toString();
    map[dbHelper.BORROWED_STATUS] = status;
    return map;
  }

  Map<String, dynamic> toCreateMap() {
    DbHelper dbHelper = DbHelper.instance;
    Map<String, dynamic> map = {};
    map[dbHelper.BORROWED_TITLE] = title;
    map[dbHelper.BORROWED_ITEMS] = Items.toJsonOfMap(items);
    map[dbHelper.BORROWED_DATE_RETURNED] = dateReturned.toString();
    map[dbHelper.BORROWED_STATUS] = status;
    return map;
  }

  Map<String, dynamic> toUpdateMap() {
    DbHelper dbHelper = DbHelper.instance;
    Map<String, dynamic> map = {};
    map[dbHelper.BORROWED_TITLE] = title;
    map[dbHelper.BORROWED_ITEMS] = Items.toJsonOfMap(items);
    map[dbHelper.BORROWED_DATE_RETURNED] = dateReturned.toString();
    map[dbHelper.BORROWED_STATUS] = status;
    return map;
  }

  factory BorrowedItem.fromMap(Map<String, dynamic> map) {
    DbHelper dbHelper = DbHelper.instance;
    return BorrowedItem(
      id: map[dbHelper.BORROWED_ID],
      title: map[dbHelper.BORROWED_TITLE],
      items: Items.fromListOfMap(jsonDecode(map[dbHelper.BORROWED_ITEMS])),
      dateReturned: DateTime.parse(map[dbHelper.BORROWED_DATE_RETURNED]),
      status: map[dbHelper.BORROWED_STATUS],
    );
  }
}
