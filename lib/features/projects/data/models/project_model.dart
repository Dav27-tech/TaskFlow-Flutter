import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';

class ProjectModel extends Project {
  const ProjectModel({
    required super.id,
    required super.name,
    required super.description,
    required super.ownerId,
    required super.invitationCode,
    super.status,
    required super.createdAt,
    required super.updatedAt,
    super.memberIds,
    super.tasksCount,
    super.completedTasksCount,
    super.membersCount,
  });

  factory ProjectModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ProjectModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      ownerId: data['ownerId'] as String? ?? '',
      invitationCode: data['invitationCode'] as String? ?? '',
      status: data['status'] as String? ?? 'active',
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : (data['createdAt'] != null ? DateTime.tryParse(data['createdAt'].toString()) ?? DateTime.now() : DateTime.now()),
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : (data['updatedAt'] != null ? DateTime.tryParse(data['updatedAt'].toString()) ?? DateTime.now() : DateTime.now()),
      memberIds: data['memberIds'] is List
          ? List<String>.from(data['memberIds'] as List)
          : (data['ownerId'] != null ? [data['ownerId'] as String] : []),
      tasksCount: (data['tasksCount'] as num?)?.toInt() ?? 0,
      completedTasksCount: (data['completedTasksCount'] as num?)?.toInt() ?? 0,
      membersCount: (data['membersCount'] as num?)?.toInt() ?? 0,
    );
  }

  factory ProjectModel.fromEntity(Project project) {
    return ProjectModel(
      id: project.id,
      name: project.name,
      description: project.description,
      ownerId: project.ownerId,
      invitationCode: project.invitationCode,
      status: project.status,
      createdAt: project.createdAt,
      updatedAt: project.updatedAt,
      memberIds: project.memberIds,
      tasksCount: project.tasksCount,
      completedTasksCount: project.completedTasksCount,
      membersCount: project.membersCount,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'invitationCode': invitationCode,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'memberIds': memberIds.isEmpty ? [ownerId] : memberIds,
    };
  }

  Map<String, dynamic> toExportJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ownerId': ownerId,
    };
  }

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      invitationCode: json['invitationCode'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      createdAt: json['createdAt'] != null
          ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
      memberIds: json['memberIds'] is List
          ? List<String>.from(json['memberIds'] as List)
          : [],
      tasksCount: (json['tasksCount'] as num?)?.toInt() ?? 0,
      completedTasksCount: (json['completedTasksCount'] as num?)?.toInt() ?? 0,
      membersCount: (json['membersCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'invitationCode': invitationCode,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'memberIds': memberIds,
      'tasksCount': tasksCount,
      'completedTasksCount': completedTasksCount,
      'membersCount': membersCount,
    };
  }
}
