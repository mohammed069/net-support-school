import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/request_status.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/usecases/auth_usecases.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required WatchAuthenticatedUserUseCase watchAuthenticatedUserUseCase,
    required SignUpWithEmailUseCase signUpWithEmailUseCase,
    required SignInWithEmailUseCase signInWithEmailUseCase,
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required SaveUserRoleUseCase saveUserRoleUseCase,
    required SignOutUseCase signOutUseCase,
  }) : _watchAuthenticatedUserUseCase = watchAuthenticatedUserUseCase,
       _signUpWithEmailUseCase = signUpWithEmailUseCase,
       _signInWithEmailUseCase = signInWithEmailUseCase,
       _signInWithGoogleUseCase = signInWithGoogleUseCase,
       _saveUserRoleUseCase = saveUserRoleUseCase,
       _signOutUseCase = signOutUseCase,
       super(const AuthState());

  final WatchAuthenticatedUserUseCase _watchAuthenticatedUserUseCase;
  final SignUpWithEmailUseCase _signUpWithEmailUseCase;
  final SignInWithEmailUseCase _signInWithEmailUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SaveUserRoleUseCase _saveUserRoleUseCase;
  final SignOutUseCase _signOutUseCase;

  StreamSubscription<AppUser?>? _authSubscription;

  void startListening() {
    _authSubscription?.cancel();
    _authSubscription = _watchAuthenticatedUserUseCase().listen(
      (user) {
        emit(
          state.copyWith(
            status:
                user == null ? RequestStatus.initial : RequestStatus.success,
            user: user,
            clearError: true,
          ),
        );
      },
      onError: (error) {
        emit(
          state.copyWith(
            status: RequestStatus.failure,
            errorMessage: error.toString(),
          ),
        );
      },
    );
  }

  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      emit(state.copyWith(status: RequestStatus.loading, clearError: true));
      final createdUser = await _signUpWithEmailUseCase(
        name: name,
        email: email,
        password: password,
      );
      // debug log: created user from signup usecase
      // ignore: avoid_print
      print('AuthCubit: signUpWithEmail success -> $createdUser');
      emit(
        state.copyWith(
          status: RequestStatus.success,
          user: createdUser,
          clearError: true,
        ),
      );
    } catch (error) {
      // debug log: signup error
      // ignore: avoid_print
      print('AuthCubit: signUpWithEmail error -> $error');
      emit(
        state.copyWith(
          status: RequestStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      emit(state.copyWith(status: RequestStatus.loading, clearError: true));
      await _signInWithEmailUseCase(email: email, password: password);
      emit(state.copyWith(status: RequestStatus.success));
    } catch (error) {
      emit(
        state.copyWith(
          status: RequestStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      emit(state.copyWith(status: RequestStatus.loading, clearError: true));
      await _signInWithGoogleUseCase();
    } catch (error) {
      emit(
        state.copyWith(
          status: RequestStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> saveRole(UserRole role) async {
    try {
      emit(state.copyWith(status: RequestStatus.loading, clearError: true));
      await _saveUserRoleUseCase(role);
    } catch (error) {
      emit(
        state.copyWith(
          status: RequestStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> signOut() async {
    await _signOutUseCase();
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }
}
