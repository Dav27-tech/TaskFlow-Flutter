import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_flow/core/constants/app_colors.dart';
import 'package:task_flow/core/widgets/error_view.dart';
import 'package:task_flow/core/widgets/loading_indicator.dart';
import 'package:task_flow/features/projects/presentation/providers/project_provider.dart';
import 'package:task_flow/features/projects/presentation/widgets/project_card.dart';

class ProjectsPage extends ConsumerWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(currentUserIdProvider);
    final projectsAsync = ref.watch(projectsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, size: 26),
            tooltip: 'Create Project',
            onPressed: () => context.push('/projects/create'),
          ),
        ],
      ),
      body: projectsAsync.when(
        data: (projects) {
          if (projects.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(projectsStreamProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return ProjectCard(
                  project: project,
                  currentUserId: currentUserId,
                  onTap: () {
                    context.push('/projects/${project.id}', extra: project);
                  },
                );
              },
            ),
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading your projects...'),
        error: (error, stack) => ErrorView(
          message: error.toString().replaceFirst('AppException: ', ''),
          onRetry: () => ref.invalidate(projectsStreamProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/projects/create'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Project', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.folder_open_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No projects yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first project to start organizing tasks and collaborating with your team.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => context.push('/projects/create'),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Project'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
