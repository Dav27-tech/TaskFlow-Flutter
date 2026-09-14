import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../projects/presentation/providers/project_provider.dart';
import '../../data/datasources/task_remote_datasource.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/entities/task.dart';

final taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
  return TaskRemoteDataSource();
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(ref.watch(taskRemoteDataSourceProvider));
});

final tasksStreamProvider = StreamProvider.family<List<Task>, String>(
  (ref, projectId) {
    return ref.watch(taskRepositoryProvider).watchTasks(projectId);
  },
);

class TaskActionController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> createTask({
    required String projectId,
    required String title,
    required String description,
  }) async {
    return _run(() => ref.read(taskRepositoryProvider).createTask(
          projectId: projectId,
          title: title,
          description: description,
          userId: ref.read(currentUserIdProvider),
        ));
  }

  Future<bool> updateStatus({
    required String projectId,
    required String taskId,
    required String status,
  }) async {
    return _run(() => ref.read(taskRepositoryProvider).updateStatus(
          projectId: projectId,
          taskId: taskId,
          status: status,
        ));
  }

  Future<bool> deleteTask({
    required String projectId,
    required String taskId,
  }) async {
    return _run(() => ref.read(taskRepositoryProvider).deleteTask(
          projectId: projectId,
          taskId: taskId,
        ));
  }

  Future<bool> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    try {
      await action();
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }
}

final taskActionControllerProvider =
    NotifierProvider<TaskActionController, AsyncValue<void>>(
  TaskActionController.new,
);