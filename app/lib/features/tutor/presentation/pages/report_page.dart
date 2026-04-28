import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/request_status.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../shared/services/toast_service.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../cubit/tutor_cubit.dart';
import '../cubit/tutor_state.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({
    super.key,
    required TutorCubit tutorCubit,
    required this.examId,
  }) : _tutorCubit = tutorCubit;

  final TutorCubit _tutorCubit;
  final String examId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _tutorCubit,
      child: _ReportView(examId: examId),
    );
  }
}

class _ReportView extends StatelessWidget {
  const _ReportView({required this.examId});

  final String examId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.text('full_report'))),
      body: BlocListener<TutorCubit, TutorState>(
        listener: (context, state) {
          if (state.status == RequestStatus.failure &&
              state.errorMessage != null) {
            ToastService.error(state.errorMessage!);
          }
        },
        child: BlocBuilder<TutorCubit, TutorState>(
          builder: (context, state) {
            if (state.status.isLoading && state.reports.isEmpty) {
              return const LoadingView();
            }

            if (examId.isEmpty) {
              return Center(child: Text(l10n.text('pick_exam_for_report')));
            }

            if (state.reports.isEmpty) {
              return EmptyStateView(
                title: l10n.text('reports'),
                message: l10n.text('empty_report'),
                icon: Icons.assessment_outlined,
              );
            }

            final totalScore = state.reports.fold<int>(
              0,
              (sum, report) => sum + report.score,
            );

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: l10n.text('students'),
                        value: state.reports.length.toString(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        title: l10n.text('score'),
                        value: totalScore.toString(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ...state.reports.map(
                  (report) => Card(
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
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 10),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }
}
