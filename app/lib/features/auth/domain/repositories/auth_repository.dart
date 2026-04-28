import '../entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> watchAuthUser();

  Future<AppUser> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  });

  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> signInWithGoogle();

  Future<void> saveRole(UserRole role);

  Future<void> signOut();
}
