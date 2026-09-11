import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await remoteDataSource.register(
      email: email,
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception('Impossible de créer le compte.');
    }

    await remoteDataSource.createUserProfile(
      userId: user.uid,
      email: email,
      displayName: displayName,
    );
  }

  @override
  Future<void> login({required String email, required String password}) async {
    await remoteDataSource.login(email: email, password: password);
  }
}
