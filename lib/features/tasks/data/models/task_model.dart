import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/task.dart';

class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.projectId,
    required super.title,
    required super.description,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    required super.createdBy,
  });

  factory TaskModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return TaskModel(
      id: doc.id,
      projectId: data['projectId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      status: data['status'] as String? ?? 'todo',
      createdAt: _dateValue(data['createdAt']),
      updatedAt: _dateValue(data['updatedAt']),
      createdBy: data['createdBy'] as String? ?? '',
    );
  }

  static DateTime _dateValue(Object? value) {
    if (value is Timestamp) return value.toDate();
    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
  }

  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'title': title,
      'description': description,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
    };
  }
}