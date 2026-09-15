import '../datasources/task_remote_datasource.dart';
import '../models/task_model.dart';
import 'task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl(this.dataSource);

  final TaskRemoteDataSource dataSource;

  @override
  Stream<List<TaskModel>> watchTasks(String projectId) =>
      dataSource.watchTasks(projectId);

  @override
  Future<void> createTask({
    required String projectId,
    required String title,
    required String description,
    required String assignedMemberId,
    required String priority,
    required String status,
    required DateTime deadline,
    required String userId,
  }) => dataSource.createTask(
    projectId: projectId,
    title: title,
    description: description,
    assignedMemberId: assignedMemberId,
    priority: priority,
    status: status,
    deadline: deadline,
    userId: userId,
  );

  @override
  Future<void> updateTask({
    required String projectId,
    required String taskId,
    required String title,
    required String description,
    required String assignedMemberId,
    required String priority,
    required String status,
    required DateTime deadline,
  }) => dataSource.updateTask(
    projectId: projectId,
    taskId: taskId,
    title: title,
    description: description,
    assignedMemberId: assignedMemberId,
    priority: priority,
    status: status,
    deadline: deadline,
  );

  @override
  Future<void> updateStatus({
    required String projectId,
    required String taskId,
    required String status,
  }) => dataSource.updateStatus(
    projectId: projectId,
    taskId: taskId,
    status: status,
  );

  @override
  Future<void> deleteTask({
    required String projectId,
    required String taskId,
  }) => dataSource.deleteTask(projectId: projectId, taskId: taskId);
}
