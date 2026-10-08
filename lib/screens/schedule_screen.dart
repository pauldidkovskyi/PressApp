import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/schedule_item.dart';
import '../widgets/event_card.dart';
import '../widgets/task_card.dart';
import '../widgets/item_detail_sheet.dart';
import '../widgets/calendar_sheet.dart';
import '../services/notification_service.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();

  late List<EventItem> _allEvents;
  late List<TaskItem> _allTasks;

  final _eventsBox = Hive.box<EventItem>('events');
  final _tasksBox = Hive.box<TaskItem>('tasks');

  @override
  void initState() {
    super.initState();
    _allEvents = _eventsBox.values.toList();
    _allEvents.sort((a, b) => a.startTime.compareTo(b.startTime));
    _allTasks = _tasksBox.values.toList();
  }

  void _saveData() {
    _eventsBox.clear();
    for (var e in _allEvents) {
      _eventsBox.put(e.id, e);
    }

    _tasksBox.clear();
    for (var t in _allTasks) {
      _tasksBox.put(t.id, t);
    }

    NotificationService().syncNotifications(_allEvents, _allTasks);
  }

  List<EventItem> get _currentEvents => _allEvents
      .where(
        (e) =>
            e.startTime.year == _selectedDate.year &&
            e.startTime.month == _selectedDate.month &&
            e.startTime.day == _selectedDate.day,
      )
      .toList();

  List<TaskItem> get _currentTasks => _allTasks
      .where(
        (t) =>
            t.date.year == _selectedDate.year &&
            t.date.month == _selectedDate.month &&
            t.date.day == _selectedDate.day,
      )
      .toList();

  void _showRescheduleOptions(ScheduleItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: const BoxDecoration(
          color: Color(0xFF2C2C2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            _buildRescheduleBtn(
              icon: Icons.wb_sunny_rounded,
              color: const Color(0xFFFF9F0A),
              text: 'Tomorrow',
              onTap: () {
                Navigator.pop(context);
                _executeReschedule(
                  item,
                  DateTime.now().add(const Duration(days: 1)),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildRescheduleBtn(
              icon: Icons.calendar_month_rounded,
              color: const Color(0xFF0A84FF),
              text: 'Pick Date',
              onTap: () {
                Navigator.pop(context);
                CalendarSheet.show(
                  context,
                  initialDate: _selectedDate,
                  onDateSelected: (pickedDate) =>
                      _executeReschedule(item, pickedDate),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _executeReschedule(ScheduleItem item, DateTime newDate) {
    setState(() {
      if (item is TaskItem) {
        item.date = newDate;
      } else if (item is EventItem) {
        final duration = item.endTime.difference(item.startTime);
        item.startTime = DateTime(
          newDate.year,
          newDate.month,
          newDate.day,
          item.startTime.hour,
          item.startTime.minute,
        );
        item.endTime = item.startTime.add(duration);
      }
      _saveData();
    });
  }

  Widget _buildRescheduleBtn({
    required IconData icon,
    required Color color,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity == null) return;
                  if (details.primaryVelocity! < -300) {
                    setState(
                      () => _selectedDate = _selectedDate.add(
                        const Duration(days: 1),
                      ),
                    );
                  } else if (details.primaryVelocity! > 300) {
                    setState(
                      () => _selectedDate = _selectedDate.subtract(
                        const Duration(days: 1),
                      ),
                    );
                  }
                },
                child: _buildList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 110),
        child: FloatingActionButton(
          onPressed: () {
            final newItem = TaskItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: '',
              date: _selectedDate,
            );
            ItemDetailSheet.show(
              context,
              item: newItem,
              onSave: (savedItem) {
                setState(() {
                  if (savedItem is EventItem) {
                    _allEvents.add(savedItem);
                    _allEvents.sort(
                      (a, b) => a.startTime.compareTo(b.startTime),
                    );
                  } else if (savedItem is TaskItem) {
                    _allTasks.add(savedItem);
                  }
                  _saveData();
                });
              },
            );
          },
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

  String _getHeaderDateText() {
    final now = DateTime.now();
    final isToday =
        _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
    final List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final dateStr = '${months[_selectedDate.month - 1]} ${_selectedDate.day}';
    return isToday ? 'Today, $dateStr' : dateStr;
  }

  Widget _buildHeader() {
    return GestureDetector(
      onTap: () {
        CalendarSheet.show(
          context,
          initialDate: _selectedDate,
          onDateSelected: (newDate) => setState(() => _selectedDate = newDate),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Row(
          children: [
            Text(
              _getHeaderDateText(),
              style: const TextStyle(
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
      ),
    );
  }

  Widget _buildList() {
    final events = _currentEvents;
    final tasks = _currentTasks;

    return ListView(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 120),
      children: [
        if (events.isEmpty && tasks.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 100),
            child: Center(
              child: Text(
                'No schedule for this day',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            ),
          ),
        ...events.map(
          (event) => EventCard(
            key: ValueKey(event.id),
            item: event,
            onToggle: () {
              HapticFeedback.lightImpact();
              setState(() {
                event.isCompleted = !event.isCompleted;
              });
              _saveData();
            },
            onTap: () {
              ItemDetailSheet.show(
                context,
                item: event,
                onSave: (updatedItem) {
                  setState(() {
                    if (updatedItem is TaskItem) {
                      _allEvents.remove(event);
                      _allTasks.add(updatedItem);
                    }
                    _allEvents.sort(
                      (a, b) => a.startTime.compareTo(b.startTime),
                    );
                    _saveData();
                  });
                },
              );
            },
            onReschedule: () => _showRescheduleOptions(event),
            onDelete: () {
              setState(() => _allEvents.remove(event));
              _saveData();
            },
          ),
        ),
        if (tasks.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text(
            'Tasks',
            style: TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            proxyDecorator:
                (Widget child, int index, Animation<double> animation) {
                  return Material(
                    color: Colors.transparent,
                    elevation: 0,
                    child: child,
                  );
                },
            onReorderItem: (oldIndex, newIndex) {
              setState(() {
                final currentDayTasks = _currentTasks.toList();

                final item = currentDayTasks.removeAt(oldIndex);
                currentDayTasks.insert(newIndex, item);

                _allTasks.removeWhere(
                  (t) =>
                      t.date.year == _selectedDate.year &&
                      t.date.month == _selectedDate.month &&
                      t.date.day == _selectedDate.day,
                );

                _allTasks.addAll(currentDayTasks);
                _saveData();
              });
            },
            children: tasks
                .map(
                  (task) => TaskCard(
                    key: ValueKey(task.id),
                    item: task,
                    onToggle: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        task.isCompleted = !task.isCompleted;
                      });
                      _saveData();
                    },
                    onTap: () {
                      ItemDetailSheet.show(
                        context,
                        item: task,
                        onSave: (updatedItem) {
                          setState(() {
                            if (updatedItem is EventItem) {
                              _allTasks.remove(task);
                              _allEvents.add(updatedItem);
                              _allEvents.sort(
                                (a, b) => a.startTime.compareTo(b.startTime),
                              );
                            }
                            _saveData();
                          });
                        },
                      );
                    },
                    onReschedule: () => _showRescheduleOptions(task),
                    onDelete: () {
                      setState(() => _allTasks.remove(task));
                      _saveData();
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}
