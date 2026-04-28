import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/entities/app_user.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/role_selection_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/exam/presentation/cubit/exam_cubit.dart';
import '../../features/exam/presentation/pages/exam_designer_page.dart';
import '../../features/exam/presentation/pages/exam_screen_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/student/presentation/cubit/student_cubit.dart';
import '../../features/student/presentation/pages/student_home_page.dart';
import '../../features/tutor/presentation/cubit/tutor_cubit.dart';
import '../../features/tutor/presentation/pages/report_page.dart';
import '../../features/tutor/presentation/pages/tutor_dashboard_page.dart';
import '../di/injection_container.dart';
import '../utils/go_router_refresh_stream.dart';

class AppRouter {
  AppRouter(this._authCubit);

  static const loginPath = '/login';
  static const signUpPath = '/sign-up';
  static const roleSelectionPath = '/role-selection';
  static const studentHomePath = '/student-home';
  static const tutorDashboardPath = '/tutor-dashboard';
  static const examScreenPath = '/exam-screen';
  static const reportPath = '/report';
  static const examDesignerPath = '/exam-designer';
  static const settingsPath = '/settings';

  final AuthCubit _authCubit;

  late final GoRouter router = GoRouter(
    initialLocation: loginPath,
    refreshListenable: GoRouterRefreshStream(_authCubit.stream),
    redirect: _redirect,
    routes: [
      GoRoute(path: loginPath, builder: (context, state) => const LoginPage()),
      GoRoute(
        path: signUpPath,
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: roleSelectionPath,
        builder: (context, state) => const RoleSelectionPage(),
      ),
      GoRoute(
        path: settingsPath,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: studentHomePath,
        builder: (context, state) {
          final user = _authCubit.state.user;
          if (user == null) return const SizedBox.shrink();
          final studentCubit = getIt<StudentCubit>()..startListening(user.id);
          return StudentHomePage(studentCubit: studentCubit);
        },
      ),
      GoRoute(
        path: tutorDashboardPath,
        builder:
            (context, state) => TutorDashboardPage(
              tutorCubit: getIt<TutorCubit>()..startListening(),
              examCubit: getIt<ExamCubit>()..watchExams(),
            ),
      ),
      GoRoute(
        path: examDesignerPath,
        builder: (context, state) {
          final user = _authCubit.state.user;
          if (user == null) return const SizedBox.shrink();
          return ExamDesignerPage(
            examCubit: getIt<ExamCubit>()..watchExams(),
            currentUserId: user.id,
            initialExamId: state.uri.queryParameters['examId'],
          );
        },
      ),
      GoRoute(
        path: examScreenPath,
        builder: (context, state) {
          final user = _authCubit.state.user;
          if (user == null) return const SizedBox.shrink();
          final studentCubit = getIt<StudentCubit>()..startListening(user.id);
          final examCubit =
              getIt<ExamCubit>()..initializeExam(
                examId: state.uri.queryParameters['examId'] ?? '',
                durationMinutes:
                    int.tryParse(state.uri.queryParameters['duration'] ?? '') ??
                    0,
                studentId: user.id,
                studentName: user.name,
              );
          return ExamScreenPage(
            studentCubit: studentCubit,
            examCubit: examCubit,
          );
        },
      ),
      GoRoute(
        path: reportPath,
        builder:
            (context, state) => ReportPage(
              tutorCubit:
                  getIt<TutorCubit>()
                    ..loadReports(state.uri.queryParameters['examId'] ?? ''),
              examId: state.uri.queryParameters['examId'] ?? '',
            ),
      ),
    ],
  );

  String? _redirect(BuildContext context, GoRouterState state) {
    final user = _authCubit.state.user;
    final location = state.matchedLocation;

    if (location == settingsPath) {
      return null;
    }

    if (user == null) {
      return location == loginPath || location == signUpPath ? null : loginPath;
    }

    if (user.role == UserRole.unknown) {
      return location == roleSelectionPath ? null : roleSelectionPath;
    }

    final isStudentRoute =
        location == studentHomePath || location == examScreenPath;
    final isTutorRoute =
        location == tutorDashboardPath ||
        location == reportPath ||
        location == examDesignerPath;

    if (user.role == UserRole.student) {
      if (location == loginPath ||
          location == signUpPath ||
          location == roleSelectionPath) {
        return studentHomePath;
      }
      if (isTutorRoute) {
        return studentHomePath;
      }
    }

    if (user.role == UserRole.tutor) {
      if (location == loginPath ||
          location == signUpPath ||
          location == roleSelectionPath) {
        return tutorDashboardPath;
      }
      if (isStudentRoute) {
        return tutorDashboardPath;
      }
    }

    return null;
  }
}
