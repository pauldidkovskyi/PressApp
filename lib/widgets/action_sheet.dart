import 'package:flutter/material.dart';

class ActionSheet {
  static void show(BuildContext context, {required VoidCallback onDelete, required VoidCallback onReschedule}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionItem(
                icon: Icons.calendar_today_rounded,
                title: 'Reschedule to tomorrow',
                onTap: () {
                  Navigator.pop(context);
                  onReschedule();
                },
              ),
              Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
              _buildActionItem(
                icon: Icons.delete_outline_rounded,
                title: 'Delete',
                color: const Color(0xFFFF453A), // iOS Red
                onTap: () {
                  Navigator.pop(context);
                  onDelete();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildActionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}