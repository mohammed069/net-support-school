import 'dart:typed_data';

class ProfileUpdateParams {
  const ProfileUpdateParams({
    required this.name,
    required this.email,
    this.currentPassword,
    this.photoBytes,
  });

  final String name;
  final String email;
  final String? currentPassword;
  final Uint8List? photoBytes;
}

class ChangePasswordParams {
  const ChangePasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });

  final String currentPassword;
  final String newPassword;
}
