import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/common_widgets/async_value_widget.dart';
import 'package:sarqyt/src/common_widgets/outlined_section_widget.dart';
import 'package:sarqyt/src/common_widgets/responsive_centered_grid.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/items/domain/item.dart';
import 'package:sarqyt/src/features/items/presentation/item_screen/item_details.dart';
import 'package:sarqyt/src/features/orders/data/orders_repository.dart';
import 'package:sarqyt/src/features/orders/presentation/order_card.dart';
import 'package:sarqyt/src/features/store/data/store_repository.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';

class OverviewContent extends ConsumerWidget {
  const OverviewContent({super.key, required this.storeId, required this.item});

  final StoreID storeId;
  final Item item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersValue = ref.watch(ordersListStreamProvider(storeId));
    final storeName = ref.watch(storeStreamProvider(storeId)).value?.name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedSectionWidgetWithHeader(
          header: 'Reservations',
          child: AsyncValueWidget(
            value: ordersValue,
            data: (orders) {
              return orders.isEmpty
                  ? SizedBox(
                      height: 240.0,
                      child: Center(
                        child: Text(
                          'Once you start selling, you will see your Surprise Bag reservations here.',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ResponsiveCenteredGrid(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return OrderCard(order: order);
                      },
                    );
            },
          ),
        ),
        gapH24,
        OutlinedSectionWidgetWithHeader(
          header: 'Surprise bag details',
          child: ItemDetails(item: item, storeName: storeName),
        ),
        gapH64,
      ],
    );
  }
}
