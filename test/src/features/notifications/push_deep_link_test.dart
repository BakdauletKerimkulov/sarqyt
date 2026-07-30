import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/src/features/notifications/application/push_deep_link.dart';
import 'package:sarqyt/src/features/notifications/domain/push_audience.dart';
import 'package:sarqyt/src/features/notifications/domain/push_deep_link_target.dart';
import 'package:sarqyt/src/routing/business_router.dart';
import 'package:sarqyt/src/routing/client_router.dart';

void main() {
  group('mapPushToDeepLink — client audience', () {
    test('maps new_status to orderDetail with orderId', () {
      final target = mapPushToDeepLink(
        audience: PushAudience.client,
        type: 'new_status',
        data: {'orderId': 'order-1'},
      );

      expect(target?.routeName, ClientRoute.orderDetail.name);
      expect(target?.pathParameters, {'orderId': 'order-1'});
    });

    test('maps reminder to orderDetail with orderId', () {
      final target = mapPushToDeepLink(
        audience: PushAudience.client,
        type: 'reminder',
        data: {'orderId': 'order-2'},
      );

      expect(target?.routeName, ClientRoute.orderDetail.name);
      expect(target?.pathParameters, {'orderId': 'order-2'});
    });

    test('maps review_prompt to review with orderId, storeId, storeName', () {
      final target = mapPushToDeepLink(
        audience: PushAudience.client,
        type: 'review_prompt',
        data: {
          'orderId': 'order-3',
          'storeId': 'store-1',
          'storeName': 'Пекарня',
        },
      );

      expect(target?.routeName, ClientRoute.review.name);
      expect(target?.pathParameters, {'orderId': 'order-3'});
      expect(target?.queryParameters, {
        'storeId': 'store-1',
        'storeName': 'Пекарня',
      });
    });

    test('returns null for review_prompt missing storeId/storeName', () {
      final target = mapPushToDeepLink(
        audience: PushAudience.client,
        type: 'review_prompt',
        data: {'orderId': 'order-3'},
      );

      expect(target, isNull);
    });

    test('returns null for new_status missing orderId', () {
      final target = mapPushToDeepLink(
        audience: PushAudience.client,
        type: 'new_status',
        data: const {},
      );

      expect(target, isNull);
    });

    test('returns null for an unknown type', () {
      final target = mapPushToDeepLink(
        audience: PushAudience.client,
        type: 'something_else',
        data: {'orderId': 'order-1'},
      );

      expect(target, isNull);
    });

    test('returns null for a business-only type (E10/E11)', () {
      final target = mapPushToDeepLink(
        audience: PushAudience.client,
        type: 'new_order',
        data: {'storeId': 'store-1'},
      );

      expect(target, isNull);
    });
  });

  group('mapPushToDeepLink — business audience', () {
    for (final type in [
      'new_order',
      'order_completed',
      'order_cancelled',
      'order_expired',
    ]) {
      test('maps $type to dashboard with storeId', () {
        final target = mapPushToDeepLink(
          audience: PushAudience.business,
          type: type,
          data: {'storeId': 'store-1'},
        );

        expect(target?.routeName, BusinessRoute.dashboard.name);
        expect(target?.pathParameters, {'storeId': 'store-1'});
      });
    }

    test('returns null when storeId is missing', () {
      final target = mapPushToDeepLink(
        audience: PushAudience.business,
        type: 'new_order',
        data: const {},
      );

      expect(target, isNull);
    });

    test('returns null for a client-only type (E10/E11)', () {
      final target = mapPushToDeepLink(
        audience: PushAudience.business,
        type: 'reminder',
        data: {'orderId': 'order-1'},
      );

      expect(target, isNull);
    });
  });

  group('pendingDeepLinkProvider', () {
    test('starts empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(pendingDeepLinkProvider), isNull);
    });

    test('set() stores the target', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      const target = PushDeepLinkTarget(
        routeName: 'orderDetail',
        pathParameters: {'orderId': 'order-1'},
      );

      container.read(pendingDeepLinkProvider.notifier).set(target);

      expect(container.read(pendingDeepLinkProvider), target);
    });

    test('clear() empties the pending target', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container
          .read(pendingDeepLinkProvider.notifier)
          .set(const PushDeepLinkTarget(routeName: 'orderDetail'));

      container.read(pendingDeepLinkProvider.notifier).clear();

      expect(container.read(pendingDeepLinkProvider), isNull);
    });

    test('setting an equal target twice emits only once (R14: no duplicate '
        'navigation from repeated identical taps/registrations)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      var emissions = 0;
      container.listen(pendingDeepLinkProvider, (previous, next) {
        emissions++;
      });

      final notifier = container.read(pendingDeepLinkProvider.notifier);
      notifier.set(
        const PushDeepLinkTarget(
          routeName: 'orderDetail',
          pathParameters: {'orderId': 'order-1'},
        ),
      );
      notifier.set(
        const PushDeepLinkTarget(
          routeName: 'orderDetail',
          pathParameters: {'orderId': 'order-1'},
        ),
      );

      expect(emissions, 1);
    });
  });
}
