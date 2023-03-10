import 'dart:math';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'model/event.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation Bar Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NavigationBar(),
    );
  }
}

class NavigationBar extends StatefulWidget {
  @override
  _NavigationBarState createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {
  int _selectedIndex = 0;
  List<Widget> _pages = [
    GuidePage(),
    CalendarView(),
    ReorderableList(),
    TransitionPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Navigation Bar'),
      ),
      body: Center(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
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
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List',
              backgroundColor: Colors.blue
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.refresh),
            label: 'Transition',
              backgroundColor: Colors.blue
          ),
        ],
      ),
    );
  }
}

class GuidePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('This is the guide page.'),
    );
  }
}

class CalendarView extends StatefulWidget {
  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView>
    with TickerProviderStateMixin {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  late DateTime _selectedDay;
  Map<DateTime, List<Event>> _events =  <DateTime, List<Event>>{
    DateTime.utc(2023, 3, 10): [
      Event(title: 'TEST', description: 'TEST', date:  DateTime.utc(2023, 3, 10),),
      Event(title: 'TESTB', description: 'TEST', date:  DateTime.utc(2023, 3, 10),),
    ],
    DateTime.utc(2023, 3, 15): [
      Event(title: 'TESTC', description: 'TEST', date:  DateTime.utc(2023, 3, 15),),
    ],
  };
  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  void _addEvent(BuildContext context) {
    // Implement your logic to add an event for the selected day here
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Event"),
          content: Text("Add event for $_selectedDay"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("CANCEL"),
            ),
            TextButton(
              onPressed: () {
                // Save the event and close the dialog
                Navigator.of(context).pop();
              },
              child: Text("SAVE"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEventList() {
    final events = _events[_selectedDay];
    if (events == null || events.isEmpty) {
      return Center(
        child: Text('No events for this day'),
      );
    }
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return ListTile(
          title: Text(event.title),
          subtitle: Text(event.description),
        );
      },
    );
  }
  CalendarBuilders _calendarBuilder() {
    return CalendarBuilders(
      selectedBuilder: (context, date, events) {
        return Container(
          margin: EdgeInsets.all(4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            shape: BoxShape.circle,
          ),
          child: Text(
            date.day.toString(),
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    markerBuilder: (context, date, events) {
    final eventCount = _events[date]?.length ?? 0;
    final markers = <Widget>[];
    if (eventCount > 0) {
      return ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: eventCount,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.all(1),
              child: Container(
                // height: 7,
                width: 5,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black),
              ),
            );
          });
    }
    return SizedBox();
    },
      // singleMarkerBuilder: (context, date, _) {
      //   return Container(
      //     decoration: BoxDecoration(
      //         shape: BoxShape.circle,
      //         color: date == _selectedDay ? Colors.white : Colors.black), //Change color
      //     width: 5.0,
      //     height: 5.0,
      //     margin: const EdgeInsets.symmetric(horizontal: 1.5),
      //   );
      // },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2022, 1, 1),
          lastDay: DateTime.utc(2023, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: _calendarFormat,
          onDaySelected: _onDaySelected,
          calendarStyle: CalendarStyle(
            // todayDecoration: BoxDecoration(
            //   color: Colors.blue,
            //   shape: BoxShape.circle,
            // ),
            selectedDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          availableCalendarFormats: {
            CalendarFormat.month: 'Month',
            CalendarFormat.week: 'Week',
          },
          calendarBuilders: _calendarBuilder()
        ),
        ElevatedButton(
          onPressed: () {
            _addEvent(context);
          },
          child: Text("Add Event"),
        ),
      ],
    );
  }
}

class ReorderableList extends StatefulWidget {
  @override
  _ReorderableListState createState() => _ReorderableListState();
}

class _ReorderableListState extends State<ReorderableList> {
  List<String> _items = [
    'Item 1',
    'Item 2',
    'Item 3',
    'Item 4',
    'Item 5',
  ];

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final String item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      onReorder: _onReorder,
      children: _items
          .map((item) => ListTile(
        key: ValueKey(item),
        title: Text(item),
      ))
          .toList(),
    );
  }
}

class TransitionPage extends StatefulWidget {
  @override
  _TransitionPageState createState() => _TransitionPageState();
}

class _TransitionPageState extends State<TransitionPage> {
  bool _isLoading =false;

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  void _simulateLoading() {
    setState(() {
      _isLoading = true;
    });
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _isLoading
          ? CircularProgressIndicator()
          : Text('This is the transition page.'),
    );
  }
}
