import '../../domain/entities/user_entity.dart';

class MockProfileRepository {
  Future<UserEntity> getUserProfile() async {
    // Simule un appel réseau
    await Future.delayed(const Duration(milliseconds: 500));

    return UserEntity(
      id: 'mock-user-001',
      fullName: 'James Wilson',
      email: 'james.wilson@example.com',
      photoUrl: null,
      memberSince: DateTime(2024, 5, 12),
      language: 'English (US)',
      timeZone: '(UTC+01:00) West Africa Time',
      isActive: true,
    );
  }
}