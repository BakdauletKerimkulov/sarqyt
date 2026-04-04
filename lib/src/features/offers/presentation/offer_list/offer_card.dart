import 'package:flutter/material.dart';
import 'package:sarqyt/src/common_widgets/custom_image.dart';
import 'package:sarqyt/src/common_widgets/info_badge.dart';
import 'package:sarqyt/src/common_widgets/rating_icon.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/offers/domain/offer.dart';

class OfferCard extends StatelessWidget {
  const OfferCard({
    super.key,
    this.onPressed,
    required this.offer,
    this.distanceLabel,
    this.onFavoriteToggle,
    this.isFavorite = false,
  });

  final Offer offer;
  final VoidCallback? onPressed;
  final String? distanceLabel;
  final VoidCallback? onFavoriteToggle;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4.0,
      child: InkWell(
        onTap: onPressed,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CustomImage(imageUrl: offer.productImage, aspectRatio: 3),

                Positioned(
                  left: Sizes.p12,
                  top: Sizes.p12,
                  child: InfoBadge(text: offer.availableText),
                ),
                Positioned(
                  right: Sizes.p12,
                  top: Sizes.p12,
                  child: GestureDetector(
                    onTap: onFavoriteToggle,
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.white,
                      size: 28,
                      shadows: const [
                        Shadow(blurRadius: 4, color: Colors.black45),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  left: Sizes.p12,
                  bottom: Sizes.p12,
                  child: StoreTitle(
                    logoUrl: offer.storeLogo,
                    name: offer.storeName,
                  ),
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
                    offer.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    offer.pickupLabel,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  gapH12,
                  Row(
                    children: [
                      RatingIcon(),
                      gapW8,
                      if (distanceLabel != null && distanceLabel!.isNotEmpty) ...[
                        Text(
                          distanceLabel!,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        '${offer.price.round()} ${offer.currencySymbol}',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: Sizes.p20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
