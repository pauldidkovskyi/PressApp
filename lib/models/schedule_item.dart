import 'package:hive/hive.dart';

part 'schedule_item.g.dart'; 

abstract class ScheduleItem {
  @HiveField(0) String id;
  @HiveField(1) String title;
  @HiveField(2) String? description;
  @HiveField(3) bool isCompleted;

  ScheduleItem({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
  });
}

@HiveType(typeId: 0)
class EventItem extends ScheduleItem {
  @HiveField(4) DateTime startTime;
  @HiveField(5) DateTime endTime;
  @HiveField(6) int? reminderMinutes; 
  EventItem({
    required super.id,
    required super.title,
    super.description,
    super.isCompleted,
    required this.startTime,
    required this.endTime,
    this.reminderMinutes,
  });
}

@HiveType(typeId: 1)
class TaskItem extends ScheduleItem {
  @HiveField(4) DateTime date;
  @HiveField(5) DateTime? reminderTime; 

  TaskItem({
    required super.id,
    required super.title,
    required this.date,
    super.description,
    super.isCompleted,
    this.reminderTime,
  });
}