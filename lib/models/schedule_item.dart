abstract class ScheduleItem {
  String id;
  String title;
  String? description;
  bool isCompleted;

  ScheduleItem({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
  });
}

class EventItem extends ScheduleItem {
  DateTime startTime;
  DateTime endTime;

  EventItem({
    required super.id,
    required super.title,
    super.description,
    super.isCompleted,
    required this.startTime,
    required this.endTime,
  });
}

class TaskItem extends ScheduleItem {
  DateTime date;
  TaskItem({
    required super.id,
    required super.title,
    required this.date,
    super.description,
    super.isCompleted,
  });
}
