import 'package:task_flow/core/errors/exceptions.dart';
import 'package:task_flow/features/projects/domain/repositories/project_repository.dart';

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
      throw const PermissionDeniedException('Only the project owner can remove members.');
    }
    if (memberId == ownerId) {
      throw const ValidationException('The project owner cannot be removed from the project.');
    }

    await repository.removeMember(
      projectId: projectId,
      memberId: memberId,
      currentUserId: currentUserId,
    );
  }
}
