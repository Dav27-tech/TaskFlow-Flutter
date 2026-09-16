import 'package:flutter/material.dart';
import 'package:task_flow/core/constants/app_colors.dart';
import 'package:task_flow/features/projects/domain/entities/project.dart';

class ProjectSummary extends StatelessWidget {
  final Project project;
  final bool isOwner;

  const ProjectSummary({
    super.key,
    required this.project,
    this.isOwner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Role and Status Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isOwner
                      ? AppColors.ownerBadgeBackground
                      : AppColors.memberBadgeBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOwner ? Icons.stars_rounded : Icons.person_outline_rounded,
                      size: 14,
                      color: isOwner
                          ? AppColors.ownerBadgeText
                          : AppColors.memberBadgeText,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isOwner ? 'PROPRIÉTAIRE' : 'MEMBRE',
                      style: TextStyle(
                        color: isOwner
                            ? AppColors.ownerBadgeText
                            : AppColors.memberBadgeText,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(project.status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  project.status.toUpperCase(),
                  style: TextStyle(
                    color: _getStatusColor(project.status),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Project Title
          Text(
            project.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          if (project.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              project.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Metrics Grid (Circular style like image)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCircularMetric(
                  value: '${project.progressPercentage}%',
                  label: 'Progression',
                  color: AppColors.primary,
                  progress: project.progressRatio,
                ),
                _buildCircularMetric(
                  value: '${project.tasksCount}',
                  label: 'Total Tâches',
                  color: AppColors.textSecondary,
                  icon: Icons.task_outlined,
                ),
                _buildCircularMetric(
                  value: '${project.completedTasksCount}',
                  label: 'Terminées',
                  color: AppColors.success,
                  icon: Icons.check_circle_outline_rounded,
                ),
                _buildCircularMetric(
                  value: '${project.membersCount > 0 ? project.membersCount : (project.memberIds.isNotEmpty ? project.memberIds.length : 1)}',
                  label: 'Membres',
                  color: AppColors.secondary,
                  icon: Icons.people_outline_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularMetric({
    required String value,
    required String label,
    required Color color,
    double? progress,
    IconData? icon,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 54,
              height: 54,
              child: CircularProgressIndicator(
                value: progress ?? 1.0,
                strokeWidth: 3.5,
                backgroundColor: AppColors.divider,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress != null ? color : color.withValues(alpha: 0.2),
                ),
              ),
            ),
            if (icon != null)
              Icon(icon, size: 20, color: color)
            else
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (icon != null)
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'done':
        return AppColors.success;
      case 'in_progress':
        return AppColors.warning;
      case 'archived':
        return AppColors.textMuted;
      case 'active':
      default:
        return AppColors.primary;
    }
  }
}
