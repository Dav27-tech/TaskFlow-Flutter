import 'package:flutter/material.dart';

enum Priority { high, medium, low }

enum TaskStatus { todo, inProgress, completed }

extension PriorityStyle on Priority {
  Color get color {
    switch (this) {
      case Priority.high: return const Color(0xFFEF476F);
      case Priority.medium: return const Color(0xFFF59E0B);
      case Priority.low: return const Color(0xFF16B981);
    }
  }

  String get label {
    switch (this) {
      case Priority.high: return 'Urgent';
      case Priority.medium: return 'Moyen';
      case Priority.low: return 'Faible';
    }
  }
}

class FocusTask {
  final String name;
  final String project;
  final Color projectColor;
  final Priority priority;
  final String due;
  final bool urgent;

  const FocusTask({
    required this.name,
    required this.project,
    required this.projectColor,
    required this.priority,
    required this.due,
    this.urgent = false,
  });
}

class ProjectItem {
  final String name;
  final List<Color> gradient;
  final double progress;
  final int tasks;
  final int members;

  const ProjectItem({
    required this.name,
    required this.gradient,
    required this.progress,
    required this.tasks,
    required this.members,
  });
}

class ImportantTask {
  final String name;
  final String project;
  final Color projectColor;
  final Priority priority;
  final String due;

  const ImportantTask({
    required this.name,
    required this.project,
    required this.projectColor,
    required this.priority,
    required this.due,
  });
}
