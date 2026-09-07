import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/mock_profile_repository.dart';
import '../../domain/entities/user_entity.dart';

final profileRepositoryProvider = Provider<MockProfileRepository>((ref) {
  return MockProfileRepository();
});

/// Permet de stocker une version modifiée localement (après Edit Profile)
/// en attendant la vraie intégration Firestore.
final mockProfileOverrideProvider = StateProvider<UserEntity?>((ref) => null);

final userProfileProvider = FutureProvider<UserEntity>((ref) async {
  final override = ref.watch(mockProfileOverrideProvider);
  if (override != null) return override;

  final repository = ref.watch(profileRepositoryProvider);
  return repository.getUserProfile();
});
