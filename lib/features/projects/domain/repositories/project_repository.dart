import 'package:task_flow/features/projects/domain/entities/project.dart';
import 'package:task_flow/features/projects/domain/entities/project_member.dart';

abstract class ProjectRepository {
  /// Streams all projects where the user is a member or owner.
  Stream<List<Project>> getProjects({required String userId});

  /// Fetches a single project by its ID.
  Future<Project> getProject(String projectId);

  /// Creates a project atomically with the creator set as owner.
  Future<Project> createProject({
    required String name,
    required String description,
    required String currentUserId,
    String? initialInvitationCode,
  });

  /// Updates project fields (name, description, status).
  Future<void> updateProject(Project project);

  /// Deletes a project and related subcollections.
  Future<void> deleteProject(String projectId);

  /// Streams the list of members for a given project.
  Stream<List<ProjectMember>> getProjectMembers(String projectId);

  /// Removes a member from the project (Owner only).
  Future<void> removeMember({
    required String projectId,
    required String memberId,
    required String currentUserId,
  });

  /// Allows a member to leave the project.
  Future<void> leaveProject({
    required String projectId,
    required String currentUserId,
  });

  /// Regenerates and saves a new invitation code for the project (Owner only).
  Future<String> regenerateInvitationCode({
    required String projectId,
    required String currentUserId,
  });

  /// Generates the JSON export and triggers file sharing.
  Future<void> exportProjectJson({
    required String projectId,
  });
}
