import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/l10n/app_localizations.dart';
import 'package:sarqyt/src/features/offers/application/discover_filter.dart';
import 'package:sarqyt/src/features/offers/presentation/offer_list/discover_app_bar.dart';

Widget _buildSubject(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(appBar: DiscoverAppBar()),
    ),
  );
}

void main() {
  group('DiscoverAppBar search', () {
    testWidgets('search icon opens a text field', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      // discoverFilterControllerProvider is autoDispose; DiscoverAppBar
      // only ref.reads it in callbacks, never watches it. In the real app
      // DiscoverScreen's ref.watch keeps it alive — here we simulate that
      // with an explicit listener, otherwise it resets between reads.
      container.listen(discoverFilterControllerProvider, (_, _) {});
      await tester.pumpWidget(_buildSubject(container));

      expect(find.text('Discover'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('typing updates the filter after the debounce', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.listen(discoverFilterControllerProvider, (_, _) {});
      await tester.pumpWidget(_buildSubject(container));

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'croissant');

      // Not yet applied — still inside the debounce window.
      await tester.pump(const Duration(milliseconds: 100));
      expect(container.read(discoverFilterControllerProvider).searchQuery, '');

      await tester.pump(const Duration(milliseconds: 300));
      expect(
        container.read(discoverFilterControllerProvider).searchQuery,
        'croissant',
      );
    });

    testWidgets('back button closes search and clears the query', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.listen(discoverFilterControllerProvider, (_, _) {});
      await tester.pumpWidget(_buildSubject(container));

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'bag');
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        container.read(discoverFilterControllerProvider).searchQuery,
        'bag',
      );

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      expect(find.byType(TextField), findsNothing);
      expect(container.read(discoverFilterControllerProvider).searchQuery, '');
    });
  });
}
