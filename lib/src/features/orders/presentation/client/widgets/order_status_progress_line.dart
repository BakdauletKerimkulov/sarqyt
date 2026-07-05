import 'package:flutter/material.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/orders/domain/order.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

/// A 4-dot progress line showing the order status progression:
/// confirmed → preparing → readyForPickup → completed.
///
/// Filled dots and connecting line segments use [AppColors.primary].
/// Unfilled dots and segments use [theme.colorScheme.outlineVariant].
///
/// Not intended for cancelled/expired orders — caller should show
/// [OrderStatusBadge] instead.
class OrderStatusProgressLine extends StatelessWidget {
  const OrderStatusProgressLine({super.key, required this.status});

  final OrderStatus status;

  static const _steps = [
    OrderStatus.confirmed,
    OrderStatus.preparing,
    OrderStatus.readyForPickup,
    OrderStatus.completed,
  ];

  int get _filledCount {
    final index = _steps.indexOf(status);
    // For completed, all 4 are filled. For statuses not in _steps, fill 0.
    return index == -1 ? 0 : index + 1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filledColor = AppColors.primary;
    final unfilledColor = theme.colorScheme.outlineVariant;
    final filledCount = _filledCount;

    final labels = [
      context.loc.statusConfirmed,
      context.loc.statusPreparing,
      context.loc.statusReady,
      context.loc.statusCompleted,
    ];

    return Semantics(
      label: 'Order progress: ${labels[filledCount - 1]}',
      child: Row(
        children: [
          for (int i = 0; i < _steps.length; i++) ...[
            if (i > 0)
              Expanded(
                child: Container(
                  height: 2,
                  color: i < filledCount ? filledColor : unfilledColor,
                ),
              ),
            _ProgressDot(
              label: labels[i],
              isFilled: i < filledCount,
              filledColor: filledColor,
              unfilledColor: unfilledColor,
            ),
          ],
        ],
      ),
    );
  }
}

class _ProgressDot extends StatelessWidget {
  const _ProgressDot({
    required this.label,
    required this.isFilled,
    required this.filledColor,
    required this.unfilledColor,
  });

  final String label;
  final bool isFilled;
  final Color filledColor;
  final Color unfilledColor;

  @override
  Widget build(BuildContext context) {
    final color = isFilled ? filledColor : unfilledColor;

    return Semantics(
      label: '$label: ${isFilled ? "completed" : "pending"}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: Sizes.p12,
            height: Sizes.p12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          gapH4,
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: isFilled ? FontWeight.w600 : FontWeight.w400,
                ),
          ),
        ],
      ),
    );
  }
}
