import 'package:flutter/material.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/orders/domain/order.dart';
import 'package:sarqyt/src/features/orders/presentation/client/widgets/order_status_progress_line.dart';
import 'package:sarqyt/src/features/orders/presentation/order_ui_helpers.dart';

/// Expanded inline view for a single active order.
/// Shows store name, item×qty, progress line, pickup window, total.
class ActiveOrderInline extends StatelessWidget {
  const ActiveOrderInline({super.key, required this.order, this.onTap});

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
              Text(
                order.storeName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              gapH4,
              Text(
                '${order.itemName} x${order.itemQuantity}',
                style: theme.textTheme.bodyMedium,
              ),
              gapH16,
              OrderStatusProgressLine(status: order.status),
              gapH16,
              Row(
                children: [
                  if (order.pickupLabelLocalized(context) != null) ...[
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: theme.colorScheme.outline,
                    ),
                    gapW4,
                    Expanded(
                      child: Text(
                        order.pickupLabelLocalized(context)!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ),
                  ] else
                    const Spacer(),
                  Text(
                    order.totalFormatted,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
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
