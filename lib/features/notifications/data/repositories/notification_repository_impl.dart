import '../../domain/entities/notification.dart';
import '../datasources/notification_remote_datasource.dart';
import 'notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl(this.dataSource);

  final NotificationRemoteDataSource dataSource;

  @override
  Stream<List<AppNotification>> watchNotifications(String userId) {
    return dataSource.watchNotifications(userId);
  }

  @override
  Future<void> addNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? projectId,
    String? taskId,
  }) {
    return dataSource.addNotification(
      userId: userId,
      title: title,
      message: message,
      type: type,
      projectId: projectId,
      taskId: taskId,
    );
  }

  @override
  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  }) {
    return dataSource.markAsRead(userId: userId, notificationId: notificationId);
  }

  @override
  Future<void> markAllAsRead({required String userId}) {
    return dataSource.markAllAsRead(userId: userId);
  }
}
