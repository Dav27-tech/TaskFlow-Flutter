import 'package:taskflow/core/errors/exceptions.dart';
import 'package:taskflow/core/utils/invitation_code_generator.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';
import 'package:taskflow/features/projects/domain/repositories/project_repository.dart';

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
      throw const AuthException('Vous devez être authentifié pour créer un projet.');
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
