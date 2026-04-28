import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class WatchAuthenticatedUserUseCase {
  const WatchAuthenticatedUserUseCase(this._repository);

  final AuthRepository _repository;

  Stream<AppUser?> call() => _repository.watchAuthUser();
}

class SignUpWithEmailUseCase {
  const SignUpWithEmailUseCase(this._repository);

  final AuthRepository _repository;

  Future<AppUser> call({
    required String name,
    required String email,
    required String password,
  }) {
    return _repository.signUpWithEmail(
      name: name,
      email: email,
      password: password,
    );
  }
}

class SignInWithEmailUseCase {
  const SignInWithEmailUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String email, required String password}) {
    return _repository.signInWithEmail(email: email, password: password);
  }
}

class SignInWithGoogleUseCase {
  const SignInWithGoogleUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.signInWithGoogle();
}

class SaveUserRoleUseCase {
  const SaveUserRoleUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call(UserRole role) => _repository.saveRole(role);
}

class SignOutUseCase {
  const SignOutUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.signOut();
}
