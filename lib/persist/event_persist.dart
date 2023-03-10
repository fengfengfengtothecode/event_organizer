import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/event.dart';

class EventCRUD {
  Future<void> createEvent(Event event) async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getString('events');
    Map<DateTime, List<Event>> events = {};
    if (eventsJson != null) {
      final eventsMap = json.decode(eventsJson);
      eventsMap.forEach((key, value) {
        events[DateTime.parse(key)] = (value as List).map((e) => Event.fromJson(e)).toList();
      });
    }
    if (events.containsKey(event.date)) {
      events[event.date]?.add(event);
    } else {
      events[event.date] = [event];
    }
    await prefs.setString('events', json.encode(events));
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

  Future<void> deleteEvent(Event event) async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getString('events');
    if (eventsJson != null) {
      final eventsMap = json.decode(eventsJson);
      Map<DateTime, List<Event>> events = {};
      eventsMap.forEach((key, value) {
        events[DateTime.parse(key)] = (value as List).map((e) => Event.fromJson(e)).toList();
      });
      final selectedDateEvents = events[event.date];
      selectedDateEvents?.removeWhere((e) => e.title == event.title);
      if (selectedDateEvents!.isEmpty) {
        events.remove(event.date);
      } else {
        events[event.date] = selectedDateEvents;
      }
      await prefs.setString('events', json.encode(events));
    }
  }
}
