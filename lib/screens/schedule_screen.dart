import 'package:flutter/material.dart';

import '../models/schedule_item.dart';
import '../widgets/event_card.dart';
import '../widgets/task_card.dart';
import '../widgets/item_detail_sheet.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final List<EventItem> _events = [
    EventItem(
      id: '1',
      title: 'Тренування: Спина / Біцепс',
      startTime: DateTime.now().subtract(const Duration(hours: 2)),
      endTime: DateTime.now().subtract(const Duration(hours: 1)),
    )..isCompleted = true,
    EventItem(
      id: '2',
      title: 'Мітинг по системній інженерії',
      startTime: DateTime.now().add(const Duration(hours: 1)),
      endTime: DateTime.now().add(const Duration(hours: 2)),
    ),
  ];

  final List<TaskItem> _tasks = [
    TaskItem(id: 't1', title: 'Випити 2л води'),
    TaskItem(id: 't2', title: 'Зробити вакуум живота'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(child: _buildList()),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 110),
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: const Color(0xFF0A84FF),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Row(
        children: [
          const Text(
            'Today, Oct 6',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 120),
      children: [
        ..._events.map(
          (event) => EventCard(
            key: ValueKey(event.id),
            item: event,
            onToggle: () =>
                setState(() => event.isCompleted = !event.isCompleted),
            onTap: () {
              ItemDetailSheet.show(
                context,
                item: event,
                onSave: (updatedItem) {
                  setState(() {
                    if (updatedItem is TaskItem) {
                      // Якщо повернувся Task, видаляємо зі Schedule і кидаємо в Tasks
                      _events.remove(event);
                      _tasks.add(updatedItem);
                    } else {
                      // Інакше просто пересортовуємо події
                      _events.sort(
                        (a, b) => a.startTime.compareTo(b.startTime),
                      );
                    }
                  });
                },
              );
            },
            onReschedule: () {
              setState(() => _events.remove(event));
            },
            onDelete: () {
              setState(() => _events.remove(event));
            },
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Tasks',
          style: TextStyle(
            color: Color(0xFF8E8E93),
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 12),
        ..._tasks.map(
          (task) => TaskCard(
            key: ValueKey(task.id),
            item: task,
            onToggle: () =>
                setState(() => task.isCompleted = !task.isCompleted),
            onTap: () {
              ItemDetailSheet.show(
                context,
                item: task,
                onSave: (updatedItem) {
                  setState(() {
                    if (updatedItem is EventItem) {
                      _tasks.remove(task);
                      _events.add(updatedItem);
                      _events.sort(
                        (a, b) => a.startTime.compareTo(b.startTime),
                      );
                    }
                  });
                },
              );
            },
            onReschedule: () {
              setState(() => _tasks.remove(task));
            },
            onDelete: () {
              setState(() => _tasks.remove(task));
            },
          ),
        ),
      ],
    );
  }
}
