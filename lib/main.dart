import 'package:event_organizer/controller/navigator_controller.dart';
import 'package:event_organizer/persist/event_persist.dart';
import 'package:event_organizer/view/dialog_event.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_walkthrough_screen/flutter_walkthrough_screen.dart';

import 'model/event.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Organizer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const NavigationBar(),
    );
  }
}

class NavigationBar extends StatefulWidget {
  const NavigationBar({super.key});

  @override
  NavigationBarState createState() => NavigationBarState();
}

class NavigationBarState extends State<NavigationBar> {
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
        title: const Text('Navigation Bar'),
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

class GuidePage extends StatelessWidget {
  NavigatorController _navigatorController =NavigatorController();
  final List<OnbordingData> list = [
    OnbordingData(
      image: AssetImage('images/head.png'),
      titleText:Text("This is Title1"),
      descText: Text("This is desc1"),
    ),
    OnbordingData(
      image: AssetImage("images/head.png"),
      titleText:Text("This is Title2"),
      descText: Text("This is desc2"),
    ),
    OnbordingData(
      image: AssetImage("images/head.png"),
      titleText:Text("This is Title3"),
      descText: Text("This is desc4"),
    ),
    OnbordingData(
      image: AssetImage("images/head.png"),
      titleText:Text("This is Title4"),
      descText: Text("This is desc4"),
    ),
  ];
  final Function(int) onItemTapped;
  GuidePage(this.onItemTapped, {super.key});

  @override
  Widget build(BuildContext context) {
    /* remove the back button in the AppBar is to set automaticallyImplyLeading to false
  here we need to pass the list and the route for the next page to be opened after this. */
    return IntroScreen(
      onbordingDataList: list,
      colors: [
        //list of colors for per pages
        Colors.white,
        Colors.red,
      ],
      doneRead: (i)=>{
        _navigatorController.update(i),
        onItemTapped(i)
      },
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
      selectedDotColor: Colors.orange,
      unSelectdDotColor: Colors.grey,
    );
  }
}


class CalendarView extends StatefulWidget {
  CalendarView({super.key});

  @override
  CalendarViewState createState() => CalendarViewState();

  final EventCRUD eventCRUD = EventCRUD();
}

class CalendarViewState extends State<CalendarView>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.utc(DateTime.now().year,DateTime.now().month,DateTime.now().day);
  late DateTime _selectedDay;
  Map<DateTime, List<Event>> _events =  <DateTime, List<Event>>{
    DateTime.utc(2023, 3, 10): [
      Event(title: 'TEST', description: 'TEST', date:  DateTime.utc(2023, 3, 10),time:'10:00AM',index:1,status:Event_Status.TO_DO.name),
      Event(title: 'TESTB', description: 'TEST', date:  DateTime.utc(2023, 3, 10),time:'03:00PM',index:2,status:Event_Status.TO_DO.name),
    ],
    DateTime.utc(2023, 3, 15): [
      Event(title: 'TESTC', description: 'TEST', date:  DateTime.utc(2023, 3, 15),time:'10:00AM',index:1,status:Event_Status.TO_DO.name),
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
            }catch(e){
              //throw something
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

  double toDouble(TimeOfDay myTime) => myTime.hour + myTime.minute/60.0;
  bool isOverdue(Event event){
    DateTime now = DateTime.now().toUtc();
    DateTime eventDate = event.date;
    TimeOfDay nowTime = TimeOfDay.now();
    List<String> time;
    if(event.time.contains("M")){
      time =  event.time.trim().substring(0, event.time.length - 2).trim().split(':');
    }else{
      time =  event.time.trim().split(':');
    }
    TimeOfDay eventTime;
    if(event.time.contains('PM')){
      eventTime = TimeOfDay(hour:int.parse(time.first)==12?12:int.parse(time.first)+12,minute:int.parse(time.last));
    }else{
      eventTime = TimeOfDay(hour:int.parse(time.first),minute:int.parse(time.last));
    }
    if(now.day==eventDate.day &&now.month==eventDate.month&&now.year==eventDate.year){
      if(toDouble(nowTime)>toDouble(eventTime)){
        event.status = Event_Status.OVERDUE.name;
        return true;
      }else{
        return false;
      }
    }else{
      return false;
    }
  }

  Color _colorDeciderStatus(Event event){
    if(event.status==Event_Status.DONE.name){
      return Colors.lightGreenAccent;
    }else if(event.status==Event_Status.OVERDUE.name||isOverdue(event)){
      return Colors.orangeAccent;
    }else{
      return Colors.white70;
    }
  }

  List<Widget> _buildList(event){
    return <Widget>[
      for(final items in event)
        Card(
          color: _colorDeciderStatus(items),
          key: ValueKey(items),
          elevation: 1,
          child: ListTile(
            title: Text("${(items.index).toString()}) ${items.title}  (ON ${items.time})"),
            subtitle: Text("${items.status}"),
            leading: const Icon(Icons.event,color: Colors.blue,),

          ),
        ),
      ElevatedButton(
        onPressed: () {
          _routeToDetail(event);
        },
        child: const Text("View Events"),
      ),
    ];
  }
  void _simulateLoading() {
      setState(() {
        _isLoading = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });
      });
    }

