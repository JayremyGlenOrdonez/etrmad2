import 'dart:async';
import 'dart:developer';


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myapp/Database/db_helper.dart';
import 'package:myapp/Screens/Events/event_screen.dart';
import 'package:myapp/Screens/Home/home_screen.dart';
import 'package:myapp/Screens/Items/borrowed_items_screen.dart';
import 'package:myapp/Styles/custom_colors.dart';
import 'package:myapp/Styles/fonts.dart';
import 'package:myapp/Styles/titles.dart';
import 'package:myapp/controller/event_controller.dart';
import 'package:myapp/models/event_model.dart';



class ScreenControls extends StatefulWidget {
  const ScreenControls({super.key});

  @override
  State<ScreenControls> createState() => _ScreenControlsState();
}

class _ScreenControlsState extends State<ScreenControls> {
  int _selectedIndex = 0;

  var controller = Get.put(EventController());

  final List<Widget> _screens = [
    const HomeScreen(),
    const EventScreen(),
    const BorrowedItemScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      controller.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: bodyScreen(),
      bottomNavigationBar: bottomNavigationBar(),
    );
  }

  //
  // DRAWER

//
  // APP BAR
  PreferredSizeWidget appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      centerTitle: true,

      //TITLE GRADIENT STYLE
      title: ShaderMask(
        shaderCallback: (Rect bounds) {
          return const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor,
              secondaryColor,
            ],
          ).createShader(bounds);
        },

        // APP TITLE
        child: const Text(
          mainTitle,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w300,
            color: Colors.white,
            fontFamily: fontFamily,
          ),
        ),
      ),
    );
  }

  //
  // BODY SCREENS
  Widget bodyScreen() {
    startTimer();
    return AnimatedContainer(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(16.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.bounceInOut,
      child: _screens[_selectedIndex],
    );
  }

  //
  //CUSTOM BOTTOM NAVIGATION BAR
  BottomNavigationBar bottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: Colors.indigo,
      unselectedItemColor: Colors.black,
      selectedLabelStyle: const TextStyle(color: Colors.indigo),
      unselectedLabelStyle: const TextStyle(color: Colors.black),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event),
          label: 'Event',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.checklist),
          label: 'Borrowed Items',
        ),
      ],
    );
  }

//=============================
  Timer? timer;

  void startTimer() {
    // Start the timer and store the reference
    timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      print('Running timer...');
      List<Event> events =
          await DbHelper.instance.fetchAllEvents(status: 'All');

      for (var event in events) {
        // Create full event DateTime from date and time
        DateTime fullEventDateTime = DateTime(
            event.dateTime.year,
            event.dateTime.month,
            event.dateTime.day,
            event.dateTime.hour,
            event.dateTime.minute);

        // Get the current time, ignoring milliseconds
        var formattedDateTime =
            DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
        DateTime now = DateTime.parse(formattedDateTime);

        // Print for debugging
        // print("Full Event DateTime: $fullEventDateTime");
        // print("Datetime now: $now");

        // Compare the times without milliseconds
        if (fullEventDateTime.isAtSameMomentAs(now) &&
            (event.status != 'Current' && event.status != 'Ended')) {
          event.status = 'Current';
          DbHelper.instance.updateEvent(event);
          log('Event ${event.name} is now Current');
          controller.refresh();
        }

        if (fullEventDateTime.isAfter(now.add(const Duration(days: 1))) &&
            event.status != 'Ended') {
          event.status = 'Ended';
          DbHelper.instance.updateEvent(event);
          log('Event ${event.name} is now Ended');
          controller.refresh();
        }
      }
    });
  }

// To cancel the timer, you can call:
  void cancelTimer() {
    if (timer != null) {
      timer!.cancel();
      print('Timer cancelled');
    }
  }
}
