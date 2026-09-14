import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task.dart';
import '../providers/task_provider.dart';
import '../../../projects/presentation/providers/project_provider.dart';

class TasksPage extends ConsumerStatefulWidget {
  const TasksPage({super.key});

  @override
  ConsumerState<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends ConsumerState<TasksPage> {
  String? _selectedProjectId;

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsStreamProvider);
    final actionState = ref.watch(taskActionControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tâches')),
      body: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Impossible de charger les projets.\n$error')),
        data: (projects) {
          if (projects.isEmpty) return _EmptyTasks(onCreateProject: () {});
          final selectedId = projects.any((p) => p.id == _selectedProjectId)
              ? _selectedProjectId!
              : projects.first.id;
          final tasksAsync = ref.watch(tasksStreamProvider(selectedId));
          final selectedProject = projects.firstWhere((p) => p.id == selectedId);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedId,
                        decoration: const InputDecoration(labelText: 'Projet'),
                        items: projects
                            .map((project) => DropdownMenuItem(
                                  value: project.id,
                                  child: Text(project.name),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() => _selectedProjectId = value),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filled(
                      tooltip: 'Nouvelle tâche',
                      onPressed: actionState.isLoading
                          ? null
                          : () => _showCreateTaskDialog(selectedId),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: tasksAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('Impossible de charger les tâches.\n$error')),
                  data: (tasks) => tasks.isEmpty
                      ? _EmptyTasks(onCreateProject: () => _showCreateTaskDialog(selectedId))
                      : ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: tasks.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) => _TaskTile(
                            task: tasks[index],
                            onStatusChanged: (status) => ref
                                .read(taskActionControllerProvider.notifier)
                                .updateStatus(
                                  projectId: selectedProject.id,
                                  taskId: tasks[index].id,
                                  status: status,
                                ),
                            onDelete: () => ref
                                .read(taskActionControllerProvider.notifier)
                                .deleteTask(
                                  projectId: selectedProject.id,
                                  taskId: tasks[index].id,
                                ),
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showCreateTaskDialog(String projectId) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle tâche'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Titre'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Le titre est requis.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(context, true);
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );

    if (created == true && mounted) {
      await ref.read(taskActionControllerProvider.notifier).createTask(
            projectId: projectId,
            title: titleController.text.trim(),
            description: descriptionController.text.trim(),
          );
    }
    titleController.dispose();
    descriptionController.dispose();
  }
}

class _EmptyTasks extends StatelessWidget {
  const _EmptyTasks({required this.onCreateProject});
  final VoidCallback onCreateProject;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.task_alt_outlined, size: 48, color: Color(0xFF8A9AB2)),
              const SizedBox(height: 14),
              const Text('Aucune tâche pour le moment', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text('Créez une tâche pour commencer à structurer votre travail.', textAlign: TextAlign.center),
              const SizedBox(height: 18),
              FilledButton.icon(onPressed: onCreateProject, icon: const Icon(Icons.add), label: const Text('Créer une tâche')),
            ],
          ),
        ),
      );
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task, required this.onStatusChanged, required this.onDelete});
  final Task task;
  final ValueChanged<String> onStatusChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: task.description.isEmpty ? null : Text(task.description),
          leading: DropdownButton<String>(
            value: task.status,
            underline: const SizedBox.shrink(),
            items: const [
              DropdownMenuItem(value: 'todo', child: Text('À faire')),
              DropdownMenuItem(value: 'in_progress', child: Text('En cours')),
              DropdownMenuItem(value: 'completed', child: Text('Terminée')),
            ],
            onChanged: (value) {
              if (value != null) onStatusChanged(value);
            },
          ),
          trailing: IconButton(
            tooltip: 'Supprimer',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ),
      );
}
