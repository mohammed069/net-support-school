import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/enums/request_status.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../shared/services/toast_service.dart';
import '../../../../shared/widgets/app_primary_button.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../student/presentation/cubit/student_cubit.dart';
import '../../../student/presentation/cubit/student_state.dart';
import '../../../student/presentation/widgets/lock_screen_view.dart';
import '../cubit/exam_cubit.dart';
import '../cubit/exam_state.dart';

class ExamScreenPage extends StatelessWidget {
  const ExamScreenPage({
    super.key,
    required StudentCubit studentCubit,
    required ExamCubit examCubit,
  }) : _studentCubit = studentCubit,
       _examCubit = examCubit;

  final StudentCubit _studentCubit;
  final ExamCubit _examCubit;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _studentCubit),
        BlocProvider.value(value: _examCubit),
      ],
      child: const _ExamScreenView(),
    );
  }
}

class _ExamScreenView extends StatelessWidget {
  const _ExamScreenView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final authUser = context.select((AuthCubit cubit) => cubit.state.user);

    return BlocListener<ExamCubit, ExamState>(
      listener: (context, state) {
        if (state.status == RequestStatus.failure &&
            state.errorMessage != null) {
          ToastService.error(state.errorMessage!);
        }
        if (state.successMessage == 'exam_ready') {
          ToastService.success(l10n.text('exam_ready'));
        }
        if (state.successMessage == 'answers_submitted') {
          ToastService.success(l10n.text('success_answers_submitted'));
          context.go(AppRouter.studentHomePath);
        }
        if (state.successMessage == 'auto_submitted') {
          ToastService.warning(l10n.text('auto_submitted'));
          context.go(AppRouter.studentHomePath);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(l10n.text('active_exam')),
        ),
        body: BlocBuilder<ExamCubit, ExamState>(
          builder: (context, examState) {
            if (examState.status.isLoading && examState.examDetails == null) {
              return const LoadingView();
            }

            final details = examState.examDetails;
            if (details == null) {
              return Center(child: Text(l10n.text('no_exam_assigned')));
            }

            if (details.questions.isEmpty) {
              return EmptyStateView(
                title: l10n.text('active_exam'),
                message: l10n.text('no_questions_available'),
                icon: Icons.quiz_outlined,
              );
            }

            return BlocBuilder<StudentCubit, StudentState>(
              builder: (context, studentState) {
                final session = studentState.session;
                final isLocked = session?.isLocked ?? false;

                return Stack(
                  children: [
                    ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        details.exam.title,
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.headlineSmall,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(details.exam.description),
                                    ],
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    '${l10n.text('remaining_time')}: ${examState.formattedRemainingTime}',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        for (
                          var index = 0;
                          index < details.questions.length;
                          index++
                        ) ...[
                          _QuestionCard(
                            index: index,
                            questionId: details.questions[index].id,
                            question: details.questions[index].question,
                            options: details.questions[index].options,
                            selectedAnswer:
                                examState.selectedAnswers[details
                                    .questions[index]
                                    .id],
                            onChanged: (value) {
                              context.read<ExamCubit>().selectAnswer(
                                questionId: details.questions[index].id,
                                answerIndex: value,
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                        AppPrimaryButton(
                          label: l10n.text('submit_answers'),
                          icon: Icons.send_rounded,
                          isLoading: examState.status.isLoading,
                          onPressed: () {
                            if (examState.selectedAnswers.length <
                                details.questions.length) {
                              ToastService.error(
                                l10n.text('answer_all_questions'),
                              );
                              return;
                            }

                            context.read<ExamCubit>().submitAnswers(
                              studentId: authUser!.id,
                              studentName: authUser.name,
                              autoSubmitted: false,
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                    if (isLocked)
                      LockScreenView(
                        title: l10n.text('screen_locked_title'),
                        message: l10n.text('screen_locked_message'),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.index,
    required this.questionId,
    required this.question,
    required this.options,
    required this.selectedAnswer,
    required this.onChanged,
  });

  final int index;
  final String questionId;
  final String question;
  final List<String> options;
  final int? selectedAnswer;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${index + 1}. $question',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            for (
              var optionIndex = 0;
              optionIndex < options.length;
              optionIndex++
            )
              RadioListTile<int>(
                value: optionIndex,
                groupValue: selectedAnswer,
                onChanged: (value) => onChanged(value ?? 0),
                contentPadding: EdgeInsets.zero,
                title: Text(options[optionIndex]),
              ),
          ],
        ),
      ),
    );
  }
}
