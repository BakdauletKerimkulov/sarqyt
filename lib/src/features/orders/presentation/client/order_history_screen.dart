import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/common_widgets/async_value_widget.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/orders/data/client_orders_repository.dart';
import 'package:sarqyt/src/features/orders/presentation/client/widgets/recent_order_card.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/routing/client_router.dart';

/// Shows all orders (active and past) in chronological order (newest first).
class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(customerOrdersStreamProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.loc.orderHistory)),
      body: AsyncValueWidget(
        value: ordersAsync,
        data: (orders) {
          if (orders.isEmpty) {
            return Center(child: Text(context.loc.noOrdersYet));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(Sizes.p16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => gapH8,
            itemBuilder: (context, index) {
              final order = orders[index];
              return RecentOrderCard(
                order: order,
                onTap: () => context.pushNamed(
                  ClientRoute.orderDetail.name,
                  pathParameters: {'orderId': order.id},
                ),
              );
            },
          );
        },
      ),
    );
  }
}
