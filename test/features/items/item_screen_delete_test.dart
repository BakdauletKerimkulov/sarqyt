import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/l10n/app_localizations.dart';
import 'package:sarqyt/src/features/items/data/items_repository.dart';
import 'package:sarqyt/src/features/items/domain/item.dart';
import 'package:sarqyt/src/features/items/domain/weekly_schedule.dart';
import 'package:sarqyt/src/features/items/presentation/item_screen/item_screen.dart';
import 'package:sarqyt/src/features/items/presentation/item_tab.dart';

final _testItem = Item(
  id: 'item-1',
  name: 'Test Bag',
  price: 1500,
  schedule: WeeklySchedule.defaultSchedule(),
);

void main() {
  group('ItemScreen delete navigation', () {
    testWidgets('calls context.pop when item stream emits null after data',
        (tester) async {
      // Start stream with the item already available (avoids Lottie loading)
      final streamController = StreamController<Item?>.broadcast();

      late final GoRouter router;
      router = GoRouter(
        initialLocation: '/item',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const Scaffold(body: Text('Items list')),
          ),
          GoRoute(
            path: '/item',
            builder: (_, __) => Scaffold(
              body: ItemScreen(
                itemId: 'item-1',
                storeId: 'store-1',
                initialTab: ItemTab.calendar,
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Use Stream.value for immediate data to skip loading state
            itemStreamProvider(id: 'item-1', storeId: 'store-1')
                .overrideWith((_) => Stream.value(_testItem)
                    .asyncExpand((item) async* {
                  yield item;
                  yield* streamController.stream;
                })),
          ],
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            routerConfig: router,
          ),
        ),
      );

      // Let the initial data settle
      await tester.pump();
      await tester.pump();
      expect(find.text('Calendar'), findsAny);

      // Emit null — item was deleted
      // context.pop() will throw GoError because /item has no parent to pop to
      // in this test setup — catching the error proves pop was called.
      streamController.add(null);
      await tester.pump();

      // Verify: GoRouter tried to pop (proves the ref.listen fired correctly).
      // In production, the route IS pushed, so pop succeeds.
      // Here we verify behavior by checking that the "No item found" text
      // does NOT stay — the screen reacted to the deletion.
      expect(
        tester.takeException(),
        isA<GoError>().having(
          (e) => e.toString(),
          'message',
          contains('nothing to pop'),
        ),
        reason: 'context.pop() should be called when item is deleted',
      );

      await streamController.close();
    });
  });
}
