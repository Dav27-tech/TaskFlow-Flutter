import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../projects/domain/entities/project.dart';
import '../../../projects/domain/entities/project_member.dart';
import '../../../projects/presentation/providers/project_provider.dart';
import '../../domain/entities/task.dart';
import '../providers/task_provider.dart';

class TasksPage extends ConsumerStatefulWidget {
  const TasksPage({super.key});

  @override
  ConsumerState<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends ConsumerState<TasksPage> {
  final _searchController = TextEditingController();
  String _query = '';
  String _selectedStatus = 'all';
  String _selectedPriority = 'all';
  String _selectedProjectId = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsStreamProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: projectsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Impossible de charger les projets.\n$error'),
            ),
          ),
          data: (projects) {
            if (projects.isEmpty) {
              return _EmptyTasks(onCreateTask: null);
            }

            final rows = _taskRows(projects);
            final isLoadingTasks = projects.any(
              (project) => ref.watch(tasksStreamProvider(project.id)).isLoading,
            );
            final filteredRows = _filterRows(rows);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
                  child: _TasksHeader(
                    onCreateTask: () => context.push(
                      '/tasks/create?projectId=${_createProjectId(projects)}',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: _SearchField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    onClear: _clearFilters,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                  child: _FilterBar(
                    status: _selectedStatus,
                    priority: _selectedPriority,
                    projectId: _selectedProjectId,
                    projects: projects,
                    onStatusChanged: (value) =>
                        setState(() => _selectedStatus = value),
                    onPriorityChanged: (value) =>
                        setState(() => _selectedPriority = value),
                    onProjectChanged: (value) =>
                        setState(() => _selectedProjectId = value),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 12),
                  child: Row(
                    children: [
                      Text(
                        '${filteredRows.length} tâche${filteredRows.length > 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _hasFilters ? _clearFilters : null,
                        child: const Text('Effacer les filtres'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: isLoadingTasks && rows.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : filteredRows.isEmpty
                      ? _EmptyTasks(
                          onCreateTask: () => context.push(
                            '/tasks/create?projectId=${_createProjectId(projects)}',
                          ),
                        )
                      : _TaskList(rows: filteredRows),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<_TaskRow> _taskRows(List<Project> projects) {
    final rows = <_TaskRow>[];
    for (final project in projects) {
      final members = ref
          .watch(projectMembersStreamProvider(project.id))
          .maybeWhen(
            data: (members) => members,
            orElse: () => const <ProjectMember>[],
          );
      final tasks = ref
          .watch(tasksStreamProvider(project.id))
          .maybeWhen(data: (tasks) => tasks, orElse: () => const <Task>[]);
      for (final task in tasks) {
        rows.add(
          _TaskRow(
            task: task,
            project: project,
            assignedMember: _findMember(members, task.assignedMemberId),
          ),
        );
      }
    }
    rows.sort((a, b) {
      final aDeadline = a.task.deadline ?? a.task.createdAt;
      final bDeadline = b.task.deadline ?? b.task.createdAt;
      return aDeadline.compareTo(bDeadline);
    });
    return rows;
  }

  List<_TaskRow> _filterRows(List<_TaskRow> rows) {
    final query = _query.trim().toLowerCase();
    return rows.where((row) {
      final matchesQuery =
          query.isEmpty ||
          row.task.title.toLowerCase().contains(query) ||
          row.task.description.toLowerCase().contains(query) ||
          row.project.name.toLowerCase().contains(query) ||
          (row.assignedMember?.displayTitle.toLowerCase().contains(query) ??
              false);
      final matchesStatus =
          _selectedStatus == 'all' || row.task.status == _selectedStatus;
      final matchesPriority =
          _selectedPriority == 'all' || row.task.priority == _selectedPriority;
      final matchesProject =
          _selectedProjectId == 'all' || row.project.id == _selectedProjectId;

      return matchesQuery && matchesStatus && matchesPriority && matchesProject;
    }).toList();
  }

  bool get _hasFilters =>
      _query.isNotEmpty ||
      _selectedStatus != 'all' ||
      _selectedPriority != 'all' ||
      _selectedProjectId != 'all';

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _selectedStatus = 'all';
      _selectedPriority = 'all';
      _selectedProjectId = 'all';
    });
  }

  String _createProjectId(List<Project> projects) {
    if (_selectedProjectId != 'all') return _selectedProjectId;
    return projects.first.id;
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
}

class _TasksHeader extends StatelessWidget {
  const _TasksHeader({required this.onCreateTask});

  final VoidCallback onCreateTask;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Tâches',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 40,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        SizedBox.square(
          dimension: 52,
          child: FilledButton(
            onPressed: onCreateTask,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Icon(Icons.add_rounded, size: 34),
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Rechercher des tâches...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: IconButton(
          tooltip: 'Réinitialiser',
          onPressed: onClear,
          icon: const Icon(Icons.tune_rounded),
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.status,
    required this.priority,
    required this.projectId,
    required this.projects,
    required this.onStatusChanged,
    required this.onPriorityChanged,
    required this.onProjectChanged,
  });

  final String status;
  final String priority;
  final String projectId;
  final List<Project> projects;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onPriorityChanged;
  final ValueChanged<String> onProjectChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          _FilterMenu(
            label: _statusLabel(status),
            items: _statusFilterOptions,
            selectedValue: status,
            onSelected: onStatusChanged,
          ),
          const SizedBox(width: 8),
          _FilterMenu(
            label: _priorityLabel(priority),
            items: _priorityFilterOptions,
            selectedValue: priority,
            onSelected: onPriorityChanged,
          ),
          const SizedBox(width: 8),
          _FilterMenu(
            label: projectId == 'all'
                ? 'Projet'
                : projects
                      .firstWhere((project) => project.id == projectId)
                      .name,
            items: [
              const _FilterOption(value: 'all', label: 'Tous les projets'),
              ...projects.map(
                (project) =>
                    _FilterOption(value: project.id, label: project.name),
              ),
            ],
            selectedValue: projectId,
            onSelected: onProjectChanged,
          ),
        ],
      ),
    );
  }
}

