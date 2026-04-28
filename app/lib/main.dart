import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection_container.dart';
import 'core/services/firebase_bootstrap.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseBootstrap.initialize();
  await configureDependencies();

  final authCubit = getIt<AuthCubit>()..startListening();
  runApp(MyApp(authCubit: authCubit));
}
