class UserEntity {
  final String id;
  final String fullName;
  final String email;
  final String? photoUrl;
  final DateTime memberSince;
  final String language;
  final String timeZone;
  final bool isActive;

  const UserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    this.photoUrl,
    required this.memberSince,
    required this.language,
    required this.timeZone,
    required this.isActive,
  });
}