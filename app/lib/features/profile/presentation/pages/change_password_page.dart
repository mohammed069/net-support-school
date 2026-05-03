import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/enums/request_status.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../shared/services/toast_service.dart';
import '../../../../shared/widgets/app_primary_button.dart';
import '../../domain/entities/profile_params.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.text('change_password'))),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorScheme.primaryContainer, colorScheme.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<ProfileCubit, ProfileState>(
            listener: (context, state) {
              if (state.status == RequestStatus.failure &&
                  state.errorMessage != null) {
                ToastService.error(state.errorMessage!);
              }

              if (state.status == RequestStatus.success) {
                ToastService.success(l10n.text('password_saved'));
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRouter.profilePath);
                }
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 540),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: const Icon(
                                  Icons.lock_reset_rounded,
                                  size: 36,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                l10n.text('change_password'),
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(l10n.text('current_password_note')),
                              const SizedBox(height: 24),
                              TextFormField(
                                controller: _currentPasswordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: l10n.text('current_password'),
                                ),
                                validator: (value) {
                                  if ((value ?? '').trim().isEmpty) {
                                    return l10n.text(
                                      'validation_current_password_required',
                                    );
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _newPasswordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: l10n.text('new_password'),
                                ),
                                validator: (value) {
                                  final password = value ?? '';
                                  if (password.isEmpty) {
                                    return l10n.text(
                                      'validation_password_required',
                                    );
                                  }
                                  if (password.length < 6) {
                                    return l10n.text(
                                      'validation_password_length',
                                    );
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: l10n.text('confirm_password'),
                                ),
                                validator: (value) {
                                  if ((value ?? '').trim().isEmpty) {
                                    return l10n.text(
                                      'validation_confirm_password_required',
                                    );
                                  }
                                  if (value != _newPasswordController.text) {
                                    return l10n.text(
                                      'validation_password_mismatch',
                                    );
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              AppPrimaryButton(
                                label: l10n.text('change_password'),
                                icon: Icons.lock_reset_rounded,
                                isLoading: state.status.isLoading,
                                onPressed: () {
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }

                                  context.read<ProfileCubit>().changePassword(
                                    ChangePasswordParams(
                                      currentPassword:
                                          _currentPasswordController.text
                                              .trim(),
                                      newPassword:
                                          _newPasswordController.text.trim(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
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
