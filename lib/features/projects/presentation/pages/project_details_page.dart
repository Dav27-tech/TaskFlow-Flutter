import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_flow/core/constants/app_colors.dart';
import 'package:task_flow/core/widgets/confirm_dialog.dart';
import 'package:task_flow/core/widgets/error_view.dart';
import 'package:task_flow/core/widgets/loading_indicator.dart';
import 'package:task_flow/features/projects/domain/entities/project.dart';
import 'package:task_flow/features/projects/presentation/providers/project_provider.dart';
import 'package:task_flow/features/projects/presentation/widgets/member_tile.dart';
import 'package:task_flow/features/projects/presentation/widgets/project_menu.dart';
import 'package:task_flow/features/projects/presentation/widgets/project_summary.dart';
import 'package:task_flow/features/tasks/domain/entities/task.dart';
import 'package:task_flow/features/tasks/presentation/providers/task_provider.dart';

class ProjectDetailsPage extends ConsumerStatefulWidget {
  final String projectId;
  final Project? initialProject;

  const ProjectDetailsPage({
    super.key,
    required this.projectId,
    this.initialProject,
  });

  @override
  ConsumerState<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends ConsumerState<ProjectDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(currentUserIdProvider);
    final projectDetailsAsync = ref.watch(
      projectDetailsProvider(widget.projectId),
    );
    final membersAsync = ref.watch(
      projectMembersStreamProvider(widget.projectId),
    );

