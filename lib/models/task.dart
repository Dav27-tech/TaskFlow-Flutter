import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum TaskPriority { low, medium, high }

enum TaskStatus { todo, inProgress, completed }

extension TaskPriorityX on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  Color get bg {
    switch (this) {
      case TaskPriority.low:
        return AppColors.priorityLowBg;
      case TaskPriority.medium:
        return AppColors.priorityMediumBg;
      case TaskPriority.high:
        return AppColors.priorityHighBg;
    }
  }

  Color get fg {
    switch (this) {
      case TaskPriority.low:
        return AppColors.priorityLowFg;
      case TaskPriority.medium:
        return AppColors.priorityMediumFg;
      case TaskPriority.high:
        return AppColors.priorityHighFg;
    }
  }
}

extension TaskStatusX on TaskStatus {
  String get label {
    switch (this) {
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
    }
  }

  Color get bg {
    switch (this) {
      case TaskStatus.todo:
        return AppColors.statusTodoBg;
      case TaskStatus.inProgress:
        return AppColors.statusInProgressBg;
      case TaskStatus.completed:
        return AppColors.statusCompletedBg;
    }
  }

  Color get fg {
    switch (this) {
      case TaskStatus.todo:
        return AppColors.statusTodoFg;
      case TaskStatus.inProgress:
        return AppColors.statusInProgressFg;
      case TaskStatus.completed:
        return AppColors.statusCompletedFg;
    }
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final String projectId;
  final String memberId;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime deadline;
  final DateTime createdAt;
  final String createdBy;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.projectId,
    required this.memberId,
    required this.priority,
    required this.status,
    required this.deadline,
    required this.createdAt,
    required this.createdBy,
  });

  Task copyWith({
    String? title,
    String? description,
    String? projectId,
    String? memberId,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? deadline,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      projectId: projectId ?? this.projectId,
      memberId: memberId ?? this.memberId,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt,
      createdBy: createdBy,
    );
  }
}
