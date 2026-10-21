// ignore_for_file: scoped_providers_should_specify_dependencies
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/l10n/app_localizations.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/auth/data/fake_auth_repository.dart';
import 'package:sarqyt/src/features/business_console/presentation/settings_screen.dart';

Future<FakeAuthRepository> _signedInFakeAuth() async {
  final fakeAuth = FakeAuthRepository(addDelay: false);
  await fakeAuth.createUserWithEmailAndPassword('owner@store.com', 'password1');
  return fakeAuth;
}

Widget _buildSubject(AuthRepository authRepo) {
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(authRepo)],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: const Scaffold(body: AccountSettingsContent()),
    ),
  );
}

void main() {
  group('AccountSettingsContent', () {
    testWidgets('shows the signed-in user email', (tester) async {
      final fakeAuth = await _signedInFakeAuth();
      await tester.pumpWidget(_buildSubject(fakeAuth));
      await tester.pumpAndSettle();

      expect(find.text('owner@store.com'), findsOneWidget);
    });

    testWidgets('sign out requires confirmation, then calls signOut', (
      tester,
    ) async {
      final fakeAuth = await _signedInFakeAuth();
      await tester.pumpWidget(_buildSubject(fakeAuth));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();

      // Confirmation dialog blocks the call until confirmed.
      expect(fakeAuth.signOutCalled, isFalse);
      expect(find.text('Are you sure?'), findsOneWidget);

      await tester.tap(find.text('Log out').last);
      await tester.pumpAndSettle();

      expect(fakeAuth.signOutCalled, isTrue);
    });

    testWidgets('dismissing the sign-out confirmation does not sign out', (
      tester,
    ) async {
      final fakeAuth = await _signedInFakeAuth();
      await tester.pumpWidget(_buildSubject(fakeAuth));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(fakeAuth.signOutCalled, isFalse);
    });
  });
}
