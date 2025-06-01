import 'package:get/get.dart';
import 'package:myapp/Database/db_helper.dart';
// Ensure this imports your FirebaseDbHelper
import 'package:myapp/constant/global.dart'; // Assuming this holds your RxList globals
import 'package:myapp/models/event_model.dart';
// No need for intl/intl.dart here unless you do date formatting directly in controller,
// but for categorization, basic DateTime comparisons are enough.

class EventController extends GetxController {
  // Use FirebaseDbHelper instance
  final FirebaseDbHelper _dbHelper = FirebaseDbHelper.instance;

  // Add this new observable for the loading state
  final isLoading =
      true.obs; // Initialize as true since data needs to be loaded

  @override
  void onInit() {
    // Changed from onReady to onInit for earlier data fetching
    super.onInit();
    // Call refresh to initially load data when the controller is initialized
    refresh();
  }

  @override
  void refresh() async {
    try {
      isLoading.value = true;
      final now = DateTime.now();

      EVENTLIST.value = await _dbHelper.fetchAllEvents();
      UPCOMING_EVENTLIST.value = EVENTLIST
          .where((event) => event.dateTime.isAfter(now))
          .toList();
      CURRENT_EVENTLIST.value = EVENTLIST
          .where(
            (event) =>
                event.dateTime.isBefore(now) &&
                now.isBefore(event.dateTime.add(const Duration(minutes: 1))),
          )
          .toList();
      ENDED_EVENTLIST.value = EVENTLIST
          .where(
            (event) =>
                event.dateTime.add(const Duration(minutes: 1)).isBefore(now),
          )
          .toList();
    } catch (e) {
      print("Error fetching events: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // You can keep these individual fetch methods if other parts of your app
  // specifically need to fetch just one category, but the main refresh()
  // will handle populating the global lists for HomeScreen.
  // If these are only used internally by refresh(), you could make them private (_).

  void fetchAllEventsOnly() async {
    // Renamed to avoid confusion with the 'refresh' part
    EVENTLIST.value = await _dbHelper.fetchAllEvents();
  }

  void fetchAllUpcomingEvents(String status) async {
    UPCOMING_EVENTLIST.value = await _dbHelper.fetchAllEvents(status: status);
  }

  void fetchAllCurrentEvents(String status) async {
    CURRENT_EVENTLIST.value = await _dbHelper.fetchAllEvents(status: status);
  }

  void fetchAllEndedEvents(String status) async {
    ENDED_EVENTLIST.value = await _dbHelper.fetchAllEvents(status: status);
  }
}
