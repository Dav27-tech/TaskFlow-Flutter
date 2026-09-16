import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notification_model.dart';

class NotificationRemoteDataSource {
  NotificationRemoteDataSource({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      firestore.collection('notifications');

  Stream<List<NotificationModel>> watchNotifications(String userId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(NotificationModel.fromFirestore).toList(),
        );
  }

  Future<void> addNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? projectId,
    String? taskId,
  }) async {
    final now = DateTime.now();
    final ref = _collection.doc();
    await ref.set(
      NotificationModel(
        id: ref.id,
        userId: userId,
        title: title,
        message: message,
        type: type,
        projectId: projectId,
        taskId: taskId,
        createdAt: now,
      ).toFirestore(),
    );
  }

  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  }) async {
    await _collection.doc(notificationId).update({
      'isRead': true,
      'readAt': Timestamp.now(),
    });
  }

  Future<void> markAllAsRead({required String userId}) async {
    final snapshot = await _collection
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true, 'readAt': Timestamp.now()});
    }
    await batch.commit();
  }
}
