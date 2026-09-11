import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taskflow/core/constants/app_constants.dart';
import 'package:taskflow/core/errors/exceptions.dart';
import 'package:taskflow/features/projects/data/models/project_member_model.dart';
import 'package:taskflow/features/projects/data/models/project_model.dart';
import 'package:taskflow/features/tasks/data/models/task_model.dart';

abstract class ProjectRemoteDataSource {
  Stream<List<ProjectModel>> getProjectsStream({required String userId});
  Future<ProjectModel> getProject(String projectId);
  Future<ProjectModel> createProject({
    required String name,
    required String description,
    required String currentUserId,
    required String invitationCode,
  });
  Future<void> updateProject(ProjectModel project);
  Future<void> deleteProject(String projectId);
  Stream<List<ProjectMemberModel>> getProjectMembersStream(String projectId);
  Future<void> removeMember({
    required String projectId,
    required String memberId,
  });
  Future<void> leaveProject({
    required String projectId,
    required String currentUserId,
  });
  Future<String> regenerateInvitationCode({
    required String projectId,
    required String newCode,
  });
  Future<List<TaskModel>> getTasksForProject(String projectId);
}

class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ProjectRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : firestore = firestore ?? FirebaseFirestore.instance,
        auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _projectsCollection =>
      firestore.collection(AppConstants.projectsCollection);

  @override
  Stream<List<ProjectModel>> getProjectsStream({required String userId}) {
    try {
      return _projectsCollection
          .where('memberIds', arrayContains: userId)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => ProjectModel.fromFirestore(doc)).toList();
      });
    } catch (e) {
      throw ServerException('Impossible de charger les projets : $e');
    }
  }

  @override
  Future<ProjectModel> getProject(String projectId) async {
    try {
      final doc = await _projectsCollection.doc(projectId).get();
      if (!doc.exists) {
        throw const NotFoundException('Projet introuvable.');
      }

      // Fetch task statistics
      final tasksSnapshot = await _projectsCollection
          .doc(projectId)
          .collection(AppConstants.tasksSubcollection)
          .get();

      final totalTasks = tasksSnapshot.docs.length;
      final completedTasks = tasksSnapshot.docs.where((taskDoc) {
        final status = taskDoc.data()['status'] as String? ?? '';
        return status == 'completed' || status == 'done';
      }).length;

      // Fetch members count
      final membersSnapshot = await _projectsCollection
          .doc(projectId)
          .collection(AppConstants.membersSubcollection)
          .get();
      final membersCount = membersSnapshot.docs.length;

      final project = ProjectModel.fromFirestore(doc);
      return project.copyWith(
        tasksCount: totalTasks,
        completedTasksCount: completedTasks,
        membersCount: membersCount,
      ) as ProjectModel;
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Impossible de récupérer le projet : $e');
    }
  }

  @override
  Future<ProjectModel> createProject({
    required String name,
    required String description,
    required String currentUserId,
    required String invitationCode,
  }) async {
    try {
      final now = DateTime.now();
      final projectDocRef = _projectsCollection.doc();
      final memberDocRef = projectDocRef
          .collection(AppConstants.membersSubcollection)
          .doc(currentUserId);

      final project = ProjectModel(
        id: projectDocRef.id,
        name: name,
        description: description,
        ownerId: currentUserId,
        invitationCode: invitationCode,
        status: AppConstants.statusActive,
        createdAt: now,
        updatedAt: now,
        memberIds: [currentUserId],
        membersCount: 1,
        tasksCount: 0,
        completedTasksCount: 0,
      );

      // Fetch user profile if available
      String? displayName;
      String? email;
      String? photoUrl;

      final currentUser = auth.currentUser;
      if (currentUser != null && currentUser.uid == currentUserId) {
        displayName = currentUser.displayName;
        email = currentUser.email;
        photoUrl = currentUser.photoURL;
      }

      final member = ProjectMemberModel(
        userId: currentUserId,
        role: AppConstants.roleOwner,
        joinedAt: now,
        displayName: displayName,
        email: email,
        photoUrl: photoUrl,
      );

      // ATOMIC WRITE BATCH: Project + Owner Member
      final batch = firestore.batch();
      batch.set(projectDocRef, project.toFirestore());
      batch.set(memberDocRef, member.toFirestore());

      await batch.commit();
      return project;
    } catch (e) {
      throw ServerException('Impossible de créer le projet : $e');
    }
  }

  @override
  Future<void> updateProject(ProjectModel project) async {
    try {
      await _projectsCollection.doc(project.id).update(project.toFirestore());
    } catch (e) {
      throw ServerException('Impossible de mettre à jour le projet : $e');
    }
  }

  @override
  Future<void> deleteProject(String projectId) async {
    try {
      final projectRef = _projectsCollection.doc(projectId);

      // Clean up subcollections in a batch
      final membersSnap = await projectRef.collection(AppConstants.membersSubcollection).get();
      final tasksSnap = await projectRef.collection(AppConstants.tasksSubcollection).get();

      final batch = firestore.batch();
      for (final doc in membersSnap.docs) {
        batch.delete(doc.reference);
      }
      for (final doc in tasksSnap.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(projectRef);

      await batch.commit();
    } catch (e) {
      throw ServerException('Impossible de supprimer le projet : $e');
    }
  }

  @override
  Stream<List<ProjectMemberModel>> getProjectMembersStream(String projectId) {
    try {
      return _projectsCollection
          .doc(projectId)
          .collection(AppConstants.membersSubcollection)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => ProjectMemberModel.fromFirestore(doc)).toList();
      });
    } catch (e) {
      throw ServerException('Impossible de charger les membres du projet : $e');
    }
  }

  @override
  Future<void> removeMember({
    required String projectId,
    required String memberId,
  }) async {
    try {
      final projectRef = _projectsCollection.doc(projectId);
      final memberRef = projectRef.collection(AppConstants.membersSubcollection).doc(memberId);

      final batch = firestore.batch();
      batch.delete(memberRef);
      batch.update(projectRef, {
        'memberIds': FieldValue.arrayRemove([memberId]),
        'updatedAt': Timestamp.now(),
      });

      await batch.commit();
    } catch (e) {
      throw ServerException('Impossible de retirer le membre : $e');
    }
  }

  @override
  Future<void> leaveProject({
    required String projectId,
    required String currentUserId,
  }) async {
    try {
      final projectRef = _projectsCollection.doc(projectId);
      final memberRef = projectRef.collection(AppConstants.membersSubcollection).doc(currentUserId);

      final batch = firestore.batch();
      batch.delete(memberRef);
      batch.update(projectRef, {
        'memberIds': FieldValue.arrayRemove([currentUserId]),
        'updatedAt': Timestamp.now(),
      });

      await batch.commit();
    } catch (e) {
      throw ServerException('Impossible de quitter le projet : $e');
    }
  }

  @override
  Future<String> regenerateInvitationCode({
    required String projectId,
    required String newCode,
  }) async {
    try {
      await _projectsCollection.doc(projectId).update({
        'invitationCode': newCode,
        'updatedAt': Timestamp.now(),
      });
      return newCode;
    } catch (e) {
      throw ServerException('Impossible de régénérer le code d’invitation : $e');
    }
  }

  @override
  Future<List<TaskModel>> getTasksForProject(String projectId) async {
    try {
      final snapshot = await _projectsCollection
          .doc(projectId)
          .collection(AppConstants.tasksSubcollection)
          .get();

      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException('Impossible de récupérer les tâches du projet : $e');
    }
  }
}
