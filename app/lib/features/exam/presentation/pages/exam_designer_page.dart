import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/request_status.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../shared/services/toast_service.dart';
import '../../../../shared/widgets/app_primary_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../cubit/exam_cubit.dart';
import '../cubit/exam_state.dart';

class ExamDesignerPage extends StatelessWidget {
  const ExamDesignerPage({
    super.key,
    required ExamCubit examCubit,
    required this.currentUserId,
    this.initialExamId,
  }) : _examCubit = examCubit;

  final ExamCubit _examCubit;
  final String currentUserId;
  final String? initialExamId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _examCubit,
      child: _ExamDesignerView(
        currentUserId: currentUserId,
        initialExamId: initialExamId,
      ),
    );
  }
}

class _ExamDesignerView extends StatefulWidget {
  const _ExamDesignerView({required this.currentUserId, this.initialExamId});

  final String currentUserId;
  final String? initialExamId;

  @override
  State<_ExamDesignerView> createState() => _ExamDesignerViewState();
}

class _ExamDesignerViewState extends State<_ExamDesignerView> {
  @override
  void initState() {
    super.initState();
    if (widget.initialExamId != null && widget.initialExamId!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ExamCubit>().loadExamDetails(widget.initialExamId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.text('exam_designer'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            () => showCreateExamSheet(
              context,
              currentUserId: widget.currentUserId,
            ),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.text('create_exam')),
      ),
      body: BlocConsumer<ExamCubit, ExamState>(
        listener: (context, state) {
          if (state.status == RequestStatus.failure &&
              state.errorMessage != null) {
            ToastService.error(state.errorMessage!);
          }
          if (state.successMessage == 'exam_created') {
            ToastService.success(l10n.text('success_exam_created'));
          }
          if (state.successMessage == 'question_added') {
            ToastService.success(l10n.text('success_question_added'));
          }
        },
        builder: (context, state) {
          if (state.status.isLoading && state.exams.isEmpty) {
            return const LoadingView();
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 920;
              final examList = _ExamList(
                exams: state.exams,
                selectedExamId: state.examDetails?.exam.id,
                onSelect: (examId) {
                  context.read<ExamCubit>().loadExamDetails(examId);
                },
              );
              final details = _ExamDetailsPanel(
                state: state,
                onAddQuestion: () => _showAddQuestionDialog(context),
              );

              if (isWide) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(flex: 4, child: examList),
                      const SizedBox(width: 18),
                      Expanded(flex: 5, child: details),
                    ],
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  SizedBox(height: 320, child: examList),
                  const SizedBox(height: 18),
                  details,
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showAddQuestionDialog(BuildContext context) async {
    final state = context.read<ExamCubit>().state;
    final examId = state.examDetails?.exam.id;
    if (examId == null) {
      return;
    }

    final l10n = context.l10n;
    final questionController = TextEditingController();
    final correctAnswerController = TextEditingController();
    final wrongAnswerControllers = List.generate(
      3,
      (_) => TextEditingController(),
    );

    Future<void> saveQuestion({required bool keepDialogOpen}) async {
      final question = questionController.text.trim();
      final correctAnswer = correctAnswerController.text.trim();
      final wrongAnswers =
          wrongAnswerControllers
              .map((controller) => controller.text.trim())
              .toList();

      if (question.isEmpty ||
          correctAnswer.isEmpty ||
          wrongAnswers.any((answer) => answer.isEmpty)) {
        ToastService.error(l10n.text('validation_question_required'));
        return;
      }

      final shuffledOptions = _shuffleQuestionOptions(
        correctAnswer: correctAnswer,
        wrongAnswers: wrongAnswers,
      );

      await context.read<ExamCubit>().addQuestion(
        examId: examId,
        question: question,
        options: shuffledOptions.options,
        correctAnswerIndex: shuffledOptions.correctAnswerIndex,
      );

      if (!context.mounted) {
        return;
      }

      if (!keepDialogOpen) {
        Navigator.of(context).pop();
        return;
      }

      questionController.clear();
      correctAnswerController.clear();
      for (final controller in wrongAnswerControllers) {
        controller.clear();
      }
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setModalState) {
            return AlertDialog(
              title: Text(l10n.text('add_mcq')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      controller: questionController,
                      label: l10n.text('question'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: correctAnswerController,
                      label: l10n.text('correct_answer'),
                    ),
                    const SizedBox(height: 12),
                    for (
                      var index = 0;
                      index < wrongAnswerControllers.length;
                      index++
                    )
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppTextField(
                          controller: wrongAnswerControllers[index],
                          label: '${l10n.text('wrong_answer')} ${index + 1}',
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.text('cancel')),
                ),
                TextButton(
                  onPressed: () async {
                    await saveQuestion(keepDialogOpen: true);
                  },
                  child: Text(l10n.text('save_add_another')),
                ),
                FilledButton(
                  onPressed: () async {
                    await saveQuestion(keepDialogOpen: false);
                  },
                  child: Text(l10n.text('save')),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

Future<void> showCreateExamSheet(
  BuildContext context, {
  required String currentUserId,
}) async {
  final l10n = context.l10n;
  final examCubit = context.read<ExamCubit>();
  final labels = _CreateExamSheetLabels(
    examTitle: l10n.text('exam_title'),
    examDescription: l10n.text('exam_description'),
    durationMinutes: l10n.text('duration_minutes'),
    question: l10n.text('question'),
    correctAnswer: l10n.text('correct_answer'),
    wrongAnswer: l10n.text('wrong_answer'),
    addMoreQuestion: l10n.text('add_more_question'),
    save: l10n.text('save'),
    validationExamRequired: l10n.text('validation_exam_required'),
    validationQuestionRequired: l10n.text('validation_question_required'),
  );

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder:
        (_) => _CreateExamSheet(
          currentUserId: currentUserId,
          examCubit: examCubit,
          labels: labels,
        ),
  );
}

class _CreateExamSheet extends StatefulWidget {
  const _CreateExamSheet({
    required this.currentUserId,
    required this.examCubit,
    required this.labels,
  });

  final String currentUserId;
  final ExamCubit examCubit;
  final _CreateExamSheetLabels labels;

  @override
  State<_CreateExamSheet> createState() => _CreateExamSheetState();
}

class _CreateExamSheetLabels {
  const _CreateExamSheetLabels({
    required this.examTitle,
    required this.examDescription,
    required this.durationMinutes,
    required this.question,
    required this.correctAnswer,
    required this.wrongAnswer,
    required this.addMoreQuestion,
    required this.save,
    required this.validationExamRequired,
    required this.validationQuestionRequired,
  });

  final String examTitle;
  final String examDescription;
  final String durationMinutes;
  final String question;
  final String correctAnswer;
  final String wrongAnswer;
  final String addMoreQuestion;
  final String save;
  final String validationExamRequired;
  final String validationQuestionRequired;
}

class _CreateExamSheetState extends State<_CreateExamSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController(text: '30');
  final _questionControllers = [_QuestionDraftControllers()];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    for (final controller in _questionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addQuestion() {
    setState(() {
      _questionControllers.add(_QuestionDraftControllers());
    });
  }

  void _removeQuestion(int index) {
    final removed = _questionControllers[index];
    setState(() {
      _questionControllers.removeAt(index);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      removed.dispose();
    });
  }

  void _save() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ToastService.error(widget.labels.validationExamRequired);
      return;
    }

    final questions =
        <({String question, List<String> options, int correctAnswerIndex})>[];

    for (final controller in _questionControllers) {
      final question = controller.question.text.trim();
      final correctAnswer = controller.correctAnswer.text.trim();
      final wrongAnswers =
          controller.wrongAnswers.map((field) => field.text.trim()).toList();

      if (question.isEmpty ||
          correctAnswer.isEmpty ||
          wrongAnswers.any((answer) => answer.isEmpty)) {
        ToastService.error(widget.labels.validationQuestionRequired);
        return;
      }

      final shuffledOptions = _shuffleQuestionOptions(
        correctAnswer: correctAnswer,
        wrongAnswers: wrongAnswers,
      );
      questions.add((
        question: question,
        options: shuffledOptions.options,
        correctAnswerIndex: shuffledOptions.correctAnswerIndex,
      ));
    }

    widget.examCubit.createExam(
      title: title,
      description: description,
      durationMinutes: int.tryParse(_durationController.text.trim()) ?? 30,
      createdBy: widget.currentUserId,
      initialQuestions: questions,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final labels = widget.labels;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(controller: _titleController, label: labels.examTitle),
            const SizedBox(height: 12),
            AppTextField(
              controller: _descriptionController,
              label: labels.examDescription,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _durationController,
              label: labels.durationMinutes,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            for (
              var questionIndex = 0;
              questionIndex < _questionControllers.length;
              questionIndex++
            ) ...[
              _QuestionDraftFields(
                index: questionIndex,
                controllers: _questionControllers[questionIndex],
                labels: labels,
                canRemove: _questionControllers.length > 1,
                onRemove: () => _removeQuestion(questionIndex),
              ),
              const SizedBox(height: 16),
            ],
            OutlinedButton.icon(
              onPressed: _addQuestion,
              icon: const Icon(Icons.add_rounded),
              label: Text(labels.addMoreQuestion),
            ),
            const SizedBox(height: 16),
            AppPrimaryButton(
              label: labels.save,
              icon: Icons.check_rounded,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionDraftFields extends StatelessWidget {
  const _QuestionDraftFields({
    required this.index,
    required this.controllers,
    required this.labels,
    required this.canRemove,
    required this.onRemove,
  });

  final int index;
  final _QuestionDraftControllers controllers;
  final _CreateExamSheetLabels labels;
  final bool canRemove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${labels.question} ${index + 1}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (canRemove)
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
          ],
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: controllers.question,
          label: labels.question,
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: controllers.correctAnswer,
          label: labels.correctAnswer,
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < controllers.wrongAnswers.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppTextField(
              controller: controllers.wrongAnswers[index],
              label: '${labels.wrongAnswer} ${index + 1}',
            ),
          ),
      ],
    );
  }
}

class _QuestionDraftControllers {
  _QuestionDraftControllers()
    : wrongAnswers = List.generate(3, (_) => TextEditingController());

  final question = TextEditingController();
  final correctAnswer = TextEditingController();
  final List<TextEditingController> wrongAnswers;

  void dispose() {
    question.dispose();
    correctAnswer.dispose();
    for (final controller in wrongAnswers) {
      controller.dispose();
    }
  }
}

({List<String> options, int correctAnswerIndex}) _shuffleQuestionOptions({
  required String correctAnswer,
  required List<String> wrongAnswers,
}) {
  final shuffledOptions = [
    ({'text': correctAnswer, 'isCorrect': true}),
    for (final answer in wrongAnswers) ({'text': answer, 'isCorrect': false}),
  ]..shuffle(Random());

  return (
    options: shuffledOptions
        .map((option) => option['text'] as String)
        .toList(growable: false),
    correctAnswerIndex: shuffledOptions.indexWhere(
      (option) => option['isCorrect'] as bool,
    ),
  );
}

class _ExamList extends StatelessWidget {
  const _ExamList({
    required this.exams,
    required this.selectedExamId,
    required this.onSelect,
  });

  final List<dynamic> exams;
  final String? selectedExamId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (exams.isEmpty) {
      return EmptyStateView(
        title: l10n.text('no_exams'),
        message: l10n.text('create_first_exam'),
        icon: Icons.quiz_outlined,
      );
    }

    return Card(
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: exams.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final exam = exams[index];
          final isSelected = selectedExamId == exam.id;
          return InkWell(
            onTap: () => onSelect(exam.id),
            borderRadius: BorderRadius.circular(20),
            child: Ink(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exam.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exam.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(label: Text('${exam.durationMinutes} min')),
                      Chip(
                        label: Text(
                          exam.isActive
                              ? l10n.text('active')
                              : l10n.text('inactive'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ExamDetailsPanel extends StatelessWidget {
  const _ExamDetailsPanel({required this.state, required this.onAddQuestion});

  final ExamState state;
  final VoidCallback onAddQuestion;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final details = state.examDetails;

    if (details == null) {
      return EmptyStateView(
        title: l10n.text('exam_designer'),
        message: l10n.text('select_exam'),
        icon: Icons.design_services_outlined,
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        details.exam.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(details.exam.description),
                    ],
                  ),
                ),
                AppPrimaryButton(
                  label: l10n.text('add_question'),
                  icon: Icons.add_rounded,
                  onPressed: onAddQuestion,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              l10n.text('question_bank'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (state.status.isLoading && details.questions.isEmpty)
              const SizedBox(height: 240, child: LoadingView())
            else if (details.questions.isEmpty)
              SizedBox(
                height: 240,
                child: EmptyStateView(
                  title: l10n.text('question_bank'),
                  message: l10n.text('add_question'),
                  icon: Icons.help_outline_rounded,
                ),
              )
            else
              SizedBox(
                height: 420,
                child: ListView.separated(
                  itemCount: details.questions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final question = details.questions[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${index + 1}. ${question.question}',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 10),
                          for (
                            var optionIndex = 0;
                            optionIndex < question.options.length;
                            optionIndex++
                          )
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                '${optionIndex + 1}) ${question.options[optionIndex]}'
                                '${optionIndex == question.correctAnswerIndex ? ' (${l10n.text('correct_answer')})' : ''}',
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
