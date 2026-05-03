import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/profile_params.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({required ProfileRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<AppUser> updateProfile(ProfileUpdateParams params) {
    return _remoteDataSource.updateProfile(params);
  }

  @override
  Future<void> changePassword(ChangePasswordParams params) {
    return _remoteDataSource.changePassword(params);
  }
}
