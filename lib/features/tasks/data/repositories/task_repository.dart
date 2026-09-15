import '../models/task_model.dart';

abstract class TaskRepository {
  Stream<List<TaskModel>> watchTasks(String projectId);
  Future<void> createTask({
    required String projectId,
    required String title,
    required String description,
    required String assignedMemberId,
    required String priority,
    required String status,
    required DateTime deadline,
    required String userId,
  });
  Future<void> updateTask({
    required String projectId,
    required String taskId,
    required String title,
    required String description,
    required String assignedMemberId,
    required String priority,
    required String status,
    required DateTime deadline,
  });
  Future<void> updateStatus({
    required String projectId,
    required String taskId,
    required String status,
  });
  Future<void> deleteTask({required String projectId, required String taskId});
}
