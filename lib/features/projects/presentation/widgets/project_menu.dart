import 'package:flutter/material.dart';
import 'package:task_flow/core/constants/app_colors.dart';

enum ProjectMenuAction {
  edit,
  manageMembers,
  exportJson,
  delete,
  leave,
}

class ProjectMenu extends StatelessWidget {
  final bool isOwner;
  final VoidCallback? onEdit;
  final VoidCallback? onManageMembers;
  final VoidCallback? onExportJson;
  final VoidCallback? onDelete;
  final VoidCallback? onLeave;

  const ProjectMenu({
    super.key,
    required this.isOwner,
    this.onEdit,
    this.onManageMembers,
    this.onExportJson,
    this.onDelete,
    this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ProjectMenuAction>(
      icon: const Icon(Icons.more_vert_rounded, color: AppColors.textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      onSelected: (action) {
        switch (action) {
          case ProjectMenuAction.edit:
            onEdit?.call();
            break;
          case ProjectMenuAction.manageMembers:
            onManageMembers?.call();
            break;
          case ProjectMenuAction.exportJson:
            onExportJson?.call();
            break;
          case ProjectMenuAction.delete:
            onDelete?.call();
            break;
          case ProjectMenuAction.leave:
            onLeave?.call();
            break;
        }
      },
      itemBuilder: (context) {
        if (isOwner) {
          return [
            const PopupMenuItem(
              value: ProjectMenuAction.edit,
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 20, color: AppColors.textPrimary),
                  SizedBox(width: 12),
                  Text('Edit Project', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: ProjectMenuAction.manageMembers,
              child: Row(
                children: [
                  Icon(Icons.group_outlined, size: 20, color: AppColors.textPrimary),
                  SizedBox(width: 12),
                  Text('Manage Members', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: ProjectMenuAction.exportJson,
              child: Row(
                children: [
                  Icon(Icons.file_download_outlined, size: 20, color: AppColors.textPrimary),
                  SizedBox(width: 12),
                  Text('Export Tasks as JSON', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: ProjectMenuAction.delete,
              child: Row(
                children: [
                  Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
                  SizedBox(width: 12),
                  Text('Delete Project',
                      style: TextStyle(fontSize: 14, color: AppColors.error)),
                ],
              ),
            ),
          ];
        } else {
          return [
            const PopupMenuItem(
              value: ProjectMenuAction.exportJson,
              child: Row(
                children: [
                  Icon(Icons.file_download_outlined, size: 20, color: AppColors.textPrimary),
                  SizedBox(width: 12),
                  Text('Export Tasks as JSON', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: ProjectMenuAction.leave,
              child: Row(
                children: [
                  Icon(Icons.logout_rounded, size: 20, color: AppColors.error),
                  SizedBox(width: 12),
                  Text('Leave Project',
                      style: TextStyle(fontSize: 14, color: AppColors.error)),
                ],
              ),
            ),
          ];
        }
      },
    );
  }
}
