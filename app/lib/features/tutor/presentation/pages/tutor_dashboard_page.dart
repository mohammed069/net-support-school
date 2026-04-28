import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/enums/request_status.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../shared/services/toast_service.dart';
import '../../../../shared/widgets/app_primary_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../exam/presentation/cubit/exam_cubit.dart';
import '../../../exam/presentation/cubit/exam_state.dart';
import '../../domain/entities/student_overview.dart';
import '../cubit/tutor_cubit.dart';
import '../cubit/tutor_state.dart';

class TutorDashboardPage extends StatelessWidget {
  const TutorDashboardPage({
    super.key,
    required TutorCubit tutorCubit,
    required ExamCubit examCubit,
  }) : _tutorCubit = tutorCubit,
       _examCubit = examCubit;

  final TutorCubit _tutorCubit;
  final ExamCubit _examCubit;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _tutorCubit),
        BlocProvider.value(value: _examCubit),
      ],
      child: const _TutorDashboardView(),
    );
  }
}

class _TutorDashboardView extends StatelessWidget {
  const _TutorDashboardView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.text('tutor_dashboard')),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.text('students')),
              Tab(text: l10n.text('exams')),
              Tab(text: l10n.text('reports')),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () => context.read<AuthCubit>().signOut(),
              icon: const Icon(Icons.logout_rounded),
            ),
          ],
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<TutorCubit, TutorState>(
              listener: (context, state) {
                if (state.status == RequestStatus.failure &&
                    state.errorMessage != null) {
                  ToastService.error(state.errorMessage!);
                }
                if (state.successMessage == 'student_locked') {
                  ToastService.success(l10n.text('success_locked'));
                } else if (state.successMessage == 'student_unlocked') {
                  ToastService.success(l10n.text('success_unlocked'));
                } else if (state.successMessage == 'exam_started') {
                  ToastService.success(l10n.text('success_exam_started'));
                } else if (state.successMessage == 'exam_stopped') {
                  ToastService.success(l10n.text('success_exam_stopped'));
                }
              },
            ),
            BlocListener<ExamCubit, ExamState>(
              listener: (context, state) {
                if (state.status == RequestStatus.failure &&
                    state.errorMessage != null) {
                  ToastService.error(state.errorMessage!);
                }
              },
            ),
          ],
          child: const TabBarView(
            children: [_StudentsTab(), _ExamsTab(), _ReportsTab()],
          ),
        ),
      ),
    );
  }
}

