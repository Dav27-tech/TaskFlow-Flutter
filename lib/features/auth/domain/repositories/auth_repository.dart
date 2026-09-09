abstract class AuthRepository {
  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  });

  Future<void> login({required String email, required String password});
}
