import '../../../auth/domain/entities/app_user.dart';
import '../entities/profile_params.dart';

abstract class ProfileRepository {
  Future<AppUser> updateProfile(ProfileUpdateParams params);

  Future<void> changePassword(ChangePasswordParams params);
}