class _StudentsTab extends StatelessWidget {
  const _StudentsTab();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<TutorCubit, TutorState>(
      builder: (context, state) {
        if (state.status.isLoading && state.students.isEmpty) {
          return const LoadingView();
        }

        if (state.students.isEmpty) {
          return EmptyStateView(
            title: l10n.text('students'),
            message: l10n.text('no_students'),
            icon: Icons.group_outlined,
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: state.students.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final student = state.students[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      child: Text(
                        student.displayName.isNotEmpty
                            ? student.displayName[0].toUpperCase()
                            : 'S',
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.displayName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(student.email),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Chip(label: Text(student.currentStatus)),
                              if ((student.activeExamTitle ?? '').isNotEmpty)
                                Chip(label: Text(student.activeExamTitle!)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          student.isLocked
                              ? l10n.text('locked')
                              : l10n.text('unlocked'),
                        ),
                        Switch(
                          value: student.isLocked,
                          onChanged: (value) {
                            context.read<TutorCubit>().toggleStudentLock(
                              studentId: student.id,
                              isLocked: value,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ExamsTab extends StatelessWidget {
  const _ExamsTab();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<ExamCubit, ExamState>(
      builder: (context, examState) {
        if (examState.status.isLoading && examState.exams.isEmpty) {
          return const LoadingView();
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: AppPrimaryButton(
                      label: l10n.text('open_designer'),
                      icon: Icons.design_services_rounded,
                      onPressed: () => context.push(AppRouter.examDesignerPath),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child:
                  examState.exams.isEmpty
                      ? EmptyStateView(
                        title: l10n.text('no_exams'),
                        message: l10n.text('create_first_exam'),
                        icon: Icons.quiz_outlined,
                      )
                      : BlocBuilder<TutorCubit, TutorState>(
                        builder: (context, tutorState) {
                          return ListView.separated(
                            padding: const EdgeInsets.all(20),
                            itemCount: examState.exams.length,
                            separatorBuilder:
                                (_, _) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final exam = examState.exams[index];
                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              exam.title,
                                              style:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.titleLarge,
                                            ),
                                          ),
                                          Chip(
                                            label: Text(
                                              exam.isActive
                                                  ? l10n.text('active')
                                                  : l10n.text('inactive'),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(exam.description),
                                      const SizedBox(height: 14),
                                      Wrap(
                                        spacing: 10,
                                        runSpacing: 10,
                                        children: [
                                          AppPrimaryButton(
                                            label: l10n.text('start_exam'),
                                            icon: Icons.play_arrow_rounded,
                                            onPressed: () {
                                              _showAssignExamDialog(
                                                context,
                                                examId: exam.id,
                                                examTitle: exam.title,
                                                students: tutorState.students,
                                                defaultDuration:
                                                    exam.durationMinutes,
                                              );
                                            },
                                          ),
                                          OutlinedButton.icon(
                                            onPressed: () {
                                              context.push(
                                                '${AppRouter.examDesignerPath}?examId=${exam.id}',
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.edit_note_rounded,
                                            ),
                                            label: Text(
                                              l10n.text('edit_questions'),
                                            ),
                                          ),
                                          OutlinedButton.icon(
                                            onPressed:
                                                exam.isActive
                                                    ? () {
                                                      final targetedStudents =
                                                          tutorState.students
                                                              .where(
                                                                (student) =>
                                                                    student
                                                                        .activeExamId ==
                                                                    exam.id,
                                                              )
                                                              .map(
                                                                (student) =>
                                                                    student.id,
                                                              )
                                                              .toList();
                                                      context
                                                          .read<TutorCubit>()
                                                          .stopExam(
                                                            examId: exam.id,
                                                            studentIds:
                                                                targetedStudents,
                                                          );
                                                    }
                                                    : null,
                                            icon: const Icon(
                                              Icons.stop_circle_outlined,
                                            ),
                                            label: Text(l10n.text('stop_exam')),
                                          ),
                                          OutlinedButton.icon(
                                            onPressed: () {
                                              context.push(
                                                '${AppRouter.reportPath}?examId=${exam.id}',
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.assessment_outlined,
                                            ),
                                            label: Text(
                                              l10n.text('view_report'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAssignExamDialog(
    BuildContext context, {
    required String examId,
    required String examTitle,
    required List<StudentOverview> students,
    required int defaultDuration,
  }) async {
    final selectedIds = <String>{};
    final durationController = TextEditingController(
      text: defaultDuration.toString(),
    );
    final l10n = context.l10n;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (innerContext, setModalState) {
            return AlertDialog(
              title: Text(l10n.text('assign_exam')),
              content: SizedBox(
                width: 460,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        controller: durationController,
                        label: l10n.text('duration_minutes'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.text('select_students'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      for (final student in students)
                        CheckboxListTile(
                          value: selectedIds.contains(student.id),
                          contentPadding: EdgeInsets.zero,
                          title: Text(student.displayName),
                          subtitle: Text(student.email),
                          onChanged: (checked) {
                            setModalState(() {
                              if (checked ?? false) {
                                selectedIds.add(student.id);
                              } else {
                                selectedIds.remove(student.id);
                              }
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.text('cancel')),
                ),
                FilledButton(
                  onPressed: () {
                    context.read<TutorCubit>().startExam(
                      examId: examId,
                      examTitle: examTitle,
                      studentIds: selectedIds.toList(),
                      durationMinutes:
                          int.tryParse(durationController.text.trim()) ??
                          defaultDuration,
                    );
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(l10n.text('start_exam')),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ReportsTab extends StatelessWidget {
  const _ReportsTab();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: BlocBuilder<ExamCubit, ExamState>(
            builder: (context, examState) {
              if (examState.exams.isEmpty) {
                return Text(l10n.text('pick_exam_for_report'));
              }

              return DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: l10n.text('select_exam'),
                ),
                value: context.select(
                  (TutorCubit cubit) => cubit.state.selectedReportExamId,
                ),
                items:
                    examState.exams
                        .map(
                          (exam) => DropdownMenuItem<String>(
                            value: exam.id,
                            child: Text(exam.title),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  context.read<TutorCubit>().loadReports(value ?? '');
                },
              );
            },
          ),
        ),
        Expanded(
          child: BlocBuilder<TutorCubit, TutorState>(
            builder: (context, state) {
              if (state.status.isLoading && state.reports.isEmpty) {
                return const LoadingView();
              }

              if (state.selectedReportExamId == null) {
                return Center(child: Text(l10n.text('pick_exam_for_report')));
              }

              if (state.reports.isEmpty) {
                return EmptyStateView(
                  title: l10n.text('reports'),
                  message: l10n.text('empty_report'),
                  icon: Icons.assessment_outlined,
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: state.reports.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final report = state.reports[index];
                  return Card(
                    child: ListTile(
                      title: Text(report.studentName),
                      subtitle: Text(
                        '${l10n.text('answered')}: ${report.answeredQuestions}/${report.totalQuestions}',
                      ),
                      trailing: Text(
                        '${l10n.text('score')}: ${report.score}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
