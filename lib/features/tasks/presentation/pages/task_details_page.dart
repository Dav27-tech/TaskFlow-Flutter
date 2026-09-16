import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../projects/domain/entities/project_member.dart';
import '../../../projects/presentation/providers/project_provider.dart';
import '../../domain/entities/task.dart';
import '../providers/task_provider.dart';

class TaskDetailsPage extends ConsumerWidget {
  const TaskDetailsPage({
    super.key,
    required this.projectId,
    required this.taskId,
    this.initialTask,
  });

  final String projectId;
  final String taskId;
  final Task? initialTask;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksStreamProvider(projectId));
    final projectAsync = ref.watch(projectDetailsProvider(projectId));
    final membersAsync = ref.watch(projectMembersStreamProvider(projectId));
    final currentUserId = ref.watch(currentUserIdProvider);

    final streamedTask = tasksAsync.maybeWhen(
      data: (tasks) {
        for (final task in tasks) {
          if (task.id == taskId) return task;
        }
        return null;
      },
      orElse: () => null,
    );
    final task = streamedTask ?? initialTask;
    final project = projectAsync.maybeWhen(
      data: (project) => project,
      orElse: () => null,
    );
    final members = membersAsync.maybeWhen(
      data: (members) => members,
      orElse: () => const <ProjectMember>[],
    );

    if (task == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: tasksAsync.isLoading
              ? const Center(child: CircularProgressIndicator())
              : const Center(child: Text('Tâche introuvable.')),
        ),
      );
    }

    final assignedMember = _findMember(members, task.assignedMemberId);
    final creator = _findMember(members, task.createdBy);
    final isOwner = project?.isOwner(currentUserId) ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  tooltip: 'Retour',
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz_rounded),
                  onSelected: (value) {
                    if (value == 'edit') {
                      context.push(
                        '/tasks/${task.projectId}/${task.id}/edit',
                        extra: task,
                      );
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Modifier')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Détails de la tâche',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              task.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 34,
                height: 1.06,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _StatusPill(option: _priorityOption(task.priority)),
                _StatusPill(option: _statusOption(task.status)),
              ],
            ),
            const SizedBox(height: 30),
            const _SectionTitle('Description'),
            _DescriptionBox(description: task.description),
            const SizedBox(height: 28),
            const _SectionTitle('Détails'),
            _DetailsCard(
              children: [
                _DetailRow(
                  icon: Icons.folder_outlined,
                  iconColor: AppColors.primary,
                  label: 'Projet',
                  value: project?.name ?? 'Chargement...',
                  valueColor: AppColors.primary,
                  showChevron: true,
                  onTap: project == null
                      ? null
                      : () => context.push(
                          '/projects/${project.id}',
                          extra: project,
                        ),
                ),
                _DetailRow(
                  icon: Icons.person_outline_rounded,
                  iconColor: AppColors.success,
                  label: 'Assignée à',
                  value: assignedMember?.displayTitle ?? 'Non assignée',
                  leadingValue: assignedMember == null
                      ? null
                      : _MemberAvatar(member: assignedMember, size: 34),
                ),
                _DetailRow(
                  icon: Icons.flag_outlined,
                  iconColor: AppColors.warning,
                  label: 'Priorité',
                  trailing: _StatusPill(
                    option: _priorityOption(task.priority),
                    dense: true,
                  ),
                ),
                _DetailRow(
                  icon: Icons.pending_actions_outlined,
                  iconColor: AppColors.primary,
                  label: 'Statut',
                  trailing: _StatusPill(
                    option: _statusOption(task.status),
                    dense: true,
                  ),
                ),
                _DetailRow(
                  icon: Icons.calendar_month_outlined,
                  iconColor: AppColors.secondary,
                  label: 'Deadline',
                  value: _formatDate(task.deadline),
                  subValue: _deadlineLabel(task.deadline),
                  subValueColor: AppColors.error,
                ),
                _DetailRow(
                  icon: Icons.schedule_rounded,
                  iconColor: AppColors.textSecondary,
                  label: 'Créée',
                  value: _formatDateTime(task.createdAt),
                ),
                _DetailRow(
                  icon: Icons.person_pin_outlined,
                  iconColor: AppColors.textSecondary,
                  label: 'Créée par',
                  value: creator?.displayTitle ?? 'Membre du projet',
                  hasDivider: false,
                ),
              ],
            ),
            const SizedBox(height: 28),
            const _SectionTitle('Mettre à jour le statut'),
            _StatusSelector(
              currentStatus: task.status,
              onStatusChanged: (status) =>
                  _updateStatus(context, ref, task, status),
            ),
            const SizedBox(height: 28),
            const _SectionTitle('Actions'),
            _DetailsCard(
              children: [
                _DetailRow(
                  icon: Icons.edit_outlined,
                  iconColor: AppColors.primary,
                  label: 'Modifier la tâche',
                  showChevron: true,
                  onTap: () => context.push(
                    '/tasks/${task.projectId}/${task.id}/edit',
                    extra: task,
                  ),
                ),
                _DetailRow(
                  icon: Icons.delete_outline_rounded,
                  iconColor: AppColors.error,
                  label: 'Supprimer la tâche',
                  labelColor: isOwner
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                  showChevron: isOwner,
                  hasDivider: false,
                  onTap: isOwner
                      ? () => _confirmDelete(context, ref, task)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: const [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Seuls les propriétaires peuvent supprimer les tâches.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static ProjectMember? _findMember(
    List<ProjectMember> members,
    String? userId,
  ) {
    if (userId == null || userId.isEmpty) return null;
    for (final member in members) {
      if (member.userId == userId) return member;
    }
    return null;
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return 'Non définie';
    return '${date.day} ${_shortMonthName(date.month)} ${date.year}';
  }

  static String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} à ${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';
  }

  static String? _deadlineLabel(DateTime? deadline) {
    if (deadline == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(deadline.year, deadline.month, deadline.day);
    final diff = dueDate.difference(today).inDays;
    if (diff == 0) return 'Aujourd’hui';
    if (diff < 0) return 'En retard';
    if (diff == 1) return 'Demain';
    return null;
  }

  static Future<void> _updateStatus(
    BuildContext context,
    WidgetRef ref,
    Task task,
    String status,
  ) async {
    if (status == task.status) return;
    final success = await ref
        .read(taskActionControllerProvider.notifier)
        .updateStatus(
          projectId: task.projectId,
          taskId: task.id,
          status: status,
        );
    if (!context.mounted || success) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Impossible de mettre à jour le statut.')),
    );
  }

  static Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Task task,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la tâche ?'),
        content: const Text('Cette action est définitive.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final success = await ref
        .read(taskActionControllerProvider.notifier)
        .deleteTask(projectId: task.projectId, taskId: task.id);
    if (!context.mounted) return;
    if (success) {
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de supprimer la tâche.')),
      );
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 15,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _DescriptionBox extends StatelessWidget {
  const _DescriptionBox({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        description.isEmpty ? 'Aucune description.' : description,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          height: 1.45,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.value,
    this.subValue,
    this.trailing,
    this.leadingValue,
    this.valueColor,
    this.subValueColor,
    this.labelColor,
    this.showChevron = false,
    this.hasDivider = true,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String? value;
  final String? subValue;
  final Widget? trailing;
  final Widget? leadingValue;
  final Color? valueColor;
  final Color? subValueColor;
  final Color? labelColor;
  final bool showChevron;
  final bool hasDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 23),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: labelColor ?? AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.visible,
              softWrap: false,
            ),
          ),
          if (leadingValue != null) ...[
            leadingValue!,
            const SizedBox(width: 10),
          ],
          if (trailing != null)
            trailing!
          else
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value ?? '',
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: valueColor ?? AppColors.textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subValue != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subValue!,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: subValueColor ?? AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          if (showChevron) ...[
            const SizedBox(width: 10),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ],
      ),
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          content,
          if (hasDivider)
            const Divider(height: 1, color: AppColors.divider, indent: 58),
        ],
      ),
    );
  }
}

