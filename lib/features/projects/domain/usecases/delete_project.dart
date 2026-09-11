import 'package:task_flow/core/errors/exceptions.dart';
import 'package:task_flow/features/projects/domain/repositories/project_repository.dart';

class DeleteProjectUseCase {
  final ProjectRepository repository;

  DeleteProjectUseCase(this.repository);

  Future<void> call({
    required String projectId,
    required String ownerId,
    required String currentUserId,
  }) async {
    if (ownerId != currentUserId) {
      throw const PermissionDeniedException('Only the project owner can delete this project.');
    }
    await repository.deleteProject(projectId);
  }
}
