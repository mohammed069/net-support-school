import 'package:app/core/enums/request_status.dart';
import 'package:app/features/profile/domain/entities/profile_params.dart';
import 'package:app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:app/features/profile/presentation/cubit/profile_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/auth_fixtures.dart';
import '../../../../mocks/mocks.dart';

void main() {
  group('ProfileCubit', () {
    late MockUpdateProfileUseCase mockUpdateProfileUseCase;
    late MockChangePasswordUseCase mockChangePasswordUseCase;
    late ProfileCubit profileCubit;

    setUp(() {
      mockUpdateProfileUseCase = MockUpdateProfileUseCase();
      mockChangePasswordUseCase = MockChangePasswordUseCase();
      profileCubit = ProfileCubit(
        updateProfileUseCase: mockUpdateProfileUseCase,
        changePasswordUseCase: mockChangePasswordUseCase,
      );

      registerFallbackValue(
        const ProfileUpdateParams(name: '', email: ''),
      );
      registerFallbackValue(
        const ChangePasswordParams(currentPassword: '', newPassword: ''),
      );
    });

    tearDown(() async {
      await profileCubit.close();
    });

    test('initial state should be idle with no user', () {
      expect(
        profileCubit.state,
        const ProfileState(
          status: RequestStatus.initial,
          user: null,
          errorMessage: null,
        ),
      );
    });

    blocTest<ProfileCubit, ProfileState>(
      'updateProfile emits loading then success with updated user',
      build: () {
        when(
          () => mockUpdateProfileUseCase(any()),
        ).thenAnswer((_) async => AuthFixtures.sampleAppUser);
        return profileCubit;
      },
      act:
          (cubit) => cubit.updateProfile(
            const ProfileUpdateParams(
              name: AuthFixtures.testName,
              email: AuthFixtures.testEmail,
            ),
          ),
      expect:
          () => [
            isA<ProfileState>().having(
              (state) => state.status,
              'status',
              RequestStatus.loading,
            ),
            isA<ProfileState>()
                .having((state) => state.status, 'status', RequestStatus.success)
                .having((state) => state.user, 'user', AuthFixtures.sampleAppUser)
                .having((state) => state.errorMessage, 'errorMessage', null),
          ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'changePassword emits loading then failure when the use case throws',
      build: () {
        when(
          () => mockChangePasswordUseCase(any()),
        ).thenThrow(Exception('Password update failed'));
        return profileCubit;
      },
      act:
          (cubit) => cubit.changePassword(
            const ChangePasswordParams(
              currentPassword: AuthFixtures.testPassword,
              newPassword: 'newPassword123',
            ),
          ),
      expect:
          () => [
            isA<ProfileState>().having(
              (state) => state.status,
              'status',
              RequestStatus.loading,
            ),
            isA<ProfileState>()
                .having((state) => state.status, 'status', RequestStatus.failure)
                .having(
                  (state) => state.errorMessage,
                  'errorMessage',
                  contains('Password update failed'),
                ),
          ],
    );
  });
}
