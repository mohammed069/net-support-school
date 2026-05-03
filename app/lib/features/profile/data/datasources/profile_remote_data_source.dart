import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../auth/data/models/app_user_model.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/profile_params.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  }) : _auth = auth,
       _firestore = firestore,
       _storage = storage;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  Future<AppUserModel> updateProfile(ProfileUpdateParams params) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    final name = params.name.trim();
    final email = params.email.trim();
    final currentEmail = user.email ?? '';
    final shouldUpdateEmail = email.isNotEmpty && email != currentEmail;
    String? photoUrl = user.photoURL;

    if (shouldUpdateEmail) {
      final currentPassword = params.currentPassword?.trim();
      if (currentPassword == null || currentPassword.isEmpty) {
        throw Exception('Current password is required to change email.');
      }

      if (currentEmail.isEmpty) {
        throw Exception('This account does not support email changes.');
      }

      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(
          email: currentEmail,
          password: currentPassword,
        ),
      );
      // Keep the immediate email change path so Firestore and auth stay in sync.
      // ignore: deprecated_member_use
      await user.updateEmail(email);
    }

    if (name.isNotEmpty && name != (user.displayName ?? '')) {
      await user.updateDisplayName(name);
    }

    if (params.photoBytes != null) {
      photoUrl = await _uploadAvatar(user.uid, params.photoBytes!);
      await user.updatePhotoURL(photoUrl);
    }

    await user.reload();

    final docRef = _firestore
        .collection(FirestoreCollections.users)
        .doc(user.uid);
    final snapshot = await docRef.get();
    final existingData = snapshot.data() ?? <String, dynamic>{};

    await docRef.set({
      'email': _auth.currentUser?.email ?? email,
      'name': _auth.currentUser?.displayName ?? name,
      'role': existingData['role'] ?? UserRole.unknown.value,
      'photoUrl': photoUrl,
      'createdAt': existingData['createdAt'] ?? FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final updatedSnapshot = await docRef.get();
    return AppUserModel.fromFirestore(updatedSnapshot);
  }

  Future<void> changePassword(ChangePasswordParams params) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    final email = user.email;
    if (email == null || email.isEmpty) {
      throw Exception('This account does not support password changes.');
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: params.currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(params.newPassword);
  }

  Future<String> _uploadAvatar(String userId, Uint8List bytes) async {
    final ref = _storage.ref().child('users/$userId/avatar.jpg');
    await ref.putData(bytes);
    return ref.getDownloadURL();
  }
}
