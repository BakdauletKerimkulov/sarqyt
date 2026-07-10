import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/src/features/orders/data/orders_repository.dart';

void main() {
  test('ordersRepositoryProvider is keepAlive (not auto-dispose)', () {
    // Repository providers must be keepAlive per riverpod.md.
    // Auto-dispose causes stream re-subscription flickering in dependent providers.
    expect(ordersRepositoryProvider.isAutoDispose, isFalse);
  });
}
