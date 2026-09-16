import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/notification.dart';

class NotificationModel extends AppNotification {
  const NotificationModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.message,
    required super.type,
    required super.createdAt,
    super.projectId,
    super.taskId,
    super.isRead,
    super.readAt,
  });

  factory NotificationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      message: data['message'] as String? ?? '',
      type: data['type'] as String? ?? 'info',
      projectId: data['projectId'] as String?,
      taskId: data['taskId'] as String?,
      isRead: data['isRead'] as bool? ?? false,
      createdAt: _readDate(data['createdAt']),
      readAt: _readOptionalDate(data['readAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'projectId': projectId,
      'taskId': taskId,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'readAt': readAt == null ? null : Timestamp.fromDate(readAt!),
    };
  }

  static DateTime _readDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
  }

  static DateTime? _readOptionalDate(Object? value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    return DateTime.tryParse(value.toString());
  }
}
