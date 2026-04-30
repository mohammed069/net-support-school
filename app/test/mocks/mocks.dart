import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:app/features/auth/domain/usecases/auth_usecases.dart';
import 'package:app/features/exam/data/datasources/exam_remote_data_source.dart';
import 'package:app/features/exam/domain/repositories/exam_repository.dart';
import 'package:app/features/student/data/datasources/student_remote_data_source.dart';
import 'package:app/features/student/domain/repositories/student_repository.dart';
import 'package:app/features/tutor/data/datasources/tutor_remote_data_source.dart';
import 'package:app/features/tutor/domain/repositories/tutor_repository.dart';

// Firebase Mocks
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock {}

class MockGoogleSignInAuthentication extends Mock {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {
  @override
  String get uid => 'test-user-id';

  @override
  String? get email => 'test@example.com';

  @override
  String? get displayName => 'Test User';

  @override
  String? get photoURL => null;
}

// Firestore sealed classes - use generic Mock instead
class MockCollectionReference extends Mock {}

class MockDocumentReference extends Mock {}

class MockDocumentSnapshot extends Mock {}

class MockQuerySnapshot extends Mock {}

class MockQuery extends Mock {}

// Data Source Mocks
class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockStudentRemoteDataSource extends Mock
    implements StudentRemoteDataSource {}

class MockTutorRemoteDataSource extends Mock implements TutorRemoteDataSource {}

class MockExamRemoteDataSource extends Mock implements ExamRemoteDataSource {}

// Repository Mocks
class MockAuthRepository extends Mock implements AuthRepository {}

class MockStudentRepository extends Mock implements StudentRepository {}

class MockTutorRepository extends Mock implements TutorRepository {}

class MockExamRepository extends Mock implements ExamRepository {}

// Use Case Mocks
class MockWatchAuthenticatedUserUseCase extends Mock
    implements WatchAuthenticatedUserUseCase {}

class MockSignUpWithEmailUseCase extends Mock
    implements SignUpWithEmailUseCase {}

class MockSignInWithEmailUseCase extends Mock
    implements SignInWithEmailUseCase {}

class MockSignInWithGoogleUseCase extends Mock
    implements SignInWithGoogleUseCase {}

class MockSaveUserRoleUseCase extends Mock implements SaveUserRoleUseCase {}

class MockSignOutUseCase extends Mock implements SignOutUseCase {}
