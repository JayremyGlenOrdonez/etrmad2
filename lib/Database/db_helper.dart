import 'dart:developer';


import 'package:myapp/models/borrowed_item.dart';
import 'package:myapp/models/event_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class DbHelper {
  static Database? _db;

  static final DbHelper instance = DbHelper._();

  DbHelper._();

  static Future<Database?> get database async {
    if (_db != null) {
      return _db;
    }
    _db = await instance._openDb();
    return _db;
  }

  String dbName = 'reminense.db';
  int dbVersion = 1;

  //table 1
  String EVENT_TABLE = 'events';
  //
  String EVENT_ID = 'id';
  String EVENT_NAME = 'name';
  String EVENT_DATE = 'date';
  String EVENT_TIME = 'time';
  String EVENT_DESCRIPTION = 'description';
  String EVENT_STATUS = 'status';

  String EVENT_PACK_REMINDER = 'pack_reminder';
  String EVENT_RETRIEVE_REMINDER = 'retrieve_reminder';
  String EVENT_PACK_DATE = 'pack_date';
  String EVENT_RETRIEVE_DATE = 'retrieve_date';
  String EVENT_VENUE = 'venue';
  String EVENT_IMAGE = 'image';
  String EVENT_ITEMS = 'items';

  //==================================

  String ITEM_ID = 'id';
  String ITEM_NAME = 'name';
  String ITEM_QUANTITY = 'quantity';
  String ITEM_DESCRIPTION = 'description';
  String ITEM_IS_RETURNED = 'isReturned';

  //===================================

  String BORROWED_TABLE = 'borrowed_items';

  String BORROWED_ID = 'id';
  String BORROWED_TITLE = 'title';
  String BORROWED_ITEMS = 'items';
  String BORROWED_DATE_RETURNED = 'dateReturned';
  String BORROWED_STATUS = 'status';

  //OPEN DB
  Future<Database> _openDb() async {
    String dbPath = await getDatabasesPath();
    dbPath = join(dbPath, dbName);
    // print(dbPath);
    // deleteDatabase(dbPath);
    return openDatabase(
      dbPath,
      version: dbVersion,
      onCreate: (db, version) {
        try {
          db.execute('''
          CREATE TABLE $EVENT_TABLE (
            $EVENT_ID INTEGER PRIMARY KEY AUTOINCREMENT,
            $EVENT_NAME TEXT NOT NULL,
            $EVENT_DATE TEXT NOT NULL,
            $EVENT_DESCRIPTION TEXT,
            $EVENT_STATUS TEXT NOT NULL,
            $EVENT_PACK_REMINDER INTEGER NOT NULL,
            $EVENT_RETRIEVE_REMINDER INTEGER NOT NULL,
            $EVENT_PACK_DATE TEXT NULL,
            $EVENT_RETRIEVE_DATE TEXT NULL,
            $EVENT_VENUE TEXT NULL,
            $EVENT_IMAGE TEXT NULL,
            $EVENT_ITEMS TEXT NULL
          )
        ''');

          db.execute('''
          CREATE TABLE $BORROWED_TABLE (
            $BORROWED_ID INTEGER PRIMARY KEY AUTOINCREMENT,
            $BORROWED_TITLE TEXT NOT NULL,
            $BORROWED_ITEMS TEXT NOT NULL,
            $BORROWED_STATUS TEXT NOT NULL,
            $BORROWED_DATE_RETURNED TEXT NOT NULL
          )
        ''');

          log(name: 'Database', 'Tables Created Successfully');
        } catch (e) {
          log(name: 'Database', 'Error Creating Tables: $e');
        }
      },
    );
  }

  //insert data
  Future<Event> insertEvent(Event event) async {
    Database? db = await database;
    var jsonData = await event.createJsonEvent();
    var id = await db!.insert(EVENT_TABLE, jsonData);
    return await getEventId(id);
  }

  //FETCH DATA
  Future<List<Event>> fetchAllEvents({String status = 'All'}) async {
    Database? db = await database;
    var data = status == 'All'
        ? await db!.query(EVENT_TABLE, orderBy: '$EVENT_DATE DESC')
        : await db!.query(EVENT_TABLE,
            where: '$EVENT_STATUS = ?',
            whereArgs: [status],
            orderBy: '$EVENT_DATE DESC');

    // log(data.toString());

    List<Event> events = data.map((e) => Event.fromJson(e)).toList();
    // print(events.length);
    return events;
  }

  //Delete event
  Future<int> deleteEvent(int id) async {
    Database? db = await database;
    return await db!
        .delete(EVENT_TABLE, where: '$EVENT_ID = ?', whereArgs: [id]);
  }

  //Update event
  Future<Event> updateEvent(Event event) async {
    print(event.status);
    Database? db = await database;
    var jsonData = await event.updateJsonEvent();
    var id = await db!.update(EVENT_TABLE, jsonData,
        where: '$EVENT_ID = ?', whereArgs: [event.id]);

    return await getEventId(event.id);
  }

  Future<Event> getEventId(int id) async {
    Database? db = await database;
    var data =
        await db!.query(EVENT_TABLE, where: '$EVENT_ID = ?', whereArgs: [id]);
    return Event.fromJson(data[0]);
  }

  //===================

  Future<BorrowedItem> insertBorrowedItem(BorrowedItem borrowedItem) async {
    Database? db = await database;
    var jsonData = borrowedItem.toCreateMap();
    var id = await db!.insert(BORROWED_TABLE, jsonData);
    return await getBorrowedItemId(id);
  }

  Future<List<BorrowedItem>> fetchAllBorrowedItems(
      {String status = 'All'}) async {
    Database? db = await database;
    var data = status == 'All'
        ? await db!.query(BORROWED_TABLE, orderBy: '$BORROWED_ID DESC')
        : await db!.query(BORROWED_TABLE,
            where: '$BORROWED_STATUS = ?',
            whereArgs: [status],
            orderBy: '$BORROWED_ID DESC');
    return data.map((e) => BorrowedItem.fromMap(e)).toList();
  }

  Future<int> deleteBorrowedItem(int id) async {
    Database? db = await database;
    return await db!
        .delete(BORROWED_TABLE, where: '$BORROWED_ID = ?', whereArgs: [id]);
  }

  Future<BorrowedItem> updateBorrowedItem(BorrowedItem borrowedItem) async {
    Database? db = await database;
    var jsonData = borrowedItem.toUpdateMap();
    var id = await db!.update(BORROWED_TABLE, jsonData,
        where: '$BORROWED_ID = ?', whereArgs: [borrowedItem.id]);
    return await getBorrowedItemId(borrowedItem.id);
  }

  Future<BorrowedItem> getBorrowedItemId(int id) async {
    Database? db = await database;
    var data = await db!
        .query(BORROWED_TABLE, where: '$BORROWED_ID = ?', whereArgs: [id]);
    return BorrowedItem.fromMap(data[0]);
  }
}
