import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/common_widgets/alert_dialogs.dart';
import 'package:sarqyt/src/common_widgets/custom_image.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/offers/domain/offer.dart';
import 'package:sarqyt/src/utils/currency_formatter.dart';

class OfferCard extends StatelessWidget {
  const OfferCard({super.key, required this.offer, this.onPressed});
  final Offer offer;
  final VoidCallback? onPressed;

  // * Keys for testing using find.byKey()
  static const offerCardKey = Key('offer-card');

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        key: offerCardKey,
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(Sizes.p8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(Sizes.p8),
                child: Stack(
                  children: [
                    CustomImage(imageUrl: offer.imageUrl),

                    if (offer.availableQuantity > 0)
                      Positioned(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(Sizes.p8),
                            ),
                            color: Colors.black87.withAlpha(25),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: Sizes.p4,
                              right: Sizes.p8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, color: Colors.amber),
                                Text(offer.avgRating.toString()),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              gapH12,
              Text(offer.title, style: textTheme.titleSmall),
              Text(
                offer.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall,
              ),
              gapH12,
              Row(
                children: [
                  PriceText(
                    currPrice: offer.currPrice,
                    oldPrice: offer.origPrice,
                  ),
                  Spacer(),

                  IconButton.filled(
                    style: ButtonStyle(),
                    onPressed: () =>
                        showNotImplementedAlertDialog(context: context),
                    icon: Icon(Icons.add),
                  ),
                ],
              ),
              gapH8,
            ],
          ),
        ),
      ),
    );
  }
}

class PriceText extends ConsumerWidget {
  const PriceText({super.key, required this.currPrice, this.oldPrice});

  final double currPrice;
  final double? oldPrice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatCurrPrice = ref
        .watch(currencyFormatterProvider)
        .format(currPrice);
    final formatOldPrice = oldPrice != null
        ? ref.watch(currencyFormatterProvider).format(oldPrice)
        : null;

    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (oldPrice != null)
          Text(
            formatOldPrice!,
            style: textTheme.bodySmall?.copyWith(
              color: Colors.grey,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        gapW4,
        Text(
          formatCurrPrice,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
