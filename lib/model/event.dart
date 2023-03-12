
enum Event_Status{
  TO_DO,OVERDUE,DONE
}

class Event {

   String title;
   String description;
   DateTime date;
   String time;
   int index;
   String status;


  Event({
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.index,
    required this.status
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date.toIso8601String(),
      'description': description,
      'time': time,
      'index': index,
      'status': status,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
        title: json['title'],
        date: DateTime.parse(json['date']),
        description: json['description'],
        time: json['time'],
        index: json['index'],
        status: json['status']
    );
  }
}