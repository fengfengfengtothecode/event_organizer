import 'package:event_organizer/controller/my_app_controller.dart';
import 'package:event_organizer/controller/navigator_controller.dart';
import 'package:event_organizer/persist/event_persist.dart';
import 'package:event_organizer/view/dialog_event.dart';
import 'package:event_organizer/view/walkthrough_screen.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_walkthrough_screen/flutter_walkthrough_screen.dart';

import 'model/event.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final MyAppController _myAppController = MyAppController();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Organizer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _myAppController.check(context),
    );
  }
}







