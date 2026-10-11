import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/auth/data/fake_auth_repository.dart';
import 'package:sarqyt/src/features/auth/presentation/forgot_password/forgot_password_controller.dart';

void main() {
  group('ForgotPasswordController', () {
    test(
      'submit sends reset email for a known user and returns true',
      () async {
        final fakeAuth = FakeAuthRepository(addDelay: false);
        // Register a user first so the fake accepts the email.
        await fakeAuth.createUserWithEmailAndPassword('a@b.com', 'password1');
        await fakeAuth.signOut();

        final container = ProviderContainer(
          overrides: [authRepositoryProvider.overrideWithValue(fakeAuth)],
        );
        addTearDown(container.dispose);

        final success = await container
            .read(forgotPasswordControllerProvider.notifier)
            .submit('a@b.com');

        expect(success, isTrue);
        expect(fakeAuth.sendPasswordResetEmailCalled, isTrue);
      },
    );

    test('submit returns false for an unknown email', () async {
      final fakeAuth = FakeAuthRepository(addDelay: false);
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(fakeAuth)],
      );
      addTearDown(container.dispose);

      final success = await container
          .read(forgotPasswordControllerProvider.notifier)
          .submit('unknown@nowhere.com');

      expect(success, isFalse);
    });
  });
}
