class AppConstants {
  AppConstants._();

  // Firestore Collections
  static const String projectsCollection = 'projects';
  static const String membersSubcollection = 'members';
  static const String tasksSubcollection = 'tasks';
  static const String usersCollection = 'users';

  // Project Statuses
  static const String statusActive = 'active';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';
  static const String statusArchived = 'archived';

  // Member Roles
  static const String roleOwner = 'owner';
  static const String roleMember = 'member';

  // Invitation Code Format: TFMA-XXXX-XXXX
  static const String invitationCodePrefix = 'TFMA';
  static const int invitationCodeBlockLength = 4;
}
