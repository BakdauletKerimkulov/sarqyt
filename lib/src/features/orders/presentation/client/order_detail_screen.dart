import 'dart:async';

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
      appBar: AppBar(title: Text('Order Details'.hardcoded)),
      body: AsyncValueWidget(
        value: orderAsync,
        data: (order) {
          if (order == null) {
            return Center(child: Text('Order not found'.hardcoded));
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
                    'Order #${order.orderNumber}'.hardcoded,
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
              order.status != OrderStatus.cancelled)
            _PickupCountdown(order: order),

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
                      'x${order.itemQuantity}'.hardcoded,
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
          if (order.pickupLabel != null) ...[
            Text(
              'Pickup window'.hardcoded,
              style: theme.textTheme.titleSmall,
            ),
            gapH8,
            Row(
              children: [
                const Icon(Icons.schedule, size: 20, color: Colors.grey),
                gapW8,
                Text(order.pickupLabel!, style: theme.textTheme.bodyLarge),
              ],
            ),
            gapH16,
            const Divider(),
            gapH16,
          ],

          // Payment info
          _InfoRow(
            label: 'Payment'.hardcoded,
            value: order.paymentStatus == PaymentStatus.paid
                ? 'Paid'.hardcoded
                : 'Refunded'.hardcoded,
          ),
          gapH8,
          _InfoRow(
            label: 'Total'.hardcoded,
            value: order.totalFormatted,
          ),

          // Cancel button for active orders
          if (order.status == OrderStatus.confirmed ||
              order.status == OrderStatus.preparing) ...[
            gapH24,
            _CancelOrderButton(orderId: order.id),
          ],

          // Review button for completed orders
          if (order.status == OrderStatus.completed) ...[
            gapH24,
            PrimaryButton(
              text: 'Leave a review'.hardcoded,
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

class _PickupCountdown extends StatefulWidget {
  const _PickupCountdown({required this.order});

  final Order order;

  @override
  State<_PickupCountdown> createState() => _PickupCountdownState();
}

class _PickupCountdownState extends State<_PickupCountdown> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
    });
  }

  void _updateRemaining() {
    final remaining = widget.order.timeUntilPickupEnd ?? Duration.zero;
    if (mounted) setState(() => _remaining = remaining);
    if (remaining == Duration.zero) _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = _remaining == Duration.zero;
    final hours = _remaining.inHours;
    final minutes = _remaining.inMinutes.remainder(60);
    final seconds = _remaining.inSeconds.remainder(60);

    final timeText = hours > 0
        ? '${hours}h ${minutes}m ${seconds}s'
        : '${minutes}m ${seconds}s';

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
          Text(
            isExpired
                ? 'Pickup time expired'.hardcoded
                : 'Pick up within'.hardcoded,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (!isExpired) ...[
            gapH8,
            Text(
              timeText,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _remaining.inMinutes < 15 ? Colors.orange : null,
                  ),
            ),
          ],
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
      title: 'Cancel order?'.hardcoded,
      content: 'You will receive a full refund.'.hardcoded,
      cancelActionText: 'No'.hardcoded,
      defaultActionText: 'Yes, cancel'.hardcoded,
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
          SnackBar(content: Text(e.toString())),
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
          : Text('Cancel order'.hardcoded),
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
