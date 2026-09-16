import '../../domain/entities/notification.dart';

abstract class NotificationRepository {
  Stream<List<AppNotification>> watchNotifications(String userId);

  Future<void> addNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? projectId,
    String? taskId,
  });

  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  });

  Future<void> markAllAsRead({required String userId});
}
