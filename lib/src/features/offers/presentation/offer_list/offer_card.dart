import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/common_widgets/custom_image.dart';
import 'package:sarqyt/src/common_widgets/info_badge.dart';
import 'package:sarqyt/src/common_widgets/rating_icon.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/offers/domain/offer.dart';
import 'package:sarqyt/src/features/products/domain/product.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';
import 'package:sarqyt/src/utils/currency_formatter.dart';

class OfferCard extends StatelessWidget {
  OfferCard({super.key, this.onPressed, required this.offer})
    : product = offer.product,
      store = offer.store;

  final Offer offer;
  final VoidCallback? onPressed;

  final Product product;
  final Store store;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onPressed,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadiusGeometry.only(
                    topRight: Radius.circular(Sizes.p16),
                    topLeft: Radius.circular(Sizes.p16),
                  ),
                  child: CustomImage(imageUrl: store.coverUrl, aspectRatio: 3),
                ),

                Positioned(
                  left: Sizes.p12,
                  top: Sizes.p12,
                  child: InfoBadge(text: offer.availableText),
                ),

                Positioned(
                  left: Sizes.p12,
                  bottom: Sizes.p12,
                  child: StoreTitle(logoUrl: store.logoUrl, name: store.name),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: Sizes.p16,
                right: Sizes.p16,
                bottom: Sizes.p16,
                top: Sizes.p8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.displayName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  // TODO: указать время забора
                  Text('', style: TextStyle(color: Colors.grey)),
                  gapH12,
                  Row(
                    children: [
                      RatingIcon(),
                      gapW8,
                      if (product.rating != null)
                        Text(
                          product.rating!.average.toString(),
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      gapW12,
                      SizedBox(
                        height: Sizes.p24,
                        child: VerticalDivider(
                          thickness: 1.5,
                          color: Colors.grey,
                        ),
                      ),
                      gapW12,
                      if (offer.distanceFormatter != null)
                        Text(
                          offer.distanceFormatter!,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      Spacer(),
                      Text(
                        product.priceWithCurrency,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: Sizes.p20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // OfferPrice(price: product.price.amount),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OfferPrice extends ConsumerWidget {
  const OfferPrice({super.key, required this.price});

  final double price;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = ref.watch(currencyFormatterProvider);
    return Text(
      formatter.format(price),
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}

class StoreTitle extends StatelessWidget {
  const StoreTitle({super.key, required this.name, this.logoUrl});

  final String name;
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.drawerHeaderBackground,
          backgroundImage: customImageProvider(logoUrl),
        ),
        gapW12,
        Text(
          name,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: Sizes.p20,
            shadows: [
              Shadow(
                offset: Offset(0, 2.5),
                blurRadius: Sizes.p4,
                color: Colors.black.withAlpha(125),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
