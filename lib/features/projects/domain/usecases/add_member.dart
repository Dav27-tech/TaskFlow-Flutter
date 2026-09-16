import 'package:task_flow/core/errors/exceptions.dart';
import 'package:task_flow/features/projects/domain/repositories/project_repository.dart';

class AddMemberUseCase {
  AddMemberUseCase(this.repository);

  final ProjectRepository repository;

  Future<void> call({
    required String projectId,
    required String memberId,
    required String ownerId,
    required String currentUserId,
  }) async {
    if (ownerId != currentUserId) {
      throw const PermissionDeniedException(
        'Seul le propriétaire peut ajouter des membres.',
      );
    }
    if (memberId == ownerId) {
      throw const ValidationException(
        'Le propriétaire appartient déjà au projet.',
      );
    }

    await repository.addMember(
      projectId: projectId,
      memberId: memberId,
      currentUserId: currentUserId,
    );
  }
}