class _StatusSelector extends StatelessWidget {
  const _StatusSelector({
    required this.currentStatus,
    required this.onStatusChanged,
  });

  final String currentStatus;
  final ValueChanged<String> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: _statusOptions
            .map(
              (option) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: OutlinedButton.icon(
                    onPressed: () => onStatusChanged(option.value),
                    icon: Icon(
                      option.value == 'completed'
                          ? Icons.check_circle_outline
                          : Icons.radio_button_unchecked_rounded,
                      size: 21,
                    ),
                    label: FittedBox(child: Text(option.label)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: option.color,
                      backgroundColor: currentStatus == option.value
                          ? option.color.withValues(alpha: .08)
                          : Colors.white,
                      side: BorderSide(
                        color: currentStatus == option.value
                            ? option.color
                            : option.color.withValues(alpha: .28),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(0, 52),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.option, this.dense = false});

  final _TaskOption option;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 12 : 16,
        vertical: dense ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: option.color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: dense ? 8 : 9,
            height: dense ? 8 : 9,
            decoration: BoxDecoration(
              color: option.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 9),
          Text(
            option.label,
            style: TextStyle(
              color: option.color,
              fontSize: dense ? 13 : 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({required this.member, required this.size});

  final ProjectMember member;
  final double size;

  @override
  Widget build(BuildContext context) {
    final photoUrl = member.photoUrl;
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.primaryContainer,
      backgroundImage: photoUrl == null || photoUrl.isEmpty
          ? null
          : NetworkImage(photoUrl),
      child: photoUrl == null || photoUrl.isEmpty
          ? Text(
              member.initials,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: size * .36,
                fontWeight: FontWeight.w800,
              ),
            )
          : null,
    );
  }
}

class _TaskOption {
  const _TaskOption({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;
}

_TaskOption _priorityOption(String priority) {
  return _priorityOptions.firstWhere(
    (option) => option.value == priority,
    orElse: () => _priorityOptions[1],
  );
}

_TaskOption _statusOption(String status) {
  return _statusOptions.firstWhere(
    (option) => option.value == status,
    orElse: () => _statusOptions[0],
  );
}

const _priorityOptions = [
  _TaskOption(value: 'high', label: 'Haute', color: AppColors.error),
  _TaskOption(value: 'medium', label: 'Moyenne', color: AppColors.warning),
  _TaskOption(value: 'low', label: 'Basse', color: AppColors.success),
];

const _statusOptions = [
  _TaskOption(value: 'todo', label: 'À faire', color: AppColors.primary),
  _TaskOption(
    value: 'in_progress',
    label: 'En cours',
    color: AppColors.warning,
  ),
  _TaskOption(value: 'completed', label: 'Terminée', color: AppColors.success),
];

String _shortMonthName(int month) {
  const months = [
    'janv.',
    'févr.',
    'mars',
    'avr.',
    'mai',
    'juin',
    'juil.',
    'août',
    'sept.',
    'oct.',
    'nov.',
    'déc.',
  ];
  return months[(month - 1).clamp(0, months.length - 1)];
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');
