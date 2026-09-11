import 'package:taskflow/core/errors/exceptions.dart';
import 'package:taskflow/features/projects/domain/repositories/project_repository.dart';

class DeleteProjectUseCase {
  final ProjectRepository repository;

  DeleteProjectUseCase(this.repository);

  Future<void> call({
    required String projectId,
    required String ownerId,
    required String currentUserId,
  }) async {
    if (ownerId != currentUserId) {
      throw const PermissionDeniedException('Seul le propriétaire du projet peut le supprimer.');
    }
    await repository.deleteProject(projectId);
  }
}
