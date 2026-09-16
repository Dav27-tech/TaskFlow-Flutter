import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../projects/domain/entities/project.dart';
import '../../../projects/presentation/providers/project_provider.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/presentation/providers/task_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsStreamProvider);
    final userName = FirebaseAuth.instance.currentUser?.displayName ?? 'Utilisateur';
    final greetingName = userName.trim().split(RegExp(r'\s+')).first;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: projectsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Impossible de charger votre tableau de bord.\n$error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
          data: (projects) {
            final tasksByProject = <String, List<Task>>{};
            for (final project in projects) {
              final tasks = ref
                  .watch(tasksStreamProvider(project.id))
                  .maybeWhen(
                    data: (value) => value,
                    orElse: () => const <Task>[],
                  );
              tasksByProject[project.id] = tasks;
            }

            final allTasks = tasksByProject.values.expand((tasks) => tasks).toList();
            final todoCount = allTasks.where((task) => task.status == 'todo').length;
            final inProgressCount = allTasks.where((task) => task.status == 'in_progress').length;
            final completedCount = allTasks.where((task) => task.status == 'completed').length;

            final focusTasks = [...allTasks.where((task) => task.status != 'completed')]
              ..sort((a, b) {
                final aPriority = _priorityWeight(a.priority);
                final bPriority = _priorityWeight(b.priority);
                if (aPriority != bPriority) {
                  return bPriority.compareTo(aPriority);
                }
                final aDate = a.deadline ?? a.createdAt;
                final bDate = b.deadline ?? b.createdAt;
                return aDate.compareTo(bDate);
              });

            final recentProjects = projects.take(3).toList();
            final importantTasks = [...allTasks.where((task) => task.priority == 'high')]
              ..sort((a, b) {
                final aDate = a.deadline ?? a.createdAt;
                final bDate = b.deadline ?? b.createdAt;
                return aDate.compareTo(bDate);
              });

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async => ref.invalidate(projectsStreamProvider),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bonjour, $greetingName',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Voici ce qu’il faut regarder aujourd’hui.',
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.push('/notifications'),
                        icon: const Icon(Icons.notifications_none_rounded),
                        tooltip: 'Notifications',
                        color: AppColors.textPrimary,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.backgroundSurface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'RÉSUMÉ DES TÂCHES',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          label: 'À faire',
                          value: '$todoCount',
                          icon: Icons.checklist_rounded,
                          iconBackground: AppColors.primaryContainer,
                          iconColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          label: 'En cours',
                          value: '$inProgressCount',
                          icon: Icons.autorenew_rounded,
                          iconBackground: AppColors.primaryContainer,
                          iconColor: AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          label: 'Terminées',
                          value: '$completedCount',
                          icon: Icons.check_circle_rounded,
                          iconBackground: AppColors.primaryContainer,
                          iconColor: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'VOTRE FOCUS AUJOURD’HUI',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _FocusPanel(tasks: focusTasks.take(3).toList()),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'PROJETS RÉCENTS',
                          style: TextStyle(
                            fontSize: 12,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/projects'),
                        child: const Text(
                          'Voir tout',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (recentProjects.isEmpty)
                    const _EmptyDashboard()
                  else
                    Column(
                      children: recentProjects.map((project) {
                        final projectTasks = tasksByProject[project.id] ?? const <Task>[];
                        final progress = project.progressPercentage;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ProjectTile(
                            project: project,
                            progress: progress,
                            taskCount: projectTasks.length,
                            completedCount: projectTasks
                                .where((task) => task.status == 'completed')
                                .length,
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'TÂCHES IMPORTANTES',
                          style: TextStyle(
                            fontSize: 12,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/tasks'),
                        child: const Text(
                          'Voir tout',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (importantTasks.isEmpty)
                    const _EmptyTaskList()
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSurface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: importantTasks.take(3).map((task) {
                          final taskColor = _priorityColor(task.priority);
                          final projectName = projects
                              .where((project) => project.id == task.projectId)
                              .firstOrNull
                              ?.name ?? 'Projet';

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: AppColors.divider),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: taskColor, width: 2),
                                    color: taskColor.withValues(alpha: 0.12),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task.title,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        projectName,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: taskColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      _priorityLabel(task.priority),
                                      style: TextStyle(
                                        color: taskColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusPanel extends StatelessWidget {
  const _FocusPanel({required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: tasks.isEmpty
          ? const Text(
              'Aucune tâche à traiter pour le moment.',
              style: TextStyle(color: AppColors.textSecondary),
            )
          : Column(
              children: tasks.map((task) {
                final color = _priorityColor(task.priority);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: color, width: 2),
                          color: color.withValues(alpha: 0.12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          task.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _priorityLabel(task.priority),
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class _ProjectTile extends StatelessWidget {
  const _ProjectTile({
    required this.project,
    required this.progress,
    required this.taskCount,
    required this.completedCount,
  });

  final Project project;
  final int progress;
  final int taskCount;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    final accent = _projectAccentColor(project.name);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.folder_outlined,
                  color: accent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  project.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (progress / 100).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '$progress%',
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '$taskCount tâches',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.task_alt_rounded, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                '$completedCount terminées',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyDashboard extends StatelessWidget {
  const _EmptyDashboard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.folder_open_rounded, size: 42, color: AppColors.primary),
          const SizedBox(height: 12),
          const Text(
            'Aucun projet pour le moment',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Créez votre premier projet pour commencer à organiser votre travail.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTaskList extends StatelessWidget {
  const _EmptyTaskList();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: const Text(
        'Aucune tâche importante pour le moment.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

int _priorityWeight(String priority) {
  switch (priority.toLowerCase()) {
    case 'high':
      return 3;
    case 'medium':
      return 2;
    case 'low':
    default:
      return 1;
  }
}

String _priorityLabel(String priority) {
  switch (priority.toLowerCase()) {
    case 'high':
      return 'Élevée';
    case 'medium':
      return 'Moyenne';
    case 'low':
      return 'Faible';
    default:
      return 'Moyenne';
  }
}

Color _priorityColor(String priority) {
  switch (priority.toLowerCase()) {
    case 'high':
      return AppColors.error;
    case 'medium':
      return AppColors.warning;
    case 'low':
      return AppColors.success;
    default:
      return AppColors.warning;
  }
}

Color _projectAccentColor(String projectName) {
  final value = projectName.trim().isEmpty ? 'default' : projectName;
  final hash = value.codeUnits.fold<int>(0, (sum, code) => sum + code);
  final palette = [AppColors.primary, AppColors.secondary, AppColors.info, AppColors.success];
  return palette[hash % palette.length];
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
