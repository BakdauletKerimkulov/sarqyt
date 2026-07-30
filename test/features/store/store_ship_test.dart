import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/src/features/store/domain/store_ship.dart';

StoreShip _makeStoreShip({
  String storeId = 's1',
  bool welcomeCompleted = false,
  bool hasFirstItem = false,
}) {
  return StoreShip(
    storeId: storeId,
    businessId: 'b1',
    userId: 'u1',
    permissions: const ['read', 'write'],
    name: 'Store $storeId',
    role: StoreRole.owner,
    welcomeCompleted: welcomeCompleted,
    hasFirstItem: hasFirstItem,
  );
}

void main() {
  group('StoreShipListX', () {
    test('pendingWelcome returns first non-completed store', () {
      final list = [
        _makeStoreShip(storeId: 's1', welcomeCompleted: true),
        _makeStoreShip(storeId: 's2', welcomeCompleted: false),
        _makeStoreShip(storeId: 's3', welcomeCompleted: false),
      ];
      expect(list.pendingWelcome?.storeId, 's2');
    });

    test('pendingWelcome null when all completed', () {
      final list = [
        _makeStoreShip(storeId: 's1', welcomeCompleted: true),
        _makeStoreShip(storeId: 's2', welcomeCompleted: true),
      ];
      expect(list.pendingWelcome, isNull);
    });

    test('pendingWelcome null on empty list', () {
      final list = <StoreShip>[];
      expect(list.pendingWelcome, isNull);
    });

    test('defaultStoreId returns first welcome-completed store', () {
      final list = [
        _makeStoreShip(storeId: 's1', welcomeCompleted: false),
        _makeStoreShip(storeId: 's2', welcomeCompleted: true),
        _makeStoreShip(storeId: 's3', welcomeCompleted: true),
      ];
      expect(list.defaultStoreId, 's2');
    });

    test('defaultStoreId null when none completed', () {
      final list = [_makeStoreShip(storeId: 's1', welcomeCompleted: false)];
      expect(list.defaultStoreId, isNull);
    });

    test('hasActiveStores true when at least one completed', () {
      final list = [
        _makeStoreShip(storeId: 's1', welcomeCompleted: false),
        _makeStoreShip(storeId: 's2', welcomeCompleted: true),
      ];
      expect(list.hasActiveStores, true);
    });

    test('hasActiveStores false when none completed', () {
      final list = [_makeStoreShip(storeId: 's1', welcomeCompleted: false)];
      expect(list.hasActiveStores, false);
    });

    test('hasActiveStores false on empty list', () {
      final list = <StoreShip>[];
      expect(list.hasActiveStores, false);
    });
  });

  group('fromJson role fallback', () {
    test('reads role field directly', () {
      final ship = StoreShip.fromJson({
        'storeId': 's1',
        'businessId': 'b1',
        'userId': 'u1',
        'permissions': <String>['read'],
        'name': 'Test',
        'role': 'owner',
        'welcomeCompleted': true,
      });
      expect(ship.role, StoreRole.owner);
      expect(ship.welcomeCompleted, true);
    });

    test('falls back to storeRole for old docs', () {
      final ship = StoreShip.fromJson({
        'storeId': 's1',
        'businessId': 'b1',
        'userId': 'u1',
        'permissions': <String>['read'],
        'name': 'Test',
        'storeRole': 'operator',
        'welcomeCompleted': false,
      });
      expect(ship.role, StoreRole.operator);
    });
  });
}
