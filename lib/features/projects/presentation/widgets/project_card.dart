import 'package:flutter/material.dart';
import 'package:task_flow/core/constants/app_colors.dart';
import 'package:task_flow/features/projects/domain/entities/project.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final String currentUserId;
  final VoidCallback? onTap;

  const ProjectCard({
    super.key,
    required this.project,
    required this.currentUserId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOwner = project.isOwner(currentUserId);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Project Icon Container
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _getProjectIconColor(project.name).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _getProjectIcon(project.name),
                      color: _getProjectIconColor(project.name),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Project Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (project.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            project.description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 24),
                ],
              ),
              const SizedBox(height: 16),
              
              // Progress Row
              Row(
                children: [
                  Text(
                    '${project.progressPercentage}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: project.progressRatio == 1.0 ? AppColors.success : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: project.progressRatio,
                        minHeight: 6,
                        backgroundColor: AppColors.divider.withValues(alpha: 0.5),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          project.progressRatio == 1.0 ? AppColors.success : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Footer: Task & Member counts + Role
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_box_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          '${project.tasksCount} tâches',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.people_outline_rounded, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          '${project.membersCount > 0 ? project.membersCount : (project.memberIds.isNotEmpty ? project.memberIds.length : 1)} membres',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Badge Role
                  Text(
                    isOwner ? 'PROPRIÉTAIRE' : 'MEMBRE',
                    style: TextStyle(
                      color: isOwner ? AppColors.ownerBadgeText : AppColors.memberBadgeText,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getProjectIcon(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('mobile') || lowerName.contains('app')) return Icons.rocket_launch_rounded;
    if (lowerName.contains('web') || lowerName.contains('site')) return Icons.bar_chart_rounded;
    if (lowerName.contains('design') || lowerName.contains('ui')) return Icons.palette_rounded;
    if (lowerName.contains('marketing')) return Icons.campaign_rounded;
    if (lowerName.contains('internal')) return Icons.description_rounded;
    return Icons.folder_rounded;
  }

  Color _getProjectIconColor(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('mobile') || lowerName.contains('app')) return const Color(0xFF6C5CE7);
    if (lowerName.contains('web') || lowerName.contains('site')) return const Color(0xFF16A34A);
    if (lowerName.contains('design') || lowerName.contains('ui')) return const Color(0xFFF59E0B);
    if (lowerName.contains('marketing')) return const Color(0xFFE91E63);
    if (lowerName.contains('internal')) return const Color(0xFF2878E8);
    return AppColors.primary;
  }

}
