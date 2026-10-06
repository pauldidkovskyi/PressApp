import 'package:flutter/material.dart';
import '../models/schedule_item.dart';

class TaskCard extends StatefulWidget {
  final TaskItem item;
  final VoidCallback onToggle;
  final Function(String) onTitleChanged;
  final VoidCallback onLongPress;

  const TaskCard({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onTitleChanged,
    required this.onLongPress,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.item.title);
  }

  @override
  void didUpdateWidget(covariant TaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.title != widget.item.title) {
      _controller.text = widget.item.title;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: widget.onLongPress,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(child: _buildTitleBlock()),
            const SizedBox(width: 8),
            _buildCheckBlock(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleBlock() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      height: 52,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: const Color(0xFF2E2C2C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onTitleChanged,
        style: TextStyle(
          color: widget.item.isCompleted ? Colors.white.withOpacity(0.4) : Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          decoration: widget.item.isCompleted ? TextDecoration.lineThrough : null,
          decorationColor: Colors.white.withOpacity(0.4),
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildCheckBlock() {
    final completed = widget.item.isCompleted;
    return GestureDetector(
      onTap: widget.onToggle,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: completed ? const Color(0xFF0A84FF) : const Color(0xFF2E2C2C),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.check_rounded,
          color: completed ? Colors.white : Colors.white.withOpacity(0.2),
          size: 22,
        ),
      ),
    );
  }
}