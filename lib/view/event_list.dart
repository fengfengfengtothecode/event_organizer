import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/event.dart';
import '../persist/event_persist.dart';
import 'dialog_event.dart';

class EventList extends StatefulWidget {
  List<Event> _items = [];
  final EventCRUD _crud = EventCRUD();

  EventList(List<Event> events, {super.key}){
    _items = events;
  }

  @override
  EventListState createState() => EventListState(_items);
}


class EventListState extends State<EventList> {
  List<Event> _items = [];

  EventListState(item){
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
              _addEvent(context);
              // setState(() {
              //   _items.add(Event(title: 'TEST', description: 'TEST', date:  DateTime.utc(2023, 3, 10),time:'10:00AM',index:_items.length+2,status:Event_Status.DONE.name));
              //       });
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