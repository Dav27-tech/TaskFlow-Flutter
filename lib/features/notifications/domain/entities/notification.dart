class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.projectId,
    this.taskId,
    this.isRead = false,
    this.readAt,
  });

  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final String? projectId;
  final String? taskId;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? type,
    String? projectId,
    String? taskId,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      projectId: projectId ?? this.projectId,
      taskId: taskId ?? this.taskId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }
}
