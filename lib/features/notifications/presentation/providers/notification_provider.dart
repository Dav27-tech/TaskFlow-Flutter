import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../projects/presentation/providers/project_provider.dart';
import '../../data/datasources/notification_remote_datasource.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/entities/notification.dart';

final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>((ref) {
      return NotificationRemoteDataSource();
    });

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(
    ref.watch(notificationRemoteDataSourceProvider),
  );
});

final notificationsStreamProvider = StreamProvider<List<AppNotification>>((
  ref,
) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId.isEmpty) {
    return Stream.value(const <AppNotification>[]);
  }
  return ref.watch(notificationRepositoryProvider).watchNotifications(userId);
});

class NotificationActionController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> markAsRead({required String notificationId}) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId.isEmpty) return false;

    state = const AsyncLoading();
    try {
      await ref
          .read(notificationRepositoryProvider)
          .markAsRead(userId: userId, notificationId: notificationId);
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId.isEmpty) return false;

    state = const AsyncLoading();
    try {
      await ref
          .read(notificationRepositoryProvider)
          .markAllAsRead(userId: userId);
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }
}

final notificationActionControllerProvider =
    NotifierProvider<NotificationActionController, AsyncValue<void>>(
      NotificationActionController.new,
    );
