import 'package:flutter/material.dart';

class CalendarSheet extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;

  const CalendarSheet({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
  });

  static void show(BuildContext context, {required DateTime initialDate, required Function(DateTime) onDateSelected}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => CalendarSheet(
        initialDate: initialDate,
        onDateSelected: onDateSelected,
      ),
    );
  }

  @override
  State<CalendarSheet> createState() => _CalendarSheetState();
}

class _CalendarSheetState extends State<CalendarSheet> {
  late DateTime _displayedMonth;
  late DateTime _selectedDate;

  final List<String> _months = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
  }

  void _changeMonth(int offset) {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + offset, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF2C2C2E), 
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_months[_displayedMonth.month]} ${_displayedMonth.year}',
                style: const TextStyle(
                  color: Color(0xFFFF453A),
                  fontSize: 28, 
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _changeMonth(-1),
                    icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () => _changeMonth(1),
                    icon: const Icon(Icons.chevron_right_rounded, color: Colors.white),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          _buildGrid(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    int daysInMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    int firstWeekday = _displayedMonth.weekday; 
    final now = DateTime.now();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: daysInMonth + firstWeekday - 1,
      itemBuilder: (context, index) {
        if (index < firstWeekday - 1) {
          return const SizedBox(); 
        }

        int day = index - (firstWeekday - 1) + 1;
        DateTime cellDate = DateTime(_displayedMonth.year, _displayedMonth.month, day);
        
        bool isSelected = _selectedDate.year == cellDate.year &&
                          _selectedDate.month == cellDate.month &&
                          _selectedDate.day == cellDate.day;
                          
        bool isToday = now.year == cellDate.year && 
                       now.month == cellDate.month && 
                       now.day == cellDate.day;

        int weekday = (index % 7) + 1;
        bool isWeekend = weekday == 6 || weekday == 7;

        Color textColor;
        if (isSelected) {
          textColor = Colors.white;
        } else if (isWeekend) {
          textColor = const Color(0xFFFF453A);
        } else {
          textColor = Colors.white;
        }

        return GestureDetector(
          onTap: () {
            setState(() => _selectedDate = cellDate);
            widget.onDateSelected(cellDate);
            Navigator.pop(context); 
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF0A84FF) : Colors.transparent,
              shape: BoxShape.circle,
              border: isToday && !isSelected 
                  ? Border.all(color: Colors.white30, width: 1.5) 
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              day.toString(),
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }
}