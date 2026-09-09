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
        title: Text(widget.isEditMode ? 'Edit Project' : 'New Project'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card for Creator Rule
              if (!widget.isEditMode) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 22),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You will automatically be assigned as the OWNER of this project upon creation.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Project Name Field
              CustomTextField(
                controller: _nameController,
                label: 'Project Name *',
                hintText: 'e.g. Mobile App Redesign',
                prefixIcon: const Icon(Icons.folder_outlined, color: AppColors.textSecondary),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a project name';
                  }
                  if (value.trim().length < 3) {
                    return 'Project name must be at least 3 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Description Field
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                hintText: 'Describe the main goals and scope of this project...',
                maxLines: 4,
                minLines: 3,
              ),
              const SizedBox(height: 20),

              // Status Dropdown (Edit mode only)
              if (widget.isEditMode) ...[
                const Text(
                  'Status',
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
                        DropdownMenuItem(value: 'active', child: Text('Active')),
                        DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                        DropdownMenuItem(value: 'completed', child: Text('Completed')),
                        DropdownMenuItem(value: 'archived', child: Text('Archived')),
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
                text: widget.isEditMode ? 'Save Changes' : 'Create Project',
                isLoading: actionState.isLoading,
                icon: widget.isEditMode ? Icons.check_rounded : Icons.add_rounded,
                onPressed: _handleSubmit,
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Cancel',
                isOutlined: true,
                backgroundColor: AppColors.textSecondary,
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
