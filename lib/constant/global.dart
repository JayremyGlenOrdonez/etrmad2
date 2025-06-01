import 'package:get/get.dart';
import 'package:myapp/models/borrowed_item.dart';
import 'package:myapp/models/event_model.dart';

RxList<Event> EVENTLIST = RxList<Event>([]);
RxList<Event> CURRENT_EVENTLIST = RxList<Event>([]);
RxList<Event> UPCOMING_EVENTLIST = RxList<Event>([]);
RxList<Event> ENDED_EVENTLIST = RxList<Event>([]);
//=======
RxList<BorrowedItem> BORROWEDLIST = RxList<BorrowedItem>([]);
RxList<BorrowedItem> PENDING_BORROWEDLIST = RxList<BorrowedItem>([]);
RxList<BorrowedItem> RETURNED_BORROWEDLIST = RxList<BorrowedItem>([]);
