import 'package:sarqyt/src/utils/async_value_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/common_widgets/async_value_widget.dart';
import 'package:sarqyt/src/common_widgets/custom_image.dart';
import 'package:sarqyt/src/common_widgets/primary_button.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/orders/data/client_orders_repository.dart';
import 'package:sarqyt/src/features/orders/domain/order.dart';
import 'package:sarqyt/src/features/orders/presentation/client/order_status_badge.dart';
import 'package:sarqyt/src/features/orders/presentation/order_ui_helpers.dart';
import 'package:sarqyt/src/features/orders/presentation/client/widgets/order_status_progress_line.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/routing/client_router.dart';
import 'package:sarqyt/src/common_widgets/alert_dialogs.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final OrderID orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(customerOrderStreamProvider(orderId));

    return Scaffold(
      appBar: AppBar(title: Text(context.loc.orderDetails)),
      body: AsyncValueWidget(
        value: orderAsync,
        data: (order) {
          if (order == null) {
            return Center(child: Text(context.loc.orderNotFound));
          }
          return _OrderDetailContent(order: order);
        },
      ),
    );
  }
}

class _OrderDetailContent extends StatelessWidget {
  const _OrderDetailContent({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Sizes.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status
          if (order.status == OrderStatus.confirmed ||
              order.status == OrderStatus.preparing ||
              order.status == OrderStatus.readyForPickup ||
              order.status == OrderStatus.completed)
            OrderStatusProgressLine(status: order.status)
          else
            Center(child: OrderStatusBadge(status: order.status)),
          gapH24,

          // Store info
          Center(
            child: Column(
              children: [
                Text(
                  order.storeName,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                if (order.orderNumber != null) ...[
                  gapH4,
                  Text(
                    context.loc.orderNumber(order.orderNumber!.toString()),
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
          gapH24,

          // Pickup countdown timer
          if (order.pickupEndTime != null &&
              order.status != OrderStatus.completed &&
              order.status != OrderStatus.cancelled &&
              order.status != OrderStatus.expired)
            _PickupWindow(order: order),

          gapH16,
          const Divider(),
          gapH16,

          // Item details
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(Sizes.p8),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: CustomImage(imageUrl: order.itemImageUrl),
                ),
              ),
              gapW16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.itemName,
                      style: theme.textTheme.titleMedium,
                    ),
                    gapH4,
                    Text(
                      context.loc.itemQuantityPrefix(order.itemQuantity),
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Text(
                order.totalFormatted,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          gapH16,
          const Divider(),
          gapH16,

          // Pickup window
          if (order.pickupLabelLocalized(context) != null) ...[
            Text(
              context.loc.pickupWindow,
              style: theme.textTheme.titleSmall,
            ),
            gapH8,
            Row(
              children: [
                const Icon(Icons.schedule, size: 20, color: Colors.grey),
                gapW8,
                Text(order.pickupLabelLocalized(context)!, style: theme.textTheme.bodyLarge),
              ],
            ),
            gapH16,
            const Divider(),
            gapH16,
          ],

          // Payment info
          _InfoRow(
            label: context.loc.payment,
            value: context.loc.payOnPickup,
          ),
          gapH8,
          _InfoRow(
            label: context.loc.total,
            value: order.totalFormatted,
          ),

          // Cancellation reason (when cancelled by store)
          if (order.status == OrderStatus.cancelled &&
              order.cancelledBy == CancelledBy.store) ...[
            gapH16,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Sizes.p12),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(20),
                borderRadius: BorderRadius.circular(Sizes.p8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.loc.orderCancelledByStore,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (order.cancellationReason != null) ...[
                    gapH4,
                    Text(
                      order.cancellationReason!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Cancel button for active orders (including readyForPickup)
          if (order.status == OrderStatus.confirmed ||
              order.status == OrderStatus.preparing ||
              order.status == OrderStatus.readyForPickup) ...[
            gapH24,
            _CancelOrderButton(orderId: order.id),
          ],

          // Review button for completed orders
          if (order.status == OrderStatus.completed) ...[
            gapH24,
            PrimaryButton(
              text: context.loc.leaveAReview,
              onPressed: () => context.pushNamed(
                ClientRoute.review.name,
                pathParameters: {'orderId': order.id},
                queryParameters: {
                  'storeId': order.storeId,
                  'storeName': order.storeName,
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PickupWindow extends StatelessWidget {
  const _PickupWindow({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final isExpired = order.isPickupExpired;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Sizes.p16),
      decoration: BoxDecoration(
        color: isExpired
            ? Colors.red.withAlpha(20)
            : Colors.green.withAlpha(20),
        borderRadius: BorderRadius.circular(Sizes.p12),
      ),
      child: Column(
        children: [
          Icon(
            isExpired ? Icons.timer_off : Icons.schedule,
            size: 32,
            color: isExpired ? Colors.red : Colors.green,
          ),
          gapH8,
          Text(
            isExpired
                ? context.loc.pickupTimeExpired
                : context.loc.pickupWindow,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          gapH4,
          Text(
            order.pickupLabelLocalized(context) ?? '',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class _CancelOrderButton extends ConsumerStatefulWidget {
  const _CancelOrderButton({required this.orderId});
  final OrderID orderId;

  @override
  ConsumerState<_CancelOrderButton> createState() =>
      _CancelOrderButtonState();
}

class _CancelOrderButtonState extends ConsumerState<_CancelOrderButton> {
  bool _isLoading = false;

  Future<void> _cancel() async {
    final confirm = await showAlertDialog(
      context: context,
      title: context.loc.cancelOrderConfirm,
      content: context.loc.cancelOrderRefund,
      cancelActionText: context.loc.no,
      defaultActionText: context.loc.yesCancel,
    );
    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(clientOrdersRepositoryProvider)
          .cancelOrder(widget.orderId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(humanReadableError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: _isLoading ? null : _cancel,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        side: const BorderSide(color: Colors.red),
        minimumSize: const Size(double.infinity, 48),
      ),
      child: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(context.loc.cancelOrder),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
