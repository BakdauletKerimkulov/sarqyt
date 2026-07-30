import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/src/features/store/domain/store_ship.dart';

StoreShip _ship({required StoreRole role, bool welcomeCompleted = false}) {
  return StoreShip(
    storeId: 'store-1',
    businessId: 'biz-1',
    userId: 'uid-1',
    permissions: const [],
    name: 'Test Store',
    role: role,
    welcomeCompleted: welcomeCompleted,
  );
}

void main() {
  group('StoreShipListX.pendingWelcome', () {
    test('returns owner with welcomeCompleted: false', () {
      final ships = [_ship(role: StoreRole.owner, welcomeCompleted: false)];
      expect(ships.pendingWelcome, isNotNull);
      expect(ships.pendingWelcome!.role, StoreRole.owner);
    });

    test('returns null for employee with welcomeCompleted: false', () {
      final ships = [_ship(role: StoreRole.employer, welcomeCompleted: false)];
      expect(ships.pendingWelcome, isNull);
    });

    test('returns null for operator with welcomeCompleted: false', () {
      final ships = [_ship(role: StoreRole.operator, welcomeCompleted: false)];
      expect(ships.pendingWelcome, isNull);
    });

    test('returns null when all ships are completed', () {
      final ships = [_ship(role: StoreRole.owner, welcomeCompleted: true)];
      expect(ships.pendingWelcome, isNull);
    });

    test('returns owner ship when mixed roles present', () {
      final ships = [
        _ship(role: StoreRole.employer, welcomeCompleted: false),
        _ship(role: StoreRole.owner, welcomeCompleted: false),
      ];
      expect(ships.pendingWelcome, isNotNull);
      expect(ships.pendingWelcome!.role, StoreRole.owner);
    });
  });
}
