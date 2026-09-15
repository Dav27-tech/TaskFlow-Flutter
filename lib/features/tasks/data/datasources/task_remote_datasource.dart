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

  DocumentReference<Map<String, dynamic>> _member(
    String projectId,
    String memberId,
  ) {
    return firestore
        .collection(AppConstants.projectsCollection)
        .doc(projectId)
        .collection(AppConstants.membersSubcollection)
        .doc(memberId);
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
    required String assignedMemberId,
    required String priority,
    required String status,
    required DateTime deadline,
    required String userId,
  }) async {
    await _ensureProjectMember(
      projectId: projectId,
      memberId: assignedMemberId,
    );

    final now = DateTime.now();
    final reference = _tasks(projectId).doc();
    await reference.set(
      TaskModel(
        id: reference.id,
        projectId: projectId,
        title: title,
        description: description,
        status: status,
        priority: priority,
        assignedMemberId: assignedMemberId,
        deadline: deadline,
        createdAt: now,
        updatedAt: now,
        createdBy: userId,
      ).toFirestore(),
    );
  }

  Future<void> updateTask({
    required String projectId,
    required String taskId,
    required String title,
    required String description,
    required String assignedMemberId,
    required String priority,
    required String status,
    required DateTime deadline,
  }) async {
    await _ensureProjectMember(
      projectId: projectId,
      memberId: assignedMemberId,
    );

    await _tasks(projectId).doc(taskId).update({
      'title': title,
      'description': description,
      'assignedMemberId': assignedMemberId,
      'priority': priority,
      'status': status,
      'deadline': Timestamp.fromDate(deadline),
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> updateStatus({
    required String projectId,
    required String taskId,
    required String status,
  }) async {
    await _tasks(
      projectId,
    ).doc(taskId).update({'status': status, 'updatedAt': Timestamp.now()});
  }

  Future<void> deleteTask({
    required String projectId,
    required String taskId,
  }) async {
    await _tasks(projectId).doc(taskId).delete();
  }

  Future<void> _ensureProjectMember({
    required String projectId,
    required String memberId,
  }) async {
    final memberSnapshot = await _member(projectId, memberId).get();
    if (!memberSnapshot.exists) {
      throw StateError('La tâche doit être assignée à un membre du projet.');
    }
  }
}
