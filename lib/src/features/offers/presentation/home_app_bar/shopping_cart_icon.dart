import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/common_widgets/alert_dialogs.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/cart/application/cart_service.dart';

/// Shopping cart icon with items count badge
class ShoppingCartIcon extends ConsumerWidget {
  const ShoppingCartIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsCount = ref.watch(shoppingCartItemsProvider);
    return Stack(
      children: [
        Center(
          child: IconButton(
            onPressed: () => showNotImplementedAlertDialog(context: context),
            icon: Icon(Icons.shopping_cart),
          ),
        ),
        if (itemsCount > 0)
          Positioned(
            top: Sizes.p4,
            right: Sizes.p4,
            child: ShoppingCartIconBadge(itemsCount: itemsCount),
          ),
      ],
    );
  }
}

/// Icon badge showing the items count
class ShoppingCartIconBadge extends StatelessWidget {
  const ShoppingCartIconBadge({super.key, required this.itemsCount});
  final int itemsCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Sizes.p16,
      height: Sizes.p16,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        child: Text(
          '$itemsCount',
          textAlign: TextAlign.center,
          // * Force text scale factor to 1.0 irrespective of the device's
          // * textScaleFactor. This is to prevent the text from growing bigger
          // * than the available space.
          textScaler: const TextScaler.linear(1.0),
          style: Theme.of(
            context,
          ).textTheme.bodySmall!.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
