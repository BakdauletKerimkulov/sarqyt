import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/src/features/orders/data/orders_repository.dart';
import 'package:sarqyt/src/features/orders/domain/order.dart';

class FakeStoreOrdersRepository extends Fake
    implements StoreOrdersRepository {
  StreamController<List<Order>>? itemStreamController;
  StreamController<List<Order>>? storeStreamController;

  @override
  Stream<List<Order>> watchOrdersListForItem(String storeId, String itemId) {
    return itemStreamController!.stream;
  }

  @override
  Stream<List<Order>> watchOrdersListForStore(String storeId) {
    return storeStreamController!.stream;
  }
}

void main() {
  late FakeStoreOrdersRepository fakeRepo;
  late StreamController<List<Order>> controller;

  setUp(() {
    fakeRepo = FakeStoreOrdersRepository();
    controller = StreamController<List<Order>>.broadcast();
  });

  tearDown(() {
    controller.close();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        ordersRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );
  }

  group('ordersListForItemStreamProvider cache', () {
    setUp(() {
      fakeRepo.itemStreamController = controller;
    });

    test(
        'retains AsyncData when last watcher is removed and re-added within 30s',
        () {
      fakeAsync((async) {
        final container = createContainer();
        addTearDown(container.dispose);

        // Subscribe
        final sub = container.listen(
          ordersListForItemStreamProvider('store1', 'item1'),
          (_, __) {},
        );

        // Emit data
        controller.add([]);
        async.flushMicrotasks();

        // Verify we have data
        final stateBeforeUnsub = container.read(
          ordersListForItemStreamProvider('store1', 'item1'),
        );
        expect(stateBeforeUnsub, isA<AsyncData<List<Order>>>());

        // Remove last watcher
        sub.close();

        // Advance 15s (within cache window)
        async.elapse(const Duration(seconds: 15));

        // Re-subscribe — should still have AsyncData, not AsyncLoading
        final sub2 = container.listen(
          ordersListForItemStreamProvider('store1', 'item1'),
          (_, __) {},
        );
        addTearDown(sub2.close);

        final stateAfterResub = container.read(
          ordersListForItemStreamProvider('store1', 'item1'),
        );
        expect(stateAfterResub, isA<AsyncData<List<Order>>>());
      });
    });

    test('disposes after 30s with no watchers', () {
      fakeAsync((async) {
        final container = createContainer();
        addTearDown(container.dispose);

        // Subscribe and emit data
        final sub = container.listen(
          ordersListForItemStreamProvider('store1', 'item1'),
          (_, __) {},
        );
        controller.add([]);
        async.flushMicrotasks();

        // Remove watcher
        sub.close();

        // Advance past 30s
        async.elapse(const Duration(seconds: 31));

        // Re-subscribe — should be fresh (AsyncLoading)
        final sub2 = container.listen(
          ordersListForItemStreamProvider('store1', 'item1'),
          (_, __) {},
        );
        addTearDown(sub2.close);

        final state = container.read(
          ordersListForItemStreamProvider('store1', 'item1'),
        );
        expect(state, isA<AsyncLoading<List<Order>>>());
      });
    });
  });

  group('ordersListStreamProvider cache', () {
    setUp(() {
      fakeRepo.storeStreamController = controller;
    });

    test(
        'retains AsyncData when last watcher is removed and re-added within 30s',
        () {
      fakeAsync((async) {
        final container = createContainer();
        addTearDown(container.dispose);

        // Subscribe
        final sub = container.listen(
          ordersListStreamProvider('store1'),
          (_, __) {},
        );

        // Emit data
        controller.add([]);
        async.flushMicrotasks();

        // Verify data
        final stateBeforeUnsub = container.read(
          ordersListStreamProvider('store1'),
        );
        expect(stateBeforeUnsub, isA<AsyncData<List<Order>>>());

        // Remove last watcher
        sub.close();

        // Advance 15s
        async.elapse(const Duration(seconds: 15));

        // Re-subscribe
        final sub2 = container.listen(
          ordersListStreamProvider('store1'),
          (_, __) {},
        );
        addTearDown(sub2.close);

        final stateAfterResub = container.read(
          ordersListStreamProvider('store1'),
        );
        expect(stateAfterResub, isA<AsyncData<List<Order>>>());
      });
    });
  });
}
