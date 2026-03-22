// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/common_widgets/alert_dialogs.dart';
import 'package:sarqyt/src/common_widgets/async_value_widget.dart';
import 'package:sarqyt/src/common_widgets/responsive_centered_grid.dart';
import 'package:sarqyt/src/features/items/data/items_repository.dart';
import 'package:sarqyt/src/features/items/presentation/items_list/item_action_dialog.dart';
import 'package:sarqyt/src/features/items/presentation/items_list/item_card.dart';
import 'package:sarqyt/src/features/items/presentation/items_list/start_selling_dialog.dart';
import 'package:sarqyt/src/features/offers/data/business_offer_repository.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

class SliverItemsGrid extends ConsumerWidget {
  const SliverItemsGrid({super.key, required this.storeId});

  final String storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsValue = ref.watch(itemsListFutureProvider(storeId));
    final activeIdsValue =
        ref.watch(storeActiveOfferItemIdsProvider(storeId));
    final activeItemIds = activeIdsValue.value ?? {};

    return AsyncValueSliverWidget(
      value: itemsValue,
      data: (items) {
        if (items.isEmpty) {
          return Center(child: Text('No items found'.hardcoded));
        }

        return ResponsiveSliverAlignedGrid(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final isSelling = activeItemIds.contains(item.id);

            return ItemCard(
              item: item,
              isSelling: isSelling,
              onStartSelling: () async {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (_) => StartSellingDialog(
                    item: item,
                    storeId: storeId,
                  ),
                );
                if (result == true) {
                  ref.invalidate(storeActiveOfferItemIdsProvider(storeId));
                }
              },
              onStopSelling: () {
                showNotImplementedAlertDialog(context: context);
              },
              onPressed: () => showDialog(
                context: context,
                builder: (_) => ItemActionDialog(
                  item: item,
                  storeId: storeId,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
