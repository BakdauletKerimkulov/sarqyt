import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/notifications/domain/push_audience.dart';
import 'package:sarqyt/src/features/notifications/domain/push_deep_link_target.dart';

part 'push_deep_link.g.dart';

/// Route names a tapped push maps to. Kept as plain strings so this module
/// stays decoupled from both `ClientRoute` and `BusinessRoute` — they must
/// match the enum `.name` values exactly, which the test file asserts.
abstract final class _RouteNames {
  static const orderDetail = 'orderDetail';
  static const review = 'review';
  static const dashboard = 'dashboard';
}

const _kClientReviewPromptTypes = {'review_prompt'};
const _kClientOrderStatusTypes = {'new_status', 'reminder'};
const _kBusinessOrderTypes = {
  'new_order',
  'order_completed',
  'order_cancelled',
  'order_expired',
};

/// Maps a push notification's `type` + `data` to where it should navigate
/// (spec 034, R9). Pure: no Firebase imports, so this is trivially testable.
///
/// Returns `null` for an unknown `type`, a type that belongs to the other
/// app's audience (E10/E11), or missing required parameters.
PushDeepLinkTarget? mapPushToDeepLink({
  required PushAudience audience,
  required String? type,
  required Map<String, String> data,
}) {
  return switch (audience) {
    PushAudience.client => _mapClientDeepLink(type, data),
    PushAudience.business => _mapBusinessDeepLink(type, data),
  };
}

PushDeepLinkTarget? _mapClientDeepLink(String? type, Map<String, String> data) {
  if (_kClientOrderStatusTypes.contains(type)) {
    final orderId = data['orderId'];
    if (orderId == null || orderId.isEmpty) return null;
    return PushDeepLinkTarget(
      routeName: _RouteNames.orderDetail,
      pathParameters: {'orderId': orderId},
    );
  }

  if (_kClientReviewPromptTypes.contains(type)) {
    final orderId = data['orderId'];
    final storeId = data['storeId'];
    final storeName = data['storeName'];
    if (orderId == null || orderId.isEmpty) return null;
    if (storeId == null || storeId.isEmpty) return null;
    if (storeName == null || storeName.isEmpty) return null;
    return PushDeepLinkTarget(
      routeName: _RouteNames.review,
      pathParameters: {'orderId': orderId},
      queryParameters: {'storeId': storeId, 'storeName': storeName},
    );
  }

  return null;
}

PushDeepLinkTarget? _mapBusinessDeepLink(
  String? type,
  Map<String, String> data,
) {
  if (!_kBusinessOrderTypes.contains(type)) return null;

  final storeId = data['storeId'];
  if (storeId == null || storeId.isEmpty) return null;
  return PushDeepLinkTarget(
    routeName: _RouteNames.dashboard,
    pathParameters: {'storeId': storeId},
  );
}

/// The deep link a tapped push is waiting to apply, or `null` if none is
/// pending. Survives across the app's whole session (`keepAlive`) so a tap
/// from a background/terminated state reaches the router once it is ready.
@Riverpod(keepAlive: true)
class PendingDeepLink extends _$PendingDeepLink {
  @override
  PushDeepLinkTarget? build() => null;

  /// Records a target to navigate to once the router is ready.
  ///
  /// No-ops when the target is unchanged (R14): repeated identical taps or
  /// a duplicate message-handler registration must not trigger a second
  /// navigation once the applier consumes this state.
  void set(PushDeepLinkTarget target) {
    if (state == target) return;
    state = target;
  }

  /// Clears the pending target once it has been applied (or dropped).
  void clear() => state = null;
}
