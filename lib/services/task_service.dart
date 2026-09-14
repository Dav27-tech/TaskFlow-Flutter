import 'dart:async';
import 'dart:math';
import '../data/mock_data.dart';
import '../models/task.dart';

/// Simulates a backend. Every mutation is broadcast on [taskStream] so any
/// screen listening to it updates instantly ("real-time updates").
///
/// In a real app this class would wrap Firestore / a WebSocket / polling.
/// The public API (create/update/delete/watch) is exactly what you'd need
/// to swap this for a real client without touching the UI layer.
class TaskService {
  TaskService._internal() {
    _tasks = MockData.initialTasks();
    _controller = StreamController<List<Task>>.broadcast();
    _emit();
  }

  static final TaskService instance = TaskService._internal();

  late List<Task> _tasks;
  late final StreamController<List<Task>> _controller;

  Stream<List<Task>> get taskStream => _controller.stream;

  List<Task> get currentTasks => List.unmodifiable(_tasks);

  void _emit() {
    _controller.add(List.unmodifiable(_tasks));
  }

  Task? getById(String id) {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Simulated network latency so the UI can show its loading state.
  Future<void> _simulateLatency() =>
      Future.delayed(const Duration(milliseconds: 900));

  Future<Task> createTask({
    required String title,
    required String description,
    required String projectId,
    required String memberId,
    required TaskPriority priority,
    required TaskStatus status,
    required DateTime deadline,
  }) async {
    await _simulateLatency();
    final task = Task(
      id: 't${Random().nextInt(999999)}',
      title: title.trim(),
      description: description.trim(),
      projectId: projectId,
      memberId: memberId,
      priority: priority,
      status: status,
      deadline: deadline,
      createdAt: DateTime.now(),
      createdBy: 'David Amani',
    );
    _tasks = [task, ..._tasks];
    _emit();
    return task;
  }

  Future<Task> updateTask(Task updated) async {
    await _simulateLatency();
    _tasks = _tasks.map((t) => t.id == updated.id ? updated : t).toList();
    _emit();
    return updated;
  }

  Future<void> updateStatus(String taskId, TaskStatus status) async {
    final current = getById(taskId);
    if (current == null) return;
    _tasks = _tasks
        .map((t) => t.id == taskId ? t.copyWith(status: status) : t)
        .toList();
    _emit();
  }

  Future<void> deleteTask(String taskId) async {
    await _simulateLatency();
    _tasks = _tasks.where((t) => t.id != taskId).toList();
    _emit();
  }
}
