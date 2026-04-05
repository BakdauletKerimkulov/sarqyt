// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/common_widgets/async_value_widget.dart';
import 'package:sarqyt/src/common_widgets/responsive_centered_grid.dart';
import 'package:sarqyt/src/features/items/data/items_repository.dart';
import 'package:sarqyt/src/features/items/domain/item.dart';
import 'package:sarqyt/src/features/items/presentation/items_list/item_action_dialog.dart';
import 'package:sarqyt/src/features/items/presentation/items_list/item_card.dart';
import 'package:sarqyt/src/features/items/presentation/items_list/start_selling_dialog.dart';
import 'package:sarqyt/src/features/items/presentation/items_list/start_selling_dialog_controller.dart';
import 'package:sarqyt/src/features/offers/data/business_offer_repository.dart';
import 'package:sarqyt/src/features/offers/presentation/business/selling_now_dialog.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/utils/async_value_ui.dart';

class SliverItemsGrid extends ConsumerWidget {
  const SliverItemsGrid({super.key, required this.storeId});

  final String storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsValue = ref.watch(itemsListStreamProvider(storeId));

    ref.listen(
      startSellingDialogControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

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
            return _ItemCardWithOffer(
              item: item,
              storeId: storeId,
            );
          },
        );
      },
    );
  }
}

/// Wraps ItemCard with offer stream to show current state.
class _ItemCardWithOffer extends ConsumerWidget {
  const _ItemCardWithOffer({
    required this.item,
    required this.storeId,
  });

  final Item item;
  final String storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offerAsync =
        ref.watch(currentOfferForItemProvider(storeId, item.id));
    final currentOffer = offerAsync.value;

    return ItemCard(
      item: item,
      currentOffer: currentOffer,
      onStartSelling: () async {
        final result = await showDialog<bool>(
          context: context,
          builder: (_) => StartSellingDialog(
            item: item,
            storeId: storeId,
          ),
        );
        if (result == true) {
          ref.invalidate(itemsListStreamProvider(storeId));
        }
      },
      onStopSelling: () async {
        final success = await ref
            .read(startSellingDialogControllerProvider.notifier)
            .stopSelling(itemId: item.id, storeId: storeId);
        if (success) {
          ref.invalidate(itemsListStreamProvider(storeId));
        }
      },
      onPressed: () {
        // If selling now — show quantity dialog
        if (currentOffer != null &&
            currentOffer.pickupStartTime.isBefore(DateTime.now()) &&
            currentOffer.pickupEndTime.isAfter(DateTime.now())) {
          showDialog(
            context: context,
            builder: (_) => SellingNowDialog(offer: currentOffer),
          );
        } else {
          showDialog(
            context: context,
            builder: (_) => ItemActionDialog(
              item: item,
              storeId: storeId,
            ),
          );
        }
      },
    );
  }
}
