import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/src/firebase_functions_provider.dart';

void main() {
  group('Cloud Functions region', () {
    test('kFunctionsRegion still points at the deployed region', () {
      // Deliberate tripwire, not a tautology: the client region may only
      // change together with the functions deploy (047 Phase 2). Failing here
      // is the reminder that the two must ship in the same change.
      expect(kFunctionsRegion, 'us-central1');
    });

    test('nothing reaches for the default FirebaseFunctions instance', () {
      // The SDK default is pinned to us-central1, so one direct use left
      // behind survives the region migration and fails at runtime with
      // not-found. `instanceFor(region:)` is the sanctioned call and must not
      // match.
      final directInstance = RegExp(r'FirebaseFunctions\.instance(?!For)');
      final commentLine = RegExp(r'^\s*(///?|\*|/\*)');
      final offenders = <String>[];

      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        // Generated output only ever echoes the sources scanned here —
        // codegen copies doc comments verbatim.
        if (entity.path.endsWith('.g.dart') ||
            entity.path.endsWith('.freezed.dart')) {
          continue;
        }

        // Comments are stripped rather than whole files excluded: the file
        // holding the sanctioned provider must stay under the check too.
        final code = entity
            .readAsLinesSync()
            .where((line) => !commentLine.hasMatch(line))
            .join('\n');

        if (directInstance.hasMatch(code)) offenders.add(entity.path);
      }

      expect(
        offenders,
        isEmpty,
        reason:
            'Obtain FirebaseFunctions from firebaseFunctionsProvider instead, '
            'so the region is defined in exactly one place.',
      );
    });
  });
}
