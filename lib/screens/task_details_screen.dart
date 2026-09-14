import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../data/mock_data.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/priority_badge.dart';
import '../widgets/status_badge.dart';
import 'task_form_screen.dart';

class TaskDetailsScreen extends StatelessWidget {
  final String taskId;
  const TaskDetailsScreen({super.key, required this.taskId});

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  bool _isPast(DateTime d) {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    return d.isBefore(start);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final task = provider.allTasks.where((t) => t.id == taskId).cast<Task?>().firstOrNull;

    if (task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Task Details')),
        body: const Center(child: Text('This task no longer exists.')),
      );
    }

    final project = MockData.projects.firstWhere((p) => p.id == task.projectId);
    final member = MockData.members.firstWhere((m) => m.id == task.memberId);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Task Details'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'edit') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => TaskFormScreen(existingTask: task)),
                );
              } else if (v == 'delete') {
                _confirmDelete(context, provider, task);
              }
            },
            itemBuilder: (ctx) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Row(
                children: [
                  PriorityBadge(priority: task.priority),
                  const SizedBox(width: 8),
                  StatusBadge(status: task.status),
                ],
              ),
              const SizedBox(height: 20),
              const _SectionLabel('DESCRIPTION'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(task.description,
                    style: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.textPrimary)),
              ),
              const SizedBox(height: 20),
              const _SectionLabel('DETAILS'),
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.folder_outlined,
                label: 'Project',
                trailing: Text(project.name,
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                showChevron: true,
              ),
              _DetailRow(
                icon: Icons.person_outline,
                label: 'Assigned to',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Color(member.avatarColorValue),
                      child: Text(member.initials, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 8),
                    Text(member.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                showChevron: true,
              ),
              _DetailRow(
                icon: Icons.flag_outlined,
                label: 'Priority',
                trailing: PriorityBadge(priority: task.priority),
              ),
              _DetailRow(
                icon: Icons.radio_button_checked_outlined,
                label: 'Status',
                trailing: StatusBadge(status: task.status),
                showChevron: true,
              ),
              _DetailRow(
                icon: Icons.calendar_today_outlined,
                label: 'Deadline',
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(DateFormat('MMM d, y').format(task.deadline),
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    if (_isToday(task.deadline))
                      const Text('Due today',
                          style: TextStyle(color: AppColors.fieldErrorBorder, fontSize: 12))
                    else if (_isPast(task.deadline) && task.status != TaskStatus.completed)
                      const Text('Overdue',
                          style: TextStyle(color: AppColors.fieldErrorBorder, fontSize: 12)),
                  ],
                ),
              ),
              _DetailRow(
                icon: Icons.access_time,
                label: 'Created',
                trailing: Text(DateFormat('MMM d, y \'at\' h:mm a').format(task.createdAt),
                    style: const TextStyle(color: AppColors.textSecondary)),
              ),
              _DetailRow(
                icon: Icons.person_outline,
                label: 'Created by',
                trailing: Text(task.createdBy, style: const TextStyle(color: AppColors.textSecondary)),
              ),
              const SizedBox(height: 20),
              const _SectionLabel('UPDATE STATUS'),
              const SizedBox(height: 8),
              Row(
                children: TaskStatus.values.map((s) {
                  final selected = task.status == s;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: s == TaskStatus.values.last ? 0 : 8),
                      child: OutlinedButton(
                        onPressed: () => provider.updateStatus(task.id, s),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: selected ? s.bg : Colors.white,
                          side: BorderSide(color: selected ? s.fg : AppColors.cardBorder),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          s.label,
                          style: TextStyle(
                            color: selected ? s.fg : AppColors.textSecondary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const _SectionLabel('ACTIONS'),
              const SizedBox(height: 8),
              _ActionRow(
                icon: Icons.edit_outlined,
                label: 'Edit Task',
                color: AppColors.primary,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => TaskFormScreen(existingTask: task)),
                ),
              ),
              _ActionRow(
                icon: Icons.delete_outline,
                label: 'Delete Task',
                color: AppColors.fieldErrorBorder,
                onTap: () => _confirmDelete(context, provider, task),
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(Icons.lock_outline, size: 14, color: AppColors.textSecondary),
                  SizedBox(width: 6),
                  Text('Only owners can delete tasks.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, TaskProvider provider, Task task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('"${task.title}" will be permanently removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await provider.deleteTask(task.id);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.fieldErrorBorder)),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5));
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;
  final bool showChevron;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.trailing,
    this.showChevron = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 17, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          ),
          trailing,
          if (showChevron) ...[
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
          ],
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionRow({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 17, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600))),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
