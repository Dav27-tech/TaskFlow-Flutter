import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  const TaskModel({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  factory TaskModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return TaskModel(
      id: doc.id,
      projectId: data['projectId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      status: data['status'] as String? ?? 'todo',
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      createdBy: data['createdBy'] as String? ?? '',
    );
  }

  Map<String, dynamic> toExportJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'createdBy': createdBy,
      'projectId': projectId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
