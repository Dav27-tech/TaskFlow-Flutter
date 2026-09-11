import 'dart:convert';
import 'package:task_flow/core/errors/exceptions.dart';
import 'package:task_flow/core/services/share_service.dart';
import 'package:task_flow/core/utils/invitation_code_generator.dart';
import 'package:task_flow/features/projects/data/datasources/project_remote_datasource.dart';
import 'package:task_flow/features/projects/data/models/project_model.dart';
import 'package:task_flow/features/projects/domain/entities/project.dart';
import 'package:task_flow/features/projects/domain/entities/project_member.dart';
import 'package:task_flow/features/projects/domain/repositories/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource remoteDataSource;
  final ShareService shareService;

  ProjectRepositoryImpl({
    required this.remoteDataSource,
    required this.shareService,
  });

  @override
  Stream<List<Project>> getProjects({required String userId}) {
    return remoteDataSource.getProjectsStream(userId: userId);
  }

  @override
  Future<Project> getProject(String projectId) async {
    return await remoteDataSource.getProject(projectId);
  }

  @override
  Future<Project> createProject({
    required String name,
    required String description,
    required String currentUserId,
    String? initialInvitationCode,
  }) async {
    final code = initialInvitationCode ?? InvitationCodeGenerator.generateInvitationCode();
    return await remoteDataSource.createProject(
      name: name,
      description: description,
      currentUserId: currentUserId,
      invitationCode: code,
    );
  }

  @override
  Future<void> updateProject(Project project) async {
    final model = ProjectModel.fromEntity(project);
    await remoteDataSource.updateProject(model);
  }

  @override
  Future<void> deleteProject(String projectId) async {
    await remoteDataSource.deleteProject(projectId);
  }

  @override
  Stream<List<ProjectMember>> getProjectMembers(String projectId) {
    return remoteDataSource.getProjectMembersStream(projectId);
  }

  @override
  Future<void> removeMember({
    required String projectId,
    required String memberId,
    required String currentUserId,
  }) async {
    await remoteDataSource.removeMember(
      projectId: projectId,
      memberId: memberId,
    );
  }

  @override
  Future<void> leaveProject({
    required String projectId,
    required String currentUserId,
  }) async {
    await remoteDataSource.leaveProject(
      projectId: projectId,
      currentUserId: currentUserId,
    );
  }

  @override
  Future<String> regenerateInvitationCode({
    required String projectId,
    required String currentUserId,
  }) async {
    final newCode = InvitationCodeGenerator.generateInvitationCode();
    return await remoteDataSource.regenerateInvitationCode(
      projectId: projectId,
      newCode: newCode,
    );
  }

  @override
  Future<void> exportProjectJson({required String projectId}) async {
    try {
      final project = await remoteDataSource.getProject(projectId);
      final tasks = await remoteDataSource.getTasksForProject(projectId);

      final exportData = {
        'project': {
          'id': project.id,
          'name': project.name,
          'description': project.description,
          'ownerId': project.ownerId,
        },
        'exportedAt': DateTime.now().toUtc().toIso8601String(),
        'tasks': tasks.map((t) => t.toExportJson()).toList(),
      };

      const encoder = JsonEncoder.withIndent('  ');
      final jsonString = encoder.convert(exportData);

      await shareService.shareJsonFile(
        jsonContent: jsonString,
        fileName: 'project_tasks.json',
        subject: 'TaskFlow - Tasks Export: ${project.name}',
        text: 'Export of tasks for project "${project.name}" (Format: JSON)',
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw ExportException('Failed to export project tasks as JSON: $e');
    }
  }
}
