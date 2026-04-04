import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sarqyt/src/common_widgets/async_value_widget.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/orders/data/client_orders_repository.dart';
import 'package:sarqyt/src/features/orders/domain/order.dart';
import 'package:sarqyt/src/features/orders/presentation/client/order_status_badge.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/routing/client_router.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  static const _activeStatuses = {
    OrderStatus.confirmed,
    OrderStatus.preparing,
    OrderStatus.readyForPickup,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(customerOrdersStreamProvider);

    return Scaffold(
      appBar: AppBar(title: Text('My Orders'.hardcoded)),
      body: AsyncValueWidget(
        value: ordersAsync,
        data: (orders) {
          if (orders.isEmpty) {
            return Center(child: Text('No orders yet'.hardcoded));
          }

          final active =
              orders.where((o) => _activeStatuses.contains(o.status)).toList();
          final past =
              orders.where((o) => !_activeStatuses.contains(o.status)).toList();

          return ListView(
            padding: const EdgeInsets.all(Sizes.p16),
            children: [
              if (active.isNotEmpty) ...[
                Text(
                  'Current'.hardcoded,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                gapH12,
                for (final order in active) ...[
                  _ActiveOrderCard(
                    order: order,
                    onTap: () => context.pushNamed(
                      ClientRoute.orderDetail.name,
                      pathParameters: {'orderId': order.id},
                    ),
                  ),
                  gapH12,
                ],
              ],
              if (past.isNotEmpty) ...[
                gapH8,
                Text(
                  'Past orders'.hardcoded,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                gapH12,
                for (final order in past) ...[
                  _PastOrderTile(
                    order: order,
                    onTap: () => context.pushNamed(
                      ClientRoute.orderDetail.name,
                      pathParameters: {'orderId': order.id},
                    ),
                  ),
                  gapH8,
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ActiveOrderCard extends StatelessWidget {
  const _ActiveOrderCard({required this.order, this.onTap});

  final Order order;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Sizes.p12),
        child: Padding(
          padding: const EdgeInsets.all(Sizes.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.storeName,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  OrderStatusBadge(status: order.status),
                ],
              ),
              gapH8,
              Text(
                '${order.itemName} x${order.itemQuantity}',
                style: theme.textTheme.bodyMedium,
              ),
              gapH4,
              if (order.pickupLabel != null)
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 16, color: Colors.grey),
                    gapW4,
                    Text(
                      order.pickupLabel!,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PastOrderTile extends StatelessWidget {
  const _PastOrderTile({required this.order, this.onTap});

  final Order order;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('d MMM').format(order.createdAt);

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      title: Text(order.itemName),
      subtitle: Text('x${order.itemQuantity} · $dateStr'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            order.totalFormatted,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          gapW8,
          OrderStatusBadge(status: order.status),
        ],
      ),
    );
  }
}
