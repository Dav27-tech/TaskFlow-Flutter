import 'package:task_flow/features/projects/domain/entities/project_member.dart';
import 'package:task_flow/features/projects/domain/repositories/project_repository.dart';

class GetProjectMembersUseCase {
  final ProjectRepository repository;

  GetProjectMembersUseCase(this.repository);

  Stream<List<ProjectMember>> call(String projectId) {
    return repository.getProjectMembers(projectId);
  }
}
