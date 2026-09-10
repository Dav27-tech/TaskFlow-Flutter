import 'package:task_flow/features/projects/domain/repositories/project_repository.dart';

class ExportProjectJsonUseCase {
  final ProjectRepository repository;

  ExportProjectJsonUseCase(this.repository);

  Future<void> call({required String projectId}) async {
    await repository.exportProjectJson(projectId: projectId);
  }
}
