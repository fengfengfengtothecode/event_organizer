import 'package:event_organizer/view/walkthrough_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_walkthrough_screen/flutter_walkthrough_screen.dart';

import '../controller/navigator_controller.dart';

class GuidePage extends StatelessWidget {
  NavigatorController _navigatorController =NavigatorController();
  final List<OnbordingData> list = [
    OnbordingData(
      image: AssetImage('images/step1.jpeg'),
      fit:BoxFit.fitHeight,
      titleText:Text("Calender View"),
      descText: Text(""),
    ),
    OnbordingData(
      image: AssetImage("images/step2.jpeg"),
      fit:BoxFit.fitHeight,
      titleText:Text("Add Event View"),
      descText: Text(""),
    ),
    OnbordingData(
      image: AssetImage("images/step3.jpeg"),
      fit:BoxFit.fitHeight,
      titleText:Text("Managing Event View"),
      descText: Text(""),
    ),
  ];
  final Function(int) onItemTapped;
  GuidePage(this.onItemTapped, {super.key});

  @override
  Widget build(BuildContext context) {
    /* remove the back button in the AppBar is to set automaticallyImplyLeading to false
  here we need to pass the list and the route for the next page to be opened after this. */
    return GuideSteps((i)=>onItemTapped(i),
      onbordingDataList: list,
      colors: [
        //list of colors for per pages
        Colors.white,
        Colors.red,
      ],
      nextButton: Text(
        "NEXT",
        style: TextStyle(
          color: Colors.purple,
        ),
      ),
      lastButton: Text(
        "GOT IT",
        style: TextStyle(
          color: Colors.purple,
        ),
      ),
      skipButton: Text(
        "SKIP",
        style: TextStyle(
          color: Colors.purple,
        ),
      ),
    );
  }
}