class _FilterMenu extends StatelessWidget {
  const _FilterMenu({
    required this.label,
    required this.items,
    required this.selectedValue,
    required this.onSelected,
  });

  final String label;
  final List<_FilterOption> items;
  final String selectedValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      itemBuilder: (context) => items
          .map(
            (item) => PopupMenuItem(
              value: item.value,
              child: Row(
                children: [
                  Expanded(child: Text(item.label)),
                  if (item.value == selectedValue)
                    const Icon(Icons.check_rounded, color: AppColors.primary),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  const _TaskList({required this.rows});

  final List<_TaskRow> rows;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: rows.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _TaskCard(row: rows[index]),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.row});

  final _TaskRow row;

  @override
  Widget build(BuildContext context) {
    final task = row.task;
    return InkWell(
      onTap: () =>
          context.push('/tasks/${task.projectId}/${task.id}', extra: task),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .04),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: _listContent(context),
      ),
    );
  }

  Widget _listContent(BuildContext context) {
    final task = row.task;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _CompletionButton(task: task),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                task.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      row.project.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          flex: 0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 178),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.end,
                  children: [
                    _TaskPill(option: _priorityOption(task.priority)),
                    _TaskPill(option: _statusOption(task.status)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      size: 17,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _shortDate(task.deadline),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _MemberAvatar(member: row.assignedMember, size: 34),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CompletionButton extends ConsumerWidget {
  const _CompletionButton({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = task.status == 'completed';
    return InkWell(
      onTap: () => ref
          .read(taskActionControllerProvider.notifier)
          .updateStatus(
            projectId: task.projectId,
            taskId: task.id,
            status: isCompleted ? 'todo' : 'completed',
          ),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isCompleted
              ? AppColors.success.withValues(alpha: .1)
              : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isCompleted ? AppColors.success : const Color(0xFFC7D0DF),
            width: 2,
          ),
        ),
        child: isCompleted
            ? const Icon(
                Icons.check_rounded,
                color: AppColors.success,
                size: 20,
              )
            : null,
      ),
    );
  }
}

class _TaskPill extends StatelessWidget {
  const _TaskPill({required this.option});

  final _TaskOption option;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: option.color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        option.label,
        style: TextStyle(
          color: option.color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({required this.member, required this.size});

  final ProjectMember? member;
  final double size;

  @override
  Widget build(BuildContext context) {
    final photoUrl = member?.photoUrl;
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.primaryContainer,
      backgroundImage: photoUrl == null || photoUrl.isEmpty
          ? null
          : NetworkImage(photoUrl),
      child: photoUrl == null || photoUrl.isEmpty
          ? Text(
              member?.initials ?? '?',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: size * .36,
                fontWeight: FontWeight.w900,
              ),
            )
          : null,
    );
  }
}

class _EmptyTasks extends StatelessWidget {
  const _EmptyTasks({required this.onCreateTask});

  final VoidCallback? onCreateTask;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.task_alt_outlined,
              size: 52,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 14),
            const Text(
              'Aucune tâche pour le moment',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Créez une tâche et assignez-la à un membre du projet concerné.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            if (onCreateTask != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onCreateTask,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Créer une tâche'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TaskRow {
  const _TaskRow({
    required this.task,
    required this.project,
    required this.assignedMember,
  });

  final Task task;
  final Project project;
  final ProjectMember? assignedMember;
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

class _FilterOption {
  const _FilterOption({required this.value, required this.label});

  final String value;
  final String label;
}

String _shortDate(DateTime? date) {
  if (date == null) return '--';
  return '${date.day} ${_shortMonthName(date.month)}';
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

String _priorityLabel(String priority) {
  if (priority == 'all') return 'Priorité';
  return _priorityOption(priority).label;
}

String _statusLabel(String status) {
  if (status == 'all') return 'Statut';
  return _statusOption(status).label;
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

const _priorityFilterOptions = [
  _FilterOption(value: 'all', label: 'Toutes les priorités'),
  _FilterOption(value: 'high', label: 'Haute'),
  _FilterOption(value: 'medium', label: 'Moyenne'),
  _FilterOption(value: 'low', label: 'Basse'),
];

const _statusFilterOptions = [
  _FilterOption(value: 'all', label: 'Tous les statuts'),
  _FilterOption(value: 'todo', label: 'À faire'),
  _FilterOption(value: 'in_progress', label: 'En cours'),
  _FilterOption(value: 'completed', label: 'Terminée'),
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
