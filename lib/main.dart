import 'package:event_organizer/persist/event_persist.dart';
import 'package:event_organizer/view/dialog_event.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'model/event.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Organizer',
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
    // TransitionPage(),
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

  EventCRUD eventCRUD = EventCRUD();
}

class _CalendarViewState extends State<CalendarView>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.utc(DateTime.now().year,DateTime.now().month,DateTime.now().day);
  late DateTime _selectedDay;
  Map<DateTime, List<Event>> _events =  <DateTime, List<Event>>{
    DateTime.utc(2023, 3, 10): [
      Event(title: 'TEST', description: 'TEST', date:  DateTime.utc(2023, 3, 10),time:'10:00AM',index:1),
      Event(title: 'TESTB', description: 'TEST', date:  DateTime.utc(2023, 3, 10),time:'03:00PM',index:2),
    ],
    DateTime.utc(2023, 3, 15): [
      Event(title: 'TESTC', description: 'TEST', date:  DateTime.utc(2023, 3, 15),time:'10:00AM',index:1),
    ],
  };


  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _getEvents();
  }

  void _getEvents(){
    widget.eventCRUD.readEvents().then((value) => {
    _simulateLoading(),
      _onLoadEvent(value)
    });
  }

  void _onLoadEvent(value){
    setState(() {
      _events=value;
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _simulateLoading();
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  void _addEvent(BuildContext context) {
    // Implement your logic to add an event for the selected day here
    showDialog(
      context: context,
      builder: (context) => EventDialog(
        selectedDate: _selectedDay,
        onSave: (event) {
          setState(() {
            // _events[event.date] = [...?_events[event.date], event];
            try{
              widget.eventCRUD.createEvent(event).then((value) => {
                _getEvents()
              });
              print("done");
            }catch(e){
              print(e);
            }
          });
        },
      ),
      // builder: (BuildContext context) {
      //   return AlertDialog(
      //     title: Text("Add Event"),
      //     content: Text("Add event for $_selectedDay"),
      //     actions: [
      //       TextButton(
      //         onPressed: () {
      //           Navigator.of(context).pop();
      //         },
      //         child: Text("CANCEL"),
      //       ),
      //       TextButton(
      //         onPressed: () {
      //           // Save the event and close the dialog
      //           Navigator.of(context).pop();
      //         },
      //         child: Text("SAVE"),
      //       ),
      //     ],
      //   );
      // },
    );
  }

  void _routeToDetail(List<Event> events){
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>  ReorderableList(events),
          ),
        ).then((value) => {
          _getEvents()
        });
  }

  List<Widget> _buildList(event){
    return <Widget>[
      for(final items in event)
        Card(
          color: Colors.white70,
          key: ValueKey(items),
          elevation: 1,
          child: ListTile(
            title: Text((items.index).toString()+") "+items.title+"  (ON "+items.time+")"),
            leading: Icon(Icons.event,color: Colors.blue,),

          ),
        ),
      ElevatedButton(
        onPressed: () {
          _routeToDetail(event);
        },
        child: Text("View Events"),
      ),
    ];
  }
  void _simulateLoading() {
      setState(() {
        print("loading");
        _isLoading = true;
      });
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          print("finish load");
          _isLoading = false;
        });
      });
    }

  Widget _buildEventList() {
    final events = _events[_selectedDay];
    if (events == null || events.isEmpty) {
      return  FittedBox(
        fit:BoxFit.fitWidth,
         child: Center(
            child: Text('No events for this day',textScaleFactor: 3,),
          )
      );

    }
    return Container(
      child: Column(
      children:
        _buildList(events),
          // FittedBox(
          // fit:BoxFit.fitWidth,
          // child: Center(
          //   child: Text('There are '+events.length.toString()+' events today!',textScaleFactor: 3,),
          // )
          // ),
      )
    );
    //   ListView.builder(
    //   itemCount: events.length,
    //   itemBuilder: (context, index) {
    //     final event = events[index];
    //     return ListTile(
    //       title: Text(event.title),
    //       subtitle: Text(event.description),
    //     );
    //   },
    // );
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
    return Scaffold(
       body:  SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child:Column(
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
            _isLoading?TransitionPage():_buildEventList(),
          ],
        ),
       ),
        floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
       _addEvent(context);
    },
        label: const Text("Add Event"),
    icon: const Icon(Icons.add)
        ),
    );
  }
}

class ReorderableList extends StatefulWidget {
  List<Event> _items = [];
  EventCRUD _crud = EventCRUD();

  ReorderableList(List<Event> events){
    _items = events;
  }

  @override
  _ReorderableListState createState() => _ReorderableListState(_items);
}


class _ReorderableListState extends State<ReorderableList> {
  List<Event> _items = [];

  _ReorderableListState(events){
      _items=events;
      _items.sort((a,b)=>a.index.compareTo(b.index));
  }

  void _setEvents(events){
    setState(() {
      _items.clear();
      _items.addAll(events);
    });

  }

  void _onReorder(int oldIndex, int newIndex) {
    print(oldIndex.toString()+"  "+newIndex.toString());
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final Event item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
      _items.asMap().forEach((key, value) =>{
        value.index = key

      });
        widget._crud.saveAll(item.date.toIso8601String(), _items);
    });
  }

  void _deleteEvent(Event event){
    widget._crud.deleteEvent(event).then((value) => {
      print(value),
      _onLoadList(value),
    });
  }

  void _onLoadList(events){
      _setEvents(events);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text('Events')
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: (){
            setState(() {
              _items.add(Event(title: 'TEST', description: 'TEST', date:  DateTime.utc(2023, 3, 10),time:'10:00AM',index:_items.length+2));
                  });
             },
          label: const Text("Add Event"),
          icon: const Icon(Icons.add)
      ),
      body: ReorderableListView(
        onReorder: _onReorder,
        children:  <Widget>[
          for(final items in widget._items)
            Card(
              color: Colors.white70,
              key: ValueKey(items),
              elevation: 1,
              child: ListTile(
                title: Text((items.index).toString()+") "+items.title+"  (ON "+items.time+")"),
                subtitle: Text(items.description),
                leading: Icon(Icons.event,color: Colors.blue,),
                trailing: IconButton(
                  icon:const Icon(Icons.delete,color: Colors.red),
                  tooltip: "Delete",
                  onPressed: (){
                    _deleteEvent(items);
                  }
                ),
              ),
            ),
        ],
        // children: _items
        //     .map((item) => ListTile(
        //   key: ValueKey(item),
        //   title: Text(item.title),
        // ))
        //     .toList(),
      )
    );
  }
}

class TransitionPage extends StatefulWidget {
  @override
  _TransitionPageState createState() => _TransitionPageState();
}

class _TransitionPageState extends State<TransitionPage> {
  // bool _isLoading =false;

  @override
  void initState() {
    super.initState();
    // _simulateLoading();
  }

  // void _simulateLoading() {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   Future.delayed(Duration(seconds: 2), () {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Center(
      child:  CircularProgressIndicator()
    );
  }
}
