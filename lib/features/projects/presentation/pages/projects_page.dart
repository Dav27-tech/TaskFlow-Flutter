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
    final projectsAsync = ref.watch(filteredProjectsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Harmonized Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Projets',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  SizedBox.square(
                    dimension: 52,
                    child: FilledButton(
                      onPressed: () => context.push('/projects/create'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Icon(Icons.add_rounded, size: 30),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: TextField(
                onChanged: (value) =>
                    ref.read(projectSearchQueryProvider.notifier).setQuery(value),
                decoration: InputDecoration(
                  hintText: 'Rechercher un projet...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
            ),

            Expanded(
              child: projectsAsync.when(
                data: (projects) {
                  if (projects.isEmpty) {
                    final query = ref.watch(projectSearchQueryProvider);
                    return _buildEmptyState(context, query.isNotEmpty);
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      ref.invalidate(projectsStreamProvider);
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: projects.length,
                      itemBuilder: (context, index) {
                        final project = projects[index];
                        return ProjectCard(
                          project: project,
                          currentUserId: currentUserId,
                          onTap: () {
                            context.push(
                              '/projects/${project.id}',
                              extra: project,
                            );
                          },
                        );
                      },
                    ),
                  );
                },
                loading: () =>
                    const LoadingIndicator(message: 'Chargement des projets...'),
                error: (error, stack) => ErrorView(
                  message: error.toString().replaceFirst('AppException: ', ''),
                  onRetry: () => ref.invalidate(projectsStreamProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isSearch) {
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
              child: Icon(
                isSearch ? Icons.search_off_rounded : Icons.folder_open_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isSearch ? 'Aucun résultat' : 'Aucun projet',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 28),
            if (!isSearch)
              ElevatedButton.icon(
                onPressed: () => context.push('/projects/create'),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Créer un projet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
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
