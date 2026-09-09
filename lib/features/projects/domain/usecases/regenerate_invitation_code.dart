import 'package:task_flow/core/errors/exceptions.dart';
import 'package:task_flow/features/projects/domain/repositories/project_repository.dart';

class RegenerateInvitationCodeUseCase {
  final ProjectRepository repository;

  RegenerateInvitationCodeUseCase(this.repository);

  Future<String> call({
    required String projectId,
    required String ownerId,
    required String currentUserId,
  }) async {
    if (ownerId != currentUserId) {
      throw const PermissionDeniedException('Only the project owner can regenerate the invitation code.');
    }

    return repository.regenerateInvitationCode(
      projectId: projectId,
      currentUserId: currentUserId,
    );
  }
}
