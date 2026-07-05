import 'package:flutter/material.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/orders/domain/order.dart';
import 'package:sarqyt/src/features/orders/presentation/client/order_status_badge.dart';

/// Compact card for active orders in list mode (>1 active).
/// Shows store name, item, status badge, pickup time, total.
class ActiveOrderCard extends StatelessWidget {
  const ActiveOrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

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
              Row(
                children: [
                  if (order.pickupLabel != null) ...[
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: theme.colorScheme.outline,
                    ),
                    gapW4,
                    Expanded(
                      child: Text(
                        order.pickupLabel!,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.outline),
                      ),
                    ),
                  ] else
                    const Spacer(),
                  Text(
                    order.totalFormatted,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
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
