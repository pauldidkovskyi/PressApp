import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/schedule_item.dart';

class EventCard extends StatelessWidget {
  final EventItem item;
  final VoidCallback onToggle;
  final VoidCallback onTap; 
  final VoidCallback onDelete; 
  final VoidCallback onReschedule; 

  const EventCard({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
    required this.onReschedule,
  });

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final completed = item.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      
      child: Slidable(
        key: ValueKey(item.id),
        endActionPane: ActionPane(
          motion: const BehindMotion(), 
          extentRatio: 0.45, 
          children: [
            const SizedBox(width: 8),
            SlidableAction(
              onPressed: (_) => onReschedule(),
              backgroundColor: const Color(0xFFFF9F0A), // iOS Orange
              foregroundColor: Colors.white,
              icon: Icons.calendar_today_rounded,
              borderRadius: BorderRadius.circular(16),
            ),
            const SizedBox(width: 8),
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: const Color(0xFFFF453A), // iOS Red
              foregroundColor: Colors.white,
              icon: Icons.delete_outline_rounded,
              borderRadius: BorderRadius.circular(16),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: onTap, 
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              _buildTimeBlock(),
              const SizedBox(width: 8),
              Expanded(child: _buildTitleBlock(completed)),
              const SizedBox(width: 8),
              _buildCheckBlock(completed),
            ],
          ),
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
            _formatTime(item.startTime),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _formatTime(item.endTime),
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleBlock(bool completed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      height: 52,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: const Color(0xFF2C2D32),
        borderRadius: BorderRadius.circular(16),
      ),

      child: Text(
        item.title,
        style: TextStyle(
          color: completed ? Colors.white54 : Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          decoration: completed ? TextDecoration.lineThrough : null,
          decorationColor: Colors.white54,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildCheckBlock(bool completed) {
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: completed ? const Color(0xFF32D74B) : const Color(0xFF2C2D32),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.check_rounded,
          color: completed ? Colors.white : Colors.white24,
          size: 26,
        ),
      ),
    );
  }
}