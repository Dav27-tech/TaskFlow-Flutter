import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_flow/core/constants/app_colors.dart';
import 'package:task_flow/core/widgets/confirm_dialog.dart';
import 'package:task_flow/core/widgets/error_view.dart';
import 'package:task_flow/core/widgets/loading_indicator.dart';
import 'package:task_flow/features/projects/domain/entities/project.dart';
import 'package:task_flow/features/projects/presentation/providers/project_provider.dart';
import 'package:task_flow/features/projects/presentation/widgets/member_tile.dart';

class ManageMembersPage extends ConsumerStatefulWidget {
  final String projectId;
  final Project? initialProject;

  const ManageMembersPage({
    super.key,
    required this.projectId,
    this.initialProject,
  });

  @override
  ConsumerState<ManageMembersPage> createState() => _ManageMembersPageState();
}

class _ManageMembersPageState extends ConsumerState<ManageMembersPage> {
  @override
  Widget build(BuildContext context) {
    final projectDetailsAsync = ref.watch(
      projectDetailsProvider(widget.projectId),
    );
    final membersAsync = ref.watch(
      projectMembersStreamProvider(widget.projectId),
    );
    final activeUsersAsync = ref.watch(
      activeUsersNotInProjectProvider(widget.projectId),
    );
    final currentUserId = ref.watch(currentUserIdProvider);

    return projectDetailsAsync.when(
      data: (project) => _buildPage(
        context,
        project,
        currentUserId,
        membersAsync,
        activeUsersAsync,
      ),
      loading: () => widget.initialProject != null
          ? _buildPage(
              context,
              widget.initialProject!,
              currentUserId,
              membersAsync,
              activeUsersAsync,
            )
          : const Scaffold(
              body: LoadingIndicator(
                message: 'Chargement de la gestion des membres...',
              ),
            ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Gérer les membres',
            style: TextStyle(fontWeight: FontWeight.bold),
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

  Widget _buildPage(
    BuildContext context,
    Project project,
    String currentUserId,
    AsyncValue membersAsync,
    AsyncValue activeUsersAsync,
  ) {
    final isOwner = project.isOwner(currentUserId);
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Gérer les membres')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Header Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.folder_outlined,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (project.description.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            project.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

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
                  IconButton(
                    onPressed: () =>
                        _showAddMemberDialog(project, activeUsersAsync),
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    color: AppColors.primary,
                    tooltip: 'Ajouter un membre actif',
                  ),
              ],
            ),
            const SizedBox(height: 4),
            const SizedBox(height: 12),
            // MEMBERS LIST SECTION
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                membersAsync.maybeWhen(
                  data: (members) => Text(
                    '${members.length} membres',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            membersAsync.when(
              data: (members) {
                if (members.isEmpty) {
                  return const Center(
                    child: Text('Aucun membre dans ce projet.'),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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
              loading: () => const Padding(
                padding: EdgeInsets.all(24.0),
                child: LoadingIndicator(size: 24),
              ),
              error: (err, _) => ErrorView(
                message: err.toString(),
                onRetry: () =>
                    ref.invalidate(projectMembersStreamProvider(project.id)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddMemberDialog(
    Project project,
    AsyncValue activeUsersAsync,
  ) async {
    if (!mounted) return;

    List<dynamic> users;
    if (activeUsersAsync.isLoading) {
      try {
        users = await ref.read(
          activeUsersNotInProjectProvider(project.id).future,
        );
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Impossible de charger les utilisateurs actifs.\n$error',
            ),
          ),
        );
        return;
      }
    } else if (activeUsersAsync.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Impossible de charger les utilisateurs actifs.\n${activeUsersAsync.error}',
          ),
        ),
      );
      return;
    } else {
      users = activeUsersAsync.maybeWhen(
        data: (value) => value,
        orElse: () => const [],
      );
    }

    if (!mounted) return;
    if (users.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun utilisateur actif disponible.')),
      );
      return;
    }

    final selectedId = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ajouter un membre actif'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(child: Text(user.initials)),
                title: Text(user.displayTitle),
                subtitle: user.email == null ? null : Text(user.email!),
                onTap: () => Navigator.of(dialogContext).pop(user.userId),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );

    if (selectedId == null || !mounted) return;
    final added = await ref
        .read(projectActionControllerProvider.notifier)
        .addMember(
          projectId: project.id,
          memberId: selectedId,
          ownerId: project.ownerId,
        );
    if (added && mounted) {
      ref.invalidate(projectMembersStreamProvider(project.id));
      ref.invalidate(activeUsersNotInProjectProvider(project.id));
      ref.invalidate(projectDetailsProvider(project.id));
    }
  }

  void _handleRemoveMember(Project project, String memberId) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Retirer le membre',
      content: 'Êtes-vous sûr de vouloir retirer ce membre de ce projet ?',
      confirmText: 'Retirer le membre',
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
      ref.invalidate(projectMembersStreamProvider(project.id));
      ref.invalidate(projectDetailsProvider(project.id));
    }
  }
}
