class Event {
  final String title;
  final String description;
  final DateTime date;
  final int index;

  Event({
    required this.title,
    required this.description,
    required this.date,
    required this.index,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date.toIso8601String(),
      'description': description,
      'index': index,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
        title: json['title'],
        date: DateTime.parse(json['date']),
        description: json['description'],
        index: json['index']
    );
  }
}