import 'package:sarqyt/src/utils/async_value_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/common_widgets/async_value_widget.dart';
import 'package:sarqyt/src/common_widgets/responsive_centered_grid.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/orders/data/orders_repository.dart';
import 'package:sarqyt/src/features/orders/domain/order.dart';
import 'package:sarqyt/src/features/orders/presentation/client/order_status_badge.dart';
import 'package:sarqyt/src/features/orders/presentation/order_ui_helpers.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/routing/business_router.dart';

// ignore: provider_dependencies
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
            return Center(child: Text(context.loc.noOrdersYet));
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
                  context.loc.activeOrders,
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
                  context.loc.pastOrders,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                gapH12,
                for (final order in past) ...[
                  _BusinessOrderCard(order: order),
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
  ConsumerState<_BusinessOrderCard> createState() => _BusinessOrderCardState();
}

class _BusinessOrderCardState extends ConsumerState<_BusinessOrderCard> {
  bool _isLoading = false;

  static const _activeStatuses = {
    OrderStatus.confirmed,
    OrderStatus.preparing,
    OrderStatus.readyForPickup,
  };

  String? _nextStatusLabel(BuildContext context) {
    return switch (widget.order.status) {
      OrderStatus.confirmed => context.loc.startPreparing,
      OrderStatus.preparing => context.loc.readyForPickup,
      OrderStatus.readyForPickup => context.loc.markCompleted,
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

  static const _pickupWindowGatedNextStatuses = {'readyForPickup', 'completed'};

  /// Reason the next-status action is blocked by the pickup window, or null
  /// if it's allowed right now. Mirrors the server-side gate in
  /// `updateOrderStatus` (functions/.../update-order-status.ts) so staff see
  /// why before they tap, instead of only after the call fails.
  String? _pickupWindowBlockReason(BuildContext context) {
    final next = _nextStatus;
    if (next == null || !_pickupWindowGatedNextStatuses.contains(next)) {
      return null;
    }
    final order = widget.order;
    final now = DateTime.now();
    final start = order.pickupStartTime;
    if (start != null && now.isBefore(start)) {
      return context.loc.pickupWindowNotOpenYet;
    }
    if (order.isPickupExpired(now)) {
      return context.loc.pickupWindowAlreadyClosed;
    }
    return null;
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(humanReadableError(e))));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelOrder() async {
    final reason = await _showCancelReasonDialog(context);
    if (reason == null) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(ordersRepositoryProvider)
          .cancelOrder(widget.order.id, reason: reason);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(humanReadableError(e))));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final theme = Theme.of(context);
    final isActive = _activeStatuses.contains(order.status);
    final pickupWindowBlockReason = _pickupWindowBlockReason(context);

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
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
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
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (order.pickupLabelLocalized(context) != null) ...[
              gapH4,
              Text(
                order.pickupLabelLocalized(context)!,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
            if (_nextStatusLabel(context) != null) ...[
              gapH12,
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isLoading || pickupWindowBlockReason != null)
                      ? null
                      : _updateStatus,
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
                      : Text(_nextStatusLabel(context)!),
                ),
              ),
              if (pickupWindowBlockReason != null) ...[
                gapH4,
                Text(
                  pickupWindowBlockReason,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ],
            if (isActive) ...[
              gapH8,
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _cancelOrder,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: Text(context.loc.cancelOrder),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<String?> _showCancelReasonDialog(BuildContext context) {
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(context.loc.cancelOrderConfirm),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: context.loc.cancelReason,
            hintText: context.loc.cancelReasonHint,
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return context.loc.cancelReasonRequired;
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(context.loc.no),
        ),
        TextButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.of(ctx).pop(controller.text.trim());
            }
          },
          child: Text(
            context.loc.yesCancel,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
}

enum _OrderFilter { all, active, completed, cancelled }

/// Sliver version of business orders for use inside OutlinedSectionSliver.
class SliverBusinessOrders extends ConsumerStatefulWidget {
  const SliverBusinessOrders({super.key, required this.storeId});

  final String storeId;

  @override
  ConsumerState<SliverBusinessOrders> createState() =>
      _SliverBusinessOrdersState();
}

class _SliverBusinessOrdersState extends ConsumerState<SliverBusinessOrders> {
  _OrderFilter _filter = _OrderFilter.all;

  static const _activeStatuses = {
    OrderStatus.confirmed,
    OrderStatus.preparing,
    OrderStatus.readyForPickup,
  };

  List<Order> _applyFilter(List<Order> orders) {
    return switch (_filter) {
      _OrderFilter.all => orders,
      _OrderFilter.active =>
        orders.where((o) => _activeStatuses.contains(o.status)).toList(),
      _OrderFilter.completed =>
        orders
            .where(
              (o) =>
                  o.status == OrderStatus.completed ||
                  o.status == OrderStatus.expired,
            )
            .toList(),
      _OrderFilter.cancelled =>
        orders.where((o) => o.status == OrderStatus.cancelled).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersListStreamProvider(widget.storeId));

    return SliverMainAxisGroup(
      slivers: [
        // Filter chips
        SliverToBoxAdapter(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(bottom: Sizes.p12),
            child: Row(
              children: _OrderFilter.values.map((f) {
                return Padding(
                  padding: const EdgeInsets.only(right: Sizes.p8),
                  child: ChoiceChip(
                    label: Text(switch (f) {
                      _OrderFilter.all => context.loc.all,
                      _OrderFilter.active => context.loc.active,
                      _OrderFilter.completed => context.loc.completed,
                      _OrderFilter.cancelled => context.loc.cancelled,
                    }),
                    selected: _filter == f,
                    selectedColor: AppColors.primary.withAlpha(30),
                    onSelected: (_) => setState(() => _filter = f),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Orders grid
        AsyncValueSliverWidget(
          value: ordersAsync,
          data: (orders) {
            final filtered = _applyFilter(orders);

            if (filtered.isEmpty) {
              return SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(Sizes.p32),
                    child: Text(
                      _filter == _OrderFilter.all
                          ? context.loc.noOrdersDescription
                          : context.loc.noOrdersWithStatus,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              );
            }

            return ResponsiveSliverAlignedGrid(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                return _BusinessOrderCard(order: filtered[index]);
              },
            );
          },
        ),
      ],
    );
  }
}
