import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_flow/core/services/share_service.dart';
import 'package:task_flow/features/projects/data/datasources/project_remote_datasource.dart';
import 'package:task_flow/features/projects/data/repositories/project_repository_impl.dart';
import 'package:task_flow/features/projects/domain/entities/project.dart';
import 'package:task_flow/features/projects/domain/entities/project_member.dart';
import 'package:task_flow/features/projects/domain/repositories/project_repository.dart';
import 'package:task_flow/features/projects/domain/usecases/create_project.dart';
import 'package:task_flow/features/projects/domain/usecases/delete_project.dart';
import 'package:task_flow/features/projects/domain/usecases/export_project_json.dart';
import 'package:task_flow/features/projects/domain/usecases/get_project.dart';
import 'package:task_flow/features/projects/domain/usecases/get_project_members.dart';
import 'package:task_flow/features/projects/domain/usecases/get_projects.dart';
import 'package:task_flow/features/projects/domain/usecases/leave_project.dart';
import 'package:task_flow/features/projects/domain/usecases/regenerate_invitation_code.dart';
import 'package:task_flow/features/projects/domain/usecases/remove_member.dart';
import 'package:task_flow/features/projects/domain/usecases/update_project.dart';

// ==========================================
// INFRASTRUCTURE & SERVICE PROVIDERS
// ==========================================

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final currentUserIdProvider = Provider<String>((ref) {
  final user = ref.watch(firebaseAuthProvider).currentUser;
  return user?.uid ?? '';
});

final shareServiceProvider = Provider<ShareService>((ref) {
  return ShareServiceImpl();
});

// ==========================================
// DATA LAYER PROVIDERS
// ==========================================

final projectRemoteDataSourceProvider = Provider<ProjectRemoteDataSource>((ref) {
  return ProjectRemoteDataSourceImpl(
    firestore: ref.watch(firestoreProvider),
    auth: ref.watch(firebaseAuthProvider),
  );
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepositoryImpl(
    remoteDataSource: ref.watch(projectRemoteDataSourceProvider),
    shareService: ref.watch(shareServiceProvider),
  );
});

// ==========================================
// USE CASE PROVIDERS
// ==========================================

final getProjectsUseCaseProvider = Provider<GetProjectsUseCase>((ref) {
  return GetProjectsUseCase(ref.watch(projectRepositoryProvider));
});

final getProjectUseCaseProvider = Provider<GetProjectUseCase>((ref) {
  return GetProjectUseCase(ref.watch(projectRepositoryProvider));
});

final createProjectUseCaseProvider = Provider<CreateProjectUseCase>((ref) {
  return CreateProjectUseCase(ref.watch(projectRepositoryProvider));
});

final updateProjectUseCaseProvider = Provider<UpdateProjectUseCase>((ref) {
  return UpdateProjectUseCase(ref.watch(projectRepositoryProvider));
});

final deleteProjectUseCaseProvider = Provider<DeleteProjectUseCase>((ref) {
  return DeleteProjectUseCase(ref.watch(projectRepositoryProvider));
});

final getProjectMembersUseCaseProvider = Provider<GetProjectMembersUseCase>((ref) {
  return GetProjectMembersUseCase(ref.watch(projectRepositoryProvider));
});

final removeMemberUseCaseProvider = Provider<RemoveMemberUseCase>((ref) {
  return RemoveMemberUseCase(ref.watch(projectRepositoryProvider));
});

final leaveProjectUseCaseProvider = Provider<LeaveProjectUseCase>((ref) {
  return LeaveProjectUseCase(ref.watch(projectRepositoryProvider));
});

final regenerateInvitationCodeUseCaseProvider = Provider<RegenerateInvitationCodeUseCase>((ref) {
  return RegenerateInvitationCodeUseCase(ref.watch(projectRepositoryProvider));
});

final exportProjectJsonUseCaseProvider = Provider<ExportProjectJsonUseCase>((ref) {
  return ExportProjectJsonUseCase(ref.watch(projectRepositoryProvider));
});

