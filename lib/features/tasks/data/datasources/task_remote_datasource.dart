import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/task_model.dart';

class TaskRemoteDataSource {
  TaskRemoteDataSource({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> _tasks(String projectId) {
    return firestore
        .collection(AppConstants.projectsCollection)
        .doc(projectId)
        .collection(AppConstants.tasksSubcollection);
  }

  Stream<List<TaskModel>> watchTasks(String projectId) {
    return _tasks(projectId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(TaskModel.fromFirestore).toList());
  }

  Future<void> createTask({
    required String projectId,
    required String title,
    required String description,
    required String userId,
  }) async {
    final now = DateTime.now();
    final reference = _tasks(projectId).doc();
    await reference.set(
      TaskModel(
        id: reference.id,
        projectId: projectId,
        title: title,
        description: description,
        status: 'todo',
        createdAt: now,
        updatedAt: now,
        createdBy: userId,
      ).toFirestore(),
    );
  }

  Future<void> updateStatus({
    required String projectId,
    required String taskId,
    required String status,
  }) async {
    await _tasks(projectId).doc(taskId).update({
      'status': status,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> deleteTask({
    required String projectId,
    required String taskId,
  }) async {
    await _tasks(projectId).doc(taskId).delete();
  }
}