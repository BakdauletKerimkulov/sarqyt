import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/common_widgets/async_value_widget.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/orders/data/client_orders_repository.dart';
import 'package:sarqyt/src/features/orders/domain/order.dart';
import 'package:sarqyt/src/features/orders/presentation/client/widgets/active_order_card.dart';
import 'package:sarqyt/src/features/orders/presentation/client/widgets/active_order_inline.dart';
import 'package:sarqyt/src/features/orders/presentation/client/widgets/recent_order_card.dart';
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
      appBar: AppBar(
        title: Text(context.loc.myOrders),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: context.loc.orderHistory,
            // Route will be wired in Phase 2 when orderHistory is added to ClientRoute
            onPressed: () {},
          ),
        ],
      ),
      body: AsyncValueWidget(
        value: ordersAsync,
        data: (orders) {
          final active =
              orders.where((o) => _activeStatuses.contains(o.status)).toList();
          final past =
              orders.where((o) => !_activeStatuses.contains(o.status)).toList();

          if (orders.isEmpty) {
            return Center(child: Text(context.loc.noOrdersYet));
          }

          return ListView(
            padding: const EdgeInsets.all(Sizes.p16),
            children: [
              // Active orders section
              _ActiveOrdersSection(active: active),
              // Recent orders section (max 3 past orders)
              if (past.isNotEmpty) ...[
                gapH24,
                _RecentOrdersSection(past: past),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ActiveOrdersSection extends StatelessWidget {
  const _ActiveOrdersSection({required this.active});

  final List<Order> active;

  void _navigateToDetail(BuildContext context, Order order) {
    context.pushNamed(
      ClientRoute.orderDetail.name,
      pathParameters: {'orderId': order.id},
    );
  }

  @override
  Widget build(BuildContext context) {
    if (active.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Sizes.p24),
          child: Text(
            context.loc.noActiveOrders,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Theme.of(context).colorScheme.outline),
          ),
        ),
      );
    }

    if (active.length == 1) {
      return ActiveOrderInline(
        order: active.first,
        onTap: () => _navigateToDetail(context, active.first),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < active.length; i++) ...[
          ActiveOrderCard(
            order: active[i],
            onTap: () => _navigateToDetail(context, active[i]),
          ),
          if (i < active.length - 1) gapH8,
        ],
      ],
    );
  }
}

class _RecentOrdersSection extends StatelessWidget {
  const _RecentOrdersSection({required this.past});

  final List<Order> past;

  @override
  Widget build(BuildContext context) {
    final recent = past.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.loc.recentOrders,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        gapH12,
        for (int i = 0; i < recent.length; i++) ...[
          RecentOrderCard(
            order: recent[i],
            onTap: () => context.pushNamed(
              ClientRoute.orderDetail.name,
              pathParameters: {'orderId': recent[i].id},
            ),
          ),
          if (i < recent.length - 1) gapH8,
        ],
      ],
    );
  }
}
