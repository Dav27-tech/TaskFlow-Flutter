import 'package:task_flow/core/errors/exceptions.dart';
import 'package:task_flow/core/utils/invitation_code_generator.dart';
import 'package:task_flow/features/projects/domain/entities/project.dart';
import 'package:task_flow/features/projects/domain/repositories/project_repository.dart';

class CreateProjectUseCase {
  final ProjectRepository repository;

  CreateProjectUseCase(this.repository);

  Future<Project> call({
    required String name,
    required String description,
    required String currentUserId,
  }) async {
    if (name.trim().isEmpty) {
      throw const ValidationException('Project name cannot be empty.');
    }
    if (currentUserId.trim().isEmpty) {
      throw const AuthException('User must be authenticated to create a project.');
    }

    final code = InvitationCodeGenerator.generateInvitationCode();

    return repository.createProject(
      name: name.trim(),
      description: description.trim(),
      currentUserId: currentUserId.trim(),
      initialInvitationCode: code,
    );
  }
}
