abstract class ScheduleItem {
  final String id;
  String title;
  bool isCompleted;

  ScheduleItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });
}

class EventItem extends ScheduleItem {
  DateTime startTime;
  DateTime endTime;

  EventItem({
    required super.id,
    required super.title,
    required this.startTime,
    required this.endTime,
    super.isCompleted,
  });
}

class TaskItem extends ScheduleItem {
  TaskItem({
    required super.id,
    required super.title,
    super.isCompleted,
  });
}