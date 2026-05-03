import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/enums/request_status.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../shared/services/toast_service.dart';
import '../../../../shared/widgets/app_primary_button.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/profile_params.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  Uint8List? _photoBytes;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    super.dispose();
  }

  void _syncUser(AuthState authState) {
    if (_initialized || authState.user == null) {
      return;
    }

    final user = authState.user!;
    _nameController.text = user.name;
    _emailController.text = user.email;
    _initialized = true;
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1400,
    );
    if (file == null) {
      return;
    }

    final bytes = await file.readAsBytes();
    if (!mounted) {
      return;
    }

    setState(() {
      _photoBytes = bytes;
    });
  }

  bool _isEmailChanged(AuthState authState) {
    final user = authState.user;
    if (user == null) {
      return false;
    }
    return _emailController.text.trim() != user.email.trim();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final authState = context.watch<AuthCubit>().state;
    _syncUser(authState);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.text('edit_profile'))),
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
                ToastService.success(l10n.text('profile_saved'));
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRouter.profilePath);
                }
              }
            },
            builder: (context, state) {
              final user = authState.user;
              if (user == null) {
                return const LoadingView();
              }

              ImageProvider<Object>? avatarImage;
              if (_photoBytes != null) {
                avatarImage = MemoryImage(_photoBytes!);
              } else if (user.photoUrl != null && user.photoUrl!.isNotEmpty) {
                avatarImage = NetworkImage(user.photoUrl!);
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.text('profile_overview'),
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(l10n.text('profile_subtitle')),
                              const SizedBox(height: 24),
                              Center(
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 52,
                                      backgroundColor:
                                          colorScheme.primaryContainer,
                                      backgroundImage: avatarImage,
                                      child:
                                          avatarImage == null
                                              ? Text(
                                                user.name.isNotEmpty
                                                    ? user.name[0].toUpperCase()
                                                    : '?',
                                                style:
                                                    Theme.of(
                                                      context,
                                                    ).textTheme.headlineMedium,
                                              )
                                              : null,
                                    ),
                                    const SizedBox(height: 12),
                                    OutlinedButton.icon(
                                      onPressed:
                                          state.status.isLoading
                                              ? null
                                              : _pickPhoto,
                                      icon: const Icon(
                                        Icons.photo_camera_rounded,
                                      ),
                                      label: Text(l10n.text('pick_photo')),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      l10n.text('photo_hint'),
                                      textAlign: TextAlign.center,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: l10n.text('name'),
                                ),
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
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: l10n.text('email'),
                                  helperText: l10n.text(
                                    'current_password_note',
                                  ),
                                ),
                                validator: (value) {
                                  final email = (value ?? '').trim();
                                  if (email.isEmpty) {
                                    return l10n.text(
                                      'validation_email_required',
                                    );
                                  }
                                  if (!email.contains('@')) {
                                    return l10n.text(
                                      'validation_email_invalid',
                                    );
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _currentPasswordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: l10n.text('current_password'),
                                  helperText: l10n.text(
                                    'current_password_note',
                                  ),
                                ),
                                validator: (value) {
                                  if (_isEmailChanged(authState) &&
                                      (value ?? '').trim().isEmpty) {
                                    return l10n.text(
                                      'validation_current_password_required',
                                    );
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              AppPrimaryButton(
                                label: l10n.text('save_changes'),
                                icon: Icons.save_rounded,
                                isLoading: state.status.isLoading,
                                onPressed: () {
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }

                                  context.read<ProfileCubit>().updateProfile(
                                    ProfileUpdateParams(
                                      name: _nameController.text.trim(),
                                      email: _emailController.text.trim(),
                                      currentPassword:
                                          _isEmailChanged(authState)
                                              ? _currentPasswordController.text
                                                  .trim()
                                              : null,
                                      photoBytes: _photoBytes,
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
