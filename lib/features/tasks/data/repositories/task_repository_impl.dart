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
    required String userId,
  }) =>
      dataSource.createTask(
        projectId: projectId,
        title: title,
        description: description,
        userId: userId,
      );

  @override
  Future<void> updateStatus({
    required String projectId,
    required String taskId,
    required String status,
  }) =>
      dataSource.updateStatus(
        projectId: projectId,
        taskId: taskId,
        status: status,
      );

  @override
  Future<void> deleteTask({required String projectId, required String taskId}) =>
      dataSource.deleteTask(projectId: projectId, taskId: taskId);
}