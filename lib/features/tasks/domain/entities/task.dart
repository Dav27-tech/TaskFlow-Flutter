class Task {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final String status;
  final String priority;
  final DateTime? dueDate;
  final String? assignedTo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    this.status = 'todo',
    this.priority = 'medium',
    this.dueDate,
    this.assignedTo,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isCompleted => status == 'completed' || status == 'done';
}
