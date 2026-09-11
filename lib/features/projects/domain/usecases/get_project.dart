import 'package:taskflow/features/projects/domain/entities/project.dart';
import 'package:taskflow/features/projects/domain/repositories/project_repository.dart';

class GetProjectUseCase {
  final ProjectRepository repository;

  GetProjectUseCase(this.repository);

  Future<Project> call(String projectId) {
    return repository.getProject(projectId);
  }
}
