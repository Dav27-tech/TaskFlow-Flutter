import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/mock_data.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/task_card.dart';
import 'task_details_screen.dart';
import 'task_form_screen.dart';

class TasksListScreen extends StatelessWidget {
  const TasksListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final tasks = provider.filteredTasks;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Tasks',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TaskFormScreen()),
                    ),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: provider.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                  suffixIcon: const Icon(Icons.tune, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.cardBorder),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.cardBorder),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _FilterChip(
                    label: provider.statusFilter?.label ?? 'Status',
                    active: provider.statusFilter != null,
                    onTap: () => _pickStatus(context, provider),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: provider.priorityFilter?.label ?? 'Priority',
                    active: provider.priorityFilter != null,
                    onTap: () => _pickPriority(context, provider),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: provider.projectFilter == null
                        ? 'Project'
                        : MockData.projects.firstWhere((p) => p.id == provider.projectFilter).name,
                    active: provider.projectFilter != null,
                    onTap: () => _pickProject(context, provider),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${tasks.length} tasks',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  if (provider.hasActiveFilters)
                    GestureDetector(
                      onTap: provider.clearFilters,
                      child: const Text('Clear filters',
                          style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: tasks.isEmpty
                  ? const Center(
                      child: Text('No tasks match your filters', style: TextStyle(color: AppColors.textSecondary)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return TaskCard(
                          task: task,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => TaskDetailsScreen(taskId: task.id)),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        onTap: (_) {},
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.folder_outlined), label: 'Projects'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  /// Bottom sheets return the picked value, or throw [_Dismissed] (caught
  /// below) when closed without a choice — so a swipe-to-dismiss never
  /// silently clears the current filter.
  void _pickStatus(BuildContext context, TaskProvider provider) async {
    final result = await showModalBottomSheet<Object?>(
      context: context,
      builder: (ctx) => _SimplePickerSheet<TaskStatus>(
        title: 'Status',
        current: provider.statusFilter,
        items: TaskStatus.values.map((s) => MapEntry(s, s.label)).toList(),
      ),
    );
    if (result is _PickResult<TaskStatus>) provider.setStatusFilter(result.value);
  }

  void _pickPriority(BuildContext context, TaskProvider provider) async {
    final result = await showModalBottomSheet<Object?>(
      context: context,
      builder: (ctx) => _SimplePickerSheet<TaskPriority>(
        title: 'Priority',
        current: provider.priorityFilter,
        items: TaskPriority.values.map((p) => MapEntry(p, p.label)).toList(),
      ),
    );
    if (result is _PickResult<TaskPriority>) provider.setPriorityFilter(result.value);
  }

  void _pickProject(BuildContext context, TaskProvider provider) async {
    final result = await showModalBottomSheet<Object?>(
      context: context,
      builder: (ctx) => _SimplePickerSheet<String>(
        title: 'Project',
        current: provider.projectFilter,
        items: MockData.projects.map((p) => MapEntry(p.id, p.name)).toList(),
      ),
    );
    if (result is _PickResult<String>) provider.setProjectFilter(result.value);
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.statusTodoBg : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? AppColors.primary : AppColors.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 12.5,
                    color: active ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down,
                size: 16, color: active ? AppColors.primary : AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

/// Wrapper so we can tell "user picked null (All)" apart from "user
/// dismissed the sheet" — both would otherwise just be `null`.
class _PickResult<T> {
  final T? value;
  const _PickResult(this.value);
}

/// Generic bottom sheet used for the 3 list filters.
class _SimplePickerSheet<T> extends StatelessWidget {
  final String title;
  final T? current;
  final List<MapEntry<T, String>> items;

  const _SimplePickerSheet({required this.title, required this.current, required this.items});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: AppColors.cardBorder, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            ),
          ),
          ListTile(
            title: const Text('All'),
            trailing: current == null ? const Icon(Icons.check, color: AppColors.primary) : null,
            onTap: () => Navigator.of(context).pop(_PickResult<T>(null)),
          ),
          ...items.map((e) => ListTile(
                title: Text(e.value),
                trailing: current == e.key ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () => Navigator.of(context).pop(_PickResult<T>(e.key)),
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
