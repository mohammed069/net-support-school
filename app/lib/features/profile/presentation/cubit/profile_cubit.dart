import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/request_status.dart';
import '../../domain/entities/profile_params.dart';
import '../../domain/usecases/profile_usecases.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required UpdateProfileUseCase updateProfileUseCase,
    required ChangePasswordUseCase changePasswordUseCase,
  }) : _updateProfileUseCase = updateProfileUseCase,
       _changePasswordUseCase = changePasswordUseCase,
       super(const ProfileState());

  final UpdateProfileUseCase _updateProfileUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;

  Future<void> updateProfile(ProfileUpdateParams params) async {
    try {
      emit(state.copyWith(status: RequestStatus.loading, clearError: true));
      final user = await _updateProfileUseCase(params);
      emit(
        state.copyWith(
          status: RequestStatus.success,
          user: user,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: RequestStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> changePassword(ChangePasswordParams params) async {
    try {
      emit(state.copyWith(status: RequestStatus.loading, clearError: true));
      await _changePasswordUseCase(params);
      emit(state.copyWith(status: RequestStatus.success, clearError: true));
    } catch (error) {
      emit(
        state.copyWith(
          status: RequestStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
