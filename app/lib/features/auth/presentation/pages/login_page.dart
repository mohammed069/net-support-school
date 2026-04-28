import 'package:app/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/enums/request_status.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../shared/services/toast_service.dart';
import '../../../../shared/widgets/app_primary_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => context.push(AppRouter.settingsPath),
            icon: const Icon(Icons.settings_rounded),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorScheme.primaryContainer, colorScheme.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
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
                          context.go(AppRouter.roleSelectionPath);
                        }
                      },
                      builder: (context, state) {
                        return Column(
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
                              child: const Icon(Icons.school_rounded, size: 36),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              l10n.text('login_title'),
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.text('login_subtitle'),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 28),
                            AppTextField(
                              controller: _emailController,
                              label: l10n.text('email'),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _passwordController,
                              label: l10n.text('password'),
                              obscureText: true,
                            ),
                            const SizedBox(height: 20),
                            AppPrimaryButton(
                              label: l10n.text('sign_in'),
                              icon: Icons.login_rounded,
                              isLoading: state.status.isLoading,
                              onPressed: () {
                                context.read<AuthCubit>().signInWithEmail(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed:
                                  state.status.isLoading
                                      ? null
                                      : () {
                                        context
                                            .read<AuthCubit>()
                                            .signInWithGoogle();
                                      },
                              icon: const Icon(Icons.account_circle_outlined),
                              label: Text(l10n.text('sign_in_google')),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: TextButton(
                                onPressed:
                                    state.status.isLoading
                                        ? null
                                        : () {
                                          context.push(AppRouter.signUpPath);
                                        },
                                child: Text(l10n.text('dont_have_account')),
                              ),
                            ),
                          ],
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
