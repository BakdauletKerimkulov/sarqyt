// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:sarqyt/src/common_widgets/async_value_widget.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/offers/data/offers_repository.dart';
import 'package:sarqyt/src/features/offers/domain/offer.dart';
import 'package:sarqyt/src/features/offers/presentation/offers_list_screen/offer_card.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

class SliverOffersGrid extends ConsumerWidget {
  const SliverOffersGrid({super.key, this.onPressed});
  final void Function(BuildContext, OfferID)? onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(offerListStreamProvider);

    return AsyncValueSliverWidget(
      value: offersAsync,
      data: (offers) {
        return SliverOffersAlignedList(
          itemCount: offers.length,
          itemBuilder: (context, index) {
            final offer = offers[index];
            return OfferCard(
              onPressed: () => onPressed?.call(context, offer.id),
              offer: offer,
            );
          },
        );
      },
    );
  }
}

class SliverOffersAlignedList extends StatelessWidget {
  const SliverOffersAlignedList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  /// Total number of items to display.
  final int itemCount;

  /// Function used to build a widget for a given index in the grid.
  final Widget Function(BuildContext, int) itemBuilder;

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) {
      return SliverToBoxAdapter(
        child: Center(
          child: Text(
            'No offers found'.hardcoded,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: Sizes.p12, vertical: Sizes.p16),
      sliver: SliverAlignedGrid.count(
        mainAxisSpacing: Sizes.p8,
        crossAxisSpacing: Sizes.p4,
        itemBuilder: itemBuilder,
        itemCount: itemCount,
        crossAxisCount: 2,
      ),
    );
  }
}
