import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskflow/features/projects/domain/entities/project_member.dart';

class ProjectMemberModel extends ProjectMember {
  const ProjectMemberModel({
    required super.userId,
    required super.role,
    required super.joinedAt,
    super.displayName,
    super.email,
    super.photoUrl,
  });

  factory ProjectMemberModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    Map<String, dynamic>? userProfile,
  }) {
    final data = doc.data() ?? {};
    return ProjectMemberModel(
      userId: doc.id.isNotEmpty ? doc.id : (data['userId'] as String? ?? ''),
      role: data['role'] as String? ?? 'member',
      joinedAt: data['joinedAt'] is Timestamp
          ? (data['joinedAt'] as Timestamp).toDate()
          : (data['joinedAt'] != null ? DateTime.tryParse(data['joinedAt'].toString()) ?? DateTime.now() : DateTime.now()),
      displayName: userProfile?['displayName'] as String? ?? data['displayName'] as String?,
      email: userProfile?['email'] as String? ?? data['email'] as String?,
      photoUrl: userProfile?['photoUrl'] as String? ?? data['photoUrl'] as String?,
    );
  }

  factory ProjectMemberModel.fromEntity(ProjectMember member) {
    return ProjectMemberModel(
      userId: member.userId,
      role: member.role,
      joinedAt: member.joinedAt,
      displayName: member.displayName,
      email: member.email,
      photoUrl: member.photoUrl,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'role': role,
      'joinedAt': Timestamp.fromDate(joinedAt),
      if (displayName != null) 'displayName': displayName,
      if (email != null) 'email': email,
      if (photoUrl != null) 'photoUrl': photoUrl,
    };
  }

  factory ProjectMemberModel.fromJson(Map<String, dynamic> json) {
    return ProjectMemberModel(
      userId: json['userId'] as String? ?? '',
      role: json['role'] as String? ?? 'member',
      joinedAt: json['joinedAt'] != null
          ? (DateTime.tryParse(json['joinedAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
      displayName: json['displayName'] as String?,
      email: json['email'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'role': role,
      'joinedAt': joinedAt.toIso8601String(),
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
    };
  }
}
