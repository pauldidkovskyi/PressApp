import 'package:flutter/material.dart';

import '../models/schedule_item.dart';

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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.title);
    // Підтягуємо існуючий опис, якщо він є
    _descController = TextEditingController(
      text: widget.item.description ?? '',
    );

    if (widget.item is EventItem) {
      _startTime = (widget.item as EventItem).startTime;
      _endTime = (widget.item as EventItem).endTime;
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

  Future<void> _pickTime() async {
    final startPicked = await showTimePicker(
      context: context,
      initialTime: _startTime != null
          ? TimeOfDay.fromDateTime(_startTime!)
          : TimeOfDay.now(),
      helpText: 'SELECT START TIME',
      builder: _pickerTheme,
    );

    if (startPicked != null) {
      // ignore: use_build_context_synchronously
      final endPicked = await showTimePicker(
        context: context,
        initialTime: _endTime != null
            ? TimeOfDay.fromDateTime(_endTime!)
            : TimeOfDay(
                hour: (startPicked.hour + 1) % 24,
                minute: startPicked.minute,
              ),
        helpText: 'SELECT END TIME',
        builder: _pickerTheme,
      );

      if (endPicked != null) {
        final now = DateTime.now();
        setState(() {
          _startTime = DateTime(
            now.year,
            now.month,
            now.day,
            startPicked.hour,
            startPicked.minute,
          );
          _endTime = DateTime(
            now.year,
            now.month,
            now.day,
            endPicked.hour,
            endPicked.minute,
          );

          if (_endTime!.isBefore(_startTime!)) {
            _endTime = _endTime!.add(const Duration(days: 1));
          }
        });
      }
    }
  }

  Widget _pickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF0A84FF),
          surface: Color(0xFF2C2C2E),
        ),
      ),
      child: child!,
    );
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
      )..isCompleted = widget.item.isCompleted;
      widget.onSave(newEvent);
    } else if (widget.item is EventItem && _startTime == null) {
      final newTask = TaskItem(
        id: widget.item.id,
        title: title,
        description: desc,
        date: (widget.item as EventItem).startTime,
      )..isCompleted = widget.item.isCompleted;
      widget.onSave(newTask);
    } else {
      widget.item.title = title;
      widget.item.description = desc;
      if (widget.item is EventItem && _startTime != null) {
        (widget.item as EventItem).startTime = _startTime!;
        (widget.item as EventItem).endTime = _endTime!;
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
