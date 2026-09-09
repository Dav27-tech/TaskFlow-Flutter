import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.read(authRemoteDataSourceProvider),
  );
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.read(authRepositoryProvider));
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

final registerProvider = AsyncNotifierProvider<RegisterNotifier, void>(
  RegisterNotifier.new,
);

class RegisterNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() {
      return ref
          .read(registerUseCaseProvider)
          .call(email: email, password: password, displayName: displayName);
    });
  }
}

final loginProvider = AsyncNotifierProvider<LoginNotifier, void>(
  LoginNotifier.new,
);

class LoginNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() {
      return ref
          .read(loginUseCaseProvider)
          .call(email: email, password: password);
    });
  }
}
