import 'package:app/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/enums/request_status.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../shared/services/toast_service.dart';
import '../../../../shared/widgets/app_primary_button.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE7F7F4), Color(0xFFF8FBFC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: BlocConsumer<AuthCubit, AuthState>(
                      listener: (context, state) {
                        if (state.status == RequestStatus.failure &&
                            state.errorMessage != null) {
                          ToastService.error(state.errorMessage!);
                        }
                        if (state.status == RequestStatus.success &&
                            state.user != null) {
                          ToastService.success(
                            l10n.text('success_account_created'),
                          );
                          if (!context.mounted) return;
                          // debug log to help diagnose navigation issues
                          // ignore: avoid_print
                          print(
                            'Auth: signup success — navigating to role selection',
                          );
                          // debug: rely on router redirect to send user to role selection
                          // ignore: avoid_print
                          print(
                            'Auth: signup success — emitted user, router should redirect',
                          );
                          // Navigation is handled by AppRouter.redirect using AuthCubit's state.
                        }
                      },
                      builder: (context, state) {
                        return Form(
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
                                  Icons.person_add_alt_1_rounded,
                                  size: 36,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                l10n.text('sign_up_title'),
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.text('sign_up_subtitle'),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 28),
                              _AuthFormField(
                                controller: _nameController,
                                label: l10n.text('name'),
                                validator: (value) {
                                  if ((value ?? '').trim().isEmpty) {
                                    return l10n.text(
                                      'validation_name_required',
                                    );
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _AuthFormField(
                                controller: _emailController,
                                label: l10n.text('email'),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if ((value ?? '').trim().isEmpty) {
                                    return l10n.text(
                                      'validation_email_required',
                                    );
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _AuthFormField(
                                controller: _passwordController,
                                label: l10n.text('password'),
                                obscureText: true,
                                validator: (value) {
                                  if ((value ?? '').isEmpty) {
                                    return l10n.text(
                                      'validation_password_required',
                                    );
                                  }
                                  if ((value ?? '').length < 6) {
                                    return l10n.text(
                                      'validation_password_length',
                                    );
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _AuthFormField(
                                controller: _confirmPasswordController,
                                label: l10n.text('confirm_password'),
                                obscureText: true,
                                validator: (value) {
                                  if ((value ?? '').isEmpty) {
                                    return l10n.text(
                                      'validation_confirm_password_required',
                                    );
                                  }
                                  if (value != _passwordController.text) {
                                    return l10n.text(
                                      'validation_password_mismatch',
                                    );
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              AppPrimaryButton(
                                label: l10n.text('create_account'),
                                icon: Icons.app_registration_rounded,
                                isLoading: state.status.isLoading,
                                onPressed: () {
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }

                                  // debug: user tapped create account
                                  // ignore: avoid_print
                                  print('SignUpPage: create_account pressed');
                                  context.read<AuthCubit>().signUpWithEmail(
                                    name: _nameController.text.trim(),
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text.trim(),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              Center(
                                child: TextButton(
                                  onPressed:
                                      state.status.isLoading
                                          ? null
                                          : () {
                                            context.go(AppRouter.loginPath);
                                          },
                                  child: Text(
                                    l10n.text('already_have_account'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthFormField extends StatelessWidget {
  const _AuthFormField({
    required this.controller,
    required this.label,
    required this.validator,
    this.keyboardType,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(labelText: label),
    );
  }
}
