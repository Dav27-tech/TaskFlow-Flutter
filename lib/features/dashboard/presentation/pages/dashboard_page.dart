import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../projects/presentation/providers/project_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        actions: [
          IconButton(
            onPressed: () => context.push('/notifications'),
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: 'Notifications',
            color: AppColors.textPrimary,
          ),
        ],
      ),
      body: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Impossible de charger vos projets.\n$error')),
        data: (projects) {
          final totalTasks = projects.fold<int>(0, (sum, project) => sum + project.tasksCount);
          final completedTasks = projects.fold<int>(0, (sum, project) => sum + project.completedTasksCount);
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(projectsStreamProvider),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Votre activité',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF14213D),
                      ),
                ),
                const SizedBox(height: 6),
                const Text('Une vue simple de l’avancement de vos projets.'),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _SummaryCard(label: 'Projets', value: '${projects.length}', icon: Icons.folder_outlined)),
                    const SizedBox(width: 12),
                    Expanded(child: _SummaryCard(label: 'Tâches', value: '$totalTasks', icon: Icons.task_alt_outlined)),
                    const SizedBox(width: 12),
                    Expanded(child: _SummaryCard(label: 'Terminées', value: '$completedTasks', icon: Icons.check_circle_outline)),
                  ],
                ),
                const SizedBox(height: 28),
                Text('Projets récents', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                if (projects.isEmpty)
                  _EmptyDashboard(onCreateProject: () => context.go('/projects'))
                else
                  ...projects.take(5).map(
                        (project) => Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.folder_outlined)),
                            title: Text(project.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Text('${project.completedTasksCount}/${project.tasksCount} tâches terminées'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => context.push('/projects/${project.id}', extra: project),
                          ),
                        ),
                      ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => context.go('/projects'),
                  icon: const Icon(Icons.folder_open_outlined),
                  label: const Text('Voir tous les projets'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xFF2878E8)),
              const SizedBox(height: 10),
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              Text(label, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      );
}

class _EmptyDashboard extends StatelessWidget {
  const _EmptyDashboard({required this.onCreateProject});
  final VoidCallback onCreateProject;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Column(
          children: [
            const Icon(Icons.dashboard_customize_outlined, size: 46, color: Color(0xFF8A9AB2)),
            const SizedBox(height: 12),
            const Text('Votre espace est prêt', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
            const SizedBox(height: 6),
            const Text('Créez votre premier projet pour commencer.', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: onCreateProject, icon: const Icon(Icons.add), label: const Text('Créer un projet')),
          ],
        ),
      );
}
