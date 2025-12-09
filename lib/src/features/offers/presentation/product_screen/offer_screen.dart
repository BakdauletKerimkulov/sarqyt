import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lorem_ipsum/lorem_ipsum.dart';
import 'package:sarqyt/src/common_widgets/alert_dialogs.dart';
import 'package:sarqyt/src/common_widgets/async_value_widget.dart';
import 'package:sarqyt/src/common_widgets/custom_image.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/offers/data/offers_repository.dart';
import 'package:sarqyt/src/features/offers/domain/offer.dart';
import 'package:sarqyt/src/features/offers/presentation/offers_list_screen/offer_card.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

final description = loremIpsum(words: 40);

/// Shows the offer page for a given product ID.
class OfferScreen extends ConsumerWidget {
  const OfferScreen({super.key, required this.offerId});

  final String offerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offerAsync = ref.watch(offerStreamProvider(offerId));
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.chevron_left),
        ),
        title: Text('Detail'.hardcoded),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => showNotImplementedAlertDialog(context: context),
            icon: Icon(Icons.favorite_outline_outlined),
          ),
        ],
      ),
      body: AsyncValueWidget(
        value: offerAsync,
        data: (offer) {
          return offer == null
              ? Center(
                  child: Text(
                    'Offer not found'.hardcoded,
                    style: textTheme.bodyLarge,
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(Sizes.p16),
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(Sizes.p16),
                        child: CustomImage(imageUrl: offer.imageUrl),
                      ),
                      gapH24,
                      Text(offer.title, style: textTheme.titleLarge),
                      gapH8,
                      Text(offer.description),
                      gapH24,
                      Row(children: [Icon(Icons.star, color: Colors.amber)]),
                      gapH12,
                      const Divider(),
                      gapH12,
                      Text(
                        'Description'.hardcoded,
                        style: textTheme.titleMedium,
                      ),
                      gapH12,
                      // TODO: заменить описание на offer.description
                      Text(
                        description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey),
                      ),
                      gapH16,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Price'.hardcoded,
                                  style: textTheme.bodyLarge,
                                ),
                                gapH12,
                                PriceText(
                                  currPrice: offer.currPrice,
                                  oldPrice: offer.origPrice,
                                ),
                              ],
                            ),
                          ),

                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => showNotImplementedAlertDialog(
                                context: context,
                              ),
                              child: Text('Buy now'.hardcoded),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }
}

class OfferContent extends StatefulWidget {
  const OfferContent({super.key, required this.offer});

  final Offer offer;

  @override
  State<OfferContent> createState() => _OfferContentState();
}

class _OfferContentState extends State<OfferContent> {
  late ScrollController _controller;

  @override
  void initState() {
    _controller = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Sizes.p16),
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Sizes.p16),
            child: CustomImage(imageUrl: widget.offer.imageUrl),
          ),
          gapH24,
          Text(widget.offer.title, style: textTheme.titleLarge),
          gapH8,
          Text(widget.offer.description),
          gapH24,
          Row(children: [Icon(Icons.star, color: Colors.amber)]),
          gapH12,
          const Divider(),
          gapH12,
          Text('Description'.hardcoded, style: textTheme.titleMedium),
          gapH12,
          Text(
            description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey),
          ),
          gapH16,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Price'.hardcoded, style: textTheme.bodyLarge),
                    gapH12,
                    PriceText(
                      currPrice: widget.offer.currPrice,
                      oldPrice: widget.offer.origPrice,
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      showNotImplementedAlertDialog(context: context),
                  child: Text('Buy now'.hardcoded),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
