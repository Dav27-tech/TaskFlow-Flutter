import 'package:taskflow/core/errors/exceptions.dart';
import 'package:taskflow/features/projects/domain/repositories/project_repository.dart';

class RegenerateInvitationCodeUseCase {
  final ProjectRepository repository;

  RegenerateInvitationCodeUseCase(this.repository);

  Future<String> call({
    required String projectId,
    required String ownerId,
    required String currentUserId,
  }) async {
    if (ownerId != currentUserId) {
      throw const PermissionDeniedException('Seul le propriétaire du projet peut régénérer le code d’invitation.');
    }

    return repository.regenerateInvitationCode(
      projectId: projectId,
      currentUserId: currentUserId,
    );
  }
}
