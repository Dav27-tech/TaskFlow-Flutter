import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  TaskProvider() {
    _sub = TaskService.instance.taskStream.listen((tasks) {
      _tasks = tasks;
      notifyListeners();
    });
  }

  List<Task> _tasks = TaskService.instance.currentTasks;
  late final StreamSubscription<List<Task>> _sub;

  // Filters for the list screen
  TaskStatus? statusFilter;
  TaskPriority? priorityFilter;
  String? projectFilter;
  String searchQuery = '';

  List<Task> get allTasks => _tasks;

  List<Task> get filteredTasks {
    return _tasks.where((t) {
      final matchesStatus = statusFilter == null || t.status == statusFilter;
      final matchesPriority =
          priorityFilter == null || t.priority == priorityFilter;
      final matchesProject =
          projectFilter == null || t.projectId == projectFilter;
      final matchesSearch = searchQuery.isEmpty ||
          t.title.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesStatus && matchesPriority && matchesProject && matchesSearch;
    }).toList();
  }

  bool get hasActiveFilters =>
      statusFilter != null || priorityFilter != null || projectFilter != null || searchQuery.isNotEmpty;

  void setStatusFilter(TaskStatus? v) {
    statusFilter = v;
    notifyListeners();
  }

  void setPriorityFilter(TaskPriority? v) {
    priorityFilter = v;
    notifyListeners();
  }

  void setProjectFilter(String? v) {
    projectFilter = v;
    notifyListeners();
  }

  void setSearchQuery(String v) {
    searchQuery = v;
    notifyListeners();
  }

  void clearFilters() {
    statusFilter = null;
    priorityFilter = null;
    projectFilter = null;
    searchQuery = '';
    notifyListeners();
  }

  Future<void> updateStatus(String taskId, TaskStatus status) {
    return TaskService.instance.updateStatus(taskId, status);
  }

  Future<void> deleteTask(String taskId) {
    return TaskService.instance.deleteTask(taskId);
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
