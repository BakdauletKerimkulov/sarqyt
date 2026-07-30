import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/src/features/items/data/items_repository.dart';
import 'package:sarqyt/src/features/items/presentation/item_screen/settings_content_controller.dart';

void main() {
  group('SettingsContentController', () {
    test(
      'deleteItem does not throw when provider is disposed before future completes',
      () async {
        final deleteCompleter = Completer<void>();
        final fakeRepo = _FakeItemsRepository(deleteCompleter);

        final container = ProviderContainer(
          overrides: [itemsRepositoryProvider.overrideWithValue(fakeRepo)],
        );

        // Read the notifier to initialize it.
        final notifier = container.read(
          settingsContentControllerProvider.notifier,
        );

        // Start the delete — future is pending.
        final deleteFuture = notifier.deleteItem(
          storeId: 'store-1',
          itemId: 'item-1',
        );

        // Dispose the container (simulates navigating away while delete is
        // in flight).
        container.dispose();

        // Complete the Cloud Function future after disposal.
        deleteCompleter.complete();

        // This should NOT throw "Cannot use Ref after disposal".
        // Before the fix, this line throws.
        await expectLater(deleteFuture, completes);
      },
    );
  });
}

class _FakeItemsRepository implements ItemsRepository {
  _FakeItemsRepository(this._deleteCompleter);

  final Completer<void> _deleteCompleter;

  @override
  Future<void> deleteItem(String storeId, {required String id}) {
    return _deleteCompleter.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}
