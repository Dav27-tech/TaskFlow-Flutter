import 'package:taskflow/core/errors/exceptions.dart';
import 'package:taskflow/features/projects/domain/repositories/project_repository.dart';

class RemoveMemberUseCase {
  final ProjectRepository repository;

  RemoveMemberUseCase(this.repository);

  Future<void> call({
    required String projectId,
    required String memberId,
    required String ownerId,
    required String currentUserId,
  }) async {
    if (ownerId != currentUserId) {
      throw const PermissionDeniedException('Seul le propriétaire du projet peut retirer des membres.');
    }
    if (memberId == ownerId) {
      throw const ValidationException('Le propriétaire du projet ne peut pas être retiré du projet.');
    }

    await repository.removeMember(
      projectId: projectId,
      memberId: memberId,
      currentUserId: currentUserId,
    );
  }
}
