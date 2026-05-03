import 'package:app/core/router/app_router.dart';
import 'package:app/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OnboardingPage', () {
    testWidgets('shows onboarding content and skips to login', (
      WidgetTester tester,
    ) async {
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      final router = GoRouter(
        initialLocation: AppRouter.onboardingPath,
        routes: [
          GoRoute(
            path: AppRouter.onboardingPath,
            builder: (context, state) => const OnboardingPage(),
          ),
          GoRoute(
            path: AppRouter.loginPath,
            builder:
                (context, state) => const Scaffold(body: Text('Login Page')),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('Welcome'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.text('Login Page'), findsOneWidget);
    });
  });
}
