// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventItemAdapter extends TypeAdapter<EventItem> {
  @override
  final int typeId = 0;

  @override
  EventItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EventItem(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      isCompleted: fields[3] as bool,
      startTime: fields[4] as DateTime,
      endTime: fields[5] as DateTime,
      reminderMinutes: fields[6] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, EventItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(4)
      ..write(obj.startTime)
      ..writeByte(5)
      ..write(obj.endTime)
      ..writeByte(6)
      ..write(obj.reminderMinutes)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskItemAdapter extends TypeAdapter<TaskItem> {
  @override
  final int typeId = 1;

  @override
  TaskItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskItem(
      id: fields[0] as String,
      title: fields[1] as String,
      date: fields[4] as DateTime,
      description: fields[2] as String?,
      isCompleted: fields[3] as bool,
      reminderTime: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TaskItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.reminderTime)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
