import 'package:flutter/material.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';

class ItemQuantitySelector extends StatelessWidget {
  const ItemQuantitySelector({
    super.key,
    required this.quantity,
    required this.maxQuantity,
    this.index,
    this.onChanged,
  });

  final int quantity;
  final int maxQuantity;
  final int? index;
  final ValueChanged<int>? onChanged;

  static Key decrementKey([int? index]) =>
      index != null ? Key('decrement-$index') : const Key('decrement');
  static Key incrementKey([int? index]) =>
      index != null ? Key('increment-$index') : const Key('increment');
  static Key quantityKey([int? index]) =>
      index != null ? Key('quantity-$index') : const Key('quantity');

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(40),
        borderRadius: BorderRadius.circular(Sizes.p24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            key: decrementKey(),
            onPressed: onChanged != null && quantity > 1
                ? () => onChanged!.call(quantity - 1)
                : null,
            icon: Icon(Icons.remove),
          ),
          SizedBox(
            width: Sizes.p24,
            child: Text(
              key: quantityKey(),
              '$quantity',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: Sizes.p20),
            ),
          ),
          IconButton(
            key: incrementKey(),
            onPressed: onChanged != null && quantity < maxQuantity
                ? () => onChanged!.call(quantity + 1)
                : null,
            icon: Icon(Icons.add),
          ),
        ],
      ),
    );

    // return Row(
    //   mainAxisSize: MainAxisSize.min,
    //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //   crossAxisAlignment: CrossAxisAlignment.center,
    //   children: [
    //     Material(
    //       elevation: 2,
    //       shape: const CircleBorder(),
    //       color: Theme.of(context).colorScheme.surface,
    //       child: IconButton(
    //         key: decrementKey(),
    //         onPressed: onChanged != null && quantity > 1
    //             ? () => onChanged!.call(quantity - 1)
    //             : null,
    //         icon: const Icon(Icons.remove),
    //       ),
    //     ),
    //     gapW24,
    //     SizedBox(
    //       width: Sizes.p48,
    //       child: Text(
    //         '$quantity',
    //         key: quantityKey(),
    //         textAlign: TextAlign.center,
    //         style: Theme.of(context).textTheme.headlineLarge,
    //       ),
    //     ),
    //     gapW24,
    //     Material(
    //       elevation: 2,
    //       shape: const CircleBorder(),
    //       color: Theme.of(context).colorScheme.surface,
    //       child: IconButton(
    //         key: incrementKey(),
    //         onPressed: onChanged != null && quantity < maxQuantity
    //             ? () => onChanged!.call(quantity + 1)
    //             : null,
    //         icon: const Icon(Icons.add),
    //       ),
    //     ),
    //   ],
    // );
  }
}
