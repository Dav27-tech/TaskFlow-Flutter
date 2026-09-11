import 'package:taskflow/core/errors/exceptions.dart';
import 'package:taskflow/features/projects/domain/repositories/project_repository.dart';

class LeaveProjectUseCase {
  final ProjectRepository repository;

  LeaveProjectUseCase(this.repository);

  Future<void> call({
    required String projectId,
    required String ownerId,
    required String currentUserId,
  }) async {
    if (ownerId == currentUserId) {
      throw const ValidationException('Le propriétaire du projet ne peut pas le quitter. Transférez la propriété ou supprimez le projet.');
    }

    await repository.leaveProject(
      projectId: projectId,
      currentUserId: currentUserId,
    );
  }
}