    // Listen to action controller messages
    ref.listen<ProjectActionState>(projectActionControllerProvider, (
      prev,
      next,
    ) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      if (next.successMessage != null &&
          next.successMessage != prev?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return projectDetailsAsync.when(
      data: (project) =>
          _buildContent(context, project, currentUserId, membersAsync),
      loading: () => widget.initialProject != null
          ? _buildContent(
              context,
              widget.initialProject!,
              currentUserId,
              membersAsync,
            )
          : const Scaffold(
              body: LoadingIndicator(message: 'Loading project details...'),
            ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          toolbarHeight: 62,
          backgroundColor: AppColors.backgroundSurface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Détails du projet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: ErrorView(
          message: error.toString().replaceFirst('AppException: ', ''),
          onRetry: () =>
              ref.invalidate(projectDetailsProvider(widget.projectId)),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Project project,
    String currentUserId,
    AsyncValue membersAsync,
  ) {
    final isOwner = project.isOwner(currentUserId);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        toolbarHeight: 62,
        backgroundColor: AppColors.backgroundSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Détails du projet',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          ProjectMenu(
            isOwner: isOwner,
            onEdit: () {
              context.push('/projects/${project.id}/edit', extra: project);
            },
            onManageMembers: () {
              context.push('/projects/${project.id}/members', extra: project);
            },
            onExportJson: () => _handleExportJson(project.id),
            onDelete: () => _handleDeleteProject(project),
            onLeave: () => _handleLeaveProject(project),
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: ProjectSummary(project: project, isOwner: isOwner),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.check_box_outlined, size: 20),
                      text: 'Tâches',
                    ),
                    Tab(
                      icon: Icon(Icons.people_alt_outlined, size: 20),
                      text: 'Membres',
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildTasksTab(project),
            _buildMembersTab(project, isOwner, membersAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksTab(Project project) {
    final tasksAsync = ref.watch(tasksStreamProvider(project.id));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tasksAsync.maybeWhen(
                  data: (tasks) => 'Tâches (${tasks.length})',
                  orElse: () => 'Tâches (${project.tasksCount})',
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () =>
                        context.push('/tasks/create?projectId=${project.id}'),
                    icon: const Icon(Icons.add_task_rounded),
                    color: AppColors.primary,
                    tooltip: 'Ajouter une tâche',
                  ),
                  IconButton(
                    onPressed: () => _handleExportJson(project.id),
                    icon: const Icon(Icons.file_download_outlined),
                    color: AppColors.primary,
                    tooltip: 'Exporter les tâches',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: tasksAsync.when(
              loading: () => const LoadingIndicator(size: 28),
              error: (error, stackTrace) => ErrorView(
                message: error.toString(),
                onRetry: () => ref.invalidate(tasksStreamProvider(project.id)),
              ),
              data: (tasks) {
                if (tasks.isEmpty) {
                  return _EmptyProjectTasks(
                    onCreateTask: () =>
                        context.push('/tasks/create?projectId=${project.id}'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) =>
                      _ProjectTaskCard(task: tasks[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersTab(
    Project project,
    bool isOwner,
    AsyncValue membersAsync,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Membres du projet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (isOwner)
                TextButton.icon(
                  onPressed: () {
                    context.push(
                      '/projects/${project.id}/members',
                      extra: project,
                    );
                  },
                  icon: const Icon(Icons.settings_outlined, size: 18),
                  label: const Text('Gérer'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: membersAsync.when(
              data: (members) {
                if (members.isEmpty) {
                  return const Center(child: Text('Aucun membre trouvé.'));
                }
                return ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return MemberTile(
                      member: member,
                      isCurrentUserManager: isOwner,
                      onRemove: () =>
                          _handleRemoveMember(project, member.userId),
                    );
                  },
                );
              },
              loading: () => const LoadingIndicator(size: 24),
              error: (err, _) => ErrorView(
                message: err.toString(),
                onRetry: () =>
                    ref.invalidate(projectMembersStreamProvider(project.id)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleExportJson(String projectId) async {
    await ref
        .read(projectActionControllerProvider.notifier)
        .exportProjectTasksJson(projectId: projectId);
  }

  void _handleDeleteProject(Project project) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Supprimer le projet',
      content:
          'Êtes-vous sûr de vouloir supprimer "${project.name}" ? Cette action est irréversible et toutes les tâches seront définitivement supprimées.',
      confirmText: 'Supprimer',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      final success = await ref
          .read(projectActionControllerProvider.notifier)
          .deleteProject(projectId: project.id, ownerId: project.ownerId);

      if (success && mounted) {
        context.go('/projects');
      }
    }
  }

  void _handleLeaveProject(Project project) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Quitter le projet',
      content:
          'Êtes-vous sûr de vouloir quitter "${project.name}" ? Vous perdrez l\'accès à ce projet et à ses tâches.',
      confirmText: 'Quitter',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      final success = await ref
          .read(projectActionControllerProvider.notifier)
          .leaveProject(projectId: project.id, ownerId: project.ownerId);

      if (success && mounted) {
        context.go('/projects');
      }
    }
  }

  void _handleRemoveMember(Project project, String memberId) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Retirer le membre',
      content: 'Êtes-vous sûr de vouloir retirer ce membre de ce projet ?',
      confirmText: 'Retirer',
      cancelText: 'Annuler',
      isDestructive: true,
    );

    if (confirmed == true) {
      await ref
          .read(projectActionControllerProvider.notifier)
          .removeMember(
            projectId: project.id,
            memberId: memberId,
            ownerId: project.ownerId,
          );
    }
  }
}

class _EmptyProjectTasks extends StatelessWidget {
  const _EmptyProjectTasks({required this.onCreateTask});

  final VoidCallback onCreateTask;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.task_alt_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucune tâche pour ce projet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Commencez par créer une tâche.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onCreateTask,
            icon: const Icon(Icons.add_task_rounded, size: 18),
            label: const Text('Créer une tâche'),
          ),
        ],
      ),
    );
  }
}

class _ProjectTaskCard extends StatelessWidget {
  const _ProjectTaskCard({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == 'completed';
    final statusColor = _statusColor(task.status);
    final priorityColor = _priorityColor(task.priority);

    return InkWell(
      onTap: () =>
          context.push('/tasks/${task.projectId}/${task.id}', extra: task),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(
              isCompleted
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isCompleted ? AppColors.success : AppColors.textMuted,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _TaskLabel(
                        text: _statusLabel(task.status),
                        color: statusColor,
                      ),
                      _TaskLabel(
                        text: _priorityLabel(task.priority),
                        color: priorityColor,
                      ),
                      if (task.deadline != null)
                        _TaskLabel(
                          text: _formatDate(task.deadline!),
                          color: AppColors.textSecondary,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'in_progress':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'high':
        return AppColors.error;
      case 'low':
        return AppColors.success;
      default:
        return AppColors.warning;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'completed':
        return 'Terminée';
      case 'in_progress':
        return 'En cours';
      default:
        return 'À faire';
    }
  }

  String _priorityLabel(String priority) {
    switch (priority) {
      case 'high':
        return 'Haute';
      case 'low':
        return 'Basse';
      default:
        return 'Moyenne';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }
}

class _TaskLabel extends StatelessWidget {
  const _TaskLabel({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
