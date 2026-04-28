import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/localization/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/settings/app_settings_controller.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key, required AuthCubit authCubit})
    : _authCubit = authCubit,
      _router = AppRouter(authCubit),
      _settingsController = AppSettingsController();

  final AuthCubit _authCubit;
  final AppRouter _router;
  final AppSettingsController _settingsController;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authCubit,
      child: AppSettingsScope(
        controller: _settingsController,
        child: AnimatedBuilder(
          animation: _settingsController,
          builder: (context, _) {
            return MaterialApp.router(
              title: 'NetSupport School',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: _settingsController.themeMode,
              locale: _settingsController.locale,
              routerConfig: _router.router,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
            );
          },
        ),
      ),
    );
  }
}
