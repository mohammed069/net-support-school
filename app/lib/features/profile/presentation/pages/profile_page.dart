import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.text('profile'))),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorScheme.primaryContainer, colorScheme.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final user = state.user;
              if (user == null) {
                return const LoadingView();
              }

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _ProfileHeader(user: user),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.text('account_details'),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          _DetailRow(
                            icon: Icons.badge_outlined,
                            label: l10n.text('name'),
                            value: user.name,
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            icon: Icons.email_outlined,
                            label: l10n.text('email_sign_in'),
                            value: user.email,
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            icon: Icons.verified_user_outlined,
                            label: l10n.text('current_role'),
                            value: user.role.name,
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            icon: Icons.event_available_outlined,
                            label: l10n.text('member_since'),
                            value: l10n.formatDateTime(user.createdAt),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.edit_rounded),
                          title: Text(l10n.text('edit_profile')),
                          subtitle: Text(l10n.text('profile_overview')),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => context.push(AppRouter.editProfilePath),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.lock_reset_rounded),
                          title: Text(l10n.text('change_password')),
                          subtitle: Text(l10n.text('security')),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap:
                              () => context.push(AppRouter.changePasswordPath),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: colorScheme.primaryContainer,
              backgroundImage:
                  user.photoUrl != null && user.photoUrl!.isNotEmpty
                      ? NetworkImage(user.photoUrl!)
                      : null,
              child:
                  user.photoUrl == null || user.photoUrl!.isEmpty
                      ? Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: theme.textTheme.headlineMedium,
                      )
                      : null,
            ),
            const SizedBox(height: 16),
            Text(user.name, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(user.email, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                Chip(
                  avatar: const Icon(Icons.badge_outlined, size: 18),
                  label: Text(user.role.name),
                ),
                Chip(
                  avatar: const Icon(Icons.verified_outlined, size: 18),
                  label: Text(l10n.text('account_summary')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(value, style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}
