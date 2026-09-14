class Task {
  const Task({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  final String id;
  final String projectId;
  final String title;
  final String description;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  Task copyWith({String? status}) {
    return Task(
      id: id,
      projectId: projectId,
      title: title,
      description: description,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
    );
  }
}