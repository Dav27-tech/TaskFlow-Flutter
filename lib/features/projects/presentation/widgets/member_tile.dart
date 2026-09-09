import 'package:flutter/material.dart';
import 'package:task_flow/core/constants/app_colors.dart';
import 'package:task_flow/features/projects/domain/entities/project_member.dart';

class MemberTile extends StatelessWidget {
  final ProjectMember member;
  final bool isCurrentUserManager;
  final VoidCallback? onRemove;

  const MemberTile({
    super.key,
    required this.member,
    this.isCurrentUserManager = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          // Avatar / Initials
          _buildAvatar(),
          const SizedBox(width: 14),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.displayTitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (member.email != null && member.email!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    member.email!,
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
          const SizedBox(width: 8),

          // Role Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: member.isOwner
                  ? AppColors.ownerBadgeBackground
                  : AppColors.memberBadgeBackground,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              member.role.toUpperCase(),
              style: TextStyle(
                color: member.isOwner
                    ? AppColors.ownerBadgeText
                    : AppColors.memberBadgeText,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Remove Action (Visible only for Owner managing a regular Member)
          if (isCurrentUserManager && !member.isOwner) ...[
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (val) {
                if (val == 'remove') {
                  onRemove?.call();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.person_remove_outlined, size: 18, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Remove from project',
                          style: TextStyle(fontSize: 13, color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (member.photoUrl != null && member.photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(member.photoUrl!),
      );
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: member.isOwner
              ? [AppColors.ownerBadgeText, const Color(0xFFF39C12)]
              : [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        member.initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
