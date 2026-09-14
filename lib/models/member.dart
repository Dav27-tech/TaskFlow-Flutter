class Member {
  final String id;
  final String name;
  final String? avatarUrl;
  final String initials;
  final int avatarColorValue;

  const Member({
    required this.id,
    required this.name,
    required this.initials,
    required this.avatarColorValue,
    this.avatarUrl,
  });
}
