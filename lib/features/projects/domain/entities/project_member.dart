class ProjectMember {
  final String userId;
  final String role; // 'owner' | 'member'
  final DateTime joinedAt;
  final String? displayName;
  final String? email;
  final String? photoUrl;

  const ProjectMember({
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.displayName,
    this.email,
    this.photoUrl,
  });

  bool get isOwner => role == 'owner';
  bool get isMember => role == 'member';

  String get displayTitle {
    if (displayName != null && displayName!.trim().isNotEmpty) {
      return displayName!;
    }
    if (email != null && email!.trim().isNotEmpty) {
      return email!.split('@').first;
    }
    return 'User ${userId.length > 5 ? userId.substring(0, 5) : userId}';
  }

  String get initials {
    final title = displayTitle.trim();
    if (title.isEmpty) return 'U';
    final parts = title.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return title.substring(0, title.length >= 2 ? 2 : 1).toUpperCase();
  }

  ProjectMember copyWith({
    String? userId,
    String? role,
    DateTime? joinedAt,
    String? displayName,
    String? email,
    String? photoUrl,
  }) {
    return ProjectMember(
      userId: userId ?? this.userId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectMember &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          role == other.role;

  @override
  int get hashCode => userId.hashCode ^ role.hashCode;
}
