import 'package:task_flow/core/errors/exceptions.dart';
import 'package:task_flow/features/projects/domain/entities/project.dart';
import 'package:task_flow/features/projects/domain/repositories/project_repository.dart';

class UpdateProjectUseCase {
  final ProjectRepository repository;

  UpdateProjectUseCase(this.repository);

  Future<void> call({
    required Project project,
    required String currentUserId,
  }) async {
    if (!project.isOwner(currentUserId)) {
      throw const PermissionDeniedException('Only the project owner can update this project.');
    }
    if (project.name.trim().isEmpty) {
      throw const ValidationException('Project name cannot be empty.');
    }

    final updatedProject = project.copyWith(
      name: project.name.trim(),
      description: project.description.trim(),
      updatedAt: DateTime.now(),
    );

    await repository.updateProject(updatedProject);
  }
}
