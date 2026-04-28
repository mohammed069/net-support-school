import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/request_status.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../shared/services/toast_service.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../domain/entities/app_user.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = context.select((AuthCubit cubit) => cubit.state.user);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.text('choose_role')),
        actions: [
          TextButton(
            onPressed: () => context.read<AuthCubit>().signOut(),
            child: Text(l10n.text('logout')),
          ),
        ],
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == RequestStatus.failure &&
              state.errorMessage != null) {
            ToastService.error(state.errorMessage!);
          }
          if (state.status == RequestStatus.success &&
              state.user?.role != UserRole.unknown) {
            ToastService.success(l10n.text('success_role_saved'));
          }
        },
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, viewportConstraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight - 48,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 780),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${l10n.text('welcome')}, ${user?.name ?? ''}',
                            style: Theme.of(context).textTheme.headlineMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.text('choose_role_subtitle'),
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 28),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth > 700;
                              final studentCard = _RoleCard(
                                icon: Icons.person_rounded,
                                title: l10n.text('student_role'),
                                description:
                                    'Real-time exam notifications, lock screen control, and answer submission.',
                                onTap:
                                    () => context.read<AuthCubit>().saveRole(
                                      UserRole.student,
                                    ),
                              );
                              final tutorCard = _RoleCard(
                                icon: Icons.admin_panel_settings_rounded,
                                title: l10n.text('tutor_role'),
                                description:
                                    'Manage students, assign exams, monitor progress, and review reports.',
                                onTap:
                                    () => context.read<AuthCubit>().saveRole(
                                      UserRole.tutor,
                                    ),
                              );

                              if (isWide) {
                                return Row(
                                  children: [
                                    Expanded(child: studentCard),
                                    const SizedBox(width: 16),
                                    Expanded(child: tutorCard),
                                  ],
                                );
                              }

                              return Column(
                                children: [
                                  studentCard,
                                  const SizedBox(height: 16),
                                  tutorCard,
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Ink(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Colors.white,
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon),
            ),
            const SizedBox(height: 20),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Text(description, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
