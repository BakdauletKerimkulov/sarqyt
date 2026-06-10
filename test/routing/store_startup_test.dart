import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/src/features/business_console/data/business_repository.dart';
import 'package:sarqyt/src/features/business_console/domain/business.dart';
import 'package:sarqyt/src/features/store/data/store_ship_repository.dart';
import 'package:sarqyt/src/features/store/domain/store_ship.dart';
import 'package:sarqyt/src/routing/store_startup.dart';

const _testShip = StoreShip(
  storeId: 'store-1',
  businessId: 'biz-1',
  userId: 'uid-1',
  permissions: [],
  name: 'Test Store',
  role: StoreRole.owner,
  welcomeCompleted: true,
);

final _testBusiness = Business(
  id: 'biz-1',
  ownerId: 'uid-1',
  name: 'Test Business',
  commissionRate: 0.15,
  createdAt: DateTime(2026),
);

void main() {
  group('storeStartupProvider', () {
    test(
      'returns StoreStartupData by reusing currentPartnerStoreShipsProvider',
      () async {
        final container = ProviderContainer(
          overrides: [
            // Provide storeShips via the keepAlive stream (already loaded by redirect).
            currentPartnerStoreShipsProvider
                .overrideWith((_) => Stream.value([_testShip])),
            // Provide a fake business repo that returns test business.
            businessRepositoryProvider.overrideWith(
              (_) => _FakeBusinessRepository(),
            ),
            // NOTE: storeShipsListStreamForPartnerProvider is NOT overridden.
            // If storeStartupProvider still subscribes to it, this test will
            // throw (missing storeShipRepositoryProvider dependency).
          ],
        );
        addTearDown(container.dispose);

        // Listen to keep the auto-dispose provider alive during the test.
        final completer = Completer<StoreStartupData>();
        container.listen(
          storeStartupProvider('store-1'),
          (_, next) {
            if (next is AsyncData<StoreStartupData> && !completer.isCompleted) {
              completer.complete(next.value);
            }
            if (next is AsyncError && !completer.isCompleted) {
              completer.completeError(next.error!, next.stackTrace);
            }
          },
          fireImmediately: true,
        );

        final result = await completer.future;

        expect(result.storeShip, _testShip);
        expect(result.business.id, 'biz-1');
        expect(result.business.name, 'Test Business');
      },
    );
  });
}

/// Fake that returns [_testBusiness] without hitting Firestore.
class _FakeBusinessRepository implements BusinessRepository {
  @override
  Future<Business?> fetchBusinessInfo(BusinessID id) async => _testBusiness;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
    'Unexpected call: ${invocation.memberName}',
  );
}
