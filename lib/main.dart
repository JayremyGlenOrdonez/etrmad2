import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/testscreen.dart';
import 'firebase_options.dart';

import 'package:myapp/_screen_controls.dart';
import 'package:myapp/services/notification_helper.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Timezone setup
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Manila'));

  // Initialize notification helper
  await NotificationHelper.init();

  runApp(const EtrMad());
}

class EtrMad extends StatelessWidget {
  const EtrMad({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ScreenControls(),
    );
  }
}
