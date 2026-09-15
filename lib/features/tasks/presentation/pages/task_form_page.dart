import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../projects/presentation/providers/project_provider.dart';
import '../../domain/entities/task.dart';
import '../providers/task_provider.dart';

class TaskFormPage extends ConsumerStatefulWidget {
  const TaskFormPage({super.key, this.initialProjectId, this.initialTask});

  final String? initialProjectId;
  final Task? initialTask;

  @override
  ConsumerState<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends ConsumerState<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _deadlineController;
  late DateTime _deadline;
  late String _priority;
  late String _status;
  String? _selectedProjectId;
  String? _assignedMemberId;

  bool get _isEditing => widget.initialTask != null;

  @override
  void initState() {
    super.initState();
    final task = widget.initialTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(
      text: task?.description ?? '',
    );
    _selectedProjectId = task?.projectId ?? widget.initialProjectId;
    _assignedMemberId = task?.assignedMemberId;
    _priority = _validPriority(task?.priority) ? task!.priority : 'medium';
    _status = _validStatus(task?.status) ? task!.status : 'todo';
    _deadline = task?.deadline ?? DateTime.now().add(const Duration(days: 1));
    _deadlineController = TextEditingController(
      text: _formatDeadline(_deadline),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final projectsAsync = ref.watch(projectsStreamProvider);
    final actionState = ref.watch(taskActionControllerProvider);
    final currentUserId = ref.watch(currentUserIdProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        toolbarHeight: 62,
        backgroundColor: AppColors.backgroundSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Retour',
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          _isEditing ? 'Modifier la tâche' : 'Créer une tâche',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: authState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Impossible de vérifier la session.\n$error'),
            ),
          ),
          data: (user) {
            if (user == null || currentUserId.isEmpty) {
              return const Center(
                child: Text('Votre session a expiré. Reconnectez-vous.'),
              );
            }

            return projectsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Impossible de charger les projets.\n$error'),
                ),
              ),
              data: (projects) {
                if (projects.isEmpty) {
                  return const Center(child: Text('Aucun projet disponible.'));
                }

                final projectId =
                    projects.any((p) => p.id == _selectedProjectId)
                    ? _selectedProjectId!
                    : projects.first.id;
                _selectedProjectId = projectId;
                final membersAsync = ref.watch(
                  projectMembersStreamProvider(projectId),
                );

                return membersAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('Impossible de charger les membres.\n$error'),
                    ),
                  ),
                  data: (members) {
                    final memberIds = members
                        .map((member) => member.userId)
                        .toSet();
                    var assignedMemberId = memberIds.contains(_assignedMemberId)
                        ? _assignedMemberId
                        : null;
                    if (assignedMemberId == null && members.isNotEmpty) {
                      assignedMemberId = memberIds.contains(currentUserId)
                          ? currentUserId
                          : members.first.userId;
                      _assignedMemberId = assignedMemberId;
                    }

                    return Form(
                      key: _formKey,
                      child: ListView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
                        children: [
                          _RequiredLabel('Titre'),
                          TextFormField(
                            controller: _titleController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              hintText: 'Design system update',
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Le titre est requis.'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          const _FieldLabel('Description'),
                          TextFormField(
                            controller: _descriptionController,
                            minLines: 3,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              hintText: 'Décrivez le travail attendu.',
                            ),
                          ),
                          const SizedBox(height: 16),
                          _RequiredLabel('Projet'),
                          DropdownButtonFormField<String>(
                            key: ValueKey('project-$projectId'),
                            initialValue: projectId,
                            decoration: const InputDecoration(),
                            items: projects
                                .map(
                                  (project) => DropdownMenuItem(
                                    value: project.id,
                                    child: Text(project.name),
                                  ),
                                )
                                .toList(),
                            onChanged: _isEditing
                                ? null
                                : (value) {
                                    setState(() {
                                      _selectedProjectId = value;
                                      _assignedMemberId = null;
                                    });
                                  },
                          ),
                          const SizedBox(height: 16),
                          _RequiredLabel('Membre assigné'),
                          if (members.isEmpty)
                            const InputDecorator(
                              decoration: InputDecoration(),
                              child: Text('Aucun membre disponible'),
                            )
                          else
                            DropdownButtonFormField<String>(
                              key: ValueKey(
                                'member-$projectId-$assignedMemberId',
                              ),
                              initialValue: assignedMemberId,
                              decoration: const InputDecoration(),
                              items: members
                                  .map(
                                    (member) => DropdownMenuItem(
                                      value: member.userId,
                                      child: Text(
                                        member.displayTitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              validator: (value) => value == null
                                  ? 'Choisissez un membre du projet.'
                                  : null,
                              onChanged: (value) =>
                                  setState(() => _assignedMemberId = value),
                            ),
                          if (members.isEmpty) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'Ajoutez des membres au projet avant de créer une tâche.',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                          const SizedBox(height: 16),
                          _RequiredLabel('Priorité'),
                          DropdownButtonFormField<String>(
                            initialValue: _priority,
                            decoration: const InputDecoration(),
                            items: _priorityOptions
                                .map(
                                  (option) => DropdownMenuItem(
                                    value: option.value,
                                    child: _ColoredOption(option: option),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _priority = value ?? _priority),
                          ),
                          const SizedBox(height: 16),
                          _RequiredLabel('Statut'),
                          DropdownButtonFormField<String>(
                            initialValue: _status,
                            decoration: const InputDecoration(),
                            items: _statusOptions
                                .map(
                                  (option) => DropdownMenuItem(
                                    value: option.value,
                                    child: _ColoredOption(option: option),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _status = value ?? _status),
                          ),
                          const SizedBox(height: 16),
                          _RequiredLabel('Deadline'),
                          TextFormField(
                            readOnly: true,
                            controller: _deadlineController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.calendar_today_outlined),
                            ),
                            onTap: _pickDeadline,
                          ),
                          const SizedBox(height: 34),
                          ElevatedButton(
                            onPressed: actionState.isLoading || members.isEmpty
                                ? null
                                : _submit,
                            child: actionState.isLoading
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        _isEditing
                                            ? 'Mise à jour...'
                                            : 'Création...',
                                      ),
                                    ],
                                  )
                                : Text(
                                    _isEditing
                                        ? 'Enregistrer'
                                        : 'Créer la tâche',
                                  ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Choisir une deadline',
    );
    if (picked != null && mounted) {
      setState(() {
        _deadline = picked;
        _deadlineController.text = _formatDeadline(picked);
      });
    }
  }

  String _formatDeadline(DateTime deadline) {
    return '${deadline.day} ${_monthName(deadline.month)} ${deadline.year}';
  }

  bool _validPriority(String? value) =>
      _priorityOptions.any((option) => option.value == value);

  bool _validStatus(String? value) =>
      _statusOptions.any((option) => option.value == value);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final projectId = _selectedProjectId;
    final assignedMemberId = _assignedMemberId;
    if (projectId == null || assignedMemberId == null) return;

    final controller = ref.read(taskActionControllerProvider.notifier);
    final success = _isEditing
        ? await controller.updateTask(
            projectId: projectId,
            taskId: widget.initialTask!.id,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            assignedMemberId: assignedMemberId,
            priority: _priority,
            status: _status,
            deadline: _deadline,
          )
        : await controller.createTask(
            projectId: projectId,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            assignedMemberId: assignedMemberId,
            priority: _priority,
            status: _status,
            deadline: _deadline,
          );

    if (!mounted) return;
    if (success) {
      context.pop();
    } else {
      final error = ref
          .read(taskActionControllerProvider)
          .whenOrNull(error: (error, _) => error.toString());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error ?? 'Action impossible.')));
    }
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 7),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RequiredLabel extends StatelessWidget {
  const _RequiredLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 7),
      child: RichText(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          children: const [
            TextSpan(
              text: ' *',
              style: TextStyle(color: AppColors.error),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColoredOption extends StatelessWidget {
  const _ColoredOption({required this.option});

  final _TaskOption option;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: option.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Text(option.label),
      ],
    );
  }
}

class _TaskOption {
  const _TaskOption({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;
}

const _priorityOptions = [
  _TaskOption(value: 'high', label: 'Haute', color: AppColors.error),
  _TaskOption(value: 'medium', label: 'Moyenne', color: AppColors.warning),
  _TaskOption(value: 'low', label: 'Basse', color: AppColors.success),
];

const _statusOptions = [
  _TaskOption(value: 'todo', label: 'À faire', color: AppColors.primary),
  _TaskOption(
    value: 'in_progress',
    label: 'En cours',
    color: AppColors.warning,
  ),
  _TaskOption(value: 'completed', label: 'Terminée', color: AppColors.success),
];

String _monthName(int month) {
  const months = [
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre',
  ];
  return months[(month - 1).clamp(0, months.length - 1)];
}
