import 'dart:async';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<AppUser> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) {
    return _remoteDataSource.signUpWithEmail(
      name: name,
      email: email,
      password: password,
    );
  }

  @override
  Stream<AppUser?> watchAuthUser() {
    late final StreamController<AppUser?> controller;
    StreamSubscription<dynamic>? authSubscription;
    StreamSubscription<dynamic>? profileSubscription;

    controller = StreamController<AppUser?>.broadcast(
      onListen: () {
        authSubscription = _remoteDataSource.authStateChanges().listen((
          firebaseUser,
        ) async {
          await profileSubscription?.cancel();

          if (firebaseUser == null) {
            controller.add(null);
            return;
          }


          await _remoteDataSource.ensureUserDocument(firebaseUser);
          profileSubscription = _remoteDataSource
              .watchUserProfile(firebaseUser.uid)
              .listen((profile) {
                controller.add(profile);
              });
        }, onError: controller.addError);
      },
      onCancel: () async {
        await profileSubscription?.cancel();
        await authSubscription?.cancel();
      },
    );

    return controller.stream;
  }

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _remoteDataSource.signInWithEmail(email: email, password: password);
  }

  @override
  Future<void> signInWithGoogle() => _remoteDataSource.signInWithGoogle();

  @override
  Future<void> saveRole(UserRole role) => _remoteDataSource.saveRole(role);

  @override
  Future<void> signOut() => _remoteDataSource.signOut();
}
