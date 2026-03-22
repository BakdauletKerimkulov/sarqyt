import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/common_widgets/async_value_widget.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/offers/data/client_offer_repository.dart';
import 'package:sarqyt/src/features/offers/presentation/offer_list/discover_app_bar.dart';
import 'package:sarqyt/src/features/offers/presentation/offer_list/offer_card.dart';
import 'package:sarqyt/src/routing/client_router.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: DiscoverAppBar(),
        body: TabBarView(
          children: [
            DiscoverContent(
              onPressed: (context, productId) => context.goNamed(
                ClientRoute.offer.name,
                pathParameters: {'id': productId},
              ),
            ),

            Center(child: Text('Map')),
          ],
        ),
      ),
    );
  }
}

class DiscoverContent extends ConsumerWidget {
  const DiscoverContent({super.key, this.onPressed});

  final void Function(BuildContext, String)? onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersValue = ref.watch(offersListFutureProvider);
    return AsyncValueWidget(
      value: offersValue,
      data: (offers) {
        return OffersListAligned(
          itemCount: offers.length,
          itemBuilder: (context, index) {
            final offer = offers[index];
            return OfferCard(
              offer: offer,
              onPressed: () => onPressed?.call(context, offer.productId),
            );
          },
        );
      },
    );
  }
}

class OffersListAligned extends StatelessWidget {
  const OffersListAligned({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  final int itemCount;

  final Widget Function(BuildContext, int) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(Sizes.p8),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      separatorBuilder: (context, index) => gapH12,
    );
  }
}
