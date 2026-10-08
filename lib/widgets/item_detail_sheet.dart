import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../models/schedule_item.dart';

import 'package:flutter/services.dart';

class ItemDetailSheet extends StatefulWidget {
  final ScheduleItem item;
  final Function(ScheduleItem) onSave;

  const ItemDetailSheet({super.key, required this.item, required this.onSave});

  static void show(
    BuildContext context, {
    required ScheduleItem item,
    required Function(ScheduleItem) onSave,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ItemDetailSheet(item: item, onSave: onSave),
      ),
    );
  }

  @override
  State<ItemDetailSheet> createState() => _ItemDetailSheetState();
}

class _ItemDetailSheetState extends State<ItemDetailSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  DateTime? _startTime;
  DateTime? _endTime;
  int? _reminderMinutes;
  DateTime? _reminderTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.title);
    _descController = TextEditingController(
      text: widget.item.description ?? '',
    );

    if (widget.item is EventItem) {
      _startTime = (widget.item as EventItem).startTime;
      _endTime = (widget.item as EventItem).endTime;
      _reminderMinutes = (widget.item as EventItem).reminderMinutes;
    } else if (widget.item is TaskItem) {
      _reminderTime = (widget.item as TaskItem).reminderTime;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<DateTime?> _showCenteredTimePicker({
    required DateTime initialTime,
    required String title,
    required String buttonText,
  }) {
    DateTime tempTime = initialTime;
    return showDialog<DateTime>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF2C2C2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //(SELECT START TIME / END TIME)
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  height: 200,
                  child: Transform.scale(
                    scale: 1.25, // +25%
                    child: CupertinoTheme(
                      data: const CupertinoThemeData(
                        brightness: Brightness.dark,
                      ),
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        use24hFormat: true,
                        initialDateTime: initialTime,
                        onDateTimeChanged: (newTime) {
                          HapticFeedback.selectionClick(); 
                          tempTime = newTime;
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, tempTime),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A84FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickTime() async {
    final now = DateTime.now();
    DateTime startTemp =
        _startTime ??
        DateTime(now.year, now.month, now.day, now.hour, now.minute);

    final pickedStart = await _showCenteredTimePicker(
      initialTime: startTemp,
      title: 'SELECT START TIME',
      buttonText: 'Next',
    );

    if (pickedStart == null || !mounted) return;

    DateTime endTemp = _endTime ?? pickedStart.add(const Duration(hours: 1));
    if (endTemp.isBefore(pickedStart)) {
      endTemp = pickedStart.add(const Duration(hours: 1));
    }

    final pickedEnd = await _showCenteredTimePicker(
      initialTime: endTemp,
      title: 'SELECT END TIME',
      buttonText: 'Done',
    );

    if (pickedEnd == null || !mounted) return;

    setState(() {
      _startTime = pickedStart;
      _endTime = pickedEnd;
      if (_endTime!.isBefore(_startTime!)) {
        _endTime = _endTime!.add(const Duration(days: 1));
      }
      _reminderTime = null;
    });
  }

  Future<void> _pickTaskReminderTime() async {
    final baseDate = widget.item is TaskItem
        ? (widget.item as TaskItem).date
        : DateTime.now();
    DateTime tempTime =
        _reminderTime ??
        DateTime(baseDate.year, baseDate.month, baseDate.day, 9, 0);

    final picked = await _showCenteredTimePicker(
      initialTime: tempTime,
      title: 'SET REMINDER TIME',
      buttonText: 'Done',
    );

    if (picked != null && mounted) {
      setState(() {
        _reminderTime = DateTime(
          baseDate.year,
          baseDate.month,
          baseDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _handleReminderTap() {
    if (_startTime != null && _endTime != null) {
      _showEventReminderOptions();
    } else {
      _pickTaskReminderTime();
    }
  }

  void _showEventReminderOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Remind me'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() => _reminderMinutes = null);
              Navigator.pop(context);
            },
            child: const Text('None', style: TextStyle(color: Colors.white)),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() => _reminderMinutes = 0);
              Navigator.pop(context);
            },
            child: const Text(
              'At event time',
              style: TextStyle(color: Colors.white),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() => _reminderMinutes = 5);
              Navigator.pop(context);
            },
            child: const Text(
              '5 minutes before',
              style: TextStyle(color: Colors.white),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() => _reminderMinutes = 15);
              Navigator.pop(context);
            },
            child: const Text(
              '15 minutes before',
              style: TextStyle(color: Colors.white),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() => _reminderMinutes = 30);
              Navigator.pop(context);
            },
            child: const Text(
              '30 minutes before',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: CupertinoColors.activeBlue),
          ),
        ),
      ),
    );
  }

  String _getReminderText() {
    if (_startTime != null && _endTime != null) {
      if (_reminderMinutes == null) return 'Remind me';
      if (_reminderMinutes == 0) return 'At event time';
      return '$_reminderMinutes minutes before';
    } else {
      if (_reminderTime == null) return 'Remind me';
      return _formatTime(_reminderTime!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasTime = _startTime != null && _endTime != null;
    final timeText = hasTime
        ? '${_formatTime(_startTime!)} - ${_formatTime(_endTime!)}'
        : 'Add Time';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF2C2C2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
            decoration: const InputDecoration(
              hintText: 'Title',
              hintStyle: TextStyle(color: Colors.white30),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 24),
          _buildActionRow(
            icon: Icons.access_time_rounded,
            title: timeText,
            color: hasTime ? Colors.white : const Color(0xFF0A84FF),
            onTap: _pickTime,
            trailing: hasTime
                ? GestureDetector(
                    onTap: () => setState(() {
                      _startTime = null;
                      _endTime = null;
                      _reminderMinutes = null;
                    }),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
                        size: 16,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          _buildActionRow(
            icon: CupertinoIcons.bell_fill,
            title: _getReminderText(),
            color: (_reminderMinutes != null || _reminderTime != null)
                ? Colors.white
                : const Color(0xFF8E8E93),
            onTap: _handleReminderTap,
            trailing: (_reminderMinutes != null || _reminderTime != null)
                ? GestureDetector(
                    onTap: () => setState(() {
                      _reminderMinutes = null;
                      _reminderTime = null;
                    }),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
                        size: 16,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: _descController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: const InputDecoration(
                hintText: 'Add description...',
                hintStyle: TextStyle(color: Colors.white30),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _saveItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A84FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _saveItem() {
    final title = _titleController.text.trim().isEmpty
        ? 'Untitled'
        : _titleController.text;
    final desc = _descController.text.trim().isEmpty
        ? null
        : _descController.text.trim();

    if (widget.item is TaskItem && _startTime != null && _endTime != null) {
      final newEvent = EventItem(
        id: widget.item.id,
        title: title,
        description: desc,
        startTime: _startTime!,
        endTime: _endTime!,
        reminderMinutes: _reminderMinutes,
      )..isCompleted = widget.item.isCompleted;
      widget.onSave(newEvent);
    } else if (widget.item is EventItem && _startTime == null) {
      final newTask = TaskItem(
        id: widget.item.id,
        title: title,
        description: desc,
        date: (widget.item as EventItem).startTime,
        reminderTime: _reminderTime,
      )..isCompleted = widget.item.isCompleted;
      widget.onSave(newTask);
    } else {
      widget.item.title = title;
      widget.item.description = desc;
      if (widget.item is EventItem && _startTime != null) {
        (widget.item as EventItem).startTime = _startTime!;
        (widget.item as EventItem).endTime = _endTime!;
        (widget.item as EventItem).reminderMinutes = _reminderMinutes;
      } else if (widget.item is TaskItem) {
        (widget.item as TaskItem).reminderTime = _reminderTime;
      }
      widget.onSave(widget.item);
    }
    Navigator.pop(context);
  }

  Widget _buildActionRow({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }
}
