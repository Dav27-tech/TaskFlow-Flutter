import 'package:task_flow/core/errors/exceptions.dart';
import 'package:task_flow/features/projects/domain/repositories/project_repository.dart';

class LeaveProjectUseCase {
  final ProjectRepository repository;

  LeaveProjectUseCase(this.repository);

  Future<void> call({
    required String projectId,
    required String ownerId,
    required String currentUserId,
  }) async {
    if (ownerId == currentUserId) {
      throw const ValidationException('The project owner cannot leave the project. Please transfer ownership or delete the project instead.');
    }

    await repository.leaveProject(
      projectId: projectId,
      currentUserId: currentUserId,
    );
  }
}
