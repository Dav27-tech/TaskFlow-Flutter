import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String? _localInvitationCode;

  @override
  Widget build(BuildContext context) {
    final projectDetailsAsync = ref.watch(projectDetailsProvider(widget.projectId));
    final membersAsync = ref.watch(projectMembersStreamProvider(widget.projectId));
    final currentUserId = ref.watch(currentUserIdProvider);

    return projectDetailsAsync.when(
      data: (project) => _buildPage(context, project, currentUserId, membersAsync),
      loading: () => widget.initialProject != null
          ? _buildPage(context, widget.initialProject!, currentUserId, membersAsync)
          : const Scaffold(body: LoadingIndicator(message: 'Loading member management...')),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Manage Members')),
        body: ErrorView(
          message: error.toString().replaceFirst('AppException: ', ''),
          onRetry: () => ref.invalidate(projectDetailsProvider(widget.projectId)),
        ),
      ),
    );
  }

  Widget _buildPage(
    BuildContext context,
    Project project,
    String currentUserId,
    AsyncValue membersAsync,
  ) {
    final isOwner = project.isOwner(currentUserId);
    final displayedCode = _localInvitationCode ?? project.invitationCode;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Manage Members'),
      ),
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
                    child: const Icon(Icons.folder_outlined, color: AppColors.primary, size: 24),
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
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
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

            // INVITATION CODE CARD
            const Text(
              'Invitation Code',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Share this code with team members to let them join this project.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFF4834D4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.vpn_key_rounded, color: Colors.white70, size: 20),
                      const SizedBox(width: 8),
                      SelectableText(
                        displayedCode,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: Colors.white,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _copyCodeToClipboard(displayedCode),
                          icon: const Icon(Icons.copy_rounded, size: 16),
                          label: const Text('Copy Code'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primaryDark,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      if (isOwner) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _handleRegenerateCode(project),
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: const Text('Regenerate'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white60, width: 1.2),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // MEMBERS LIST SECTION
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
                membersAsync.maybeWhen(
                  data: (members) => Text(
                    '${members.length} members',
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
                  return const Center(child: Text('No members in this project.'));
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
                      onRemove: () => _handleRemoveMember(project, member.userId),
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
                onRetry: () => ref.invalidate(projectMembersStreamProvider(project.id)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyCodeToClipboard(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Invitation code copied to clipboard!'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleRegenerateCode(Project project) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Regenerate Code',
      content:
          'Are you sure you want to regenerate the invitation code? The old code will immediately stop working.',
      confirmText: 'Regenerate',
      cancelText: 'Cancel',
      isDestructive: false,
    );

    if (confirmed == true && mounted) {
      final newCode = await ref
          .read(projectActionControllerProvider.notifier)
          .regenerateInvitationCode(projectId: project.id, ownerId: project.ownerId);

      if (newCode != null && mounted) {
        setState(() {
          _localInvitationCode = newCode;
        });
        ref.invalidate(projectDetailsProvider(project.id));
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
      ref.invalidate(projectMembersStreamProvider(project.id));
      ref.invalidate(projectDetailsProvider(project.id));
    }
  }
}
