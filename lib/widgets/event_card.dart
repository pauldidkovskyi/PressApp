import 'package:flutter/material.dart';
import '../models/schedule_item.dart';

class EventCard extends StatefulWidget {
  final EventItem item;
  final VoidCallback onToggle;
  final Function(String) onTitleChanged;
  final VoidCallback onLongPress;

  const EventCard({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onTitleChanged,
    required this.onLongPress,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.item.title);
    _checkAutoCompletion();
  }

  @override
  void didUpdateWidget(covariant EventCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.title != widget.item.title) {
      _controller.text = widget.item.title;
    }
    _checkAutoCompletion();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkAutoCompletion() {
    final now = DateTime.now();
    if (!widget.item.isCompleted && now.isAfter(widget.item.endTime)) {
      widget.item.isCompleted = true;
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
            _buildTimeBlock(),
            const SizedBox(width: 8),
            Expanded(child: _buildTitleBlock()),
            const SizedBox(width: 8),
            _buildCheckBlock(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeBlock() {
    return Container(
      width: 68,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2D32),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatTime(widget.item.startTime),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _formatTime(widget.item.endTime),
            style: TextStyle(
              color: Colors.white.withOpacity(0.35),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleBlock() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      height: 52,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: const Color(0xFF2C2D32),
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
          color: completed ? const Color(0xFF0A84FF) : const Color(0xFF2C2D32),
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