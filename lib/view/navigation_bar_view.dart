import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../controller/navigator_controller.dart';
import '../main.dart';
import 'calender_view.dart';
import 'guide_steps.dart';

class NavigationBarView extends StatefulWidget {
  const NavigationBarView({super.key});

  @override
  NavigationBarState createState() => NavigationBarState();
}

class NavigationBarState extends State<NavigationBarView> {
  NavigatorController _navigatorController = NavigatorController();
  late final List<Widget> _pages = [
    GuidePage((value)=>_onItemTapped(value)),
    CalendarView(),
    // TransitionPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _navigatorController.update(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_navigatorController.appBarName),
      ),
      body: Center(
        child: _pages[_navigatorController.index],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navigatorController.index,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.help),
              label: 'Guide',
              backgroundColor: Colors.blue
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Calendar',
              backgroundColor: Colors.blue
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.list),
          //   label: 'List',
          //     backgroundColor: Colors.blue
          // ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.refresh),
          //   label: 'Transition',
          //     backgroundColor: Colors.blue
          // ),
        ],
      ),
    );
  }
}