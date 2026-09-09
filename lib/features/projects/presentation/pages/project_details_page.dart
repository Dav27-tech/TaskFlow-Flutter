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
    final projectDetailsAsync = ref.watch(projectDetailsProvider(widget.projectId));
    final membersAsync = ref.watch(projectMembersStreamProvider(widget.projectId));

    // Listen to action controller messages
    ref.listen<ProjectActionState>(projectActionControllerProvider, (prev, next) {
      if (next.errorMessage != null && next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      if (next.successMessage != null && next.successMessage != prev?.successMessage) {
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
      data: (project) => _buildContent(context, project, currentUserId, membersAsync),
      loading: () => widget.initialProject != null
          ? _buildContent(context, widget.initialProject!, currentUserId, membersAsync)
          : const Scaffold(
              body: LoadingIndicator(message: 'Loading project details...'),
            ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Project Details')),
        body: ErrorView(
          message: error.toString().replaceFirst('AppException: ', ''),
          onRetry: () => ref.invalidate(projectDetailsProvider(widget.projectId)),
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
        title: Text(project.name, maxLines: 1, overflow: TextOverflow.ellipsis),
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
                child: ProjectSummary(
                  project: project,
                  isOwner: isOwner,
                ),
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
                      text: 'Tasks',
                    ),
                    Tab(
                      icon: Icon(Icons.people_alt_outlined, size: 20),
                      text: 'Members',
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tasks (${project.tasksCount})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton.icon(
                onPressed: () => _handleExportJson(project.id),
                icon: const Icon(Icons.file_download_outlined, size: 18),
                label: const Text('Export JSON'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.task_alt_rounded,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${project.completedTasksCount} of ${project.tasksCount} tasks completed',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tasks are managed collaboratively by project members.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
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
                'Project Members',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (isOwner)
                TextButton.icon(
                  onPressed: () {
                    context.push('/projects/${project.id}/members', extra: project);
                  },
                  icon: const Icon(Icons.settings_outlined, size: 18),
                  label: const Text('Manage'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: membersAsync.when(
              data: (members) {
                if (members.isEmpty) {
                  return const Center(child: Text('No members found.'));
                }
                return ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return MemberTile(
                      member: member,
                      isCurrentUserManager: isOwner,
                      onRemove: () => _handleRemoveMember(project, member.userId),
                    );
                  },
                );
              },
              loading: () => const LoadingIndicator(size: 24),
              error: (err, _) => ErrorView(
                message: err.toString(),
                onRetry: () => ref.invalidate(projectMembersStreamProvider(project.id)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleExportJson(String projectId) async {
    await ref.read(projectActionControllerProvider.notifier).exportProjectTasksJson(
          projectId: projectId,
        );
  }

  void _handleDeleteProject(Project project) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Project',
      content: 'Are you sure you want to delete "${project.name}"? This action cannot be undone and all tasks will be permanently removed.',
      confirmText: 'Delete',
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
      title: 'Leave Project',
      content: 'Are you sure you want to leave "${project.name}"? You will lose access to this project and its tasks.',
      confirmText: 'Leave',
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
      title: 'Remove Member',
      content: 'Are you sure you want to remove this member from this project?',
      confirmText: 'Remove Member',
      cancelText: 'Cancel',
      isDestructive: true,
    );

    if (confirmed == true) {
      await ref.read(projectActionControllerProvider.notifier).removeMember(
            projectId: project.id,
            memberId: memberId,
            ownerId: project.ownerId,
          );
    }
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
