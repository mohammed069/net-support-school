import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/exam/data/datasources/exam_remote_data_source.dart';
import '../../features/exam/data/repositories/exam_repository_impl.dart';
import '../../features/exam/domain/repositories/exam_repository.dart';
import '../../features/exam/domain/usecases/exam_usecases.dart';
import '../../features/exam/presentation/cubit/exam_cubit.dart';
import '../../features/student/data/datasources/student_remote_data_source.dart';
import '../../features/student/data/repositories/student_repository_impl.dart';
import '../../features/student/domain/repositories/student_repository.dart';
import '../../features/student/domain/usecases/student_usecases.dart';
import '../../features/student/presentation/cubit/student_cubit.dart';
import '../../features/tutor/data/datasources/tutor_remote_data_source.dart';
import '../../features/tutor/data/repositories/tutor_repository_impl.dart';
import '../../features/tutor/domain/repositories/tutor_repository.dart';
import '../../features/tutor/domain/usecases/tutor_usecases.dart';
import '../../features/tutor/presentation/cubit/tutor_cubit.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  getIt
    ..registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance)
    ..registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance)
    ..registerLazySingleton<GoogleSignIn>(GoogleSignIn.new)
    ..registerLazySingleton(
      () => AuthRemoteDataSource(
        auth: getIt(),
        firestore: getIt(),
        googleSignIn: getIt(),
      ),
    )
    ..registerLazySingleton(() => StudentRemoteDataSource(firestore: getIt()))
    ..registerLazySingleton(() => TutorRemoteDataSource(firestore: getIt()))
    ..registerLazySingleton(() => ExamRemoteDataSource(firestore: getIt()))
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remoteDataSource: getIt()),
    )
    ..registerLazySingleton<StudentRepository>(
      () => StudentRepositoryImpl(remoteDataSource: getIt()),
    )
    ..registerLazySingleton<TutorRepository>(
      () => TutorRepositoryImpl(remoteDataSource: getIt()),
    )
    ..registerLazySingleton<ExamRepository>(
      () => ExamRepositoryImpl(remoteDataSource: getIt()),
    )
    ..registerLazySingleton(() => WatchAuthenticatedUserUseCase(getIt()))
    ..registerLazySingleton(() => SignUpWithEmailUseCase(getIt()))
    ..registerLazySingleton(() => SignInWithEmailUseCase(getIt()))
    ..registerLazySingleton(() => SignInWithGoogleUseCase(getIt()))
    ..registerLazySingleton(() => SaveUserRoleUseCase(getIt()))
    ..registerLazySingleton(() => SignOutUseCase(getIt()))
    ..registerLazySingleton(() => WatchStudentSessionUseCase(getIt()))
    ..registerLazySingleton(() => MarkExamStartedUseCase(getIt()))
    ..registerLazySingleton(() => SubmitExamAnswersUseCase(getIt()))
    ..registerLazySingleton(() => WatchStudentsUseCase(getIt()))
    ..registerLazySingleton(() => SetStudentLockUseCase(getIt()))
    ..registerLazySingleton(() => StartExamForStudentsUseCase(getIt()))
    ..registerLazySingleton(() => StopExamForStudentsUseCase(getIt()))
    ..registerLazySingleton(() => WatchExamReportsUseCase(getIt()))
    ..registerLazySingleton(() => WatchExamsUseCase(getIt()))
    ..registerLazySingleton(() => CreateExamUseCase(getIt()))
    ..registerLazySingleton(() => AddQuestionUseCase(getIt()))
    ..registerLazySingleton(() => LoadExamDetailsUseCase(getIt()))
    ..registerLazySingleton(
      () => AuthCubit(
        watchAuthenticatedUserUseCase: getIt(),
        signUpWithEmailUseCase: getIt(),
        signInWithEmailUseCase: getIt(),
        signInWithGoogleUseCase: getIt(),
        saveUserRoleUseCase: getIt(),
        signOutUseCase: getIt(),
      ),
    )
    ..registerFactory(() => StudentCubit(watchStudentSessionUseCase: getIt()))
    ..registerFactory(
      () => TutorCubit(
        watchStudentsUseCase: getIt(),
        setStudentLockUseCase: getIt(),
        startExamForStudentsUseCase: getIt(),
        stopExamForStudentsUseCase: getIt(),
        watchExamReportsUseCase: getIt(),
      ),
    )
    ..registerFactory(
      () => ExamCubit(
        watchExamsUseCase: getIt(),
        createExamUseCase: getIt(),
        addQuestionUseCase: getIt(),
        loadExamDetailsUseCase: getIt(),
        markExamStartedUseCase: getIt(),
        submitExamAnswersUseCase: getIt(),
      ),
    );
}