// ==========================================
// DATA STREAMS & QUERIES
// ==========================================

/// Stream of all projects the current user belongs to
final projectsStreamProvider = StreamProvider<List<Project>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId.isEmpty) {
    return Stream.value([]);
  }
  return ref.watch(getProjectsUseCaseProvider).call(userId: userId);
});

/// Future provider for a single project details
final projectDetailsProvider = FutureProvider.family<Project, String>((ref, projectId) async {
  return ref.watch(getProjectUseCaseProvider).call(projectId);
});

/// Stream provider for a project's members
final projectMembersStreamProvider = StreamProvider.family<List<ProjectMember>, String>((ref, projectId) {
  return ref.watch(getProjectMembersUseCaseProvider).call(projectId);
});

// ==========================================
// ACTION CONTROLLER (Riverpod 3 compatible)
// ==========================================

class ProjectActionState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const ProjectActionState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  ProjectActionState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return ProjectActionState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class ProjectActionController extends Notifier<ProjectActionState> {
  @override
  ProjectActionState build() => const ProjectActionState();

  Future<Project?> createProject({
    required String name,
    required String description,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      final currentUserId = ref.read(currentUserIdProvider);
      final project = await ref.read(createProjectUseCaseProvider).call(
        name: name,
        description: description,
        currentUserId: currentUserId,
      );
      state = state.copyWith(isLoading: false, successMessage: 'Project created successfully!');
      return project;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('AppException: ', '').replaceFirst('Exception: ', ''),
      );
      return null;
    }
  }

  Future<bool> updateProject({
    required Project project,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      final currentUserId = ref.read(currentUserIdProvider);
      await ref.read(updateProjectUseCaseProvider).call(
        project: project,
        currentUserId: currentUserId,
      );
      state = state.copyWith(isLoading: false, successMessage: 'Project updated successfully!');
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('AppException: ', '').replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> deleteProject({
    required String projectId,
    required String ownerId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      final currentUserId = ref.read(currentUserIdProvider);
      await ref.read(deleteProjectUseCaseProvider).call(
        projectId: projectId,
        ownerId: ownerId,
        currentUserId: currentUserId,
      );
      state = state.copyWith(isLoading: false, successMessage: 'Project deleted successfully.');
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('AppException: ', '').replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> removeMember({
    required String projectId,
    required String memberId,
    required String ownerId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      final currentUserId = ref.read(currentUserIdProvider);
      await ref.read(removeMemberUseCaseProvider).call(
        projectId: projectId,
        memberId: memberId,
        ownerId: ownerId,
        currentUserId: currentUserId,
      );
      state = state.copyWith(isLoading: false, successMessage: 'Member removed successfully.');
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('AppException: ', '').replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> leaveProject({
    required String projectId,
    required String ownerId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      final currentUserId = ref.read(currentUserIdProvider);
      await ref.read(leaveProjectUseCaseProvider).call(
        projectId: projectId,
        ownerId: ownerId,
        currentUserId: currentUserId,
      );
      state = state.copyWith(isLoading: false, successMessage: 'You have left the project.');
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('AppException: ', '').replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<String?> regenerateInvitationCode({
    required String projectId,
    required String ownerId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      final currentUserId = ref.read(currentUserIdProvider);
      final newCode = await ref.read(regenerateInvitationCodeUseCaseProvider).call(
        projectId: projectId,
        ownerId: ownerId,
        currentUserId: currentUserId,
      );
      state = state.copyWith(isLoading: false, successMessage: 'Invitation code regenerated successfully!');
      return newCode;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('AppException: ', '').replaceFirst('Exception: ', ''),
      );
      return null;
    }
  }

  Future<bool> exportProjectTasksJson({
    required String projectId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      await ref.read(exportProjectJsonUseCaseProvider).call(projectId: projectId);
      state = state.copyWith(isLoading: false, successMessage: 'Tasks exported successfully.');
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('AppException: ', '').replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }
}

final projectActionControllerProvider =
    NotifierProvider<ProjectActionController, ProjectActionState>(() {
  return ProjectActionController();
});
