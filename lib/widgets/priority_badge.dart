import 'package:flutter/material.dart';
import '../models/task.dart';

class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: priority.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        priority.label,
        style: TextStyle(
          color: priority.fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
