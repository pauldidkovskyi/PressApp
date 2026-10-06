import 'package:flutter/material.dart';
import '../models/schedule_item.dart';

class ItemDetailSheet extends StatefulWidget {
  final ScheduleItem item;
  final Function(ScheduleItem) onSave;

  const ItemDetailSheet({
    super.key,
    required this.item,
    required this.onSave,
  });

  static void show(BuildContext context, {required ScheduleItem item, required Function(ScheduleItem) onSave}) {
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
    _descController = TextEditingController();
    
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
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime != null 
          ? TimeOfDay.fromDateTime(_startTime!) 
          : TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF0A84FF),
              surface: Color(0xFF2C2C2E),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final now = DateTime.now();
      setState(() {
        _startTime = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
        _endTime = _startTime!.add(const Duration(hours: 1));
      });
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

          // Блок часу з новим хрестиком
          _buildActionRow(
            icon: Icons.access_time_rounded,
            title: timeText,
            color: hasTime ? Colors.white : const Color(0xFF0A84FF),
            onTap: _pickTime,
            // Додаємо кнопку очищення, якщо час встановлено
            trailing: hasTime ? GestureDetector(
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
                child: const Icon(Icons.close_rounded, color: Colors.white70, size: 16),
              ),
            ) : null,
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
    final title = _titleController.text.trim().isEmpty ? 'Untitled' : _titleController.text;

    if (widget.item is TaskItem && _startTime != null && _endTime != null) {
      // Task -> Event (додали час)
      final newEvent = EventItem(
        id: widget.item.id,
        title: title,
        startTime: _startTime!,
        endTime: _endTime!,
      )..isCompleted = widget.item.isCompleted;
      widget.onSave(newEvent);

    } else if (widget.item is EventItem && _startTime == null) {
      // МАГІЯ НАВПАКИ: Event -> Task (прибрали час)
      final newTask = TaskItem(
        id: widget.item.id,
        title: title,
      )..isCompleted = widget.item.isCompleted;
      widget.onSave(newTask);

    } else {
      // Звичайне оновлення (без зміни типу)
      widget.item.title = title;
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
    Widget? trailing, // Додали параметр для елемента справа
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
              // Expanded розтягує текст, щоб trailing завжди був скраю
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