  Widget _buildEventList() {
    final events = _events[_selectedDay];
    if (events == null || events.isEmpty) {
      return  const FittedBox(
        fit:BoxFit.fitWidth,
         child: Center(
            child: Text('No events for this day',textScaleFactor: 3,),
          )
      );

    }
    return Column(
    children:
      _buildList(events),
        // FittedBox(
        // fit:BoxFit.fitWidth,
        // child: Center(
        //   child: Text('There are '+events.length.toString()+' events today!',textScaleFactor: 3,),
        // )
        // ),
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
          margin: const EdgeInsets.all(4),
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Colors.deepPurple,
            shape: BoxShape.circle,
          ),
          child: Text(
            date.day.toString(),
            style: const TextStyle(color: Colors.white),
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
                decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black),
              ),
            );
          });
    }
    return const SizedBox();
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
                calendarStyle: const CalendarStyle(
                  // todayDecoration: BoxDecoration(
                  //   color: Colors.blue,
                  //   shape: BoxShape.circle,
                  // ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Month',
                  CalendarFormat.week: 'Week',
                },
                calendarBuilders: _calendarBuilder()
            ),
            _isLoading?const TransitionPage():_buildEventList(),
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
  final EventCRUD _crud = EventCRUD();

  ReorderableList(List<Event> events, {super.key}){
    _items = events;
  }

  @override
  ReorderableListState createState() => ReorderableListState(_items);
}


class ReorderableListState extends State<ReorderableList> {
  List<Event> _items = [];

  ReorderableListState(item){
      _items=item;
      _items.sort((a,b)=>a.index.compareTo(b.index));
  }

  void _setEvents(events){
    setState(() {
      _items.clear();
      _items.addAll(events);
    });

  }

