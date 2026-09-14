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
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Projets', style: TextStyle(fontWeight: FontWeight.bold),),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              color: Colors.white,
              icon: const Icon(Icons.add_rounded, size: 25),
              tooltip: 'Créer un projet',
              onPressed: () => context.push('/projects/create'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              onChanged: (value) =>
                  ref.read(projectSearchQueryProvider.notifier).setQuery(value),
              decoration: InputDecoration(
                hintText: 'Rechercher un projet...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
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
                          context.push('/projects/${project.id}', extra: project);
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const LoadingIndicator(message: 'Chargement des projets...'),
              error: (error, stack) => ErrorView(
                message: error.toString().replaceFirst('AppException: ', ''),
                onRetry: () => ref.invalidate(projectsStreamProvider),
              ),
            ),
          ),
        ],
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
            Text(
              isSearch 
                ? 'Nous n\'avons trouvé aucun projet correspondant à votre recherche.'
                : 'Commencez par créer votre premier projet pour organiser vos tâches et collaborer.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            if (!isSearch)
              ElevatedButton.icon(
                onPressed: () => context.push('/projects/create'),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Créer un projet'),
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
