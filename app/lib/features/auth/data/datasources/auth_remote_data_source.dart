import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../domain/entities/app_user.dart';
import '../models/app_user_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
  }) : _auth = auth,
       _firestore = firestore,
       _googleSignIn = googleSignIn;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<AppUserModel> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw Exception('Unable to create account.');
      }

      await user.updateDisplayName(name);
      await _firestore
          .collection(FirestoreCollections.users)
          .doc(user.uid)
          .set({
            'email': email,
            'name': name,
            'role': UserRole.unknown.value,
            'photoUrl': user.photoURL,
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      return AppUserModel(
        id: user.uid,
        email: email,
        name: name,
        role: UserRole.unknown,
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('The email is already in use. Try signing in instead.');
      }
      throw Exception(e.message ?? 'Authentication error: ${e.code}');
    }
  }

  Stream<AppUserModel?> watchUserProfile(String userId) {
    return _firestore
        .collection(FirestoreCollections.users)
        .doc(userId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) {
            return null;
          }
          final model = AppUserModel.fromFirestore(snapshot);

          return model;
        });
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google sign in was cancelled.');
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _auth.signInWithCredential(credential);
  }

  Future<void> ensureUserDocument(User user) async {
    final docRef = _firestore
        .collection(FirestoreCollections.users)
        .doc(user.uid);

    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      await docRef.set({
        'email': user.email ?? '',
        'name': user.displayName ?? 'New User',
        'role': UserRole.unknown.value,
        'photoUrl': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    await docRef.set({
      'email': user.email ?? '',
      'name': user.displayName ?? snapshot.data()?['name'] ?? 'User',
      'photoUrl': user.photoURL,
    }, SetOptions(merge: true));
  }

  Future<void> saveRole(UserRole role) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    await _firestore.collection(FirestoreCollections.users).doc(user.uid).set({
      'email': user.email ?? '',
      'name': user.displayName ?? 'User',
      'role': role.value,
      'photoUrl': user.photoURL,
    }, SetOptions(merge: true));

    await _firestore
        .collection(FirestoreCollections.students)
        .doc(user.uid)
        .set({
          'displayName': user.displayName ?? 'Student',
          'email': user.email ?? '',
          'photoUrl': user.photoURL,
          'role': role.value,
          'isLocked': false,
          'activeExamId': null,
          'activeExamTitle': null,
          'examStarted': false,
          'hasSubmitted': false,
          'currentStatus': 'idle',
          'examDurationMinutes': null,
          'examAssignedAt': null,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