  void _onReorder(int oldIndex, int newIndex) {
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
      _onLoadList(value),
    });
  }

  void _doneEvent(Event event){
    event.status = Event_Status.DONE.name;
    widget._crud.saveAll(event.date.toIso8601String(), List.from(_items)).then((value) => {
      _onLoadList(value)
    });
  }


  void _onLoadList(events){
      _setEvents(events);
  }

  double toDouble(TimeOfDay myTime) => myTime.hour + myTime.minute/60.0;
  bool isOverdue(Event event){
    DateTime now = DateTime.now().toUtc();
    DateTime eventDate = event.date;
    TimeOfDay nowTime = TimeOfDay.now();
    List<String> time ;
    if(event.time.contains("M")){
      time =  event.time.trim().substring(0, event.time.length - 2).trim().split(':');
    }else{
      time =  event.time.trim().split(':');
    }TimeOfDay eventTime = TimeOfDay.now();
    if(event.time.contains('PM')){
      eventTime = TimeOfDay(hour:int.parse(time.first)==12?12:int.parse(time.first)+12,minute:int.parse(time.last));
    }else{
      eventTime = TimeOfDay(hour:int.parse(time.first),minute:int.parse(time.last));
    }
    if(now.day==eventDate.day &&now.month==eventDate.month&&now.year==eventDate.year){
      if(toDouble(nowTime)>toDouble(eventTime)){
        event.status = Event_Status.OVERDUE.name;
        return true;
      }else{
        return false;
      }
    }else{
      return false;
    }
  }

  Color _colorDeciderStatus(Event event){
    if(event.status==Event_Status.DONE.name){
      return Colors.lightGreenAccent;
    }else if(event.status==Event_Status.OVERDUE.name||isOverdue(event)){
      return Colors.orangeAccent;
    }else{
      return Colors.white70;
    }
  }

  List<Widget> doneButton(Event event){
    return <Widget>[
    if(event.status==Event_Status.DONE.name)
     IconButton(
    icon:const Icon(Icons.done,color: Colors.blue),
    tooltip: "Done",
    onPressed: (){
    _doneEvent(event);
    }
    )

    ];

  }

  void _editEvent(BuildContext context,Event editEvent){
    showDialog(
      context: context,
      builder: (context) => EventDialog(
        selectedDate: editEvent.date,
        toBeEditEvent: editEvent,
        onSave: (event) {
          setState(() {
            // _events[event.date] = [...?_events[event.date], event];
            try{
              // _items.add(event);
              widget._crud.saveAll(event.date.toIso8601String(), List.from(_items)).then((value) => {
                _onLoadList(value)
              });
            }catch(e){
              //throw something
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

  void _addEvent(BuildContext context) {
    // Implement your logic to add an event for the selected day here
    showDialog(
      context: context,
      builder: (context) => EventDialog(
        selectedDate: _items.first.date,
        onSave: (event) {
          setState(() {
            // _events[event.date] = [...?_events[event.date], event];
            try{
              _items.add(event);
              widget._crud.saveAll(event.date.toIso8601String(), List.from(_items)).then((value) => {
                _onLoadList(value)
              });
            }catch(e){
              //throw something
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text('Events')
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: (){
            setState(() {
              _items.add(Event(title: 'TEST', description: 'TEST', date:  DateTime.utc(2023, 3, 10),time:'10:00AM',index:_items.length+2,status:Event_Status.DONE.name));
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
              color: _colorDeciderStatus(items),
              key: ValueKey(items),
              elevation: 1,
              child: ListTile(
                title: Text("${items.index}) ${items.title}  (ON ${items.time})"),
                subtitle: Text("${items.description} (${items.status})"),
                leading: const Icon(Icons.event,color: Colors.blue,),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if(items.status!=Event_Status.DONE.name)...[
                       IconButton(
                          icon:const Icon(Icons.done,color: Colors.blue),
                          tooltip: "Done",
                          onPressed: (){
                            _doneEvent(items);
                          }
                      )
                    ],
                    if(items.status==Event_Status.TO_DO.name)...[
                      IconButton(
                          icon:const Icon(Icons.edit,color: Colors.blue),
                          tooltip: "Edit",
                          onPressed: (){
                            _editEvent(context,items);
                          }
                      )
                    ],
                    IconButton(
                      icon:const Icon(Icons.delete,color: Colors.red),
                      tooltip: "Delete",
                      onPressed: (){
                        _deleteEvent(items);
                      }
                  ),
                  ],
                )
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
  const TransitionPage({super.key});

  @override
  TransitionPageState createState() => TransitionPageState();
}

class TransitionPageState extends State<TransitionPage> {
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
    return const Center(
      child:  CircularProgressIndicator()
    );
  }
}
