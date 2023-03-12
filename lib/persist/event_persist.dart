import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/event.dart';

class EventCRUD {
  Future<void> createEvent(Event event) async {
    final saveEventDateString = event.date.toIso8601String();
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getString('events');
    Map<String, dynamic> events = {};
    if (eventsJson != null) {
      final eventsMap = json.decode(eventsJson);
      eventsMap.forEach((key, value) {
        events[DateTime.parse(key).toIso8601String()] = (value as List).map((e) => Event.fromJson(e)).toList();
      });
    }
    if (events.containsKey(saveEventDateString)) {
      List<Event> existedEvent =  events[saveEventDateString]!;
      event.index = existedEvent.length+1;
      events[saveEventDateString]?.add(event);
    } else {
      event.index=1;
      events.putIfAbsent(saveEventDateString, () => [event]);
      // events[event.date] = [event];
    }
    String encodedMap = json.encode(events);
    await prefs.setString('events', encodedMap);
  }

  Future<Map<DateTime, List<Event>>> readEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getString('events');
    Map<DateTime, List<Event>> events = {};
    if (eventsJson != null) {
      final eventsMap = json.decode(eventsJson);
      eventsMap.forEach((key, value) {
        events[DateTime.parse(key)] = (value as List).map((e) => Event.fromJson(e)).toList();
      });
    }
    return events;
  }

  Future<List<Event>> saveAll(String key, List<Event> updateEvents) async{
    int i=1;
    updateEvents.forEach((s)=>{
      s.index=i,
      i++
    });
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getString('events');
    Map<String, dynamic> events = {};
    if (eventsJson != null) {
      final eventsMap = json.decode(eventsJson);
      eventsMap.forEach((key, value) {
        events[DateTime.parse(key).toIso8601String()] = (value as List).map((e) => Event.fromJson(e)).toList();
      });
      if(events.containsKey(key)){
        events.remove(key);
        events.putIfAbsent(key, () => updateEvents);
        String encodedMap = json.encode(events);
        await prefs.setString('events', encodedMap);
        return updateEvents;
      }
    }
    return [];
  }

  Future<void> updateEvent(Event oldEvent, Event newEvent) async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getString('events');
    if (eventsJson != null) {
      final eventsMap = json.decode(eventsJson);
      Map<DateTime, List<Event>> events = {};
      eventsMap.forEach((key, value) {
        events[DateTime.parse(key)] = (value as List).map((e) => Event.fromJson(e)).toList();
      });
      final selectedDateEvents = events[oldEvent.date];
      selectedDateEvents?.removeWhere((e) => e.title == oldEvent.title);
      if (selectedDateEvents!.isEmpty) {
        events.remove(oldEvent.date);
      }
      if (events.containsKey(newEvent.date)) {
        events[newEvent.date]?.add(newEvent);
      } else {
        events[newEvent.date] = [newEvent];
      }
      await prefs.setString('events', json.encode(events));
    }
  }

  Future<List<Event>> deleteEvent(Event event) async {
    String eventDateString = event.date.toIso8601String();
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getString('events');
    Map<String, dynamic> events = {};
    if (eventsJson != null) {
      final eventsMap = json.decode(eventsJson);
      eventsMap.forEach((key, value) {
        events[DateTime.parse(key).toIso8601String()] = (value as List).map((e) => Event.fromJson(e)).toList();
      });
      final selectedDateEvents = events[eventDateString];
      selectedDateEvents.removeWhere((e) => e.index == event.index);
      if (selectedDateEvents!.isEmpty) {
        events.remove(eventDateString);
      } else {
        int i=1;
        selectedDateEvents.forEach((s)=>{
          s.index=i,
          i++
        });
        events[eventDateString] = selectedDateEvents;
      }
      await prefs.setString('events', json.encode(events));
      return selectedDateEvents;
    }
    return [];
  }
}
