import 'package:flutter/material.dart';
import 'package:taskflow/core/constants/app_colors.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';

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
            color: Colors.black.withOpacity(0.02),
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
                  color: _getStatusColor(project.status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getStatusLabel(project.status),
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
          const SizedBox(height: 20),

          // Progress Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progression globale',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${project.progressPercentage}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: project.progressRatio,
              minHeight: 8,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(
                project.progressRatio == 1.0 ? AppColors.success : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Metrics Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.task_alt_rounded,
                  color: AppColors.primary,
                  title: 'Tâches totales',
                  value: '${project.tasksCount}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.check_circle_rounded,
                  color: AppColors.success,
                  title: 'Terminées',
                  value: '${project.completedTasksCount}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.groups_rounded,
                  color: AppColors.secondary,
                  title: 'Membres',
                  value: '${project.membersCount > 0 ? project.membersCount : (project.memberIds.isNotEmpty ? project.memberIds.length : 1)}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'done':
        return 'TERMINÉ';
      case 'in_progress':
        return 'EN COURS';
      case 'archived':
        return 'ARCHIVÉ';
      case 'active':
      default:
        return 'ACTIF';
    }
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
