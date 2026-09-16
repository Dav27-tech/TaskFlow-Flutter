import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_flow/core/constants/app_colors.dart';
import 'package:task_flow/core/constants/app_constants.dart';
import 'package:task_flow/core/widgets/custom_button.dart';
import 'package:task_flow/core/widgets/custom_text_field.dart';
import 'package:task_flow/features/projects/domain/entities/project.dart';
import 'package:task_flow/features/projects/presentation/providers/project_provider.dart';

class ProjectFormPage extends ConsumerStatefulWidget {
  final Project? initialProject;

  const ProjectFormPage({
    super.key,
    this.initialProject,
  });

  bool get isEditMode => initialProject != null;

  @override
  ConsumerState<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends ConsumerState<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialProject?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.initialProject?.description ?? '');
    _selectedStatus = widget.initialProject?.status ?? AppConstants.statusActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(projectActionControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(widget.isEditMode ? 'Modifier le projet' : 'Nouveau projet', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project Name Field
              CustomTextField(
                controller: _nameController,
                label: 'Nom du projet *',
                hintText: 'Nom du projet ...',
                prefixIcon: const Icon(Icons.folder_outlined, color: AppColors.textSecondary),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un nom de projet';
                  }
                  if (value.trim().length < 3) {
                    return 'Le nom du projet doit contenir au moins 5 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Description Field
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                hintText: 'Décription du projet ...',
                maxLines: 4,
                minLines: 3,
              ),
              const SizedBox(height: 20),

              // Status Dropdown (Edit mode only)
              if (widget.isEditMode) ...[
                const Text(
                  'Statut',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 1.2),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedStatus,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'active', child: Text('Actif')),
                        DropdownMenuItem(value: 'in_progress', child: Text('En cours')),
                        DropdownMenuItem(value: 'completed', child: Text('Terminé')),
                        DropdownMenuItem(value: 'archived', child: Text('Archivé')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedStatus = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ] else ...[
                const SizedBox(height: 12),
              ],

              // Action Buttons
              CustomButton(
                text: widget.isEditMode ? 'Enregistrer les modifications' : 'Créer le projet',
                isLoading: actionState.isLoading,
                icon: widget.isEditMode ? Icons.check_rounded : Icons.add_rounded,
                onPressed: _handleSubmit,
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Annuler',
                isOutlined: true,
                backgroundColor: AppColors.errorSoft,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.isEditMode) {
      final updatedProject = widget.initialProject!.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _selectedStatus,
      );

      final success = await ref
          .read(projectActionControllerProvider.notifier)
          .updateProject(project: updatedProject);

      if (success && mounted) {
        ref.invalidate(projectDetailsProvider(widget.initialProject!.id));
        ref.invalidate(projectsStreamProvider);
        context.pop();
      }
    } else {
      final project = await ref
          .read(projectActionControllerProvider.notifier)
          .createProject(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
          );

      if (project != null && mounted) {
        ref.invalidate(projectsStreamProvider);
        context.go('/projects/${project.id}', extra: project);
      }
    }
  }
}
