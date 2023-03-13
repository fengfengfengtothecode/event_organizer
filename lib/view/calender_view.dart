import 'package:event_organizer/view/event_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../model/event.dart';
import '../persist/event_persist.dart';
import 'dialog_event.dart';
import '../main.dart' as Main;
import 'loading_view.dart';

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
        builder: (context) =>  EventList(events),
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
