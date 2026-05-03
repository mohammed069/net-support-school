import '../../../auth/domain/entities/app_user.dart';
import '../entities/profile_params.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<AppUser> call(ProfileUpdateParams params) {
    return _repository.updateProfile(params);
  }
}

class ChangePasswordUseCase {
  const ChangePasswordUseCase(this._repository);

  final ProfileRepository _repository;

  Future<void> call(ChangePasswordParams params) {
    return _repository.changePassword(params);
  }
}
