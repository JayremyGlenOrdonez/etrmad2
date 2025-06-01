import 'package:get/get.dart';
import 'package:myapp/Database/db_helper.dart';
import 'package:myapp/constant/global.dart';

class BorrowController extends GetxController {
  final FirebaseDbHelper _dbHelper = FirebaseDbHelper.instance;

  @override
  void onReady() {
    refresh();
    super.onReady();
  }

  @override
  void refresh() async {
    try {
      BORROWEDLIST.value = await _dbHelper.fetchAllBorrowedItems();
      PENDING_BORROWEDLIST.value = BORROWEDLIST
          .where((item) => item.status == 'Pending')
          .toList();
      RETURNED_BORROWEDLIST.value = BORROWEDLIST
          .where((item) => item.status == 'Returned')
          .toList();
    } catch (e) {
      print("Error refreshing borrowed items: $e");
    }
  }

  void fetchAllBorrowedItems() async {
    BORROWEDLIST.value = await _dbHelper.fetchAllBorrowedItems();
  }

  void fetchAllPendingBorrowedItems(String status) async {
    PENDING_BORROWEDLIST.value = await _dbHelper.fetchAllBorrowedItems(
      status: status,
    );
  }

  void fetchAllReturnedBorrowedItems(String status) async {
    RETURNED_BORROWEDLIST.value = await _dbHelper.fetchAllBorrowedItems(
      status: status,
    );
  }
}
