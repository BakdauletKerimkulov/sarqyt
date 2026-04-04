import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sarqyt/src/common_widgets/async_value_widget.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/orders/data/orders_repository.dart';
import 'package:sarqyt/src/features/orders/domain/order.dart';
import 'package:sarqyt/src/features/orders/presentation/client/order_status_badge.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/routing/business_router.dart';

class BusinessOrdersScreen extends ConsumerWidget {
  const BusinessOrdersScreen({super.key});

  static const _activeStatuses = {
    OrderStatus.confirmed,
    OrderStatus.preparing,
    OrderStatus.readyForPickup,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeShip = ref.watch(currentStoreShipProvider);
    final ordersAsync = ref.watch(ordersListStreamProvider(storeShip.storeId));

    return Padding(
      padding: const EdgeInsets.all(Sizes.p16),
      child: AsyncValueWidget(
        value: ordersAsync,
        data: (orders) {
          if (orders.isEmpty) {
            return Center(child: Text('No orders yet'.hardcoded));
          }

          final active = orders
              .where((o) => _activeStatuses.contains(o.status))
              .toList();
          final past = orders
              .where((o) => !_activeStatuses.contains(o.status))
              .toList();

          return ListView(
            children: [
              if (active.isNotEmpty) ...[
                Text(
                  'Active orders'.hardcoded,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                gapH12,
                for (final order in active) ...[
                  _BusinessOrderCard(order: order),
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
                  _PastOrderTile(order: order),
                  gapH4,
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}

class _BusinessOrderCard extends ConsumerStatefulWidget {
  const _BusinessOrderCard({required this.order});
  final Order order;

  @override
  ConsumerState<_BusinessOrderCard> createState() =>
      _BusinessOrderCardState();
}

class _BusinessOrderCardState extends ConsumerState<_BusinessOrderCard> {
  bool _isLoading = false;

  String? get _nextStatusLabel {
    return switch (widget.order.status) {
      OrderStatus.confirmed => 'Start preparing',
      OrderStatus.preparing => 'Ready for pickup',
      OrderStatus.readyForPickup => 'Mark completed',
      _ => null,
    };
  }

  String? get _nextStatus {
    return switch (widget.order.status) {
      OrderStatus.confirmed => 'preparing',
      OrderStatus.preparing => 'readyForPickup',
      OrderStatus.readyForPickup => 'completed',
      _ => null,
    };
  }

  Future<void> _updateStatus() async {
    final next = _nextStatus;
    if (next == null) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(ordersRepositoryProvider)
          .updateOrderStatus(widget.order.id, next);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Sizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (order.orderNumber != null)
                  Text(
                    '#${order.orderNumber}',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                const Spacer(),
                OrderStatusBadge(status: order.status),
              ],
            ),
            gapH8,
            Text('${order.itemName} x${order.itemQuantity}'),
            gapH4,
            Text(
              order.totalFormatted,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            if (order.pickupLabel != null) ...[
              gapH4,
              Text(
                order.pickupLabel!,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
            if (_nextStatusLabel != null) ...[
              gapH12,
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_nextStatusLabel!.hardcoded),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PastOrderTile extends StatelessWidget {
  const _PastOrderTile({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMM, HH:mm').format(order.createdAt);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('${order.itemName} x${order.itemQuantity}'),
      subtitle: Text(dateStr),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(order.totalFormatted),
          gapW8,
          OrderStatusBadge(status: order.status),
        ],
      ),
    );
  }
}
