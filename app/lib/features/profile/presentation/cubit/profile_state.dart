import 'package:equatable/equatable.dart';

import '../../../../core/enums/request_status.dart';
import '../../../auth/domain/entities/app_user.dart';

class ProfileState extends Equatable {
  const ProfileState({
    this.status = RequestStatus.initial,
    this.user,
    this.errorMessage,
  });

  final RequestStatus status;
  final AppUser? user;
  final String? errorMessage;

  ProfileState copyWith({
    RequestStatus? status,
    Object? user = _noUserChange,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: identical(user, _noUserChange) ? this.user : user as AppUser?,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}

const Object _noUserChange = Object();
