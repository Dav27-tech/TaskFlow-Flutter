class Project {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final String invitationCode;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> memberIds;
  final int tasksCount;
  final int completedTasksCount;
  final int membersCount;

  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.invitationCode,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
    this.memberIds = const [],
    this.tasksCount = 0,
    this.completedTasksCount = 0,
    this.membersCount = 0,
  });

  /// Check if a user is the owner of this project
  bool isOwner(String userId) => ownerId == userId;

  /// Calculate completion progress ratio from 0.0 to 1.0
  double get progressRatio {
    if (tasksCount == 0) return 0.0;
    return (completedTasksCount / tasksCount).clamp(0.0, 1.0);
  }

  /// Percentage completed (0 to 100)
  int get progressPercentage => (progressRatio * 100).round();

  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    String? invitationCode,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? memberIds,
    int? tasksCount,
    int? completedTasksCount,
    int? membersCount,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      invitationCode: invitationCode ?? this.invitationCode,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      memberIds: memberIds ?? this.memberIds,
      tasksCount: tasksCount ?? this.tasksCount,
      completedTasksCount: completedTasksCount ?? this.completedTasksCount,
      membersCount: membersCount ?? this.membersCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Project &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          ownerId == other.ownerId &&
          invitationCode == other.invitationCode &&
          status == other.status;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      ownerId.hashCode ^
      invitationCode.hashCode ^
      status.hashCode;
}
