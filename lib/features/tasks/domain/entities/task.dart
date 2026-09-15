class Task {
  const Task({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.assignedMemberId,
    required this.deadline,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  final String id;
  final String projectId;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String? assignedMemberId;
  final DateTime? deadline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  Task copyWith({
    String? title,
    String? description,
    String? status,
    String? priority,
    String? assignedMemberId,
    DateTime? deadline,
  }) {
    return Task(
      id: id,
      projectId: projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assignedMemberId: assignedMemberId ?? this.assignedMemberId,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
    );
  }
}
