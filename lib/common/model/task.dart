class Task {
  final int? id;
  final String date;
  final String name;
  final String details;
  final bool done;

  Task({this.id, required this.date, required this.name, this.details = '', this.done = false});

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date,
        'name': name,
        'details': details,
        'done': done ? 1 : 0,
      };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
        id: map['id'],
        date: map['date'],
        name: map['name'],
        details: map['details'],
        done: map['done'] == 1,
      );
}
