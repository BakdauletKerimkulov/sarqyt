import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Build flavor configuration', () {
    test('no default entry point is left behind', () {
      // Deliberate tripwire, not a tautology: while `lib/main.dart` existed,
      // `flutter build` without `-t` silently produced the business app —
      // blocker 4 in ai_docs/RELEASE_READINESS.md. Its absence is the only
      // thing forcing every build command to name its target out loud.
      expect(
        File('lib/main.dart').existsSync(),
        isFalse,
        reason:
            'lib/main.dart is the default target: recreating it makes an '
            'unflagged `flutter build` silently pick one of the two apps. '
            'Use lib/main_business.dart or lib/main_client.dart instead.',
      );
    });

    test('each entry point declares its own push audience', () {
      // The two builds share one Firebase user, so PushAudience is what keeps
      // them from overwriting each other's FCM token on `users/{uid}`.
      // Swapping these two values compiles and ships: the failure only
      // surfaces later, as pushes arriving in the wrong app.
      const entryPoints = {
        'lib/main_business.dart': 'PushAudience.business',
        'lib/main_client.dart': 'PushAudience.client',
      };

      for (final MapEntry(key: path, value: audience) in entryPoints.entries) {
        final file = File(path);
        expect(
          file.existsSync(),
          isTrue,
          reason: '$path is a build target named by CI and .vscode/launch.json',
        );
        expect(
          file.readAsStringSync(),
          contains(audience),
          reason: '$path must bootstrap its container with $audience',
        );
      }
    });
  });
}
