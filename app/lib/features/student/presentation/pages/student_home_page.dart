import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/enums/request_status.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../shared/services/toast_service.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/student_cubit.dart';
import '../cubit/student_state.dart';
import '../widgets/lock_screen_view.dart';

class StudentHomePage extends StatelessWidget {
  const StudentHomePage({super.key, required StudentCubit studentCubit})
    : _studentCubit = studentCubit;

  final StudentCubit _studentCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _studentCubit,
      child: const _StudentHomeView(),
    );
  }
}

class _StudentHomeView extends StatelessWidget {
  const _StudentHomeView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final authUser = context.select((AuthCubit cubit) => cubit.state.user);

    return BlocListener<StudentCubit, StudentState>(
      listener: (context, state) {
        if (state.status == RequestStatus.failure &&
            state.errorMessage != null) {
          ToastService.error(state.errorMessage!);
        }

        final session = state.session;
        if (session != null &&
            session.hasActiveExam &&
            session.examStarted &&
            !session.hasSubmitted) {
          final examId = session.activeExamId!;
          final duration = session.examDurationMinutes ?? 0;
          context.go(
            '${AppRouter.examScreenPath}?examId=$examId&duration=$duration',
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.text('student_home')),
          actions: [
            IconButton(
              onPressed: () => context.read<AuthCubit>().signOut(),
              icon: const Icon(Icons.logout_rounded),
            ),
          ],
        ),
        body: BlocBuilder<StudentCubit, StudentState>(
          builder: (context, state) {
            if (state.status.isLoading && state.session == null) {
              return const LoadingView();
            }

            final session = state.session;
            if (session == null) {
              return Center(child: Text(l10n.text('login_required')));
            }

            final showLock = session.isLocked && !session.hasActiveExam;

            return Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0D7A72), Color(0xFF12A594)],
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l10n.text('welcome')}, ${authUser?.name ?? session.displayName}',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${l10n.text('current_role')}: ${l10n.text('student_role')}',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.text('active_exam'),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              session.activeExamTitle ??
                                  l10n.text('no_exam_assigned'),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                Chip(
                                  label: Text(
                                    '${l10n.text('status')}: ${session.currentStatus}',
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    '${l10n.text('remaining_time')}: ${session.examDurationMinutes ?? 0} min',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.text('live_tracking'),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 12),
                            Text(l10n.text('tracking_hint')),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (showLock)
                  LockScreenView(
                    title: l10n.text('screen_locked_title'),
                    message: l10n.text('screen_locked_message'),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
